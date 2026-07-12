from enum import StrEnum
from pathlib import Path

import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib import cm
from matplotlib.figure import Figure
from matplotlib.lines import Line2D
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.visualisation import DIVERGING_CMAP, configure_mpl
from ising import Ising

np.set_printoptions(linewidth=200)

console = Console()


class PlotKind(StrEnum):
    RANK = "rank"
    PAIRWISE = "pairwise"


def estimate_interaction_variance(
    Y: npt.NDArray[np.int64],
    params: npt.NDArray[np.float64],
) -> npt.NDArray[np.float64]:
    n = Y.shape[-1]
    adj = np.full((n, n), fill_value=True, dtype=bool)
    X = np.ones((Y.shape[1], Y.shape[2]), dtype=np.float64)

    Is = np.empty((params.shape[0], n**2, n**2), dtype=np.float64)
    for i, p in enumerate(params):
        h = p[:n]
        j = p[n:].reshape((n, n))
        Is[i] = (
            Ising.time_series_nll_hessian_sync(Y[i], X, h, j, adj)[n:][:, n:]
            * np.eye(n**2)  # Only diagonal
            * Y.shape[1]  # Multiply to reverse numerical-stability-related scaling
            * Y.shape[2]
        )

    I_mean = Is.mean(axis=0)
    I_inv = np.linalg.inv(I_mean)
    return I_inv.diagonal().reshape((n, n))


def plot_ranked_differentials(
    mean_diff: npt.NDArray[np.float64],
    ci_lower: npt.NDArray[np.float64],
    ci_upper: npt.NDArray[np.float64],
    labels: list[str],
) -> Figure:
    fig, ax = plt.subplots(figsize=(5, 4), constrained_layout=True)
    n = mean_diff.shape[-1]

    # Categorise relations:
    # - Symmetric: Statistically indistinguishable directionally, both non-null
    # - Asymmetric: Statistically distinguishable, both non-null
    # - Unidirectional: Exactly one non-null effect
    # - Null: Both null effects

    # significant_edge = (mean_j - ci_j > 0) | (mean_j + ci_j < 0)
    # equal_effect = ~((mean_diff - ci_diff > 0) | (mean_diff + ci_diff < 0))
    # null = ~significant_edge & ~significant_edge.T
    # symmetric = significant_edge & significant_edge.T & equal_effect
    # asymmetric = significant_edge & significant_edge.T & ~equal_effect
    # unidirectional = (
    #     np.logical_xor(significant_edge, significant_edge.T) & ~equal_effect
    # )

    # Scatter means
    positive_mean_idxes = np.where(mean_diff > 0)
    mean_diffs_flat = mean_diff[positive_mean_idxes]
    sort_idxes = np.argsort(mean_diffs_flat)[::-1]
    mean_diffs_flat = mean_diffs_flat[sort_idxes]
    ci_lower_flat = ci_lower[positive_mean_idxes][sort_idxes]
    ci_upper_flat = ci_upper[positive_mean_idxes][sort_idxes]
    ax.scatter(
        mean_diffs_flat,
        np.arange(n * (n - 1) // 2),
        color="k",
        s=10,
        zorder=5,
        label="Median difference",
    )

    # Show ci interval as shaded region
    # null = null[positive_mean_idxes][sort_idxes]
    # symmetric = symmetric[positive_mean_idxes][sort_idxes]
    # asymmetric = asymmetric[positive_mean_idxes][sort_idxes]
    # unidirectional = unidirectional[positive_mean_idxes][sort_idxes]
    bar_color = np.array(["tab:red"] * (n * (n - 1) // 2), dtype=object)
    # bar_color[null] = "tab:grey"
    # bar_color[symmetric] = "tab:blue"
    # bar_color[asymmetric] = "tab:red"
    # bar_color[unidirectional] = "tab:green"
    marker, _, bar = ax.errorbar(
        mean_diffs_flat,
        np.arange(n * (n - 1) // 2),
        xerr=np.array(
            [mean_diffs_flat - ci_lower_flat, ci_upper_flat - mean_diffs_flat]
        ),
        ls="none",
        zorder=3,
        ecolor=bar_color.tolist(),
        label="90% CI",
    )
    plt.setp(bar[0], capstyle="round")
    marker.set_fillstyle("none")
    bar[0].set_alpha(0.5)
    bar[0].set_linewidth(5)

    # Draw 0.0 as dashed
    ax.axvline(x=0, linestyle="dashed", linewidth=0.75, color="gray", zorder=1)

    # Determine max label length for X and Y in X --> Y, to center-justify
    colnames = [ds_spec.RENAME.get(colname, colname) for colname in labels]
    max_left_len = 0
    max_right_len = 0
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            if mean_diff[i, j] > 0:
                max_left_len = max(max_left_len, len(colnames[i]))
            else:
                max_right_len = max(max_right_len, len(colnames[j]))

    ylabels = [[] for _ in range(n)]
    for i in range(n):
        for j in range(n):
            c1 = colnames[i]
            c2 = colnames[j]
            ylabels[i].append(f"{c1:>{max_left_len}} → {c2:<{max_right_len}}")

    ylabels = np.asarray(ylabels)[positive_mean_idxes][sort_idxes]

    ax.set_yticks(
        np.arange(len(ylabels)), ylabels, fontfamily="Libertinus Mono", fontsize=8
    )

    ax.set_ylim(-0.5, len(ylabels) - 0.5)
    for i in range(len(ylabels)):
        ax.axhline(y=i, linewidth=0.1, color="k", linestyle="solid")

    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)

    ax.legend(
        ncol=2,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.0),
        # fontsize=8,
        # handlelength=1,
        # columnspacing=0.5,
        # labelspacing=0.2,
        frameon=False,
    )
    return fig


def plot_pairwise_differentials(
    mean: npt.NDArray[np.float64],
    ci: npt.NDArray[np.float64],
    labels: list[str],
) -> Figure:
    fig, ax = plt.subplots(figsize=(4.5, 4), constrained_layout=True)
    ax.set_aspect("equal")

    n = mean.shape[0]

    # Sort rows in increasing order of mean differential
    # such that top row has highest excess influence on avg.
    sort_idxes = np.argsort(mean.mean(axis=1))
    mean = mean[sort_idxes][:, sort_idxes]
    ci = ci[sort_idxes][:, sort_idxes]
    labels = [labels[i] for i in sort_idxes]

    # Show mean differential using colour (red -ve, blue +ve);
    # CIs with proportional size
    X, Y = np.meshgrid(np.arange(n), np.arange(n))
    colours = DIVERGING_CMAP(mean * 0.5 / (0.2) + 0.5)

    # min size non-zero CI sets max marker size. Larger CIs are smaller.
    # double CI should be half size (radius?).
    min_ci = np.sort(ci.flatten())[ci.shape[0]]
    max_ci = np.sort(ci.flatten())[-1]
    sizes = ci.copy()
    sizes[np.diag_indices_from(sizes)] = np.inf
    sizes = min_ci / sizes

    # Re-scale so min-size CI is 300 points
    scale_factor = 300
    sizes *= scale_factor

    ax.scatter(
        X.flatten(),
        Y.flatten(),
        s=sizes.flatten(),
        c=colours.ravel().reshape((-1, 4)),
        clip_on=False,
    )

    # Set tick labels
    ax.set_xticks(
        np.arange(8), labels, rotation=40, horizontalalignment="right", fontsize=9
    )
    ax.set_yticks(
        np.arange(8), labels, rotation=0, horizontalalignment="right", fontsize=9
    )

    # Axis labels
    ax.set_ylabel(r"From", rotation=90, labelpad=20, fontsize=12)
    ax.set_xlabel(r"To", fontsize=12)

    # Hide tick markers, axis frame/spines
    ax.tick_params(axis="both", which="both", length=0)
    for spine in ax.spines.values():
        spine.set_visible(False)

    # == Legends
    # Colourbar for mean differential
    cbar = fig.colorbar(
        cm.ScalarMappable(
            norm=mcolors.Normalize(vmin=-0.2, vmax=0.2), cmap=DIVERGING_CMAP
        ),
        shrink=0.8,
        aspect=25,
        ax=ax,
        pad=0.1,
    )
    cbar.set_ticks([float(x) for x in np.linspace(-0.2, 0.2, 5)])
    cbar.ax.set_title(r"$\Delta_J$", pad=18)
    # cbar.ax.set_ylabel(r"Mean directional differential", labelpad=10)

    # Size chart for CI
    # 0.01, 0.02, 0.03
    # ci_legend_vals = np.array([0.0025, 0.005, 0.01])
    # ci_legend_vals = np.array([0.03, 0.06, 0.12])
    ci_legend_vals = np.array([min_ci, max_ci])
    # ci_legend_labels = [r"$2.5\times 10^{-3}$", r"$5\times 10^{-3}$", r"$10^{-3}$"]
    ci_legend_sizes = (min_ci / ci_legend_vals) * scale_factor
    ci_legend_handles = [
        Line2D(
            [0],
            [0],
            marker="o",
            linestyle="",
            markersize=s**0.5,  # scatter size s is in points²
            label=f"{v:.2f}",
            color="black",
            markerfacecolor="white",
        )
        for v, s in zip(ci_legend_vals, ci_legend_sizes, strict=True)
    ]
    ax.legend(
        ncol=2,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.02),
        handles=ci_legend_handles,
        title="90% CI",
        frameon=False,
        labelspacing=1.0,
    )

    return fig


class DirectionalDifferentialPlotCommand(BaseCommand):
    bootstrap_models: Path
    output: Path | None = None
    kind: PlotKind
    z: float = 1.96

    def cli_cmd(self) -> None:
        configure_mpl()

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )

        labels = dataset.schema.get_short_names(kind="measurement")

        bootstrap_results = np.load(self.bootstrap_models)

        # Determine number of covariates used for baseline activations
        k = bootstrap_results["X"].shape[-1] if "X" in bootstrap_results else 0

        # Calculate interction differentials from param vectors
        bootstrap_interactions = bootstrap_results["params"][:, 8 * (k + 1) :].reshape(
            (-1, 8, 8)
        )
        diffs = bootstrap_interactions - np.swapaxes(bootstrap_interactions, 1, 2)

        # mean_diff = diffs.mean(axis=0)
        mean_diff = np.mean(diffs, axis=0)
        ci_diff = self.z * np.std(diffs, axis=0, ddof=1)  # / np.sqrt(diffs.shape[0])

        match self.kind:
            case PlotKind.RANK:
                ci_diff_lower, ci_diff_upper = np.percentile(diffs, (5, 95), axis=0)
                # fig = plot_ranked_differentials(
                #     mean_diff, mean_diff - ci_diff, mean_diff + ci_diff, labels
                # )
                fig = plot_ranked_differentials(
                    np.median(diffs, axis=0), ci_diff_lower, ci_diff_upper, labels
                )
            case PlotKind.PAIRWISE:
                fig = plot_pairwise_differentials(mean_diff, ci_diff, labels)

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
            fig.savefig(str(self.output).replace(".pdf", ".png"), bbox_inches="tight")
        else:
            plt.show()

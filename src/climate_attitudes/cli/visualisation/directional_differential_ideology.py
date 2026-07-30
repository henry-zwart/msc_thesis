from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.figure import Figure
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.visualisation import configure_mpl
from ising import Ising

np.set_printoptions(linewidth=200)

console = Console()


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
    med_diff_con: npt.NDArray[np.float64],
    med_diff_lib: npt.NDArray[np.float64],
    low_con: npt.NDArray[np.float64],
    hi_con: npt.NDArray[np.float64],
    low_lib: npt.NDArray[np.float64],
    hi_lib: npt.NDArray[np.float64],
    _full_J_con: npt.NDArray[np.float64],
    _full_J_lib: npt.NDArray[np.float64],
    labels: list[str],
) -> Figure:
    fig, ax = plt.subplots(figsize=(5, 4), constrained_layout=True)
    n = med_diff_con.shape[-1]

    # Scatter means
    positive_mean_idxes = np.where(med_diff_con > 0)
    mean_diffs_flat_con = med_diff_con[positive_mean_idxes]
    mean_diffs_flat_lib = med_diff_lib[positive_mean_idxes]
    sort_idxes = np.argsort(mean_diffs_flat_con)[::-1]
    mean_diffs_flat_con = mean_diffs_flat_con[sort_idxes]
    mean_diffs_flat_lib = mean_diffs_flat_lib[sort_idxes]
    low_con_flat = low_con[positive_mean_idxes][sort_idxes]
    hi_con_flat = hi_con[positive_mean_idxes][sort_idxes]
    low_lib_flat = low_lib[positive_mean_idxes][sort_idxes]
    hi_lib_flat = hi_lib[positive_mean_idxes][sort_idxes]
    print(mean_diffs_flat_con.shape)
    ax.scatter(
        mean_diffs_flat_con,
        np.arange(n * (n - 1) // 2) + 0.125,
        color="tab:blue",
        s=5,
        zorder=5,
        label="Median difference (cons.)",
    )
    ax.scatter(
        mean_diffs_flat_lib,
        np.arange(n * (n - 1) // 2) - 0.125,
        color="tab:orange",
        s=10,
        zorder=5,
        label="Median difference (lib.)",
    )

    # is_asymmetric_flat = is_asymmetric_con[positive_mean_idxes][sort_idxes]
    # is_nonreciprocal_flat = is_nonreciprocal_con[positive_mean_idxes][sort_idxes]
    # bar_color = np.array(["tab:grey"] * (n * (n - 1) // 2), dtype=object)
    # bar_color[is_asymmetric_flat] = "tab:blue"
    # bar_color[is_nonreciprocal_flat] = "tab:orange"

    marker, _, bar = ax.errorbar(
        mean_diffs_flat_con,
        np.arange(n * (n - 1) // 2) + 0.125,
        xerr=np.array(
            [mean_diffs_flat_con - low_con_flat, hi_con_flat - mean_diffs_flat_con]
        ),
        ls="none",
        zorder=3,
        ecolor="tab:blue",
        label="90% CI (cons.)",
    )
    plt.setp(bar[0], capstyle="round")
    marker.set_fillstyle("none")
    bar[0].set_linewidth(2.5)
    bar[0].set_alpha(0.5)
    marker, _, bar = ax.errorbar(
        mean_diffs_flat_lib,
        np.arange(n * (n - 1) // 2) - 0.125,
        xerr=np.array(
            [mean_diffs_flat_lib - low_lib_flat, hi_lib_flat - mean_diffs_flat_lib]
        ),
        ls="none",
        zorder=3,
        ecolor="tab:orange",
        label="90% CI (lib.)",
    )
    plt.setp(bar[0], capstyle="round")
    marker.set_fillstyle("none")
    bar[0].set_linewidth(2.5)
    bar[0].set_alpha(0.5)

    # for i, _bar in enumerate(bar):
    #     if mean_diffs_flat[i] - ci_lower_flat[i] <= 0:
    #         _bar.set_alpha(0.5)
    #     else:
    #         _bar.set_alpha(1.0)

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
            if med_diff_con[i, j] > 0:
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

    ax.set_xlabel(r"Directional differential ($\Delta_{i,j}$)")
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


class DirectionalDiffIdeologyPlotCommand(BaseCommand):
    bootstrap_models_con: Path
    bootstrap_models_lib: Path
    full_model_con: Path
    full_model_lib: Path
    output: Path | None = None

    def cli_cmd(self) -> None:
        configure_mpl()

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )

        labels = np.delete(dataset.schema.get_short_names(kind="measurement"), 5)
        full_J_con = np.load(self.full_model_lib)["params"][7:].reshape((7, 7))
        full_J_lib = np.load(self.full_model_con)["params"][7:].reshape((7, 7))
        full_J_con[abs(full_J_con) < 1e-2] = 0
        full_J_lib[abs(full_J_lib) < 1e-2] = 0

        bootstrap_results_con = np.load(self.bootstrap_models_con)
        bootstrap_results_lib = np.load(self.bootstrap_models_lib)

        # Calculate interction differentials from param vectors
        bootstrap_J_con = bootstrap_results_con["params"][:, 7:].reshape((-1, 7, 7))
        bootstrap_J_lib = bootstrap_results_lib["params"][:, 7:].reshape((-1, 7, 7))

        diffs_con = bootstrap_J_con - np.swapaxes(bootstrap_J_con, 1, 2)
        diffs_lib = bootstrap_J_lib - np.swapaxes(bootstrap_J_lib, 1, 2)

        lo_con, hi_con = np.percentile(diffs_con, (5, 95), axis=0)
        lo_lib, hi_lib = np.percentile(diffs_lib, (5, 95), axis=0)
        fig = plot_ranked_differentials(
            np.median(diffs_con, axis=0),
            np.median(diffs_lib, axis=0),
            lo_con,
            hi_con,
            lo_lib,
            hi_lib,
            full_J_con,
            full_J_lib,
            labels,
        )

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
            fig.savefig(str(self.output).replace(".pdf", ".png"), bbox_inches="tight")
        else:
            plt.show()

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import seaborn as sns
from matplotlib.axes import Axes

from climate_attitudes.dataset import Dataset
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import DIVERGING_CMAP, configure_mpl


def plot_baseline_activations(model_path: Path, vlim: float, ax: Axes):
    h = np.load(model_path)["params"][:, :8]

    h_mean = h.mean(axis=0)
    h_ci = np.percentile(h, (2.5, 97.5), axis=0)

    ax.scatter(np.arange(8) + 0.5, h_mean, zorder=2, s=10)
    ax.errorbar(
        np.arange(8) + 0.5,
        h_mean,
        yerr=[h_mean - h_ci[0], h_ci[1] - h_mean],
        linestyle="none",
    )

    ax.set_ylim(-vlim, vlim)
    ax.set_xlim(0, 8)

    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)
    ax.axhline(y=0, linestyle="dashed", linewidth=0.25, color="k", zorder=1)


def plot_heatmap(
    model_path: Path, symmetric: bool, vlim: float, ax: Axes
) -> npt.NDArray[np.float64]:
    params = np.load(model_path)["params"]

    if symmetric:
        J = np.zeros((8, 8), dtype=np.float64)
        J[np.triu_indices_from(J)] = params[8:]
        mask = np.tril(np.ones((8, 8), dtype=bool), k=-1)
    else:
        J = params[8:].reshape((8, 8))
        mask = np.zeros((8, 8), dtype=bool)

    J[abs(J) < 1e-2] = 0

    sns.heatmap(
        J,
        mask=mask,
        annot=True,
        fmt=".1f",
        linewidth=1,
        cmap=DIVERGING_CMAP,
        center=0.0,
        vmin=-vlim,
        vmax=vlim,
        ax=ax,
        cbar=None,
        annot_kws=dict(fontsize=8),
    )
    return J


def main():
    config = Config(_env_file=".env")
    dataset = Dataset.load(
        config,
        name="reduced_no_imputation",
        with_imputation=False,
        verbose=False,
    )
    labels = dataset.schema.get_short_names(kind="measurement")

    fig, axes = plt.subplots(
        ncols=2,
        nrows=2,
        figsize=(5, 4.25),
        # sharex=True,
        constrained_layout=True,
        gridspec_kw=dict(wspace=0.1, hspace=0.0, height_ratios=(2, 4)),
    )

    # Plot baseline activations as scatterplot
    plot_baseline_activations(
        Path(
            "reports/thesis/results/data/model/bootstrapped_fit/sym_ising_no_structure.npz"
        ),
        0.5,
        axes[0, 0],
    )
    plot_baseline_activations(
        Path(
            "reports/thesis/results/data/model/bootstrapped_fit/ising_no_structure.npz"
        ),
        0.5,
        axes[0, 1],
    )

    # Draw heatmaps
    J_sym = plot_heatmap(
        Path("reports/thesis/results/data/model/fit_full_sym_ising_no_structure.npz"),
        symmetric=True,
        vlim=0.35,
        ax=axes[1, 0],
    )
    J_asym = plot_heatmap(
        Path("reports/thesis/results/data/model/fit_full_asym_ising_no_structure.npz"),
        symmetric=False,
        vlim=0.35,
        ax=axes[1, 1],
    )

    nondiag_elts = ~np.eye(J_sym.shape[0], dtype=bool)
    nondiag_elts_symm = ~np.eye(J_sym.shape[0], dtype=bool) & ~np.tril(
        np.ones(J_sym.shape, dtype=bool)
    )
    nondiag_J_sym = J_sym[nondiag_elts_symm]
    nondiag_J_asym = J_asym[nondiag_elts]
    sym_is_nonzero = ~np.isclose(nondiag_J_sym, 0)
    asym_is_nonzero = ~np.isclose(nondiag_J_asym, 0)

    sym_sparsity = np.isclose(nondiag_J_sym, 0).sum() / nondiag_J_sym.size
    asym_sparsity = np.isclose(nondiag_J_asym, 0).sum() / nondiag_J_asym.size
    print(f"Symmetric sparsity: {sym_sparsity:.2f}")
    print(f"Asymmetric sparsity: {asym_sparsity:.2f}")

    sym_mean = nondiag_J_sym[sym_is_nonzero].sum() / sym_is_nonzero.sum()
    asym_mean = nondiag_J_asym[asym_is_nonzero].sum() / asym_is_nonzero.sum()
    print(f"Symmetric mean effect: {sym_mean:.2f}")
    print(f"Asymmetric mean effect: {asym_mean:.2f}")

    axes[1, 0].set_yticks(np.arange(len(labels)) + 0.5, labels, rotation=0, fontsize=9)
    axes[1, 1].tick_params("y", length=0)
    for ax in axes[1]:
        ax.set_aspect("equal")
        ax.set_xticks(
            np.arange(len(labels)) + 0.5,
            labels,
            rotation=90,
            fontsize=9,
        )

    for ax in axes[:, 1]:
        ax.set_yticks([])

    for ax in axes[0]:
        ax.set_xticks([])

    axes[0, 0].set_title("Symmetric model")
    axes[0, 1].set_title("Asymmetric model")

    axes[0, 1].set_ylabel(
        "Baseline\nactivation", rotation=270, verticalalignment="bottom", labelpad=35
    )
    axes[1, 1].set_ylabel("Interaction source", rotation=270, labelpad=20)
    axes[1, 0].set_xlabel("Interaction source")
    axes[1, 1].set_xlabel("Interaction recipient")
    axes[0, 1].yaxis.set_label_position("right")
    axes[1, 1].yaxis.set_label_position("right")

    # fig.align_ylabels(axes[:, 1])

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/interaction_heatmap.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    configure_mpl()
    main()

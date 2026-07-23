from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import seaborn as sns
from matplotlib.axes import Axes

from climate_attitudes.dataset import Dataset
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import DIVERGING_CMAP, configure_mpl


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
        figsize=(5, 3.5),
        sharey=True,
        constrained_layout=True,
        gridspec_kw=dict(wspace=0.1),
    )

    # Draw heatmaps
    J_sym = plot_heatmap(
        Path("reports/thesis/results/data/model/fit_full_sym_ising_no_structure.npz"),
        symmetric=True,
        vlim=0.35,
        ax=axes[0],
    )
    J_asym = plot_heatmap(
        Path("reports/thesis/results/data/model/fit_full_asym_ising_no_structure.npz"),
        symmetric=False,
        vlim=0.35,
        ax=axes[1],
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

    axes[0].set_yticks(np.arange(len(labels)) + 0.5, labels, rotation=0, fontsize=9)
    axes[1].tick_params("y", length=0)
    for ax in axes:
        ax.set_aspect("equal")
        ax.set_xticks(
            np.arange(len(labels)) + 0.5,
            labels,
            rotation=90,
            fontsize=9,
        )

    axes[0].set_title("Symmetric")
    axes[1].set_title("Asymmetric")
    fig.supylabel("From", y=0.6)
    fig.supxlabel("To", x=0.625)

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/interaction_heatmap.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    configure_mpl()
    main()

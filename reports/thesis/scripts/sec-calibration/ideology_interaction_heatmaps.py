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
        J = np.zeros((7, 7), dtype=np.float64)
        J[np.triu_indices_from(J)] = params[7:]
    else:
        J = params[7:].reshape((7, 7))

    J[abs(J) < 1e-2] = 0
    mask = np.zeros_like(J, dtype=np.bool)
    mask[abs(J) < 1e-2] = True

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
    labels = np.delete(dataset.schema.get_short_names(kind="measurement"), 5)

    fig, axes = plt.subplots(
        ncols=2,
        figsize=(5, 3.5),
        sharey=True,
        constrained_layout=True,
        gridspec_kw=dict(wspace=0.1),
    )

    # Draw heatmaps
    J_cons = plot_heatmap(
        Path("reports/thesis/results/data/model/ideology_fit_conservative.npz"),
        symmetric=False,
        vlim=0.35,
        ax=axes[0],
    )
    J_lib = plot_heatmap(
        Path("reports/thesis/results/data/model/ideology_fit_liberal.npz"),
        symmetric=False,
        vlim=0.35,
        ax=axes[1],
    )

    nondiag_elts = ~np.eye(J_cons.shape[0], dtype=bool)
    nondiag_J_cons = J_cons[nondiag_elts]
    nondiag_J_lib = J_lib[nondiag_elts]
    cons_is_nonzero = ~np.isclose(nondiag_J_cons, 0)
    lib_is_nonzero = ~np.isclose(nondiag_J_lib, 0)

    cons_sparsity = np.isclose(nondiag_J_cons, 0).sum() / nondiag_J_cons.size
    lib_sparsity = np.isclose(nondiag_J_lib, 0).sum() / nondiag_J_lib.size
    # cons_sparsity = np.isclose(J_cons, 0).sum() / (7**2 - 7)
    # lib_sparsity = np.isclose(J_lib, 0).sum() / (7**2 - 7)
    print(f"Conservative sparsity: {cons_sparsity:.2f}")
    print(f"Liberal sparsity: {lib_sparsity:.2f}")

    # cons_mean = (J_cons.sum() - np.diag(J_cons).sum()) / (7**2 - 7)
    # lib_mean = (J_lib.sum() - np.diag(J_lib).sum()) / (7**2 - 7)
    cons_mean = nondiag_J_cons[cons_is_nonzero].sum() / cons_is_nonzero.sum()
    lib_mean = nondiag_J_lib[lib_is_nonzero].sum() / lib_is_nonzero.sum()
    print(f"Conservative mean effect: {cons_mean:.2f}")
    print(f"Liberal mean effect: {lib_mean:.2f}")

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

    axes[0].set_title("Conservative")
    axes[1].set_title("Liberal")

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/ideology_interaction_heatmap.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    configure_mpl()
    main()

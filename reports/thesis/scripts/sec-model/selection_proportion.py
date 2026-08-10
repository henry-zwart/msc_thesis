from __future__ import annotations

from pathlib import Path

import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import seaborn as sns
from matplotlib.axes import Axes

from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.visualisation import DIVERGING_CMAP, configure_mpl

RANDOM_SEED = 202607101941


def plot_selection_prop(interactions: npt.NDArray[np.float64], ax: Axes):
    nonzero_interactions = interactions.copy()
    nonzero_interactions[abs(interactions) < 1e-2] = 0
    if interactions.shape[-1] == 36:
        p_selected = np.zeros((8, 8), dtype=np.float64)
        p_selected[np.triu_indices_from(p_selected)] = (
            ~np.isclose(nonzero_interactions, 0)
        ).sum(axis=0) / interactions.shape[0]
        mask = np.tril(np.ones((8, 8), dtype=np.bool), k=-1)
    elif interactions.shape[-1] == 64:
        p_selected = (
            (~np.isclose(nonzero_interactions, 0)).sum(axis=0) / interactions.shape[0]
        ).reshape((8, 8))
        mask = np.zeros((8, 8), dtype=np.bool)

    mask[np.isclose(p_selected, 1.0)] = True
    orig_cmap = DIVERGING_CMAP
    colours = orig_cmap(np.linspace(0.5, 1.0, 256))[::-1]
    new_cmap = mcolors.LinearSegmentedColormap.from_list(
        "diverging_upper_reversed", colours
    )

    sns.heatmap(
        p_selected,
        mask=mask,
        annot=True,
        cmap=new_cmap,
        vmin=0,
        vmax=1,
        fmt=".0%",
        square=True,
        linewidth=1,
        ax=ax,
        annot_kws=dict(fontsize=8),
        cbar=False,
    )


if __name__ == "__main__":
    configure_mpl()
    DATA_PATH = Path("reports/thesis/results/data/model")
    sym_data = np.load(DATA_PATH / "bootstrapped_fit/sym_ising_no_structure.npz")
    asym_data = np.load(DATA_PATH / "bootstrapped_fit/ising_no_structure.npz")

    fig, axes = plt.subplots(
        ncols=2,
        figsize=(5.77, 3.5),
        constrained_layout=True,
        gridspec_kw=dict(wspace=0.075),
    )
    plot_selection_prop(sym_data["params"][:, 8:], axes[0])
    plot_selection_prop(asym_data["params"][:, 8:], axes[1])
    labels = schema.post_index().get_short_names("measurement")

    axes[0].set_xticks(np.arange(8) + 0.5, labels, rotation=90, fontsize=9)
    axes[1].set_xticks(np.arange(8) + 0.5, labels, rotation=90, fontsize=9)
    axes[0].set_yticks(np.arange(8) + 0.5, labels, rotation=0, fontsize=9)
    axes[1].set_yticks([])
    axes[0].set_title("Symmetric model")
    axes[1].set_title("Asymmetric model")
    axes[1].yaxis.set_label_position("right")
    axes[1].set_ylabel("Interaction source", rotation=270, labelpad=20)
    axes[0].set_xlabel("Interaction source")
    axes[1].set_xlabel("Interaction recipient")

    for ax in axes:
        for spine in ax.spines:
            ax.spines[spine].set_visible(True)

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/selection_probability.{ext}",
            bbox_inches="tight",
        )

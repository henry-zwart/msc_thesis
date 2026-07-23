from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.axes import Axes

from climate_attitudes.visualisation import configure_mpl


def plot_cis(interactions: npt.NDArray[np.float64], ax: Axes):
    mean = interactions.mean(axis=0)
    lo, hi = np.percentile(interactions, (2.5, 97.5), axis=0)

    sort_idx = np.argsort(mean)
    mean = mean[sort_idx]
    lo = lo[sort_idx]
    hi = hi[sort_idx]

    ax.plot(
        mean, np.arange(mean.size), "o", markersize=0.5, zorder=4, label="Mean effect"
    )
    marker, _, bar = ax.errorbar(
        mean,
        np.arange(mean.size),
        xerr=[mean - lo, hi - mean],
        linewidth=0,
        ecolor="tab:blue",
        zorder=3,
        label="95% CI",
    )
    plt.setp(bar[0], capstyle="round")
    marker.set_fillstyle("none")
    bar[0].set_linewidth(1.5)
    bar[0].set_alpha(0.3)

    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)
    ax.spines.left.set_visible(False)
    ax.set_yticks([])
    ax.set_ylim(-1, None)
    ax.set_xlabel(r"Interaction effect ($J_{i,j}$)")


if __name__ == "__main__":
    configure_mpl()
    fig, axes = plt.subplots(ncols=2, figsize=(5.77, 2.25), constrained_layout=True)
    DATA_PATH = Path("reports/thesis/results/data/model")
    sym_data = np.load(DATA_PATH / "bootstrapped_fit/sym_ising_no_structure.npz")
    asym_data = np.load(DATA_PATH / "bootstrapped_fit/ising_no_structure.npz")
    plot_cis(sym_data["params"][:, 8:], axes[0])
    plot_cis(asym_data["params"][:, 8:], axes[1])
    axes[0].set_ylabel(r"Edge $\{i,j\}$")
    axes[1].set_ylabel(r"Edge $(i,j)$")
    axes[0].set_title("Symmetric")
    axes[1].set_title("Asymmetric")
    axes[1].legend()
    #     loc="lower center",
    #     bbox_to_anchor=(0.75, 1.1),
    #     ncols=1,
    #     frameon=True,
    # )
    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/edge_accuracy.{ext}",
            bbox_inches="tight",
        )

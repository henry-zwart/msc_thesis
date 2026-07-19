from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt

from climate_attitudes.visualisation import configure_mpl


def main(interactions: npt.NDArray[np.float64]):
    mean = interactions.mean(axis=0)
    lo, hi = np.percentile(interactions, (2.5, 97.5), axis=0)

    fig, ax = plt.subplots(figsize=(4.5, 2.25), constrained_layout=True)

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
    ax.set_ylabel("Edge ${i,j}$")

    ax.legend(
        loc="lower center",
        bbox_to_anchor=(0.5, 1.0),
        ncols=2,
        frameon=False,
    )
    fig.savefig(
        "reports/thesis/results/figures/model_fit/edge_accuracy_sym_ising.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    DATA_PATH = Path("reports/thesis/results/data/model")
    data = np.load(DATA_PATH / "bootstrapped_fit/sym_ising_no_structure.npz")
    main(data["params"][:, 8:])

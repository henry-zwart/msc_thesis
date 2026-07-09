import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import scipy as sp

from climate_attitudes.visualisation import configure_mpl


def main():
    # Load binarisation sigma
    sigma_path = Path("reports/thesis/results/data/methods/binarisation_sigma.json")
    with sigma_path.open("r") as f:
        sigma: float = json.load(f)["sigma"]

    likert_7 = np.linspace(-1.0, 1.0, 7)
    p_map_to_1 = sp.stats.norm.cdf(likert_7 / sigma)
    labels = ["SO", "O", "WO", "N", "WS", "S", "SS"]

    fig, ax = plt.subplots(figsize=(4.5, 2), constrained_layout=True)
    ax.plot(likert_7, p_map_to_1, "-", color="k", linewidth=1, clip_on=False)
    ax.plot(
        likert_7,
        p_map_to_1,
        "o",
        markerfacecolor="white",
        markeredgecolor="k",
        markersize=6,
        linestyle="none",
        zorder=3,
        clip_on=False,
    )

    ax.grid(True, linewidth=0.5, clip_on=False)
    ax.set_xticks(likert_7, labels)
    ax.set_yticks(np.linspace(0.0, 1.0, 5))
    # ax.set_xlim(-1.1, None)
    ax.set_xlim(-1.0, 1.0)
    ax.set_ylim(0, 1)
    ax.set_ylabel(r"$P(x \mapsto +1)$")
    ax.set_xlabel("Likert-7 scale response", labelpad=10)
    ax.tick_params("x", length=0, pad=8)

    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)
    ax.spines.bottom.set_visible(False)

    fig.savefig(
        "reports/thesis/results/figures/dataset/likert_7_binarisation_probability.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    main()

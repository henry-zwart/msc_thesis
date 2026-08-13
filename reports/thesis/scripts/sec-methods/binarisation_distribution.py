from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import scipy as sp

from climate_attitudes.visualisation import configure_mpl


def main():
    fig, ax = plt.subplots(figsize=(4.25, 2), constrained_layout=True)

    x = -0.35
    scale = 0.2

    # Draw normal distribution curve
    epsilon = np.linspace(-2.0, 2.0, 1_000)
    p = sp.stats.norm.pdf(epsilon, scale=scale)
    ax.plot(x + epsilon, p, linewidth=1, color="black")

    # Dashed line at x
    ax.plot(
        [x, x],
        [0, sp.stats.norm.pdf(0, scale=scale)],
        linestyle="dashed",
        linewidth=0.75,
        color="black",
    )
    ax.annotate(
        r"$x$",
        xy=(x, -0.2),
        annotation_clip=False,
        fontsize=12,
        horizontalalignment="center",
    )

    # Shaded regions on left and right tails, add annotations
    ax.fill_between(
        np.linspace(0, 2.0, 500),
        sp.stats.norm.pdf(np.linspace(0, 2.0, 500), scale=scale, loc=x),
        color="grey",
        alpha=0.5,
    )
    ax.fill_between(
        np.linspace(-2.0, 2 * x, 500),
        sp.stats.norm.pdf(np.linspace(-2.0, 2 * x, 500), scale=scale, loc=x),
        color="grey",
        alpha=0.5,
    )
    ax.annotate("A", xy=(0.125, 0.25), fontsize=12)
    ax.annotate("B", xy=(2.5 * x, 0.25), fontsize=12)

    # Add arrow denoting standard deviation
    ax.annotate(r"$\xi$", xy=(x + 0.08, 0.25), fontsize=12, verticalalignment="bottom")
    ax.arrow(
        x,
        0.25,
        scale,
        0,
        length_includes_head=True,
        head_width=0.065,
        head_length=0.02,
        color="black",
    )

    ax.set_xlabel(r"$x + \epsilon$")
    ax.set_ylabel(r"$P(x + \epsilon)$", rotation=0, loc="top")

    # ax.set_xticks(np.linspace(-1, 1, 3))
    ax.set_xticks([0])
    ax.set_yticks([], None)

    ax.set_xlim(-1.0, 0.5)
    ax.set_ylim(0, p.max() * 1.1)

    ax.spines.left.set_linewidth(1)
    ax.spines.bottom.set_linewidth(1)
    ax.spines.left.set_position(("data", 0))
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    fig.savefig(
        Path("reports/thesis/results/figures/methods/binarisation/distribution.pdf"),
        bbox_inches="tight",
    )
    fig.savefig(
        Path("reports/thesis/results/figures/methods/binarisation/distribution.png"),
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    main()

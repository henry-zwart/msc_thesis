import matplotlib.pyplot as plt
import numpy as np
from matplotlib.lines import Line2D

from climate_attitudes.visualisation import configure_mpl


def prob(heff):
    return np.exp(heff) / (2 * np.cosh(heff))


def main():
    deltas = (0.5, 1.5, 2.5)

    fig, ax = plt.subplots(figsize=(4.25, 2.35), constrained_layout=True)

    heff_min, heff_max = -4, 3
    heff = np.linspace(heff_min, heff_max, 1_000)
    p = prob(heff)
    ax.plot(heff, p, clip_on=False, linewidth=0.75, color="tab:grey", zorder=3)

    linestyles = [":", "--", "-."]
    for ls, delta in zip(linestyles, deltas, strict=True):
        p_delta = prob(heff + delta)
        ax.plot(
            heff,
            p_delta,
            clip_on=False,
            linewidth=0.75,
            linestyle=ls,
            color="tab:grey",
            zorder=3,
        )

    ax.set_xlabel(r"Effective baseline activation, $h_\text{eff}$")
    ax.set_ylabel("Activation probability", ha="center")

    ax.set_ylim(0, 1)
    ax.set_xlim(heff_min, heff_max)

    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)

    handles = [
        Line2D([0], [0], linestyle=ls, color="tab:grey", linewidth=0.75)
        for ls in ["-"] + linestyles
    ]
    labels = [
        r"$\delta_h = 0$",
        r"$\delta_h = 0.5$",
        r"$\delta_h = 1.5$",
        r"$\delta_h = 2.5$",
    ]
    ax.legend(
        handles,
        labels,
        ncol=4,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.0),
        handlelength=1.5,
        frameon=False,
    )

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/methods/intervention_strengths.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    configure_mpl()
    main()

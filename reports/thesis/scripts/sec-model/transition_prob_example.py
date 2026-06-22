"""Demonstrating behaviour of asymmetric belief system model transition prob."""

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt

from climate_attitudes.visualisation import configure_mpl


def transition_probability(
    s: int, h_eff: npt.NDArray[np.float64], temperature: float | int
) -> float:
    return np.exp(1 / temperature * s * h_eff) / (2 * np.cosh(-1 / temperature * h_eff))


def main():
    TEMPS = [1.0, 3.0]
    H_EFFS = np.linspace(-5, 5, 100)
    LINECOLOURS = ["#364B9A", "#A50026"]

    fig, ax = plt.subplots(figsize=(5.77, 2.5), constrained_layout=True)

    for temperature, line_colour in zip(TEMPS, LINECOLOURS, strict=True):
        ax.plot(
            H_EFFS,
            transition_probability(s=1, h_eff=H_EFFS, temperature=temperature),
            color=line_colour,
            label=f"$T={temperature:.1f}$",
            clip_on=False,
        )

    ax.set_xlabel(r"$h_i^\text{eff}(\boldsymbol{s})$")
    # ax.set_ylabel(r"ℙ$[S_i^{t+dt} = 1]$")
    ax.set_ylabel(r"$P_{S_i^{t+1}|\boldsymbol{S}^t=\boldsymbol{s}}(+1)$")
    ax.set_ylim(0, 1)
    ax.set_xlim(-5, 5)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.legend(
        ncol=2,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.0),
        fontsize=11,
        frameon=False,
    )
    fig.savefig(
        "reports/thesis/results/figures/model/transition_probability_example.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    main()

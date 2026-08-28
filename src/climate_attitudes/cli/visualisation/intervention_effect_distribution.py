from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import seaborn as sns

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)


class InterventionEffectDisPlotCommand(BaseCommand):
    output_dir: Path
    data_dir: Path

    delta_str: str

    measure_time: int

    def cli_cmd(self) -> None:
        configure_mpl()

        # Load data
        no_int_asym_data = np.load(
            self.data_dir / "ising_00.npz",
        )
        int_asym_data = np.load(
            self.data_dir / f"ising_{self.delta_str}.npz",
        )
        no_int_sym_data = np.load(
            self.data_dir / "sym_ising_00.npz",
        )
        int_sym_data = np.load(
            self.data_dir / f"sym_ising_{self.delta_str}.npz",
        )

        int_asym_measurements = int_asym_data["measurements"][:, :, self.measure_time]
        no_int_asym_measurements = no_int_asym_data["measurements"][
            :, :, self.measure_time
        ]
        int_sym_measurements = int_sym_data["measurements"][:, :, self.measure_time]
        no_int_sym_measurements = no_int_sym_data["measurements"][
            :, :, self.measure_time
        ]
        int_effect_asym = int_asym_measurements - no_int_asym_measurements
        int_effect_sym = int_sym_measurements - no_int_sym_measurements

        # n = int_effect_asym.shape[-1]
        # for i in range(n):
        #     int_effect_asym[..., i, i] = 0
        #     int_effect_sym[..., i, i] = 0

        # Create plot for each choice of intervention spin
        N = int_asym_measurements.shape[-1]
        labels = int_asym_data["labels"]
        asym_figures = []
        sym_figures = []
        for figures, effects in zip(
            (asym_figures, sym_figures),
            (int_effect_asym, int_effect_sym),
            strict=True,
        ):
            for i in range(N):
                fig = intervention_effect_distribution_plot(
                    effects[..., i],
                    labels,
                )
                figures.append(fig)

        # Save figures
        for figures, assumption in zip(
            (asym_figures, sym_figures),
            ("asym", "sym"),
            strict=True,
        ):
            for i, fig in enumerate(figures):
                colname = (
                    "".join(c for c in labels[i] if c.isalnum() or c == " ")
                    .lower()
                    .replace(" ", "_")
                )
                filename = f"{assumption}_{self.delta_str}_{colname}"
                fig.savefig(
                    self.output_dir / f"{filename}.pdf",
                    bbox_inches="tight",
                    transparent=True,
                )
                fig.savefig(
                    self.output_dir / f"{filename}.png",
                    bbox_inches="tight",
                    transparent=True,
                )


def intervention_effect_distribution_plot(
    int_effects: npt.NDArray[np.int64],
    intervention_labels: npt.NDArray[np.str_],
) -> plt.Figure:
    fig, axes = plt.subplots(
        nrows=2,
        ncols=4,
        figsize=(5.77, 2.5),
        constrained_layout=True,
        # sharey=True,
        sharex=True,
    )

    # Take mean effect, for each individual, as measured across repeats
    mean_effect = int_effects.mean(axis=0)
    flat_axes = axes.flatten()
    for i, intervention in enumerate(intervention_labels):
        # if i == target_idx :
        #     continue
        ax = flat_axes[i]
        sns.kdeplot(mean_effect[..., i], fill=True, ax=ax)  # , binwidth=0.02)
        ax.set_title(intervention, fontsize=9)
        ax.set_xlabel("")
        ax.set_ylabel("")
        ax.spines.top.set_visible(False)
        ax.spines.right.set_visible(False)

    fig.supxlabel(
        "Effect of intervention attitude toward climate action", fontsize=13, x=0.55
    )
    fig.supylabel("Density", fontsize=13, y=0.55)

    # Set xlim to be equally-sized around 0, just including all datapoints
    # max_effect_size = np.percentile(abs(mean_effect), q=99, axis=0).max()
    # candidates = np.linspace(0, 1, 21)
    # xmax = candidates[min(np.argmax(candidates >= max_effect_size) - 1, 1)]
    # axes[0, 0].set_xlim(-xmax / 10, xmax)
    axes[0, 0].set_xlim(0, mean_effect.max())

    # Set title
    # fig.suptitle(
    #     f"Individual-level effects for interventions targeting '{target_label}'",
    #     fontsize=12,
    #     # pad=30,
    # )

    return fig

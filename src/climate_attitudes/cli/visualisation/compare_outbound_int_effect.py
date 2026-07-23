"""Measure effect on other spins when intervening on X."""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
import seaborn as sns
from matplotlib.axes import Axes

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)


def bootstrap_mean_effects(measurements, z: float):
    # measurements: shape (repeats, replicates, n_individuals, n_interventions)
    expected_effect_collective = measurements.mean(axis=1)
    mean = expected_effect_collective.mean(axis=0)
    ci = z * expected_effect_collective.std(axis=0, ddof=1)

    return mean, mean - ci, mean + ci


class CompareOutboundIntEffectsPlotCommand(BaseCommand):
    output_dir: Path
    data_dir: Path

    point_of_intervention_idx: list[int]
    delta: float

    z: float = 1.96

    measure_time: int

    def cli_cmd(self) -> None:
        configure_mpl()

        delta_str = f"{self.delta:.1f}".replace(".", "")

        # Load data
        no_int_asym_data = np.load(
            self.data_dir / "ising_00.npz",
        )
        no_int_sym_data = np.load(
            self.data_dir / "sym_ising_00.npz",
        )

        int_asym_data = np.load(
            self.data_dir / f"ising_{delta_str}.npz",
        )
        int_sym_data = np.load(
            self.data_dir / f"sym_ising_{delta_str}.npz",
        )

        # Calculate effects of intervention
        int_asym_measurements = int_asym_data["measurements"][:, :, self.measure_time]
        no_int_asym_measurements = no_int_asym_data["measurements"][
            :, :, self.measure_time
        ]
        int_sym_measurements = int_sym_data["measurements"][:, :, self.measure_time]
        no_int_sym_measurements = no_int_sym_data["measurements"][
            :, :, self.measure_time
        ]
        int_effects_asym = int_asym_measurements - no_int_asym_measurements
        int_effects_sym = int_sym_measurements - no_int_sym_measurements

        labels = int_asym_data["labels"]
        fig, axes = plt.subplots(
            nrows=len(self.point_of_intervention_idx),
            figsize=(5, 6.5),
            constrained_layout=True,
            sharey=True,
        )

        for ax, i in zip(axes.flatten(), self.point_of_intervention_idx, strict=True):
            intervention_effect_plot(
                np.delete(int_effects_sym[..., i, :], i, axis=-1),
                np.delete(int_effects_asym[..., i, :], i, axis=-1),
                np.delete(labels, i),
                self.z,
                ax,
            )
            match self.measure_time:
                case 5:
                    ax.set_ylim(0, 0.4)
                case 10:
                    ax.set_ylim(0, 0.6)
                case _:
                    raise ValueError(f"Unsupported measure_time: {self.measure_time}")
            ax.set_xlabel("")
            ax.set_ylabel("")
            ax.set_title(f"Point-of-intervention: {labels[i]}", pad=10)

        # Replace seaborn legend with a prettier one
        old_leg = axes[0].get_legend()
        handles = old_leg.legend_handles
        leg_labels = [t.get_text() for t in old_leg.texts]

        old_leg.remove()

        axes[0].legend(
            handles,
            leg_labels,
            ncol=2,
            loc="upper right",
            bbox_to_anchor=(0.98, 1.15),
            frameon=False,
        )
        for ax in axes[1:]:
            ax.get_legend().remove()

        fig.supxlabel("Intervention target", x=0.55, fontsize=14)
        fig.supylabel("Effect of intervention", y=0.55, fontsize=14)

        for ext in ("png", "pdf"):
            fig.savefig(
                self.output_dir / f"outbound_effects_{self.measure_time}.{ext}",
                bbox_inches="tight",
            )


def intervention_effect_plot(
    int_effect_sym: npt.NDArray[np.float64],
    int_effect_asym: npt.NDArray[np.float64],
    target_labels: npt.NDArray[np.str_],
    z: float,
    ax: Axes,
):
    sym_mean, sym_lo, sym_hi = bootstrap_mean_effects(int_effect_sym, z)
    asym_mean, asym_lo, asym_hi = bootstrap_mean_effects(int_effect_asym, z)

    sort_idxes = np.argsort(sym_mean)[::-1]
    target_labels = target_labels[sort_idxes]
    asym_mean = asym_mean[sort_idxes]
    asym_lo = asym_lo[sort_idxes]
    asym_hi = asym_hi[sort_idxes]
    sym_mean = sym_mean[sort_idxes]
    sym_lo = sym_lo[sort_idxes]
    sym_hi = sym_hi[sort_idxes]

    n = target_labels.size + 1
    plot_df = pl.DataFrame(
        {
            "Model": ["Symmetric"] * (n - 1) + ["Asymmetric"] * (n - 1),
            "Target": np.concat((target_labels, target_labels)),
            "Effect": np.concat((sym_mean, asym_mean)),
            "CI low": np.concat((sym_lo, asym_lo)),
            "CI high": np.concat((sym_hi, asym_hi)),
        }
    )

    # Plot effect sizes as barplot per target, with bars coloured by symm/asymm
    sns.barplot(
        plot_df,
        x="Target",
        y="Effect",
        hue="Model",
        ax=ax,
    )
    # ax.bar_label(ax.containers[0], fmt=".2f", fontsize=8)
    ax.bar_label(ax.containers[0], fontsize=8, padding=8, fmt="%.2f")
    ax.bar_label(ax.containers[1], fontsize=8, padding=8, fmt="%.2f")

    # Show CIs as whiskers
    x = np.arange(n - 1)
    WIDTH = 0.4
    for j, model in enumerate(["Symmetric", "Asymmetric"]):
        subset_df = plot_df.filter(Model=model)
        offset = -WIDTH / 2 if j == 0 else WIDTH / 2

        ax.errorbar(
            x + offset,
            subset_df["Effect"],
            yerr=[
                subset_df["Effect"] - subset_df["CI low"],
                subset_df["CI high"] - subset_df["Effect"],
            ],
            fmt="none",
            capsize=2,
            color="black",
        )

    # Angle xtick labels so they don't overlap
    ax.set_xticks(
        np.arange(n - 1),
        target_labels,
        rotation=35,
        horizontalalignment="right",
    )

    # Turn off axis spines
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

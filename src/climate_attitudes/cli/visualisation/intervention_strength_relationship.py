"""Show linear relationship between intervention effects for different strengths"""

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


class CompareInterventionStrengthPlotCommand(BaseCommand):
    output_dir: Path
    data_dir: Path

    point_of_intervention_idx: list[int]
    delta: list[float]

    z: float = 1.96

    measure_time: int

    def cli_cmd(self) -> None:
        configure_mpl()

        delta_strs = [f"{delta:.1f}".replace(".", "") for delta in self.delta]

        if len(delta_strs) != 2:
            raise ValueError("Expected two intervention strengths to compare.")

        # Load data
        no_int_asym_data = np.load(
            self.data_dir / "ising_00.npz",
        )
        no_int_sym_data = np.load(
            self.data_dir / "sym_ising_00.npz",
        )

        int_effects_asym = []
        int_effects_sym = []

        for delta_str in delta_strs:
            int_asym_data = np.load(
                self.data_dir / f"ising_{delta_str}.npz",
            )
            int_sym_data = np.load(
                self.data_dir / f"sym_ising_{delta_str}.npz",
            )

            # Calculate effects of intervention
            int_asym_measurements = int_asym_data["measurements"][
                :, :, self.measure_time
            ]
            no_int_asym_measurements = no_int_asym_data["measurements"][
                :, :, self.measure_time
            ]
            int_sym_measurements = int_sym_data["measurements"][:, :, self.measure_time]
            no_int_sym_measurements = no_int_sym_data["measurements"][
                :, :, self.measure_time
            ]
            int_effects_asym.append(int_asym_measurements - no_int_asym_measurements)
            int_effects_sym.append(int_sym_measurements - no_int_sym_measurements)

        labels = int_asym_data["labels"]
        fig, axes = plt.subplots(
            ncols=len(self.point_of_intervention_idx),
            figsize=(5.77, 2),
            sharey=True,
            constrained_layout=True,
        )
        for i, ax in zip(self.point_of_intervention_idx, axes.flatten(), strict=True):
            for colour, model_name, res in zip(
                ["tab:blue", "tab:orange"],
                ["Symmetric", "Asymmetric"],
                (int_effects_sym, int_effects_asym),
                strict=True,
            ):
                strong_res = np.delete(res[1][..., i, :], i, axis=-1)
                weak_res = np.delete(res[0][..., i, :], i, axis=-1)
                weak_mean, weak_lo, weak_hi = bootstrap_mean_effects(weak_res, self.z)
                strong_mean, strong_lo, strong_hi = bootstrap_mean_effects(
                    strong_res, self.z
                )
                sort_order = np.argsort(strong_mean)
                weak_mean = weak_mean[sort_order]
                strong_mean = strong_mean[sort_order]
                weak_lo = weak_lo[sort_order]
                weak_hi = weak_hi[sort_order]
                strong_lo = strong_lo[sort_order]
                strong_hi = strong_hi[sort_order]

                ax.plot(
                    strong_mean,
                    weak_mean,
                    "x",
                    color=colour,
                    markersize=5,
                    markeredgewidth=0.75,
                    label=model_name,
                    zorder=5,
                )
                # ax.errorbar(
                #     strong_mean,
                #     weak_mean,
                #     xerr=(strong_mean - strong_lo, strong_hi - strong_mean),
                #     yerr=(weak_mean - weak_lo, weak_hi - weak_mean),
                #     ls="none",
                #     elinewidth=0.75,
                #     capthick=0.75,
                #     ecolor=colour,
                #     capsize=1,
                #     zorder=1,
                #     alpha=0.5,
                # )
                # Plot line of best fit
                m, b = np.polyfit(strong_mean, weak_mean, 1)
                ax.plot(
                    strong_mean,
                    m * strong_mean + b,
                    color=colour,
                    linestyle="dashed",
                    linewidth=0.75,
                    zorder=2,
                )

            ax.set_title(labels[i])
            ax.spines.top.set_visible(False)
            ax.spines.right.set_visible(False)

        axes[0].set_ylim(0, None)
        for ax in axes:
            ax.set_xlim(0, None)
        axes[0].legend(fontsize=8, frameon=True, loc="upper left")
        fig.supxlabel("Intervention effect (strong intervention)", x=0.55)
        fig.supylabel("Intervention effect\n(weak intervention)", y=0.55)

        # # Replace seaborn legend with a prettier one
        # old_leg = axes[1].get_legend()
        # handles = old_leg.legend_handles
        # leg_labels = [t.get_text() for t in old_leg.texts]
        #
        # old_leg.remove()
        # axes[0].get_legend().remove()
        #
        # axes[1].legend(
        #     handles,
        #     leg_labels,
        #     ncol=2,
        #     loc="lower center",
        #     bbox_to_anchor=(0.5, 1.0),
        #     frameon=False,
        # )

        for ext in ("png", "pdf"):
            fig.savefig(
                f"{self.output_dir}/intervention_strength_compare.{ext}",
                bbox_inches="tight",
            )


def intervention_effect_plot(
    int_effect_weak: npt.NDArray[np.float64],
    int_effect_strong: npt.NDArray[np.float64],
    target_labels: npt.NDArray[np.str_],
    z: float,
    ax: Axes,
    sort_idxes: npt.NDArray[np.int64] | None = None,
) -> npt.NDArray[np.int64]:
    weak_mean, weak_lo, weak_hi = bootstrap_mean_effects(int_effect_weak, z)
    strong_mean, strong_lo, strong_hi = bootstrap_mean_effects(int_effect_strong, z)

    if sort_idxes is None:
        sort_idxes = np.argsort(strong_mean)[::-1]
    target_labels = target_labels[sort_idxes]
    strong_mean = strong_mean[sort_idxes]
    strong_lo = strong_lo[sort_idxes]
    strong_hi = strong_hi[sort_idxes]
    weak_mean = weak_mean[sort_idxes]
    weak_lo = weak_lo[sort_idxes]
    weak_hi = weak_hi[sort_idxes]

    n = target_labels.size + 1
    plot_df = pl.DataFrame(
        {
            "Scenario": ["Strong"] * (n - 1) + ["Weak"] * (n - 1),
            "Target": np.concat((target_labels, target_labels)),
            "Effect": np.concat((strong_mean, weak_mean)),
            "CI low": np.concat((strong_lo, weak_lo)),
            "CI high": np.concat((strong_hi, weak_hi)),
        }
    )

    # Plot effect sizes as barplot per target, with bars coloured by symm/asymm
    sns.barplot(
        plot_df,
        x="Target",
        y="Effect",
        hue="Scenario",
        ax=ax,
    )
    # ax.bar_label(ax.containers[0], fmt=".2f", fontsize=8)

    # Show CIs as whiskers
    x = np.arange(n - 1)
    WIDTH = 0.4
    for j, scenario in enumerate(["Strong", "Weak"]):
        subset_df = plot_df.filter(Scenario=scenario)
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
        rotation=90,
    )

    # Turn off axis spines
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    return sort_idxes

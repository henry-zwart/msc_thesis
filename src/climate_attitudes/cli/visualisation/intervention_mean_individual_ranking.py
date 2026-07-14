from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
import seaborn as sns
from scipy.stats import rankdata

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.visualisation import configure_mpl

from .heterogeneous_intervention_effects import InterventionStrength

np.set_printoptions(linewidth=200)


def bootstrap_mean_ranks(measurements, z: float = 1.97):
    individual_ranks = rankdata(measurements.mean(axis=1), method="min", axis=-1)
    mean = individual_ranks.mean(axis=1)
    ci = z * individual_ranks.std(axis=1, ddof=1)

    return (
        mean,
        np.clip(mean - ci, a_min=0, a_max=measurements.shape[-1]),
        np.clip(mean + ci, a_min=0, a_max=measurements.shape[-1]),
    )


class InterventionIndividualRankPlotCommand(BaseCommand):
    output_dir: Path
    data_dir: Path

    intervention: list[InterventionStrength]

    measure_time: int

    z: float = 1.96

    def cli_cmd(self) -> None:
        configure_mpl()

        # Load data
        measurements = []
        for delta in self.intervention:
            data = np.load(self.data_dir / f"ising_{delta.delta_str()}.npz")
            measurements.append(data["measurements"][:, :, self.measure_time])
        measurements = np.asarray(measurements)

        # Create plot for each choice of intervention column
        N = measurements.shape[-1]
        labels = data["labels"]
        figures = []
        for i in range(N):
            fig = intervention_ranking_plot(
                np.delete(measurements[..., i], i, axis=-1),
                np.delete(labels, i),
                self.intervention,
                self.z,
            )
            figures.append(fig)

        # Save figures
        for i, fig in enumerate(figures):
            colname = (
                "".join(c for c in labels[i] if c.isalnum() or c == " ")
                .lower()
                .replace(" ", "_")
            )
            fig.savefig(self.output_dir / f"{colname}.pdf", bbox_inches="tight")
            fig.savefig(self.output_dir / f"{colname}.png", bbox_inches="tight")


def intervention_ranking_plot(
    measurements: npt.NDArray[np.int64],
    intervention_labels: npt.NDArray[np.str_],
    scenarios: list[InterventionStrength],
    z: float,
) -> plt.Figure:
    fig, ax = plt.subplots(figsize=(5, 2.5), constrained_layout=True)

    mean, lo, hi = bootstrap_mean_ranks(measurements, z)

    sort_idxes = np.argsort(mean[-1])[::-1]
    intervention_labels = intervention_labels[sort_idxes]
    mean = mean[::-1, sort_idxes]
    lo = lo[::-1, sort_idxes]
    hi = hi[::-1, sort_idxes]

    n = intervention_labels.size + 1
    scenario_names = [
        f"$\\delta_h = {delta.delta_str()[0]}.{delta.delta_str()[1]}$"
        for delta in reversed(scenarios)
    ]
    plot_df = pl.DataFrame(
        {
            "Scenario": [name for name in scenario_names for _ in range(n - 1)],
            "Intervention": np.concat((intervention_labels, intervention_labels)),
            "Mean rank": mean.flatten(),
            "CI low": lo.flatten(),
            "CI high": hi.flatten(),
        }
    )

    # Plot effect sizes as barplot per target, with bars coloured by symm/asymm
    sns.barplot(
        plot_df,
        x="Intervention",
        y="Mean rank",
        hue="Scenario",
        palette=["#5289C7", "#7BAFDE"],
        ax=ax,
    )

    # Show CIs as whiskers
    x = np.arange(n - 1)
    WIDTH = 0.4

    for j, scenario in enumerate(scenario_names):
        subset_df = plot_df.filter(Scenario=scenario)
        offset = -WIDTH / 2 if j == 0 else WIDTH / 2

        ax.errorbar(
            x + offset,
            subset_df["Mean rank"],
            yerr=[
                subset_df["Mean rank"] - subset_df["CI low"],
                subset_df["CI high"] - subset_df["Mean rank"],
            ],
            fmt="none",
            capsize=4,
            color="black",
        )

    # Replace seaborn legend with a prettier one
    old_leg = ax.get_legend()
    handles = old_leg.legend_handles  # ty: ignore
    leg_labels = [t.get_text() for t in old_leg.texts]  # ty: ignore

    old_leg.remove()  # ty: ignore

    ax.legend(
        handles,  # ty: ignore
        leg_labels,
        ncol=2,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.0),
        frameon=False,
    )

    # Angle xtick labels so they don't overlap
    ax.set_xticks(
        np.arange(n - 1),
        intervention_labels,
        rotation=30,
        horizontalalignment="right",
    )

    # Turn off axis spines
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    # Set title
    # ax.set_title(
    #     f"Mean ranks for interventions targeting '{intervention_label}'",
    #     pad=30,
    # )

    return fig

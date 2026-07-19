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
    # measurements: shape (repeats, replicates, n_individuals, n_interventions)
    # expected_effect_per_individual = measurements.mean(axis=1)
    expected_effect_collective = measurements.mean(axis=1)
    rankings_per_repeat = rankdata(expected_effect_collective, method="min", axis=-1)
    mean = rankings_per_repeat.mean(axis=0)
    ci = z * rankings_per_repeat.std(axis=0, ddof=1)

    return mean, mean - ci, mean + ci


def rank_collective_outcomes(
    measurements: npt.NDArray[np.int64], z: float
) -> tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    # Collective outcome as average measurement across individuals
    collective_outcomes = measurements.mean(axis=2)

    # Rank collective outcomes across intervention spins: high outcome --> high rank
    ranks = rankdata(collective_outcomes, method="min", axis=-1)

    # Estimate expected rank using average across repeats
    mean_ranks = ranks.mean(axis=1)

    # Confidence interval as spread around the mean
    ci = z * ranks.std(axis=1, ddof=1)

    return mean_ranks, ci


class CollectiveRankCombPlotCommand(BaseCommand):
    output_dir: Path
    data_dir: Path

    intervention: list[InterventionStrength]
    asym_results: list[Path]
    sym_results: list[Path]

    measure_time: int

    z: float = 1.96

    def cli_cmd(self) -> None:
        configure_mpl()

        # Load data
        asym_measurements = np.asarray(
            [
                np.load(fp)["measurements"][:, :, self.measure_time]
                for fp in self.asym_results
            ]
        )
        sym_measurements = np.asarray(
            [
                np.load(fp)["measurements"][:, :, self.measure_time]
                for fp in self.sym_results
            ]
        )

        # Create plot for each choice of intervention column
        N = asym_measurements.shape[-1]
        labels = np.load(self.asym_results[0])["labels"]
        figures = []
        for i in range(N):
            fig = intervention_ranking_plot(
                np.delete(asym_measurements[..., i], i, axis=-1),
                np.delete(sym_measurements[..., i], i, axis=-1),
                np.delete(labels, i),
                labels[i],
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
    asym_measurements: npt.NDArray[np.int64],
    sym_measurements: npt.NDArray[np.int64],
    intervention_labels: npt.NDArray[np.str_],
    target_label: str,
    scenarios: list[InterventionStrength],
    z: float,
) -> plt.Figure:
    fig, axes = plt.subplots(
        ncols=2,
        figsize=(5.77, 2.5),
        constrained_layout=True,
        sharey=True,
        sharex=True,
    )

    asym_mean, asym_ci = rank_collective_outcomes(asym_measurements, z)
    sym_mean, sym_ci = rank_collective_outcomes(sym_measurements, z)

    asym_lo, asym_hi = asym_mean - asym_ci, asym_mean + asym_ci
    sym_lo, sym_hi = sym_mean - sym_ci, sym_mean + sym_ci

    sort_idxes = np.argsort(sym_mean[0])[::-1]
    intervention_labels = intervention_labels[sort_idxes]
    sym_mean = sym_mean[:, sort_idxes]
    sym_lo = sym_lo[:, sort_idxes]
    sym_hi = sym_hi[:, sort_idxes]
    asym_mean = asym_mean[:, sort_idxes]
    asym_lo = asym_lo[:, sort_idxes]
    asym_hi = asym_hi[:, sort_idxes]

    n = intervention_labels.size + 1
    k = asym_mean.shape[0]
    scenario_strs = [s.title() for s in scenarios]
    plot_df = pl.DataFrame(
        {
            "Model": ["Symmetric"] * (n - 1) * k + ["Asymmetric"] * (n - 1) * k,
            "Scenario": np.tile(np.repeat(scenario_strs, n - 1), 2),
            "Intervention": np.tile(intervention_labels, 2 * k),
            "Mean rank": np.concat((sym_mean.flatten(), asym_mean.flatten())),
            "CI low": np.concat((sym_lo.flatten(), asym_lo.flatten())),
            "CI high": np.concat((sym_hi.flatten(), asym_hi.flatten())),
        }
    )

    # Plot effect sizes as barplot per target, with bars coloured by symm/asymm
    for j, model in enumerate(["Symmetric", "Asymmetric"]):
        sns.barplot(
            plot_df.filter(Model=model),
            x="Intervention",
            y="Mean rank",
            hue="Scenario",
            ax=axes[j],
        )

    # Show CIs as whiskers
    x = np.arange(n - 1)
    # WIDTH = 0.2
    WIDTH = 0.8
    for j, model in enumerate(["Symmetric", "Asymmetric"]):
        for s_i, scenario in enumerate(scenario_strs):
            subset_df = plot_df.filter(Model=model, Scenario=scenario)
            offset = (s_i - (k - 1) / 2) * (WIDTH / k)

            axes[j].errorbar(
                x + offset,
                subset_df["Mean rank"],
                yerr=[
                    subset_df["Mean rank"] - subset_df["CI low"],
                    subset_df["CI high"] - subset_df["Mean rank"],
                ],
                fmt="none",
                capsize=2,
                linewidth=0.75,
                capthick=0.75,
                color="black",
            )

    # Replace seaborn legend with a prettier one
    old_leg = axes[1].get_legend()
    handles = old_leg.legend_handles  # ty: ignore
    leg_labels = [f"{t.get_text()} intervention" for t in old_leg.texts]  # ty: ignore

    for ax in axes:
        ax.get_legend().remove()

    v1_legend = True
    if v1_legend:
        fig.legend(
            handles,
            leg_labels,
            ncol=2,
            loc="lower left",
            handlelength=1,
            columnspacing=1,
            bbox_to_anchor=(0.07, 0.8),
            fontsize=8,
            frameon=False,
        )
    else:
        # fig.legend(
        #     handles,
        #     leg_labels,
        #     ncol=2,
        #     loc="upper right",
        #     handlelength=1,
        #     columnspacing=1,
        #     bbox_to_anchor=(0.99, 1.10),
        #     fontsize=8,
        #     frameon=True,
        # )
        leg_labels = [label.replace(" intervention", "") for label in leg_labels]
        fig.legend(
            handles,
            leg_labels,
            ncol=1,
            title="Intervention",
            loc="upper right",
            handlelength=1,
            columnspacing=1,
            bbox_to_anchor=(0.99, 0.9),
            fontsize=8,
            frameon=True,
        )

    for ax in axes:
        # Angle xtick labels so they don't overlap
        ax.set_xticks(
            np.arange(n - 1),
            intervention_labels,
            rotation=40,
            horizontalalignment="right",
        )
        ax.set_xlabel("")

        # Turn off axis spines
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)

    models = ["Symmetric", "Asymmetric"]
    for i, model_name in enumerate(models):
        axes[i].set_title(model_name, pad=20 if v1_legend else 5)

    axes[0].set_yticks(np.arange(0, n + 1, 2))
    # fig.suptitle(f"Intervention target: {target_label}")
    fig.supxlabel(f"Point of Intervention: targeting '{target_label}'")

    # Set title
    # ax.set_title(
    #     f"Mean ranks for interventions targeting '{intervention_label}'",
    #     pad=30,
    # )

    return fig

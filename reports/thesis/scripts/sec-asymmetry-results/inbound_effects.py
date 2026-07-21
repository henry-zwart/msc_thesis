from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
import seaborn as sns
from matplotlib.axes import Axes
from scipy.stats import rankdata

from climate_attitudes.visualisation import configure_mpl


def load_data(
    data_dir: Path,
    delta_str: str,
    measure_time: int,
    target_idx: int,
) -> tuple[npt.NDArray[np.int64], npt.NDArray[np.int64], npt.NDArray[np.str_]]:
    null_sym = np.load(data_dir / "sym_ising_00.npz")
    null_asym = np.load(data_dir / "ising_00.npz")
    int_sym = np.load(data_dir / f"sym_ising_{delta_str}.npz")
    int_asym = np.load(data_dir / f"ising_{delta_str}.npz")

    # Calculate effects of intervention
    null_sym_outcomes = null_sym["measurements"][:, :, measure_time]
    null_asym_outcomes = null_asym["measurements"][:, :, measure_time]
    int_sym_outcomes = int_sym["measurements"][:, :, measure_time]
    int_asym_outcomes = int_asym["measurements"][:, :, measure_time]
    int_effect_sym = int_sym_outcomes - null_sym_outcomes
    int_effect_asym = int_asym_outcomes - null_asym_outcomes

    labels = int_asym["labels"]

    int_effect_sym = np.delete(int_effect_sym[..., target_idx], target_idx, axis=-1)
    int_effect_asym = np.delete(int_effect_asym[..., target_idx], target_idx, axis=-1)
    labels = np.delete(labels, target_idx)

    return int_effect_sym, int_effect_asym, labels


def bootstrap_collective_effect(measurements, z: float):
    expected_effect_collective = measurements.mean(axis=1)
    mean = expected_effect_collective.mean(axis=0)
    ci = z * expected_effect_collective.std(axis=0, ddof=1)

    return mean, mean - ci, mean + ci


def bootstrap_mean_ranks(measurements, z: float):
    expected_effect_collective = measurements.mean(axis=1)
    rankings_per_repeat = rankdata(expected_effect_collective, method="min", axis=-1)
    mean = rankings_per_repeat.mean(axis=0)
    ci = z * rankings_per_repeat.std(axis=0, ddof=1)

    return mean, mean - ci, mean + ci


def plot_inbound_intervention_effects(
    effect_sym: npt.NDArray[np.int64],
    effect_asym: npt.NDArray[np.int64],
    labels: npt.NDArray[np.str_],
    z: float,
    ax: Axes,
):
    asym_mean, asym_lo, asym_hi = bootstrap_collective_effect(effect_asym, z)
    sym_mean, sym_lo, sym_hi = bootstrap_collective_effect(effect_sym, z)

    sort_idxes = np.argsort(sym_mean)[::-1]
    labels = labels[sort_idxes]
    sym_mean = sym_mean[sort_idxes]
    sym_lo = sym_lo[sort_idxes]
    sym_hi = sym_hi[sort_idxes]
    asym_mean = asym_mean[sort_idxes]
    asym_lo = asym_lo[sort_idxes]
    asym_hi = asym_hi[sort_idxes]

    n = labels.size + 1
    plot_df = pl.DataFrame(
        {
            "Model": ["Symmetric"] * (n - 1) + ["Asymmetric"] * (n - 1),
            "Intervention": np.concat((labels, labels)),
            "Mean intervention effect": np.concat((sym_mean, asym_mean)),
            "CI low": np.concat((sym_lo, asym_lo)),
            "CI high": np.concat((sym_hi, asym_hi)),
        }
    )

    # Plot effect sizes as barplot per target, with bars coloured by symm/asymm
    sns.barplot(
        plot_df,
        x="Intervention",
        y="Mean intervention effect",
        hue="Model",
        ax=ax,
    )

    # Show CIs as whiskers
    x = np.arange(n - 1)
    WIDTH = 0.4
    for j, model in enumerate(["Symmetric", "Asymmetric"]):
        subset_df = plot_df.filter(Model=model)
        offset = -WIDTH / 2 if j == 0 else WIDTH / 2

        ax.errorbar(
            x + offset,
            subset_df["Mean intervention effect"],
            yerr=[
                subset_df["Mean intervention effect"] - subset_df["CI low"],
                subset_df["CI high"] - subset_df["Mean intervention effect"],
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
        loc="upper right",
        bbox_to_anchor=(1.0, 1.25),
        frameon=False,
    )

    # Angle xtick labels so they don't overlap
    ax.set_xticks(
        np.arange(n - 1),
        labels,
        rotation=30,
        horizontalalignment="right",
    )

    # Turn off axis spines
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)


def plot_inbound_intervention_ranks(
    effect_sym: npt.NDArray[np.int64],
    effect_asym: npt.NDArray[np.int64],
    labels: npt.NDArray[np.str_],
    z: float,
    ax: Axes,
):
    asym_mean, asym_lo, asym_hi = bootstrap_mean_ranks(effect_asym, z)
    sym_mean, sym_lo, sym_hi = bootstrap_mean_ranks(effect_sym, z)

    sort_idxes = np.argsort(sym_mean)[::-1]
    intervention_labels = labels[sort_idxes]
    sym_mean = sym_mean[sort_idxes]
    sym_lo = sym_lo[sort_idxes]
    sym_hi = sym_hi[sort_idxes]
    asym_mean = asym_mean[sort_idxes]
    asym_lo = asym_lo[sort_idxes]
    asym_hi = asym_hi[sort_idxes]

    n = intervention_labels.size + 1
    plot_df = pl.DataFrame(
        {
            "Model": ["Symmetric"] * (n - 1) + ["Asymmetric"] * (n - 1),
            "Intervention": np.concat((intervention_labels, intervention_labels)),
            "Mean rank": np.concat((sym_mean, asym_mean)),
            "CI low": np.concat((sym_lo, asym_lo)),
            "CI high": np.concat((sym_hi, asym_hi)),
        }
    )

    # Plot effect sizes as barplot per target, with bars coloured by symm/asymm
    sns.barplot(
        plot_df,
        x="Intervention",
        y="Mean rank",
        hue="Model",
        ax=ax,
        legend=False,
    )

    # Show CIs as whiskers
    x = np.arange(n - 1)
    WIDTH = 0.4
    for j, model in enumerate(["Symmetric", "Asymmetric"]):
        subset_df = plot_df.filter(Model=model)
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


def main(
    effect_sym: npt.NDArray[np.int64],
    effect_asym: npt.NDArray[np.int64],
    labels: npt.NDArray[np.str_],
    z: float,
):
    fig, axes = plt.subplots(nrows=2, figsize=(5, 4), constrained_layout=True)

    plot_inbound_intervention_effects(effect_sym, effect_asym, labels, z, axes[0])
    plot_inbound_intervention_ranks(effect_sym, effect_asym, labels, z, axes[1])

    axes[0].set_ylabel("Mean effect\nof intervention")

    axes[0].set_ylim(0, 0.4)
    axes[1].set_ylim(1, 7)
    axes[1].set_yticks(np.arange(1, 8, 2))

    axes[0].bar_label(axes[0].containers[0], fontsize=8, padding=8, fmt="%.2f")
    axes[0].bar_label(axes[0].containers[1], fontsize=8, padding=8, fmt="%.2f")

    axes[1].bar_label(axes[1].containers[0], fontsize=9, padding=8, fmt="%.1f")
    axes[1].bar_label(axes[1].containers[1], fontsize=9, padding=8, fmt="%.1f")

    for ax in axes:
        ax.set_xlabel("")

    fig.supxlabel("Point-of-intervention", x=0.55, fontsize=12)

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/asymmetry_results/inbound_effects.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    configure_mpl()
    int_effect_sym, int_effect_asym, labels = load_data(
        data_dir=Path("reports/thesis/results/data/model/all_interventions"),
        delta_str="25",
        measure_time=5,
        target_idx=7,
    )
    main(int_effect_sym, int_effect_asym, labels, z=1.96)

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
import seaborn as sns

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)


def bootstrap_collective_effect(measurements, rng, n_boot=100):
    # measurements: shape (n_individuals, repeats, n_interventions)
    M, _, N = measurements.shape
    boot_means = np.empty((n_boot, N))

    for b in range(n_boot):
        sample_rows = rng.integers(0, M, M)
        samples = measurements[sample_rows]

        # Collective effect as proportion of individuals with desired state
        collective_effect = ((samples + 1) // 2).mean(axis=0)

        # Final estimate is average proportion of adoption
        boot_means[b] = collective_effect.mean(axis=0)

    mean = boot_means.mean(axis=0)
    # ci = z * boot_means.std(axis=0, ddof=1) / np.sqrt(n_boot)
    # lower = mean - ci
    # upper = mean + ci

    lower, upper = np.percentile(boot_means, (5, 95), axis=0)
    avg_effect = ((measurements + 1) // 2).mean(axis=0)
    mean = np.mean(avg_effect, axis=0)
    lower, upper = np.percentile(avg_effect, (5, 95), axis=0)

    return mean, lower, upper


class InterventionCollectiveEffectPlotCommand(BaseCommand):
    output_dir: Path
    data_dir: Path

    delta_str: str
    use_covariates: bool = True

    measure_time: int

    seed: int

    def cli_cmd(self) -> None:
        configure_mpl()

        # Load data
        if self.use_covariates:
            covariate_flag = "yes_use_covariates"
        else:
            covariate_flag = "no_use_covariates"

        int_asym_data = np.load(
            self.data_dir / f"ising_{self.delta_str}_{covariate_flag}.npz",
        )
        int_sym_data = np.load(
            self.data_dir / f"sym_ising_{self.delta_str}_{covariate_flag}.npz",
        )

        # Calculate effects of intervention
        int_asym_measurements = int_asym_data["measurements"][:, :, self.measure_time]
        int_sym_measurements = int_sym_data["measurements"][:, :, self.measure_time]

        # Create plot for each choice of intervention column
        N = int_asym_measurements.shape[-1]
        rng = np.random.default_rng(self.seed)
        labels = int_asym_data["labels"]
        figures = []
        for i in range(N):
            intervention_col = labels[i]
            fig = intervention_collective_effect_plot(
                np.delete(int_asym_measurements[:, :, i], i, axis=-1),
                np.delete(int_sym_measurements[:, :, i], i, axis=-1),
                intervention_col,
                np.delete(labels, i),
                rng,
            )
            figures.append(fig)

        # Save figures
        for i, fig in enumerate(figures):
            colname = (
                "".join(c for c in labels[i] if c.isalnum() or c == " ")
                .lower()
                .replace(" ", "_")
            )
            filename = f"{self.delta_str}_{covariate_flag}_{colname}.pdf"
            fig.savefig(self.output_dir / filename, bbox_inches="tight")


def intervention_collective_effect_plot(
    int_asym_measurements: npt.NDArray[np.int64],
    int_sym_measurements: npt.NDArray[np.int64],
    intervention_label: np.str_,
    intervention_labels: npt.NDArray[np.str_],
    rng: np.random.Generator,
) -> plt.Figure:
    fig, ax = plt.subplots(figsize=(5, 3), constrained_layout=True)

    asym_mean, asym_lo, asym_hi = bootstrap_collective_effect(
        int_asym_measurements, rng
    )
    sym_mean, sym_lo, sym_hi = bootstrap_collective_effect(int_sym_measurements, rng)

    sort_idxes = np.argsort(sym_mean)[::-1]
    intervention_labels = intervention_labels[sort_idxes]
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
            "Collective effect": np.concat((sym_mean, asym_mean)),
            "CI low": np.concat((sym_lo, asym_lo)),
            "CI high": np.concat((sym_hi, asym_hi)),
        }
    )

    # Plot effect sizes as barplot per target, with bars coloured by symm/asymm
    sns.barplot(
        plot_df,
        x="Intervention",
        y="Collective effect",
        hue="Model",
        ax=ax,
    )

    # Set ylim bounds to closest 0.05 below/above min and max
    data_ymin = plot_df.select(pl.col("Collective effect").min()).item()
    data_ymax = plot_df.select(pl.col("Collective effect").max()).item()
    candidates = np.linspace(0.0, 1.0, 21)
    ymin = candidates[max(0, np.argmax(candidates > data_ymin) - 1)]
    ymax = candidates[np.argmax(candidates >= data_ymax)]
    if ymin == ymax:
        if ymin < 0.05:
            ymax = 0.05
        elif ymin > 0.95:
            ymin = 0.95
        else:
            ymin -= 0.025
            ymax += 0.025
    # ax.set_ylim(ymin, ymax)

    # Show CIs as whiskers
    x = np.arange(n - 1)
    WIDTH = 0.4
    for j, model in enumerate(["Symmetric", "Asymmetric"]):
        subset_df = plot_df.filter(Model=model)
        offset = -WIDTH / 2 if j == 0 else WIDTH / 2

        ax.errorbar(
            x + offset,
            subset_df["Collective effect"],
            yerr=[
                subset_df["Collective effect"] - subset_df["CI low"],
                subset_df["CI high"] - subset_df["Collective effect"],
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
    ax.set_title(
        f"Collective effect of interventions targeting '{intervention_label}'",
        pad=30,
    )

    return fig

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


def bootstrap_mean_effects(measurements, rng, n_boot=100):
    # measurements: shape (n_individuals, repeats, n_interventions)
    M, _, N = measurements.shape
    boot_means = np.empty((n_boot, N))

    for b in range(n_boot):
        sample_rows = rng.integers(0, M, M)
        samples = measurements[sample_rows]

        # Calculate mean change in outcome across individuals and repeats
        boot_means[b] = samples.mean(axis=(0, 1))

    mean = boot_means.mean(axis=0)
    # ci = z * boot_means.std(axis=0, ddof=1) / np.sqrt(n_boot)
    # lower = mean - ci
    # upper = mean + ci

    lower, upper = np.percentile(boot_means, (5, 95), axis=0)

    # Calculate directly as mean (over repeats) average (over people) effects
    # and spread.
    avg_effect = measurements.mean(axis=0)
    mean = avg_effect.mean(axis=0)
    lower, upper = np.percentile(avg_effect, (5, 95), axis=0)

    return mean, lower, upper


class InterventionMeanEffectsPlotCommand(BaseCommand):
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

        no_int_asym_data = np.load(
            self.data_dir / f"ising_00_{covariate_flag}.npz",
        )
        int_asym_data = np.load(
            self.data_dir / f"ising_{self.delta_str}_{covariate_flag}.npz",
        )
        no_int_sym_data = np.load(
            self.data_dir / f"sym_ising_00_{covariate_flag}.npz",
        )
        int_sym_data = np.load(
            self.data_dir / f"sym_ising_{self.delta_str}_{covariate_flag}.npz",
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
        int_effect_asym = int_asym_measurements - no_int_asym_measurements
        int_effect_sym = int_sym_measurements - no_int_sym_measurements

        # Create plot for each choice of intervention column
        N = int_effect_sym.shape[-1]
        rng = np.random.default_rng(self.seed)
        labels = int_asym_data["labels"]
        figures = []
        for i in range(N):
            intervention_col = labels[i]
            fig = intervention_effect_plot(
                np.delete(int_effect_asym[..., i], i, axis=-1),
                np.delete(int_effect_sym[..., i], i, axis=-1),
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
            filename = f"{self.delta_str}_{covariate_flag}_{colname}"
            fig.savefig(self.output_dir / f"{filename}.pdf", bbox_inches="tight")
            fig.savefig(self.output_dir / f"{filename}.png", bbox_inches="tight")


def intervention_effect_plot(
    int_effect_asym: npt.NDArray[np.float64],
    int_effect_sym: npt.NDArray[np.float64],
    intervention_label: np.str_,
    target_labels: npt.NDArray[np.str_],
    rng: np.random.Generator,
) -> plt.Figure:
    fig, ax = plt.subplots(figsize=(5, 3), constrained_layout=True)

    asym_mean, asym_lo, asym_hi = bootstrap_mean_effects(int_effect_asym, rng)
    sym_mean, sym_lo, sym_hi = bootstrap_mean_effects(int_effect_sym, rng)

    sort_idxes = np.argsort(sym_mean)[::-1]
    target_labels = target_labels[sort_idxes]
    sym_mean = sym_mean[sort_idxes]
    sym_lo = sym_lo[sort_idxes]
    sym_hi = sym_hi[sort_idxes]
    asym_mean = asym_mean[sort_idxes]
    asym_lo = asym_lo[sort_idxes]
    asym_hi = asym_hi[sort_idxes]

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
        np.arange(n - 1), target_labels, rotation=30, horizontalalignment="right"
    )

    # Turn off axis spines
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    # Set title
    ax.set_title(f"Effects of intervening on '{intervention_label}'", pad=30)

    return fig

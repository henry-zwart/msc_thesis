from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
import seaborn as sns

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl


def main(labels: npt.NDArray[np.str_], data_dir: Path):
    null_measurements_asym = np.load(data_dir / "ising_00.npz")["measurements"][
        ..., 5, :, 7
    ]
    null_measurements_sym = np.load(data_dir / "sym_ising_00.npz")["measurements"][
        ..., 5, :, 7
    ]
    collective_effect = []
    for delta in ("05", "10", "25"):
        measurements_asym = np.load(data_dir / f"ising_{delta}.npz")["measurements"][
            ..., 5, :, 7
        ]
        measurements_sym = np.load(data_dir / f"sym_ising_{delta}.npz")["measurements"][
            ..., 5, :, 7
        ]
        asym_effect = measurements_asym - null_measurements_asym
        sym_effect = measurements_sym - null_measurements_sym
        effect_of_asymmetry = asym_effect - sym_effect
        collective_effect.append(effect_of_asymmetry.mean(axis=1))
    collective_effect = np.asarray(collective_effect)

    fig, ax = plt.subplots(figsize=(4.5, 2.75), constrained_layout=True)

    mean_collective_effect = collective_effect.mean(axis=1)
    sort_idx = np.argsort(mean_collective_effect[0])[::-1]

    means = mean_collective_effect[:, sort_idx]
    plot_labels = labels[sort_idx]

    plot_df = (
        pl.DataFrame(means.T, schema=["Weak", "Medium", "Strong"])
        .with_columns(Spin=plot_labels)
        .unpivot(
            index="Spin", variable_name="Scenario", value_name="Effect of Asymmetry"
        )
    )

    sns.barplot(plot_df, x="Spin", y="Effect of Asymmetry", hue="Scenario", ax=ax)
    ax.set_xticks(
        np.arange(len(plot_labels)),
        plot_labels,
        rotation=45,
        horizontalalignment="right",
    )

    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)
    ax.set_ylabel("Effect of asymmetry")

    # Replace seaborn legend with a prettier one
    old_leg = ax.get_legend()
    handles = old_leg.legend_handles  # ty: ignore
    leg_labels = [t.get_text() for t in old_leg.texts]  # ty: ignore

    old_leg.remove()  # ty: ignore

    ax.legend(
        handles,  # ty: ignore
        leg_labels,
        ncol=3,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.0),
        frameon=False,
    )

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/asymmetry_results/effect_of_asymmetry_climate_action.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    DATA_PATH = Path("reports/thesis/results/data/model/all_interventions/")
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(
        config, name="reduced_no_imputation", with_imputation=False, verbose=False
    )
    schema = schema.post_index()
    survey_cols = schema.get_cols("survey")
    labels = schema.get_short_names("measurement")

    main(np.asarray(labels), DATA_PATH)

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import seaborn as sns

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl


def main(labels: npt.NDArray[np.str_], data_dir: Path):
    point_of_intervention_idxes = [4, 2, 5]
    null_measurements_asym = np.load(data_dir / "ising_00.npz")["measurements"][
        ..., 5, point_of_intervention_idxes, :
    ]
    null_measurements_sym = np.load(data_dir / "sym_ising_00.npz")["measurements"][
        ..., 5, point_of_intervention_idxes, :
    ]
    delta_str = "25"
    measurements_asym = np.load(data_dir / f"ising_{delta_str}.npz")["measurements"][
        ..., 5, point_of_intervention_idxes, :
    ]
    measurements_sym = np.load(data_dir / f"sym_ising_{delta_str}.npz")["measurements"][
        ..., 5, point_of_intervention_idxes, :
    ]
    asym_effect = measurements_asym - null_measurements_asym
    sym_effect = measurements_sym - null_measurements_sym
    effect_of_asymmetry = asym_effect - sym_effect
    collective_effect = effect_of_asymmetry.mean(axis=1)

    fig, axes = plt.subplots(
        ncols=3, figsize=(5.77, 3), constrained_layout=True, sharey=True
    )

    colours = ["tab:blue", "tab:orange", "tab:orange"]
    for i, ax in enumerate(axes.flatten()):
        mean_collective_effect = np.delete(
            collective_effect[:, i].mean(axis=0), point_of_intervention_idxes[i]
        )
        ci = np.delete(
            1.96 * collective_effect[:, i].std(axis=0, ddof=1),
            point_of_intervention_idxes[i],
        )

        sort_idx = np.argsort(mean_collective_effect)[::-1]
        means = mean_collective_effect[sort_idx]
        ci = ci[sort_idx]
        plot_labels = np.delete(labels, point_of_intervention_idxes[i])[sort_idx]

        sns.barplot(means, ax=ax, color=colours[i])
        ax.errorbar(
            np.arange(means.size),
            means,
            yerr=[ci, ci],
            fmt="none",
            capsize=3,
            markeredgewidth=0.75,
            color="black",
        )

        ax.set_title(labels[point_of_intervention_idxes[i]])

        ax.set_xticks(
            np.arange(len(plot_labels)),
            plot_labels,
            rotation=90,
        )

        ax.spines.top.set_visible(False)
        ax.spines.right.set_visible(False)

    fig.supylabel(
        r"$\mathbb{E}[S_\text{asym} - S_\text{symm}]$",
        fontsize=12,
        y=0.7,
        ha="center",
    )
    fig.supylabel(
        "Increased effectiveness\nin asymmetric model",
        fontsize=12,
        x=-0.15,
        y=0.7,
        rotation=0,
        ha="center",
    )
    fig.supxlabel("Intervention target", fontsize=12, x=0.55)

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/asymmetry_results/outbound_effect_of_asymmetry.{ext}",
            bbox_inches="tight",
            transparent=True,
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

from __future__ import annotations

import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import scipy as sp
import seaborn as sns

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl

RANDOM_SEED = 202607181656


def main(P: npt.NDArray[np.float64], sigma: float):
    X0 = sp.stats.Normal(mu=0, sigma=1).icdf(P[:, 0]) * sigma
    X1 = sp.stats.Normal(mu=0, sigma=1).icdf(P[:, 1]) * sigma
    dX = X1 - X0

    bins = [
        [-1.5, -0.5, 0.5, 1.5],
        [-2, 0, 2],
        [-4 / 3, -2 / 3, 0, 2 / 3, 4 / 3],
        [-4 / 3, -2 / 3, 0, 2 / 3, 4 / 3],
        [-4 / 3, -2 / 3, 0, 2 / 3, 4 / 3],
        [-1.25, -0.75, -0.25, 0.25, 0.75, 1.25],
        [-1.25, -0.75, -0.25, 0.25, 0.75, 1.25],
        [-1.25, -0.75, -0.25, 0.25, 0.75, 1.25],
    ]

    diff_bins = []

    for _bins in bins:
        centres = (np.asarray(_bins[:-1]) + np.asarray(_bins[1:])) / 2
        diffs = np.asarray([centres[-1] - centres[i] for i in range(len(centres))])
        diffs = np.sort(np.concat((diffs, -diffs[:-1])))
        dx = diffs[1] - diffs[0]
        bin_edges = np.linspace(diffs[0] - dx / 2, diffs[-1] + dx / 2, diffs.size + 1)
        diff_bins.append(bin_edges)

    fig, axes = plt.subplots(
        ncols=4,
        nrows=2,
        figsize=(5, 2.3),
        constrained_layout=True,
        sharex=True,
        sharey=True,
    )
    labels = schema.post_index().get_short_names("measurement")
    for i, ax in enumerate(axes.flatten()):
        sns.histplot(
            dX[:, i],
            ax=ax,
            bins=diff_bins[i],
            stat="probability",
            shrink=0.18 * (len(diff_bins[i]) - 1) / 2,
        )

        ax.set_title(labels[i], fontsize=10)
        ax.spines.top.set_visible(False)
        ax.spines.right.set_visible(False)
        ax.set_ylim(0, 1)
        ax.set_ylabel("")

    fig.supylabel("Empirical Probability", y=0.57)
    fig.supxlabel("Change in observed state")

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/dataset/transition_probability.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    configure_mpl()

    rng = np.random.default_rng(RANDOM_SEED)

    config = Config(_env_file=".env")
    dataset = Dataset.load(
        config,
        name="reduced_no_imputation",
        with_imputation=False,
        verbose=False,
    )

    sigma_path = Path("reports/thesis/results/data/methods/binarisation_sigma.json")

    with sigma_path.open("r") as f:
        sigma = json.load(f)["sigma"]

    _, _, P, *_ = dataset.indices_to_numpy(
        kind="time-series",
        binarise=True,
        scale=sigma,
        seed=rng,
        binarisation_dist="gaussian",
    )
    main(P, sigma)

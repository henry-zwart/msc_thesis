import numpy as np
import polars as pl

import matplotlib.pyplot as plt
import seaborn as sns

from climate_attitudes.settings import Config
from climate_attitudes.dataset import Dataset


def main():
    config = Config(_env_file="../../.env")

    data = Dataset.load(config)

    pids = (
        data.participant.filter(wave_1=True, wave_2=True)
        .select("participant_id")
        .collect()
        .to_series()
        .implode()
    )

    resp = (
        data.response.filter(pl.col("wave") <= 2, pl.col("participant_id").is_in(pids))
        .select(
            "participant_id",
            pl.col("wave").replace_strict({1: "wave_1", 2: "wave_2"}),
            pl.col("cc1").replace({1: 2, 99: 1}),
            "cvcc4_should",
            pl.col("cc5_world").replace(99, None),
            "cc6",
        )
        .filter(pl.all_horizontal(pl.all().is_not_null()))
        .with_columns(pl.len().over("participant_id").alias("n_waves"))
        .filter(n_waves=2)
        .drop("n_waves")
        .with_columns(
            pl.col("cc1") / 2,
            (pl.col("cvcc4_should") - 1) / 4,
            (pl.col("cc5_world") - 1) / 3,
            (pl.col("cc6") - 1) / 3,
        )
        .collect()
    )

    corr = (
        resp
        # .filter(wave="wave_2")
        .drop("participant_id", "wave")
        .to_pandas()
        .corr()
    )

    # Generate a mask for the upper triangle
    mask = np.triu(np.ones_like(corr, dtype=bool))

    # Set up the matplotlib figure
    fig, axe = plt.subplots(figsize=(8, 6))

    # Generate a custom diverging colormap
    cmap = sns.diverging_palette(230, 20, as_cmap=True)

    # Draw the heatmap with the mask and correct aspect ratio
    sns.heatmap(
        corr,
        mask=mask,
        cmap=cmap,
        annot=True,
        vmin=0,
        vmax=1,
        center=0,
        square=True,
        linewidths=0.5,
        cbar_kws={"shrink": 0.5},
        axe=axe,
    )

    labels = ["CC Happening", "CC Anthropogenic (proxy)", "CC Worry", "Future gen harm"]
    axe.set_xticks(
        np.arange(3) + 0.5, labels=labels[:-1], rotation=30, horizontalalignment="right"
    )
    axe.set_yticks(np.arange(1, 4) + 0.5, labels=labels[1:], rotation=0)

    fig.savefig("figures/lee_correlations.pdf", bbox_inches="tight", dpi=300)


if __name__ == "__main__":
    main()

import numpy as np
import polars as pl
import polars.selectors as cs

import matplotlib.pyplot as plt
import seaborn as sns


from climate_attitudes.settings import Config
from climate_attitudes.dataset import Dataset


def main():
    config = Config(_env_file="../../.env")

    data = Dataset.load(config)
    pids = (
        data.participant.filter("wave_2", "wave_3", "wave_4")
        .select("participant_id")
        .collect()
        .to_series()
        .implode()
    )
    question_cols = pl.exclude("participant_id", "wave")

    df_23 = (
        data.response.filter(pl.col("participant_id").is_in(pids))
        .filter(pl.col("wave").is_in([2, 3]))
        .select(
            "participant_id",
            "wave",
            "cc1",
            "cc2",
            pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$"),
            "cc10",
            "cc12",
            "cvcc_worryothers",
            "ew5",
            "ew6",
            "cc6",
            "cc11",
            # "cvcc2b",
            # "pol_interest",
            "pol_party",
            "pol_ideology",
            "ccCompensation",
            # "Variant_ccCompensation",
            "ccSolving",
            # "Variant_ccSolving",
            "pol_vote_support",
            # "Group_pol_vote_support",
            "cc_ica",
            "cc_pol_tax",
            "cc_pol_car",
            "cvcc4_personal",
            "cvcc4_should",
            "cvcc6",
            "pol4",
            "pol7",
            "pol9",
            "pol11",
        )
        .with_columns(
            pl.col("cc2")
            .is_in(["Human activities", "Both"])
            .cast(int)
            .alias("cc2_anthropogenic"),
            pl.col("cc2")
            .is_in(["Natural causes", "Both"])
            .cast(int)
            .alias("cc2_natural_causes"),
        )
        .drop(pl.col("cc2"))
        .filter(
            pl.all_horizontal(pl.all().is_not_null()),
            pl.all_horizontal(pl.col(r"^cc4_.*$") != 99),
        )
        .with_columns(pl.len().over("participant_id").alias("n_waves"))
        .filter(n_waves=2)
        .drop("n_waves")
        .with_columns(pl.col("cc1").replace({99: 1, 1: 2}))
        .with_columns(cs.enum().cast(int))
        # Re-code pol\d columns such that liberal view is higher
        .with_columns(
            -pl.col("pol4", "pol9", "pol11"),
        )
        .with_columns(
            (question_cols - question_cols.min())
            / (question_cols.max() - question_cols.min())
        )
    ).collect()

    corr = df_23.filter(wave=2).select(question_cols).to_pandas().corr()

    # Generate a mask for the upper triangle
    mask = np.triu(np.ones_like(corr, dtype=bool))

    # Set up the matplotlib figure
    fig, axe = plt.subplots(figsize=(17, 17))

    # Generate a custom diverging colormap
    cmap = sns.diverging_palette(230, 20, as_cmap=True)

    # Draw the heatmap with the mask and correct aspect ratio
    sns.heatmap(
        corr,
        mask=mask,
        cmap=cmap,
        fmt=".1f",
        annot=True,
        # vmin=-0.25,
        # vmax=0.25,
        center=0,
        square=True,
        linewidths=0.5,
        cbar_kws={"shrink": 0.5},
        axe=axe,
    )

    axe.set_xticks(
        np.arange(len(corr.index) - 1) + 0.5,
        labels=corr.index[:-1],
        rotation=35,
        horizontalalignment="right",
    )
    axe.set_yticks(np.arange(1, len(corr.index)) + 0.5, labels=corr.index[1:])

    axe.set_title("Pairwise correlation")

    fig.savefig("figures/all_corr.pdf", bbox_inches="tight", dpi=300)


if __name__ == "__main__":
    main()

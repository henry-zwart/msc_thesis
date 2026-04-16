"""Plots illustrating data requirements for fitting symmetric discrete spin models."""

import matplotlib.pyplot as plt
import polars as pl
import seaborn as sns


def main():
    df = pl.read_parquet("results/data/round_trip.parquet")

    sns.relplot(
        data=df,
        x="samples",
        y="relative_entropy",
        hue="n",
        col="h_intensity",
        row="j_intensity",
        kind="line",
    )
    plt.show()

    sns.relplot(
        data=df,
        x="samples",
        y="max_prob_dist",
        hue="n",
        col="h_intensity",
        row="j_intensity",
        kind="line",
    )
    plt.show()

    sns.relplot(
        data=df,
        x="samples",
        y="max_param_dist",
        hue="n",
        col="h_intensity",
        row="j_intensity",
        kind="line",
    )
    plt.show()

    sns.relplot(
        data=df,
        x="samples",
        y="log_likelihood",
        hue="n",
        col="h_intensity",
        row="j_intensity",
        kind="line",
    )
    plt.show()

    print(df.filter(n=6, j_intensity=1.0))


if __name__ == "__main__":
    main()

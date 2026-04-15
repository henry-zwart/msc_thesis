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
        kind="line",
    )
    plt.show()


if __name__ == "__main__":
    main()

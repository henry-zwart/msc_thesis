from datetime import datetime

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import polars as pl
from matplotlib.axes import Axes

from climate_attitudes.settings import Config, RawDataFile
from climate_attitudes.visualisation import configure_mpl


def plot_errors(responses: list[list[datetime]], ax: Axes):
    ax.eventplot(
        responses,  # ty: ignore
        orientation="horizontal",
        lineoffsets=[0, 1],
        linewidth=0.05,
        linelengths=0.7,
        colors=["b", "r"],
    )

    ax.set_yticks([0, 1], labels=["Ok", "Error"])
    locator = mdates.AutoDateLocator(maxticks=6)
    ax.xaxis.set_major_locator(locator)
    ax.xaxis.set_major_formatter(mdates.ConciseDateFormatter(locator))


def main(data: pl.DataFrame):
    fig, axes = plt.subplots(
        ncols=2, figsize=(5, 1.2), sharey=True, constrained_layout=True
    )

    w2_repeating = data.filter(wave=2, participant_type="repeating")

    err_pids = (
        w2_repeating.select(
            "participant_id",
            "cc_pol_RE.research",
        )
        .filter(
            pl.col(
                "cc_pol_RE.research"
            ).is_null()  # | (pl.col("cc_pol_RE.research") == ""),
        )
        .select(pl.col("participant_id").cast(int).sort())
    )

    plot_data = w2_repeating.select(
        "StartDate", "EndDate", "participant_id"
    ).with_columns(
        pl.when(pl.col("participant_id").is_in(err_pids.to_series().implode()))
        .then(pl.lit(True))
        .otherwise(pl.lit(False))
        .alias("err")
    )

    ok_responses = [
        start_date for start_date, *_, err in plot_data.iter_rows() if not err
    ]
    err_responses = [start_date for start_date, *_, err in plot_data.iter_rows() if err]
    plot_errors([ok_responses, err_responses], axes[0])

    # Plot case where no switchpoint
    w3_new = data.filter(wave=3, participant_type="new")
    err_pids = (
        w3_new.select("participant_id", "ew1_jun")
        .filter(
            pl.col("ew1_jun").is_not_null(),
            pl.col("ew1_jun") != "",
        )
        .select(pl.col("participant_id").cast(int).sort())
    )

    plot_data = w3_new.select("StartDate", "EndDate", "participant_id").with_columns(
        pl.when(pl.col("participant_id").is_in(err_pids.to_series().implode()))
        .then(pl.lit(True))
        .otherwise(pl.lit(False))
        .alias("err")
    )

    ok_responses = [
        start_date for start_date, *_, err in plot_data.iter_rows() if not err
    ]
    err_responses = [start_date for start_date, *_, err in plot_data.iter_rows() if err]
    plot_errors([ok_responses, err_responses], axes[1])

    for ax in axes.flatten():
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)

    fig.savefig(
        "reports/thesis/results/figures/dataset/validation_switchpoints.png",
        bbox_inches="tight",
    )
    fig.savefig(
        "reports/thesis/results/figures/dataset/validation_switchpoints.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    data = (
        pl.read_parquet(RawDataFile.Waves1to5Responses.filepath(config))
        .filter(pl.col("PID").is_not_null())
        .with_columns(
            pl.col("WAVE").cast(int).alias("wave"),
            pl.col("StartDate", "EndDate").str.strptime(
                pl.Datetime, format="%-m/%-d/%y %R", strict=True
            ),
        )
        .rename({"PID": "participant_id"})
        .with_columns(pl.col("wave").min().over("participant_id").alias("wave_joined"))
        .with_columns(
            pl.when(pl.col("wave") == pl.col("wave_joined"))
            .then(pl.lit("new"))
            .otherwise(pl.lit("repeating"))
            .alias("participant_type")
        )
    )

    main(data)

from itertools import combinations

import matplotlib.pyplot as plt
import numpy as np
import polars as pl
from matplotlib.collections import LineCollection, PathCollection
from upsetplot import plot as upset_plot

from climate_attitudes.settings import Config, RawDataFile
from climate_attitudes.visualisation import configure_mpl


def load_participation_indicators(config: Config) -> pl.DataFrame:
    data_w1_to_w5 = (
        pl.read_parquet(RawDataFile.Waves1to5Responses.filepath(config))
        .filter(pl.col("PID").is_not_null())
        .with_columns(
            pl.col("WAVE").cast(int).alias("wave"),
            pl.col("PID").cast(int).alias("participant_id"),
        )
        .select("wave", "participant_id")
    )

    data_w6 = (
        pl.read_parquet(RawDataFile.Wave6Responses.filepath(config))
        .filter(pl.col("PID").is_not_null())
        .with_columns(
            pl.col("WAVE").cast(int).alias("wave"),
            pl.col("PID").cast(int).alias("participant_id"),
        )
        .select("wave", "participant_id")
    )

    data = pl.concat((data_w1_to_w5, data_w6)).with_columns(
        pl.col("wave").replace_strict({i: f"Wave {i}" for i in range(1, 7)})
    )

    indicators = (
        data.with_columns(pl.lit(True).alias("is_present"))
        .sort(by="wave")
        .pivot(on="wave", index="participant_id")
        .fill_null(False)
    )
    return indicators


def main(indicators: pl.DataFrame):
    wave_cols = [c for c in indicators.columns if c != "participant_id"]
    rows = []
    for r in range(1, len(wave_cols) + 1):
        for combo in combinations(wave_cols, r):
            count = indicators.filter(
                pl.all_horizontal([pl.col(c) for c in combo])
            ).height
            rows.append({**{c: (c in combo) for c in wave_cols}, "count": count})

    plot_data = pl.DataFrame(rows).to_pandas().set_index(wave_cols)["count"]

    fig = plt.figure(figsize=(5, 2.75), constrained_layout=True)

    plot_result = upset_plot(
        plot_data,
        sort_by="cardinality",
        sort_categories_by="-input",
        min_subset_size=1500,
        totals_plot_elements=0,
        intersection_plot_elements=4,
        # element_size=18,
        element_size=None,
        fig=fig,
    )
    matrix_axe = plot_result["matrix"]
    for collection in matrix_axe.collections:
        if isinstance(collection, PathCollection):
            collection.set_sizes(collection.get_sizes() * 0.3)
        elif isinstance(collection, LineCollection):
            collection.set_linewidth(collection.get_linewidth()[0] * 0.6)

    plot_result["intersections"].set_ylabel(None)
    plot_result["intersections"].set_title("Response count")
    plot_result["intersections"].set_yticks(np.arange(0, 7000, 2000))

    fig.savefig(
        "reports/thesis/results/figures/dataset/participation.png", bbox_inches="tight"
    )
    fig.savefig(
        "reports/thesis/results/figures/dataset/participation.pdf",
        bbox_inches="tight",
        transparent=True,
    )


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    participation_indicators = load_participation_indicators(config)
    main(participation_indicators)

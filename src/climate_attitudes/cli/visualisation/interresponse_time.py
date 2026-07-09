from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import polars as pl
import seaborn as sns
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand, normalise_raw_response_schema
from climate_attitudes.settings import RawDataFile
from climate_attitudes.visualisation import QUALITATIVE_SCHEME, configure_mpl

console = Console()


class InterResponseTimePlotCommand(BaseCommand):
    output: Path | None = None

    def cli_cmd(self) -> None:
        configure_mpl()

        # Get ordered response dates for first five, and sixth waves
        w1_to_5 = normalise_raw_response_schema(
            RawDataFile.Waves1to5Responses.scan(self.settings)
        ).collect()
        w6 = normalise_raw_response_schema(
            RawDataFile.Wave6Responses.scan(self.settings)
        ).collect()

        intervals = pl.Enum([f"W{i - 1}—W{i}" for i in range(2, 7)])
        df = pl.concat(
            [
                w1_to_5.select("participant_id", "wave", "start_date"),  # ty: ignore
                w6.select("participant_id", "wave", "start_date"),  # ty: ignore
            ]
        ).filter(pl.col("participant_id").is_not_null())
        time_deltas = (
            df.join(df, on="participant_id")
            .filter(pl.col("wave_right") == (pl.col("wave") - 1))
            .with_columns(
                time_delta=(
                    pl.col("start_date") - pl.col("start_date_right")
                ).dt.total_days()
            )
            .drop("start_date", "wave_right", "start_date_right")
            .rename({"wave": "Interval"})
            .sort(by=("Interval"))
            .with_columns((pl.col("Interval") - 2).cast(intervals).cast(pl.String))
        )

        fig, ax = plt.subplots(figsize=(5.5, 1.5), constrained_layout=True)

        sns.kdeplot(
            time_deltas,
            x="time_delta",
            hue="Interval",
            fill=True,
            common_norm=False,
            ax=ax,
            bw_adjust=2.0,
            palette=QUALITATIVE_SCHEME.colors[  # ty: ignore
                : time_deltas.select(pl.col("Interval").n_unique()).item()
            ],
        )

        handles = ax.legend_.legend_handles  # ty: ignore
        leg_labels = [t.get_text() for t in ax.legend_.get_texts()]  # ty: ignore
        ax.legend_.remove()  # ty: ignore

        ax.set_xlim(0, None)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.set_xlabel("Inter-response time (days)")

        ax.legend(
            handles,  # ty: ignore
            leg_labels,
            ncol=len(leg_labels),
            loc="lower center",
            handlelength=1,
            bbox_to_anchor=(0.5, 1.0),
            frameon=False,
        )

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
        else:
            plt.show()

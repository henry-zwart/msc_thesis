from __future__ import annotations

from datetime import timedelta
from pathlib import Path

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import polars as pl
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand, normalise_raw_response_schema
from climate_attitudes.settings import RawDataFile
from climate_attitudes.visualisation import QUALITATIVE_SCHEME, configure_mpl

console = Console()

KEY_DATES = {
    # "2020 Election": date(2020, 11, 3),
}


class ResponseEventPlotCommand(BaseCommand):
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

        combined = pl.concat(
            (w1_to_5.select("wave", "end_date"), w6.select("wave", "end_date"))
        )
        start_end_dates = combined.group_by("wave").agg(
            pl.col("end_date").min().alias("first"),
            pl.col("end_date").max().alias("last"),
        )

        response_dates = [
            [sd for sd in w1_to_5.filter(wave=wave).select("start_date").to_series()]  # ty: ignore
            for wave in range(1, 6)
        ]
        response_dates.append(
            [sd for sd in w6.filter(wave=6).select("start_date").to_series()]  # ty: ignore
        )

        fig, ax = plt.subplots(figsize=(5.5, 1.25), constrained_layout=True)
        trans = ax.get_xaxis_transform()
        for wave, dates in enumerate(response_dates, start=1):
            ax.eventplot(
                dates,
                orientation="horizontal",
                linewidth=0.05,
                linelengths=0.9,
                colors=QUALITATIVE_SCHEME.colors[wave - 1],  # ty: ignore
                zorder=1,
            )
            # Annotate each wave at its midpoint
            midpoint = (mdates.date2num(max(dates)) + mdates.date2num(min(dates))) / 2
            # median_date = mdates.date2num(list(sorted(dates))[len(dates) // 2])
            ax.annotate(
                f"W{wave}",
                (midpoint, 1.6),
                horizontalalignment="center",
                zorder=3,
                weight="bold",
            )

        # Annotate key dates
        for event, _date in KEY_DATES.items():
            x = mdates.date2num(_date)
            # Dashed connector line down to below axis
            ax.plot(
                [x, x],
                [0, -0.525],
                transform=trans,
                linestyle="dashed",
                linewidth=0.75,
                color=ax.spines["bottom"].get_edgecolor(),
                clip_on=False,
            )

            # Text below axis
            ax.annotate(
                event,
                (x, -0.55),
                xycoords=trans,
                ha="left",
                va="top",
                weight="semibold",
                fontsize=9,
                clip_on=False,
            )

        # Draw arrows denoting intervals from:
        # 1. Start of W1 until end of W3, and end of W5 until start of W6
        start_w1 = start_end_dates.filter(wave=1).select("first").item()
        start_w2 = start_end_dates.filter(wave=2).select("first").item()
        start_w4 = start_end_dates.filter(wave=4).select("first").item()
        end_w3 = start_end_dates.filter(wave=3).select("last").item()
        end_w4 = start_end_dates.filter(wave=4).select("last").item()
        end_w5 = start_end_dates.filter(wave=5).select("last").item()
        start_w6 = start_end_dates.filter(wave=6).select("first").item()
        ax.annotate(
            "(i)",
            xy=(start_w1 + timedelta(days=35), 2.3),
            fontsize=10,
            verticalalignment="bottom",
            horizontalalignment="center",
        )
        ax.annotate(
            "",
            xytext=(start_w1, 2.2),
            xy=(end_w3, 2.2),
            arrowprops=dict(arrowstyle="<->", shrinkA=0, shrinkB=0),
        )
        ax.annotate(
            "(i)",
            xy=(end_w5 + (start_w6 - end_w5) / 2, 2.3),
            fontsize=10,
            verticalalignment="bottom",
            horizontalalignment="center",
        )
        ax.annotate(
            "",
            xytext=(end_w5, 2.2),
            xy=(start_w6, 2.2),
            arrowprops=dict(arrowstyle="<->", shrinkA=0, shrinkB=0),
        )
        ax.annotate(
            "(ii)",
            xy=(start_w2 + (end_w3 - start_w2) / 2, 2.7),
            fontsize=10,
            verticalalignment="bottom",
            horizontalalignment="center",
        )
        ax.annotate(
            "",
            xytext=(start_w2, 2.6),
            xy=(end_w3, 2.6),
            arrowprops=dict(arrowstyle="<->", shrinkA=0, shrinkB=0),
        )
        ax.annotate(
            "(ii)",
            xy=(start_w4 + (end_w4 - start_w4) / 2, 2.7),
            fontsize=10,
            verticalalignment="bottom",
            horizontalalignment="center",
        )
        ax.annotate(
            "",
            xytext=(start_w4, 2.6),
            xy=(end_w4, 2.6),
            arrowprops=dict(arrowstyle="<->", shrinkA=0, shrinkB=0),
        )

        ax.set_yticks([])
        ax.set_ylim(0.4, 2.8)

        ax.set_xlabel("Survey response date")

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_visible(False)

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
        else:
            plt.show()

from __future__ import annotations
from pathlib import Path
from climate_attitudes.settings import RawDataFile
from climate_attitudes.cli.common import BaseCommand, normalise_raw_response_schema
from datetime import date

import matplotlib.pyplot as plt
import matplotlib.dates as mdates

from climate_attitudes.visualisation import configure_mpl, QUALITATIVE_SCHEME

from rich.console import Console

console = Console()

KEY_DATES = {
    "2020 Election": date(2020, 11, 3),
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

        response_dates = [
            [sd for sd in w1_to_5.filter(wave=wave).select("start_date").to_series()]  # ty: ignore
            for wave in range(1, 6)
        ]
        response_dates.append(
            [sd for sd in w6.filter(wave=6).select("start_date").to_series()]  # ty: ignore
        )

        fig, ax = plt.subplots(figsize=(6, 1.25), constrained_layout=True)
        trans = ax.get_xaxis_transform()
        for wave, dates in enumerate(response_dates, start=1):
            ax.eventplot(
                dates,
                orientation="horizontal",
                linewidth=0.05,
                linelengths=0.9,
                colors=QUALITATIVE_SCHEME.colors[wave],  # ty: ignore
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

        ax.set_yticks([])
        ax.set_ylim(0.4, 1.7)

        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_visible(False)

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
        else:
            plt.show()

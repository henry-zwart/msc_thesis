from __future__ import annotations

from datetime import date
from pathlib import Path

import polars as pl
from pydantic import BaseModel, Field
from pydantic_settings import CliPositionalArg
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.settings import RawDataFile

console = Console()


class WaveMetadata(BaseModel):
    wave: int
    response_count: int
    null_pid_count: int
    first_response_date: date
    last_response_date: date

    @classmethod
    def from_responses(cls, responses: pl.LazyFrame, wave: int) -> WaveMetadata:
        data = (
            responses.clone()
            .rename(
                {
                    "WAVE": "wave",
                    "PID": "participant_id",
                    "StartDate": "start_date",
                    "EndDate": "end_date",
                }
            )
            .with_columns(
                pl.col("wave").cast(pl.Int64),
                pl.col("participant_id").cast(pl.UInt32).alias("participant_id"),
                pl.col("start_date", "end_date").str.strptime(
                    pl.Datetime, format="%-m/%-d/%y %R", strict=True
                ),
            )
            .filter(pl.col("wave") == wave)
        )

        null_pid_count = len(data.filter(pl.col("participant_id").is_null()).collect())  # ty: ignore
        data = data.filter(pl.col("participant_id").is_not_null())
        response_count = len(data.collect())  # ty: ignore

        first_response_date, last_response_date = (
            data.select(  # ty: ignore
                pl.col("start_date").dt.date().min().alias("first_start_date"),
                pl.col("start_date").dt.date().max().alias("last_start_date"),
            )
            .collect()
            .row(0)
        )

        return cls(
            wave=wave,
            response_count=response_count,
            null_pid_count=null_pid_count,
            first_response_date=first_response_date,
            last_response_date=last_response_date,
        )


class SurveyMetadata(BaseModel):
    participant_count: int
    wave_metadata: list[WaveMetadata]
    first_response_date: date
    last_response_date: date


class DatasetInfoCommand(BaseCommand):
    output: Path | None = None

    def cli_cmd(self) -> None:
        # Load responses from first five waves, and the last wave
        w1_to_5 = RawDataFile.Waves1to5Responses.scan(self.settings)
        w6 = RawDataFile.Wave6Responses.scan(self.settings)

        # Count unique participants
        w1_to_5_pids = (
            w1_to_5.filter(pl.col("PID").is_not_null())  # ty: ignore
            .select(pl.col("PID").cast(pl.UInt32))
            .collect()
            .to_series()
        )
        w6_pids = (
            w6.filter(pl.col("PID").is_not_null())  # ty: ignore
            .select(pl.col("PID").cast(pl.UInt32))
            .collect()
            .to_series()
        )
        pid_count = len(set(w1_to_5_pids) | set(w6_pids))

        waves_metadata = [WaveMetadata.from_responses(w1_to_5, w) for w in range(1, 6)]
        waves_metadata.append(WaveMetadata.from_responses(w6, 6))

        first_response_date = waves_metadata[0].first_response_date
        last_response_date = waves_metadata[-1].last_response_date

        metadata = SurveyMetadata(
            participant_count=pid_count,
            wave_metadata=waves_metadata,
            first_response_date=first_response_date,
            last_response_date=last_response_date,
        )

        # Print, or write to file
        if self.output:
            with self.output.open("w") as f:
                f.write(metadata.model_dump_json())
        else:
            console.print(metadata)


class WaveInfoCommand(BaseCommand):
    wave: CliPositionalArg[int] = Field(ge=1, le=6)
    output: Path | None = None

    def cli_cmd(self) -> None:
        # Load wave data
        match self.wave:
            case 6:
                data = RawDataFile.Wave6Responses.scan(self.settings)
            case 1 | 2 | 3 | 4 | 5:
                data = RawDataFile.Waves1to5Responses.scan(self.settings)
            case _:
                raise RuntimeError(
                    f"Expected wave in [1,2,3,4,5,6]. Found '{self.wave}'."
                )

        metadata = WaveMetadata.from_responses(data, self.wave)

        if self.output:
            with self.output.open("w") as f:
                f.write(metadata.model_dump_json())
        else:
            console.print(metadata)

from climate_attitudes.settings import (
    Config,
    RawDataFile,
)
import polars as pl


def load_participants(config: Config) -> pl.LazyFrame:
    return RawDataFile.Waves1to5Responses.scan(config).select("participant_id", "wave")


def record_wave_joined(lf: pl.LazyFrame) -> pl.LazyFrame:
    return lf.with_columns(
        pl.col("wave").min().over("participant_id").alias("wave_joined")
    )


def add_bool_participation_indicators(lf: pl.LazyFrame) -> pl.LazyFrame:
    waves = lf.select(pl.col("wave").unique().sort()).collect().to_series()
    return (
        lf.with_columns(pl.col("wave").replace_strict({i: f"wave_{i}" for i in waves}))
        .with_columns(pl.lit(True).alias("participated"))
        .pivot(
            "wave",
            on_columns=[f"wave_{i}" for i in waves],
            index=["participant_id", "wave_joined"],
            values="participated",
            maintain_order=True,
        )
        .with_columns(pl.exclude("participant_id", "wave_joined").fill_null(False))
        .select(
            "participant_id",
            "wave_joined",
            *[f"wave_{i}" for i in waves],
        )
    )


def build_participant_table(config: Config) -> pl.DataFrame:
    participants = load_participants(config)
    participants = record_wave_joined(participants)
    participants = add_bool_participation_indicators(participants)
    return participants.collect()

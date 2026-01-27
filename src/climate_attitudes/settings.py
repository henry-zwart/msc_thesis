from enum import Enum, auto

from pathlib import Path
from typing import ClassVar
from pydantic_settings import BaseSettings, SettingsConfigDict

import polars as pl
import polars.selectors as cs

ITEM_NAME_MAP_PATH = "variable_names.parquet"


CONFIG_DICT = SettingsConfigDict(
    # Read from .env file
    env_file=("_env", ".env"),
    # We don't care about extra keys in the _env
    extra="ignore",
)


def clean_participant_schema(lf: pl.LazyFrame) -> pl.LazyFrame:
    return (
        lf
        # Replace "dots" with double underscore for Python compatibility
        .rename(lambda column_name: column_name.replace(".", "__"))
        # Manual replacements
        .rename(
            {
                "WAVE": "wave",
                "PID": "participant_id",
                "StartDate": "start_date",
                "EndDate": "end_date",
            }
        )
        .with_columns(cs.integer().cast(pl.Int64))
        .with_columns(
            pl.col("wave").cast(pl.Int64),
            pl.col("participant_id").cast(pl.Int64),
            pl.col("dem_age").cast(pl.Int64),
            pl.col("start_date", "end_date").str.strptime(
                pl.Datetime, format="%-m/%-d/%y %R", strict=True
            ),
        )
    )


class Config(BaseSettings):
    _the_config: ClassVar["Config | None"] = None

    model_config = CONFIG_DICT
    raw_assets: Path
    static_assets: Path
    built_assets: Path


class RawDataFile(Enum):
    Waves1to5Responses = auto()
    Wave6Responses = auto()
    Codebook = auto()

    def filename(self) -> Path:
        match self:
            case RawDataFile.Waves1to5Responses:
                return Path("w1w2w3w4w5_indices_weights_jul12_2022.parquet")
            case RawDataFile.Wave6Responses:
                return Path("w6_cleaned_weights_june12_2023.parquet")
            case RawDataFile.Codebook:
                return Path("Codebook_220528.xlsx")

    def filepath(self, config: Config) -> Path:
        return config.raw_assets / self.filename()

    def scan(self, config) -> pl.LazyFrame:
        match self:
            case RawDataFile.Waves1to5Responses:
                return clean_participant_schema(
                    pl.scan_parquet(self.filepath(config)).filter(
                        pl.col("PID").is_not_null(),
                    )
                )
            case _:
                raise NotImplementedError


class StaticAsset(Enum):
    Lee2025 = auto()
    ErrorItem = auto()
    ItemName = auto()
    Ideology = auto()
    ItemColumns = auto()

    def filename(self) -> Path:
        match self:
            case StaticAsset.Lee2025:
                return Path("lee_2025_items.csv")
            case StaticAsset.ErrorItem:
                return Path("error_items.csv")
            case StaticAsset.ItemName:
                return Path("variable_names.csv")
            case StaticAsset.Ideology:
                return Path("ideology_type.csv")
            case StaticAsset.ItemColumns:
                return Path("item_columns.json")

    def filepath(self, config: Config) -> Path:
        return config.static_assets / self.filename()

    def load(self, config: Config) -> pl.DataFrame:
        match self:
            case StaticAsset.ItemColumns:
                raise NotImplementedError
            case _:
                return pl.read_csv(self.filepath(config))

    def scan(self, config: Config) -> pl.LazyFrame:
        match self:
            case StaticAsset.ItemColumns:
                raise NotImplementedError
            case _:
                return pl.scan_csv(self.filepath(config))


class BuiltAsset(Enum):
    Codebook = auto()
    Wave = auto()
    Item = auto()
    Question = auto()
    ItemColumns = auto()
    Participant = auto()
    Response = auto()

    def filename(self) -> Path:
        match self:
            case BuiltAsset.Codebook:
                return Path("codebook.parquet")
            case BuiltAsset.Wave:
                return Path("wave.parquet")
            case BuiltAsset.Item:
                return Path("item.parquet")
            case BuiltAsset.Question:
                return Path("question.parquet")
            case BuiltAsset.ItemColumns:
                return Path("item_columns.parquet")
            case BuiltAsset.Participant:
                return Path("participant.parquet")
            case BuiltAsset.Response:
                return Path("response.parquet")

    def filepath(self, config: Config) -> Path:
        return config.built_assets / self.filename()

    def load(self, config: Config) -> pl.DataFrame:
        return pl.read_parquet(self.filepath(config))

    def scan(self, config: Config) -> pl.LazyFrame:
        return pl.scan_parquet(self.filepath(config))

    def write(self, df: pl.DataFrame, config: Config):
        df.write_parquet(self.filepath(config))

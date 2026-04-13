from enum import Enum, auto
from pathlib import Path
from typing import ClassVar

import polars as pl
from pydantic_settings import BaseSettings, SettingsConfigDict

ITEM_NAME_MAP_PATH = "variable_names.parquet"


CONFIG_DICT = SettingsConfigDict(
    # Read from .env file
    env_file=("_env", ".env"),
    # We don't care about extra keys in the _env
    extra="ignore",
    env_prefix="CA_",
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
                return pl.scan_parquet(self.filepath(config))
            case RawDataFile.Wave6Responses:
                return pl.scan_parquet(self.filepath(config))
            case RawDataFile.Codebook:
                return pl.read_excel(
                    RawDataFile.Codebook.filepath(config),
                    schema_overrides={
                        "Display Logic": pl.String,
                        "Randomization": pl.String,
                    },
                ).lazy()


class StaticAsset(Enum):
    Lee2025 = auto()
    ErrorItem = auto()
    ItemName = auto()
    Ideology = auto()
    ItemColumns = auto()
    ItemGroups = auto()
    Category = auto()

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
            case StaticAsset.ItemGroups:
                return Path("item_groups.csv")
            case StaticAsset.Category:
                return Path("categories.csv")

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


class InterimAsset(Enum):
    Codebook = auto()
    Wave = auto()
    Item = auto()
    Question = auto()
    ItemColumns = auto()
    Participant = auto()
    Response = auto()

    def filename(self) -> Path:
        match self:
            case InterimAsset.Codebook:
                return Path("codebook.parquet")
            case InterimAsset.Wave:
                return Path("wave.parquet")
            case InterimAsset.Item:
                return Path("item.parquet")
            case InterimAsset.Question:
                return Path("question.parquet")
            case InterimAsset.ItemColumns:
                return Path("item_columns.parquet")
            case InterimAsset.Participant:
                return Path("participant.parquet")
            case InterimAsset.Response:
                return Path("response.parquet")

    def filepath(self, config: Config) -> Path:
        return config.built_assets / "extract" / self.filename()

    def load(self, config: Config) -> pl.DataFrame:
        return pl.read_parquet(self.filepath(config))

    def scan(self, config: Config) -> pl.LazyFrame:
        return pl.scan_parquet(self.filepath(config))

    def write(self, df: pl.DataFrame, config: Config):
        df.write_parquet(self.filepath(config))

    def sink(self, lf: pl.LazyFrame, config: Config):
        lf.sink_parquet(self.filepath(config))

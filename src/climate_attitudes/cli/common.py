from pathlib import Path
import polars as pl
from pydantic_settings import (
    BaseSettings,
    SettingsConfigDict,
)
from climate_attitudes.settings import Config


class BaseCommand(BaseSettings):
    """Base command with common settings."""

    raw_assets: Path = Path("assets/raw")
    static_assets: Path = Path("assets/static")
    built_assets: Path = Path("assets/built")

    model_config = SettingsConfigDict(env_file=".env", env_prefix="CA_", extra="ignore")

    @property
    def settings(self) -> Config:
        """Get the settings."""
        return Config(
            raw_assets=self.raw_assets,
            static_assets=self.static_assets,
            built_assets=self.built_assets,
        )


def normalise_raw_response_schema(resp: pl.LazyFrame) -> pl.LazyFrame:
    return (
        resp.clone()
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
    )

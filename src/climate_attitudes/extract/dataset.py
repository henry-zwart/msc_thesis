import polars as pl
from pathlib import Path


class ClimateAttitudesDataset:
    def __init__(self, assets_dir: Path):
        self.wave = pl.read_parquet(assets_dir / "wave.parquet")
        self.item = pl.read_parquet(assets_dir / "item.parquet")
        self.question = pl.read_parquet(assets_dir / "question.parquet")
        self.participant = pl.read_parquet(assets_dir / "participant.parquet")
        self.response = pl.read_parquet(assets_dir / "response.parquet")
        self.question_response = pl.read_parquet(
            assets_dir / "question_response.parquet"
        )

    def wave_participants(self, waves: int | list[int]) -> pl.DataFrame:
        """Select participants who responded to all of the specified waves."""
        if isinstance(waves, int):
            waves = [waves]

        return self.participant.filter(
            pl.all_horizontal(*[f"wave_{w}" for w in waves])
        ).select(pl.col("participant_id").unique())

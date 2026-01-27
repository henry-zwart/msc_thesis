from climate_attitudes.settings import (
    Config,
    StaticAsset,
    BuiltAsset,
)
import polars as pl


def load_items(config: Config) -> pl.LazyFrame:
    """Select the unique survey items.

    NOTE: For now 'item' is synonymous with 'Variable name' in the codebook.
    However, this is imperfect since it does not account for item variations based
    on experiment condition.
    """
    codebook = BuiltAsset.Codebook.scan(config)
    return (
        codebook.select(
            pl.col("item_name").alias("name"),
            "codebook_name",
        )
        # NOTE: Category column is unimplemented, so currently null
        # This column is intended to distinguish experience/belief/attitude/... items
        .with_columns(pl.lit(None, dtype=pl.String).alias("category"))
        .unique(maintain_order=True)
    )


def _label_demographic_items(items: pl.LazyFrame) -> pl.LazyFrame:
    return items.with_columns(
        pl.col("name").str.starts_with("dem_").alias("is_demographic")
    )


def _label_error_items(items: pl.LazyFrame, config: Config) -> pl.LazyFrame:
    error_items = StaticAsset.ErrorItem.scan(config)
    return items.join(
        error_items.with_columns(pl.lit(True).alias("has_error")),
        on="name",
        how="left",
        maintain_order="left",
    ).with_columns(pl.col("has_error").fill_null(False))


def _label_ideology_items(items: pl.LazyFrame, config: Config) -> pl.LazyFrame:
    ideology = StaticAsset.Ideology.scan(config)
    return items.join(
        ideology,
        on="name",
        how="left",
        maintain_order="left",
    ).with_columns(pl.col(r"^ideology_.*$").fill_null(False))


def _label_lee_2025_items(items: pl.LazyFrame, config: Config) -> pl.LazyFrame:
    lee_2025 = StaticAsset.Lee2025.scan(config)
    return items.join(
        lee_2025,
        on="name",
        how="left",
        maintain_order="left",
    ).with_columns(pl.col(r"^lee_2025_.*$").fill_null(False))


def _add_item_id(items: pl.LazyFrame) -> pl.LazyFrame:
    return items.with_row_index("item_id")


def build_item_table(config: Config) -> pl.DataFrame:
    items = load_items(config)
    items = _label_demographic_items(items)
    items = _label_error_items(items, config)
    items = _label_ideology_items(items, config)
    items = _label_lee_2025_items(items, config)
    items = _add_item_id(items)
    return items.collect()

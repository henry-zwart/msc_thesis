from climate_attitudes.settings import (
    Config,
    RawDataFile,
    StaticAsset,
)
import polars as pl


def _fix_schema(codebook: pl.DataFrame) -> pl.DataFrame:
    return codebook.rename(
        lambda column_name: column_name.lower().replace(" ", "_")
    ).rename(
        {
            "response_format": "response_type",  # I find these column names a little less ambiguous
            "response_fields": "response_schema",
            "wave_1": "w1_new",  # All participants are new in wave 1
            "wave_2_new": "w2_new",
            "wave_2_rep": "w2_rep",
            "wave_3_new": "w3_new",
            "wave_3_rep": "w3_rep",
            "wave_4_new": "w4_new",
            "wave_4_rep": "w4_rep",
            "wave_5_new": "w5_new",
            "wave_5_rep": "w5_rep",
        }
    )


def _normalise_item_names(codebook: pl.DataFrame, config: Config) -> pl.DataFrame:
    item_name_map = StaticAsset.ItemName.load(config)
    return (
        codebook.rename({"variable_name": "codebook_name"})
        .join(
            item_name_map.select("codebook_name", "item_name"),
            on="codebook_name",
            how="left",
        )
        .with_columns(pl.col("item_name").str.replace_all(".", "__", literal=True))
    )


def _convert_waves_to_bool(codebook: pl.DataFrame) -> pl.DataFrame:
    return codebook.with_columns(
        pl.col(r"^w\d_.*$").replace_strict(
            {"N/A": False, "ERROR": False, "X": True}, return_dtype=pl.Boolean
        )
    )


def _reorder_columns(codebook: pl.DataFrame) -> pl.DataFrame:
    return codebook.select(
        "codebook_name",
        "item_name",
        "question_text",
        "response_type",
        "response_schema",
        "display_logic",
        "response_requirements",
        "randomisation",
        "w1_new",
        "w2_new",
        "w2_rep",
        "w3_new",
        "w3_rep",
        "w4_new",
        "w4_rep",
        "w5_new",
        "w5_rep",
        "note",
    )


def build_codebook(config: Config) -> pl.DataFrame:
    codebook = pl.read_excel(
        RawDataFile.Codebook.filepath(config),
        schema_overrides={"Display Logic": pl.String, "Randomisation": pl.String},
    )
    codebook = _fix_schema(codebook)
    codebook = _normalise_item_names(codebook, config)
    codebook = _convert_waves_to_bool(codebook)
    codebook = _reorder_columns(codebook)

    # Ensure all items have column names
    assert codebook.filter(pl.col("item_name").is_null()).is_empty(), (
        "Some codebook items have no associated column name"
    )

    return codebook

from climate_attitudes.schema.extract import (
    OutputResponseSchema,
    ClimateAttitudesNullResponses,
    ParticipantType,
    ConditionalColumns,
)
import polars as pl
import polars.selectors as cs
from climate_attitudes.settings import Config, RawDataFile, InterimAsset

from pandera.typing.polars import DataFrame
import pandera.polars as pa


def remove_null_pids(lf: pl.LazyFrame) -> pl.LazyFrame:
    return lf.filter(pl.col("PID").is_not_null())


def clean_schema(lf: pl.LazyFrame) -> pl.LazyFrame:
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
            pl.col("participant_id").cast(pl.UInt32),
            pl.col("dem_age").cast(pl.Int64),
            pl.col("start_date", "end_date").str.strptime(
                pl.Datetime, format="%-m/%-d/%y %R", strict=True
            ),
        )
    )


def filter_columns(lf: pl.LazyFrame) -> pl.LazyFrame:
    # Get list of columns from schema
    schema_cols = list(OutputResponseSchema.build_schema_().columns.keys())

    # Filter down to those that are in the data (i.e., not result of transform)
    lf_cols = set(lf.collect_schema().names())
    keep_cols = [col for col in schema_cols if col in lf_cols]

    # Return data with only those cols included
    return lf.select(*keep_cols)


def split_multichoice_strings(lf: pl.LazyFrame, config: Config) -> pl.LazyFrame:
    multichoice_columns = (
        InterimAsset.Question.scan(config)
        .filter(
            pl.col("response_type") == "Multiple response",
            pl.col("item_name").is_in(lf.collect_schema().names()),
        )
        .select("item_name")
        .unique()
        .collect()
        .to_series()
    )
    return lf.with_columns(
        pl.col(multichoice_columns)
        .replace("", None)
        .str.split(",")
        .list.eval(pl.element().cast(pl.Int64))
    )


def clean_text_fields(lf: pl.LazyFrame, config: Config) -> pl.LazyFrame:
    TEXT_COL_REGEX = r"^.*_TEXT$"
    text_columns = (
        InterimAsset.Question.scan(config)
        .filter(pl.col("response_type") == "Text")
        .select("item_id")
        .unique()
        .join(InterimAsset.ItemColumns.scan(config), on="item_id", how="left")
        .filter(pl.col("column_name").is_in(lf.collect_schema().names()))
        .select("column_name")
        .collect()
        .to_series()
    )
    return lf.with_columns(
        pl.col(*text_columns, TEXT_COL_REGEX).str.strip_chars().replace("", None)
    )


def load_w1_to_5_response_data(config: Config) -> pl.LazyFrame:
    lf = RawDataFile.Waves1to5Responses.scan(config)

    # Normalise column names; coerce specialised data types
    lf = clean_schema(lf)

    # Filter out null-id participants
    lf = lf.filter(pl.col("participant_id").is_not_null())

    # Select only those columns that we validate in the Output schema
    lf = filter_columns(lf)

    # Column transformations
    lf = split_multichoice_strings(lf, config)
    lf = clean_text_fields(lf, config)

    return lf


def add_response_id(lf: pl.LazyFrame) -> pl.LazyFrame:
    return lf.with_row_index("response_id")


def add_participant_type(lf: pl.LazyFrame) -> pl.LazyFrame:
    """For each response, add indicator for whether participant is new or repeating."""
    return (
        lf.with_columns(
            pl.col("wave").min().over("participant_id").alias("wave_joined")
        )
        .with_columns(
            pl.when(pl.col("wave_joined") == pl.col("wave"))
            .then(pl.lit("new"))
            .otherwise(pl.lit("repeating"))
            .cast(ParticipantType)
            .alias("participant_type")
        )
        .drop("wave_joined")
    )


def reorder_columns(lf: pl.LazyFrame) -> pl.LazyFrame:
    schema_cols = list(OutputResponseSchema.build_schema_().columns.keys())
    return lf.select(*schema_cols)


def cast_group_cols_to_bool(lf: pl.LazyFrame) -> pl.LazyFrame:
    lf = lf.collect()
    for column in ConditionalColumns.group_columns():
        lf = lf.with_columns(
            # Filter to rows where question shown; some treatment is true
            pl.when(column.condition())
            # Replace treatment class Null/1 indicators with bool False/True
            .then(pl.col(column.name).is_not_null())
        )
    return lf.lazy()


@pa.check_types
def build_response_table(
    config: Config,
) -> DataFrame[OutputResponseSchema]:
    response = load_w1_to_5_response_data(config)
    response = add_response_id(response)
    response = add_participant_type(response)
    ClimateAttitudesNullResponses.validate(response, config)

    response = cast_group_cols_to_bool(response)

    response = reorder_columns(response)
    # Coalesce experiment condition columns
    # response = ExperimentConditions(EXPERIMENT_CONDITION_COLUMNS).coalesce(response)
    return response.collect()

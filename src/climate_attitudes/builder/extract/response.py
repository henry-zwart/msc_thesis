from climate_attitudes.schema.extract import (
    OutputResponseSchema,
    ClimateAttitudesNullResponses,
    ParticipantType,
)
import polars as pl
import polars.selectors as cs
from climate_attitudes.settings import Config, RawDataFile

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


def nullify_empty_strings(lf: pl.LazyFrame) -> pl.LazyFrame:
    cols = [
        "dem_male_77_TEXT",
        "ew1",
        "ew1_apr",
        "ew1_jun",
        "ew1_nov",
        "attr_storm_6_TEXT",
        "attr_outage_13_TEXT",
        "cc13",
        "cc13_apr",
        "cvcc8a__opp",
        "cvcc8a__supp",
        "cvcc8a__opp_6_TEXT",
        "cvcc8a__supp_8_TEXT",
        "cv__priority_7_TEXT",
        "cv__priority2_7_TEXT",
    ]
    return lf.with_columns(
        pl.col(cols).replace("", None),
    )


def split_multichoice_strings(lf: pl.LazyFrame) -> pl.LazyFrame:
    cols = [
        "ew1",
        "ew1_apr",
        "ew1_jun",
        "ew1_nov",
        "attr_storm",
        "attr_outage",
        "cc13",
        "cc13_apr",
        "cc_policybenefit",
        "cvcc8a__opp",
        "cvcc8a__supp",
    ]
    return lf.with_columns(
        pl.col(cols).str.split(",").list.eval(pl.element().cast(pl.Int64))
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
    lf = nullify_empty_strings(lf)
    lf = split_multichoice_strings(lf)

    # Validate schema
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


@pa.check_types
def build_response_table(
    config: Config,
) -> DataFrame[OutputResponseSchema]:
    response = load_w1_to_5_response_data(config)
    response = add_response_id(response)
    response = add_participant_type(response)
    ClimateAttitudesNullResponses.validate(response, config)

    response = reorder_columns(response)

    # TODO: After null checks, cast Group columns to bool
    #        - We will also need to update the schema to reflect this.

    # Coalesce experiment condition columns
    # response = ExperimentConditions(EXPERIMENT_CONDITION_COLUMNS).coalesce(response)
    return response.collect()

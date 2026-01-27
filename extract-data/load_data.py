"""Loads climate attitudes data from flat file into a database (currently a collection
of parquets/Polars DataFrames)."""

from pathlib import Path

import argparse

import polars as pl


def main(assets_dir: Path, static_assets_dir: Path, codebook_path: Path):
    data = pl.read_parquet(
        assets_dir / "building" / "w1w2w3w4w5_indices_weights_jul12_2022.parquet"
    )

    lee_2025_items = pl.read_parquet(static_assets_dir / "lee_2025_items.parquet")
    ideology_type = pl.read_parquet(static_assets_dir / "ideology_type.parquet")
    error_items = pl.read_parquet(static_assets_dir / "error_items.parquet")
    variable_names = pl.read_parquet(static_assets_dir / "variable_names.parquet")

    codebook = (
        pl.read_excel(codebook_path)
        .with_columns(pl.col("Variable name").alias("codebook_name"))
        # Retrieve column names
        .join(
            variable_names.select("codebook_name", "column_name"),
            on="codebook_name",
            how="left",
        )
    )

    # Ensure all items have column names
    assert codebook.filter(pl.col("column_name").is_null()).is_empty(), (
        "Some codebook items have no associated column name"
    )

    # Add "item_id" column to codebook, with unique id for each unique variable name
    # NOTE: See note below about item name <--> variable name
    codebook = codebook.join(
        (
            codebook.select(pl.col("column_name").unique(maintain_order=True))
            .clone()
            .with_row_index("item_id")
        ),
        how="left",
        on="column_name",
    )

    # == Construct 'Item' table
    # While questions vary between waves/experimental conditions, the item is the stationary
    #   concept which the question assesses.
    # NOTE: For now set the item name as the "variable name" (imperfect, since doesn't
    #   handle varying-condition questions).

    wave = pl.DataFrame({"id": [1, 2, 3, 4, 5]})
    item = (
        codebook.select("item_id", "codebook_name", pl.col("column_name").alias("name"))
        # NOTE: Mock the 'category' column for now
        .with_columns(pl.lit(None, dtype=pl.String).alias("category"))
        .unique(maintain_order=True)
        # Demographic columns start with 'dem_'
        .with_columns(pl.col("name").str.starts_with("dem_").alias("is_demographic"))
        # Record items with errors
        .join(
            error_items.with_columns(pl.lit(True).alias("has_error")),
            on="name",
            how="left",
        )
        .with_columns(pl.col("has_error").fill_null(False))
        # Record ideology types for political support items
        .join(ideology_type, on="name", how="left")
        .with_columns(pl.col(r"^ideology_.*$").fill_null(False))
        # Record correspondence with factors from Lee et al. (2025)
        .join(lee_2025_items, on="name", how="left")
        .with_columns(pl.col(r"^lee_2025_.*$").fill_null(False))
    )

    # == Construct 'Question' table
    question = (
        codebook
        # 1. Select relevant columns
        .select(
            pl.col("item_id"),
            pl.col("column_name").alias("item_name"),
            pl.col("Question text").alias("question_text"),
            pl.col("Response format").alias("response_type"),
            pl.col("Response fields").alias("response_schema"),
            # Wave specifications
            pl.col("Wave 1").alias("w1_new"),  # All participants are new in wave 1
            pl.col("Wave 2 NEW").alias("w2_new"),
            pl.col("Wave 2 REP").alias("w2_rep"),
            pl.col("Wave 3 NEW").alias("w3_new"),
            pl.col("Wave 3 REP").alias("w3_rep"),
            pl.col("Wave 4 NEW").alias("w4_new"),
            pl.col("Wave 4 REP").alias("w4_rep"),
            pl.col("Wave 5 NEW").alias("w5_new"),
            pl.col("Wave 5 REP").alias("w5_rep"),
        )
        .with_row_index("codebook_row_id")
        # 2. Tag with experimental condition (if necessary)
        #    NOTE: Currently not implemented.
        .with_columns(pl.lit(None, dtype=pl.Int64).alias("condition_id"))
        # 3. Remap wave occurrence to True/False
        .with_columns(
            pl.col("^w.*$").replace_strict(
                {"N/A": False, "ERROR": False, "X": True}, return_dtype=pl.Boolean
            )
        )
        # 4. Melt by wave occurrence and drop any False rows
        .unpivot(
            index=[
                "codebook_row_id",
                "item_id",
                "item_name",
                "question_text",
                "condition_id",
                "response_type",
                "response_schema",
            ],
            value_name="in_wave",
            variable_name="wave_present",
        )
        .filter(pl.col("in_wave"))
        .drop(pl.col("in_wave"))
        # 5. Create question presence columns for returning and/or new participants
        # First create column with list of conditions (new/rep) for each question and wave
        .with_columns(
            # Extract wave number
            pl.col("wave_present")
            .str.extract(r"^w(\d).*$", 1)
            .cast(pl.Int64)
            .alias("wave"),
            # Extract condition for presence (new or rep[eating])
            pl.col("wave_present")
            .str.extract(r"^w\d_(.*)$", 1)
            .alias("question_condition"),
        )
        .group_by(pl.exclude("question_condition", "wave_present"), maintain_order=True)
        .agg(pl.col("question_condition"))
        # Then create the columns of interest
        .with_columns(
            pl.when(pl.col("question_condition").list.contains("new"))
            .then(pl.lit(True))
            .otherwise(pl.lit(False))
            .alias("new_participants"),
            pl.when(pl.col("question_condition").list.contains("rep"))
            .then(pl.lit(True))
            .otherwise(pl.lit(False))
            .alias("repeating_participants"),
        )
        # 6. Create new question id column
        .sort(by=("codebook_row_id", "wave"))
        .with_row_index("question_id")
        # 7. For each question, record the last wave that it was modified
        #    NOTE: Currently not implemented. Should combine rows with same variable name.
        .with_columns(pl.lit(1).alias("wave_last_modified"))
        # 8. Filter columns, reorder for readability
        .select(
            "question_id",
            "item_id",
            "item_name",
            "wave",
            "condition_id",
            "new_participants",
            "repeating_participants",
            "wave_last_modified",
            "response_type",
            "response_schema",
            "question_text",
        )
    )

    # == Construct 'Participant' table
    WAVE_NAME_MAP = {
        1: "wave_1",
        2: "wave_2",
        3: "wave_3",
        4: "wave_4",
        5: "wave_5",
    }
    participant = (
        data
        # Exclude null-PID individuals
        .filter(pl.col("PID").is_not_null())
        # Convert PID (float), WAVE (string) columns to int
        .select(
            pl.col("PID").cast(pl.Int64).alias("participant_id"),
            pl.col("WAVE").cast(pl.Int64),
        )
        # Calculate first wave each participant was present
        .with_columns(pl.col("WAVE").min().alias("wave_joined").over("participant_id"))
        # Pivot table to show boolean indicator for waves each participant is present
        .with_columns(
            pl.col("WAVE").replace_strict(WAVE_NAME_MAP, return_dtype=pl.String)
        )
        .with_columns(pl.lit(True).alias("present_for_wave"))
        .pivot(
            on="WAVE",
            index=["participant_id", "wave_joined"],
            values="present_for_wave",
        )
        .with_columns(pl.exclude("participant_id", "wave_joined").fill_null(False))
        # Re-order columns for readability
        .select(
            "participant_id",
            "wave_joined",
            "wave_1",
            "wave_2",
            "wave_3",
            "wave_4",
            "wave_5",
        )
    )

    # == Construct 'Response' table
    response = (
        data.filter(pl.col("PID").cast(pl.Int64).is_not_null())
        .select(
            pl.col("PID").cast(pl.Int64).alias("participant_id"),
            pl.col("WAVE").cast(pl.Int64).alias("wave"),
            pl.col("StartDate").alias("start_date"),
            pl.col("EndDate").alias("end_date"),
        )
        .with_row_index(name="response_id")
    )

    # == Construct 'QuestionResponse' table
    # TODO: Filter out rows with no matching question_id for given wave.
    #   Currently we include these rows with a null response value
    question_response = (
        data.filter(pl.col("PID").is_not_null())
        .with_columns(
            pl.col("PID").cast(pl.Int64).alias("participant_id"),
            pl.col("WAVE").cast(pl.Int64).alias("wave"),
        )
        # NOTE: Excluded because can't unpivot on list type
        # Add transform columns
        # .with_columns(cc_rank().list.join(","), cc_rank_condition())
        .unpivot(
            index=["participant_id", "wave"],
            variable_name="item_name",
            value_name="response",
        )
        # Join item to get item ids
        .join(
            item.select("item_id", pl.col("name").alias("item_name")),
            on="item_name",
            how="inner",
        )
        # Join question to get question id; exclude rows where null due to
        #   question-not-asked
        .join(
            question.select("question_id", "item_id", "wave"),
            on=["item_id", "wave"],
            how="inner",
        )
        # Join response to get response ids
        .join(
            response.select("response_id", "participant_id", "wave"),
            on=["participant_id", "wave"],
            how="left",
        )
        # Add index
        .with_row_index(name="question_response_id")
        # Re-order columns for readability
        .select(
            "question_response_id",
            "wave",
            "item_name",
            "response",
            "participant_id",
            "response_id",
            "item_id",
            "question_id",
        )
    )

    # Replace any 'dots' in item names with two underscores
    item = item.with_columns(pl.col("name").str.replace_all(".", "__", literal=True))
    question = question.with_columns(
        pl.col("item_name").str.replace_all(".", "__", literal=True)
    )
    question_response = question_response.with_columns(
        pl.col("item_name").str.replace_all(".", "__", literal=True)
    )

    # Save constructed tables at specified path
    wave.write_parquet(assets_dir / "wave.parquet")
    item.write_parquet(assets_dir / "item.parquet")
    question.write_parquet(assets_dir / "question.parquet")
    participant.write_parquet(assets_dir / "participant.parquet")
    response.write_parquet(assets_dir / "response.parquet")
    question_response.write_parquet(assets_dir / "question_response.parquet")

    # db_path = f"sqlite:///{assets_dir}/climate_attitudes.db"
    # wave.write_database("wave", connection=db_path, if_table_exists="replace")
    # item.write_database("item", connection=db_path, if_table_exists="replace")
    # question.write_database("question", connection=db_path, if_table_exists="replace")
    # participant.write_database(
    #     "participant", connection=db_path, if_table_exists="replace"
    # )
    # response.write_database("response", connection=db_path, if_table_exists="replace")
    # question_response.write_database(
    #     "question_response", connection=db_path, if_table_exists="replace"
    # )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="Load", description="Load climate attitudes dataset."
    )
    parser.add_argument("--assets-dir", type=Path)
    parser.add_argument("--static-assets-dir", type=Path)
    parser.add_argument("--codebook", type=Path)
    args = parser.parse_args()
    main(args.assets_dir, args.static_assets_dir, args.codebook)

from climate_attitudes.settings import (
    Config,
    BuiltAsset,
)
import polars as pl


def load_questions(config: Config) -> pl.LazyFrame:
    codebook = BuiltAsset.Codebook.scan(config).with_row_index("codebook_row_id")
    item_ids = BuiltAsset.Item.scan(config).select(
        "item_id", pl.col("name").alias("item_name")
    )
    return codebook.join(item_ids, on="item_name", how="left", maintain_order="left")


def unpivot_questions_by_wave(questions: pl.LazyFrame) -> pl.LazyFrame:
    return (
        # For each wave + new/repeating participant condition, record whether Q asked
        questions.unpivot(
            index=[
                "codebook_row_id",
                "item_id",
                "item_name",
                "codebook_name",
                "question_text",
                "response_type",
                "response_schema",
                "response_requirements",
                "randomisation",
                "display_logic",
                "note",
            ],
            value_name="question_present",
            variable_name="wave_column_name",
        )
        # Remove rows corresponding to question-not-asked
        .filter(pl.col("question_present"))
        .drop("question_present")
        .with_columns(
            # Extract wave number
            pl.col("wave_column_name")
            .str.extract(r"^w(\d).*$", 1)
            .cast(pl.Int64)
            .alias("wave"),
            # Extract whether Q asked to new or repeating participants
            pl.col("wave_column_name")
            .str.extract(r"^w\d_(.*)$", 1)
            .alias("participant_type"),
        )
        # For each question and wave, get list of participant types who are asked Q
        .group_by(
            pl.exclude("participant_type", "wave_column_name"),
            maintain_order=True,
        )
        .agg(pl.col("participant_type"))
        # For each Q and wave, record whether asked to new or repeating, in new columns
        .with_columns(
            pl.when(pl.col("participant_type").list.contains("new"))
            .then(pl.lit(True))
            .otherwise(pl.lit(False))
            .alias("new_participants"),
            pl.when(pl.col("participant_type").list.contains("rep"))
            .then(pl.lit(True))
            .otherwise(pl.lit(False))
            .alias("repeating_participants"),
        )
        .sort(by=("codebook_row_id", "wave"))
    )


def add_question_id(questions: pl.LazyFrame) -> pl.LazyFrame:
    return questions.with_row_index("question_id")


def reorder_columns(questions: pl.LazyFrame) -> pl.LazyFrame:
    return questions.select(
        "question_id",
        "item_id",
        "item_name",
        "codebook_name",
        "wave",
        "new_participants",
        "repeating_participants",
        # "wave_last_modified", # TODO: Implement
        "response_type",
        "response_schema",
        "question_text",
    )


def build_question_table(config: Config) -> pl.DataFrame:
    questions = load_questions(config)
    print(questions.filter(pl.col("item_name") == "cc_commit").collect())
    questions = unpivot_questions_by_wave(questions)
    questions = add_question_id(questions)
    questions = reorder_columns(questions)
    return questions.collect()

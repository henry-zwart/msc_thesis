from __future__ import annotations

import polars as pl
import polars.selectors as cs

from climate_attitudes.schema.extract import (
    EXPERIMENT_CONDITION_COLUMNS,
)
from climate_attitudes.schema import dataset as schema
from climate_attitudes.settings import Config
from climate_attitudes.data_extract import DataExtract


class Dataset:
    codebook: pl.LazyFrame
    item: pl.LazyFrame
    question: pl.LazyFrame
    columns: pl.LazyFrame
    participant: pl.LazyFrame
    response: pl.LazyFrame

    def __init__(self, config: Config):
        self.config = config

    def build(self) -> Dataset:
        """Create refined climate attitudes survey dataset.

        Extracts and validates required columns from the raw data, then
        cleans and transforms these.
        """
        # Extract and validate raw data
        extract = DataExtract(self.config).load()
        self.codebook = extract.codebook.clone()
        self.item = extract.item.clone()
        self.question = extract.question.clone()
        self.columns = extract.columns.clone()
        self.participant = extract.participant.clone()
        self.response = extract.response.clone().collect().lazy()

        # Coalesce treatment columns into (response, treatment index) pairs
        self.coalesce_treatments()

        self._reorder_columns()

        self._validate()

        return self

    def write(self):
        self.codebook.sink_parquet(self.config.built_assets / "codebook.parquet")
        self.item.sink_parquet(self.config.built_assets / "item.parquet")
        self.question.sink_parquet(self.config.built_assets / "question.parquet")
        self.columns.sink_parquet(self.config.built_assets / "columns.parquet")
        self.participant.sink_parquet(self.config.built_assets / "participant.parquet")
        self.response.sink_parquet(self.config.built_assets / "response.parquet")

    @classmethod
    def load(cls, config: Config) -> Dataset:
        ds = cls(config)
        ds.codebook = pl.scan_parquet(config.built_assets / "codebook.parquet")
        ds.item = pl.scan_parquet(config.built_assets / "item.parquet")
        ds.question = pl.scan_parquet(config.built_assets / "question.parquet")
        ds.columns = pl.scan_parquet(config.built_assets / "columns.parquet")
        ds.participant = pl.scan_parquet(config.built_assets / "participant.parquet")
        ds.response = pl.scan_parquet(config.built_assets / "response.parquet")
        ds._validate()
        return ds

    def _validate(self):
        schema.OutputCodebookSchema.validate(self.codebook)
        schema.OutputItemSchema.validate(self.item)
        schema.OutputQuestionSchema.validate(self.question)
        schema.OutputItemColumnsSchema.validate(self.columns)
        schema.OutputParticipantSchema.validate(self.participant)
        schema.OutputResponseSchema.validate(self.response)

    def _reorder_columns(self):
        # Response
        schema_cols = list(schema.OutputResponseSchema.build_schema_().columns.keys())
        if missing := set(self.response.collect_schema().names()) - set(schema_cols):
            raise RuntimeError(
                "One or more response columns are not specified in the schema:"
                f"{missing}"
            )
        self.response = self.response.select(*schema_cols)

    def coalesce_treatments(self):
        # TODO: Make optional to coalesce response columns
        # e.g., for cvcc6 and cvcc10_cc, treatment only used for one of the waves.
        #       In wave 1 both questions are shown. We want to still group the
        #       treatment index columns, but not the responses
        response = self.response.clone()
        for treatment_class in EXPERIMENT_CONDITION_COLUMNS:
            response = treatment_class.coalesce(response)

        old_columns = {
            column
            for treatment_class in EXPERIMENT_CONDITION_COLUMNS
            for column in treatment_class.required_columns
        }
        response = response.drop(old_columns)

        self.response = response

        # Remove item_id column from codebook as not useful once items changed
        self.codebook = self.codebook.drop("item_id")

        # === Replace old item table rows with coalesced treatment classes
        treatment_item_data = {
            "item_name": [],
            "treatment_group": [],
            "treatment": [],
            "variant": [],
        }
        for treatment_group in EXPERIMENT_CONDITION_COLUMNS:
            for i, treatment_col in enumerate(treatment_group.columns):
                treatment_item_data["item_name"].append(treatment_col.name)
                treatment_item_data["treatment_group"].append(treatment_group.name)
                treatment_item_data["treatment"].append(i)
                treatment_item_data["variant"].append(treatment_col.variant)
        treatment_lf = pl.DataFrame(treatment_item_data).lazy()

        # 1. Get item data for each treatment item
        treatment_items = treatment_lf.join(self.item, how="left", on="item_name")

        # 2. Drop any treatment rows from item table
        item = self.item.join(treatment_items, how="anti", on="item_id")

        # 3. Aggregate treatment items by treatment. Boolean columns with "any".
        treatment_items = (
            treatment_items.group_by("treatment_group")
            .agg(
                pl.col("item_id").min(),
                pl.col("group").first(),
                pl.col("category").first(),
                cs.boolean().any(),
            )
            .rename({"treatment_group": "item_name"})
            # Re-order columns
            .select(*self.item.collect_schema().names())
        )

        # 4. Add the coalesced treatment groups back in, and re-sort on item_id
        item = pl.concat([item, treatment_items]).sort(by="item_id").lazy()
        self.item = item

        # === Add treatment group and index to question table
        # Keep same rows. Replace item_id with new id for treatment rows.
        # Replace item name. Add treatment group column. Could treat all questions
        # as treatment with default group 0.

        # 1. Get question data for each treatment item
        treatment_questions = treatment_lf.join(
            self.question, how="left", on="item_name"
        )

        # 2. Drop any treatment rows from question table
        question = self.question.join(
            treatment_questions, how="anti", on="item_id"
        ).with_columns(pl.lit(0).alias("treatment"))

        # 3. Update treatment question data
        treatment_questions = (
            treatment_questions.with_columns(
                pl.col("item_id").min().over("treatment_group"),
                pl.col("treatment").cast(pl.Int32),
            )
            .drop("item_name")
            .rename({"treatment_group": "item_name"})
            .select(question.collect_schema().names())
        )

        # 4. Add the coalesced treatment groups back in, and re-sort
        question = (
            pl.concat([question, treatment_questions]).sort(by="question_id").lazy()
        )
        self.question = question

        # === Update `columns` table
        # Any treatment questions should be removed, and replaced with the response
        # and group columns, plus variant if applicable.

        # 1. Get columns metadata for treatment columns
        treatment_columns = treatment_lf.join(self.columns, how="left", on="item_name")

        # 2. Drop any treatment rows from columns table
        columns = self.columns.join(treatment_columns, how="anti", on="item_id")

        # 3. Determine which treatment groups have a variant column
        treatment_columns = (
            treatment_columns.group_by("treatment_group")
            .agg(
                pl.col("item_id").min(),
                pl.col("variant").is_not_null().all().alias("variant_column"),
            )
            .rename({"treatment_group": "item_name"})
        )

        # 4. Create treatment columns records, with Variant column when reqd.
        treatment_columns = (
            pl.concat(
                (
                    treatment_columns.with_columns(
                        pl.col("item_name").alias("column_name")
                    ),
                    treatment_columns.with_columns(
                        pl.concat_str([pl.lit("Group_"), pl.col("item_name")]).alias(
                            "column_name"
                        )
                    ),
                    (
                        treatment_columns.filter(variant_column=True).with_columns(
                            pl.concat_str(
                                [pl.lit("Variant_"), pl.col("item_name")]
                            ).alias("column_name")
                        )
                    ),
                )
            ).select("item_id", "item_name", "column_name")
        ).lazy()

        # 4. Add the treatment columns back into columns df, re-sort
        columns = pl.concat([columns, treatment_columns]).sort(by="item_id").lazy()
        self.columns = columns

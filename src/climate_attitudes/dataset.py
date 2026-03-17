from __future__ import annotations
from datetime import date
from climate_attitudes.schema.enums import PoliticalAffiliation, President
import json

import polars as pl
import polars.selectors as cs

from climate_attitudes.schema.extract import (
    EXPERIMENT_CONDITION_COLUMNS,
)
from climate_attitudes.schema import dataset as schema
from climate_attitudes.settings import Config
from climate_attitudes.data_extract import DataExtract
from climate_attitudes.imputation import impute_viterbi


class Dataset:
    codebook: pl.LazyFrame
    item: pl.LazyFrame
    question: pl.LazyFrame
    columns: pl.LazyFrame
    participant: pl.LazyFrame
    response: pl.LazyFrame

    validated: bool = False

    def __init__(self, config: Config):
        self.config = config

    def build(
        self,
        prune_error_participants: bool = False,
        filter_valid: bool = False,
    ) -> Dataset:
        """Create refined climate attitudes survey dataset.

        Extracts and validates required columns from the raw data, then
        cleans and transforms these.
        """
        print("Building climate attitudes dataset.")

        self.prune_survey_error_participants = prune_error_participants
        self.filter_valid = filter_valid

        if prune_error_participants:
            print("Removing participants with survey errors.")
        else:
            print("Keeping participants with survey errors.")

        if filter_valid:
            print("Removing participants who fail survey validation check in any wave.")
        else:
            print("Keeping participants who fail survey validation checks.")

        # Extract and validate raw data
        extract = DataExtract(self.config).load(prune_error_participants, filter_valid)
        self.codebook = extract.codebook.clone()
        self.item = extract.item.clone()
        self.question = extract.question.clone()
        self.columns = extract.columns.clone()
        self.participant = extract.participant.clone()
        self.response = extract.response.clone().collect().lazy()

        # Coalesce treatment columns into (response, treatment index) pairs
        self.coalesce_treatments()

        # Constructed columns
        self.construct_columns()

        self._reorder_columns()

        self._validate()

        return self

    def write(self, name: str = "base", force: bool = False):
        dir = self.config.built_assets / name
        if (dir / "metadata.json").exists() and not force:
            raise RuntimeError(
                f"Dataset already exists at path '{dir}'. Pass `force=True` to "
                f"overwrite."
            )
        elif (dir / "metadata.json").exists() and force:
            print(f"Overwriting existing dataset at path '{dir}'.")
        else:
            print(f"Creating new directory at path '{dir}'.")
            # If dir exists without metadata file, treat as partial dataset; overwrite
            dir.mkdir(parents=True, exist_ok=True)

        self.codebook.sink_parquet(dir / "codebook.parquet")
        self.item.sink_parquet(dir / "item.parquet")
        self.question.sink_parquet(dir / "question.parquet")
        self.columns.sink_parquet(dir / "columns.parquet")
        self.participant.sink_parquet(dir / "participant.parquet")
        self.response.sink_parquet(dir / "response.parquet")

        md = dict(
            prune_survey_error_participants=self.prune_survey_error_participants,
            filter_valid=self.filter_valid,
            validated=self.validated,
        )
        with (dir / "metadata.json").open("w") as f:
            json.dump(md, f)

    @classmethod
    def load(cls, config: Config, name: str = "base") -> Dataset:
        ds = cls(config)
        dir = config.built_assets / name
        if not (dir / "metadata.json").exists():
            raise FileExistsError(f"No dataset found at path '{dir}'.")

        with (dir / "metadata.json").open("r") as f:
            md = json.load(f)

        print("Loading built assets:")
        for k, v in md.items():
            print(f"  {k}={v}")

        ds.prune_survey_error_participants = md["prune_survey_error_participants"]
        ds.filter_valid = md["filter_valid"]
        ds.validated = md["validated"]

        ds.codebook = pl.scan_parquet(dir / "codebook.parquet")
        ds.item = pl.scan_parquet(dir / "item.parquet")
        ds.question = pl.scan_parquet(dir / "question.parquet")
        ds.columns = pl.scan_parquet(dir / "columns.parquet")
        ds.participant = pl.scan_parquet(dir / "participant.parquet")
        ds.response = pl.scan_parquet(dir / "response.parquet")

        if not ds.validated:
            ds._validate()

        return ds

    def clone(self) -> Dataset:
        ds = Dataset(self.config.copy())

        ds.prune_survey_error_participants = self.prune_survey_error_participants
        ds.filter_valid = self.filter_valid
        ds.validated = self.validated

        ds.codebook = self.codebook.clone()
        ds.item = self.item.clone()
        ds.question = self.question.clone()
        ds.columns = self.columns.clone()
        ds.participant = self.participant.clone()
        ds.response = self.response.clone()

        return ds

    def impute_viterbi(
        self,
        columns: list[str | pl.Expr],
        impute_waves: list[int] | None = None,
    ) -> Dataset:
        ds = self.clone()
        ds.response = impute_viterbi(
            self.response.clone().collect(),  # ty: ignore
            columns=columns,
            impute_waves=impute_waves,
        ).lazy()

        return ds

    def impute_fill(
        self,
        columns: list[pl.Expr],
    ) -> Dataset:
        ds = self.clone()
        ds.response = ds.response.with_columns(
            [col.fill_null(strategy="forward") for col in columns]
        ).with_columns([col.fill_null(strategy="backward") for col in columns])

        return ds

    def filter_columns(self, columns: list[str | pl.Expr]) -> Dataset:
        ds = self.clone()
        ds.response = self.response.select(*columns).clone()

        return ds

    def filter_at_least_one_resp(self, columns: list[str | pl.Expr]) -> Dataset:
        keep_pids = (
            self.response.select("participant_id", *columns)
            .group_by("participant_id")
            .agg(pl.all().is_not_null().any())
            .unpivot(
                index="participant_id", variable_name="column", value_name="some_full"
            )
            .group_by("participant_id")
            .agg(pl.col("some_full").all().alias("no_empty_questions"))
            .filter(pl.col("no_empty_questions"))
            .select("participant_id")
            .collect()
            .to_series()
            .implode()
        )

        ds = self.clone()
        ds.participant = self.participant.filter(
            pl.col("participant_id").is_in(keep_pids)
        ).clone()
        ds.response = self.response.filter(
            pl.col("participant_id").is_in(keep_pids)
        ).clone()

        return ds

    def transform(self, *expr: pl.Expr) -> Dataset:
        ds = self.clone()
        ds.response = self.response.clone().with_columns(*expr)

        return ds

    def cast_enum_to_int(self) -> Dataset:
        ds = self.clone()
        ds.response = self.response.with_columns(cs.enum().cast(pl.Int64)).clone()

        return ds

    def reverse_coding(self, columns: list[str | pl.Expr]) -> Dataset:
        exprs = []

        for col in columns:
            if isinstance(col, str):
                exprs.append((-pl.col(col)).alias(col))
            elif isinstance(col, pl.Expr):
                exprs.append((-col))
            else:
                raise TypeError(f"Unsupported column type: {type(col)}")

        ds = self.clone()
        ds.response = self.response.with_columns(exprs).clone()

        return ds

    def standardise(self, columns: cs.Selector | pl.Expr) -> Dataset:
        ds = self.clone()
        ds.response = self.response.with_columns(
            (columns - columns.mean()) / columns.std()
        )

        return ds

    def _validate(self):
        schema.OutputCodebookSchema.validate(self.codebook)
        schema.OutputItemSchema.validate(self.item)
        schema.OutputQuestionSchema.validate(self.question)
        schema.OutputItemColumnsSchema.validate(self.columns)
        schema.OutputParticipantSchema.validate(self.participant)
        schema.OutputResponseSchema.validate(self.response)

        self.validated = True

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

    def construct_columns(self):
        self.response = (
            self.response.with_columns(
                pl.coalesce(pl.col(r"^ew1_(apr|jun|nov)$")).alias("ew1_delta"),
                pl.coalesce(pl.col(r"^ew_attribution_(apr|jun|nov)$")).alias(
                    "ew_attribution_recent"
                ),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_phy$")).alias("ew3_phy_delta"),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_mat$")).alias("ew3_mat_delta"),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_fin$")).alias("ew3_fin_delta"),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_men$")).alias("ew3_men_delta"),
            )
            .with_columns(
                (
                    pl.when(pl.col("pol_party") != "Independent")
                    .then(pl.col("pol_party").cast(pl.String))
                    .otherwise(
                        pl.col("pol_lean")
                        .cast(pl.String)
                        .replace({"Neither": "Independent"})
                    )
                    .cast(PoliticalAffiliation)
                    .alias("pol_affiliation")
                ),
            )
            .with_columns(
                pl.when(pl.col("start_date") <= date(2021, 1, 20))
                .then(pl.lit("Trump"))
                .otherwise(pl.lit("Biden"))
                .cast(President)
                .alias("current_pres")
            )
            .drop("pol_party", "pol_lean")
        )

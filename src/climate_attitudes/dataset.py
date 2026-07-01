from __future__ import annotations

import json
import pickle
from copy import copy
from datetime import date
from typing import Any, Literal

import numpy as np
import numpy.typing as npt
import polars as pl
import polars.selectors as cs
import scipy as sp
from sklearn.decomposition import PCA
from statsmodels.multivariate.factor import FactorResults

from climate_attitudes.data_extract import DataExtract
from climate_attitudes.datasets.common import DatasetSchema
from climate_attitudes.exceptions import DatasetExistsException
from climate_attitudes.imputation import impute_viterbi
from climate_attitudes.indices import IndexMethod
from climate_attitudes.schema import dataset as schema
from climate_attitudes.schema.enums import WAVES, PoliticalAffiliation, President
from climate_attitudes.schema.extract import (
    EXPERIMENT_CONDITION_COLUMNS,
)
from climate_attitudes.settings import Config

type SpinStates = npt.NDArray[np.int64]
type Probability = npt.NDArray[np.float64]
type PIDsArray = npt.NDArray[np.int64]
type Covariates = npt.NDArray[np.float64]
type Indexes = npt.NDArray[np.int64]


class Dataset:
    codebook: pl.LazyFrame
    item: pl.LazyFrame
    question: pl.LazyFrame
    columns: pl.LazyFrame
    participant: pl.LazyFrame
    response: pl.LazyFrame
    indices: pl.LazyFrame | None = None
    index_result: (
        dict[str, PCA | FactorResults]
        | dict[str, PCA]
        | dict[str, FactorResults]
        | None
    ) = None

    schema: DatasetSchema

    metadata: dict[str, Any]

    def __init__(self, config: Config, schema: DatasetSchema):
        self.config = config
        self.metadata = dict(
            validated=False,
            has_indices=False,
            imputation=False,
        )
        self.schema = schema

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

        self.metadata["exclude_error"] = prune_error_participants
        self.metadata["exclude_invalid"] = filter_valid

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
        if self.metadata["imputation"]:
            name = f"{name}_imp"

        dir = self.config.built_assets / name
        if (dir / "metadata.json").exists() and not force:
            raise DatasetExistsException(
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

        if self.indices is not None:
            self.indices.sink_parquet(dir / "indices.parquet")
            with (dir / "index_result.pkl").open("wb") as f:
                pickle.dump(self.index_result, f)

        with (dir / "schema.json").open("w") as f:
            json.dump(self.schema.model_dump(), f)

        with (dir / "metadata.json").open("w") as f:
            json.dump(self.metadata, f)

    @classmethod
    def load(
        cls,
        config: Config,
        name: str = "base",
        with_imputation: bool = True,
        verbose: bool = True,
    ) -> Dataset:
        if with_imputation:
            name = f"{name}_imp"

        dir = config.built_assets / name
        if not (dir / "metadata.json").exists():
            raise DatasetExistsException(f"No dataset found at path '{dir}'.")

        with (dir / "schema.json").open("r") as f:
            schema = DatasetSchema.model_validate(json.load(f))

        ds = cls(config, schema)

        with (dir / "metadata.json").open("r") as f:
            ds.metadata = json.load(f)

        if verbose:
            print("Loading built assets:")
            for k, v in ds.metadata.items():
                print(f"  {k}={v}")

        ds.codebook = pl.scan_parquet(dir / "codebook.parquet")
        ds.item = pl.scan_parquet(dir / "item.parquet")
        ds.question = pl.scan_parquet(dir / "question.parquet")
        ds.columns = pl.scan_parquet(dir / "columns.parquet")
        ds.participant = pl.scan_parquet(dir / "participant.parquet")
        ds.response = pl.scan_parquet(dir / "response.parquet")
        if ds.metadata["has_indices"]:
            ds.indices = pl.scan_parquet(dir / "indices.parquet")
            with (dir / "index_result.pkl").open("rb") as f:
                ds.index_result = pickle.load(f)

        if not ds.metadata["validated"]:
            ds._validate()

        return ds

    def indices_to_numpy(
        self,
        kind: Literal["cross-sectional", "time-series"],
        binarise: bool = False,
        ternarise: bool = False,
        scale: float = 0.1,
        epsilon: float = 0.25,
        binarisation_dist: Literal["gaussian", "triangular"] = "gaussian",
        replicates: int = 1,
        bootstrap: bool = False,
        seed: int | np.random.Generator | None = None,
    ) -> tuple[SpinStates, Covariates, Probability, PIDsArray, Indexes]:
        if self.indices is None:
            raise RuntimeError("`Dataset.indices` is None")
        if binarise and ternarise:
            raise RuntimeError("At most one of `binarise`, `ternarise` may be true.")

        if isinstance(seed, np.random.Generator):
            rng = seed
        else:
            rng = np.random.default_rng(seed)

        df_data = self.indices.collect().sort(by=("participant_id", "wave"))
        match kind:
            case "cross-sectional":
                Y = df_data.select(*self.schema.get_cols("measurement")).to_numpy()
                # NOTE: Hard-coded for now because I don't want to deal with the
                # binarisation of dem_urban generically.
                X = df_data.select(
                    pl.col("dem_male"),
                    pl.col("dem_educ"),
                    pl.col("dem_income_percep"),
                    (pl.col("dem_urban") == 0).cast(int).alias("dem_urban: urban"),
                    (pl.col("dem_urban") == 1).cast(int).alias("dem_urban: suburban"),
                    (pl.col("dem_urban") == 2).cast(int).alias("dem_urban: rural"),
                ).to_numpy()
                X = (X - X.mean(axis=0)) / X.std(axis=0, ddof=1)
                pids = df_data.select("participant_id").to_numpy().flatten()
            case "time-series":
                n_waves = df_data.select(pl.col("wave").n_unique()).item()
                Y = (
                    df_data.select(*self.schema.get_cols("measurement"))
                    .to_numpy()
                    .ravel()
                    .reshape(
                        (
                            -1,
                            n_waves,
                            len(self.schema.get_cols("measurement")),
                        )
                    )
                )
                # Y = Y / Y.std(axis=(0, 1))
                Y = Y / abs(Y).max(axis=(0, 1))
                # NOTE: Hard-coded for now because I don't want to deal with the
                # binarisation of dem_urban generically.
                X = (
                    df_data.select(
                        pl.col("dem_male"),
                        pl.col("dem_educ"),
                        pl.col("dem_income_percep"),
                        (pl.col("dem_urban") == 0).cast(int).alias("dem_urban: urban"),
                        (pl.col("dem_urban") == 1)
                        .cast(int)
                        .alias("dem_urban: suburban"),
                        (pl.col("dem_urban") == 2).cast(int).alias("dem_urban: rural"),
                    )
                    .to_numpy()
                    .ravel()
                    .reshape((-1, n_waves, 6))
                )
                X = (X - X.mean(axis=(0, 1))) / X.std(axis=(0, 1), ddof=1)
                pids = (
                    df_data.select("participant_id")
                    .to_numpy()
                    .ravel()
                    .reshape((-1, n_waves))[:, 0]
                )

        X = X.astype(np.float64)

        # If bootstrap is True, sample row indices
        M = Y.shape[0]
        row_idxes = np.arange(M)
        if bootstrap:
            row_idxes = rng.choice(row_idxes, M, replace=True)
        X = X[row_idxes]
        Y = Y[row_idxes]
        pids = pids[row_idxes]

        # Prepend new zeroth axis to Y, tile to create one row per replicate
        #   Output shape for time-series: (replicate, individual, observation, spin)
        #   Output shape for cross-sectional: (replicate, individual, spin)
        if replicates > 1:
            Y = np.tile(Y[None, ...], (replicates,) + (1,) * (Y.ndim))

        P = np.zeros_like(Y, dtype=np.float64)
        if binarise:
            if binarisation_dist == "gaussian":
                P = sp.stats.norm.cdf(Y / scale)
                ζ = rng.normal(scale=scale, size=Y.shape)
                Y = np.where(Y + ζ > 0, 1, -1)
            elif binarisation_dist == "triangular":
                P = np.where(Y < 0, (1 - Y) / 2, (Y - 1) / 2)
                ζ = rng.binomial(1, (Y + 1) / 2, size=Y.shape).astype(np.int64)
                Y = np.where(ζ == 1, 1, -1)
            else:
                raise ValueError(f"Unknown binarisation dist: {binarisation_dist}.")
            Y = Y.astype(np.int64)

        elif ternarise:
            ζ = rng.normal(scale=scale, size=Y.shape)
            Y_hat = Y + ζ
            Y_hat[Y_hat < -epsilon] = -1
            Y_hat[Y_hat > epsilon] = 1
            Y_hat[abs(Y_hat) <= epsilon] = 0
            Y = Y_hat.astype(np.int64)

        return Y, X, P, pids, row_idxes

    def clone(self) -> Dataset:
        ds = Dataset(self.config.model_copy(), self.schema.model_copy())

        ds.metadata = {k: copy(v) for k, v in self.metadata.items()}

        ds.codebook = self.codebook.clone()
        ds.item = self.item.clone()
        ds.question = self.question.clone()
        ds.columns = self.columns.clone()
        ds.participant = self.participant.clone()
        ds.response = self.response.clone()
        ds.indices = self.indices.clone() if self.indices is not None else None
        ds.index_result = self.index_result.copy() if self.index_result else None

        return ds

    def compute_indices(
        self,
        groups: dict[str, list[str | pl.Expr]],
        kind: IndexMethod,
        centre: bool = True,
    ) -> Dataset:
        # If no groups defined, can't compute indices
        if not groups:
            return self.clone()

        ds = self.clone()
        ds.indices = ds.response.clone()
        ds.index_result = {}
        for group_name, columns in groups.items():
            X = (
                ds.response.select(  # ty: ignore
                    *columns
                )
                .collect()
                .to_numpy()
            )
            result = kind.eval(X, centre)
            colname = group_name.lower().replace(" ", "_")
            ds.indices = ds.indices.with_columns(pl.Series(result.index).alias(colname))
            ds.index_result[colname] = result.result

        # Drop collapsed columns from indices table
        for columns in groups.values():
            ds.indices = ds.indices.drop(*columns)  # ty: ignore

        ds.metadata["has_indices"] = True

        return ds

    def impute_viterbi(
        self,
        columns: list[str | pl.Expr] | list[str] | list[pl.Expr],
        impute_waves: list[int] | None = None,
    ) -> Dataset:
        ds = self.clone()
        ds.response = impute_viterbi(
            self.response.clone().collect(),  # ty: ignore
            columns=columns,
            impute_waves=impute_waves,
        ).lazy()

        ds.metadata["imputation"] = True

        return ds

    def impute_fill(
        self,
        columns: list[pl.Expr],
    ) -> Dataset:
        ds = self.clone()
        ds.response = ds.response.with_columns(
            [col.fill_null(strategy="forward") for col in columns]
        ).with_columns([col.fill_null(strategy="backward") for col in columns])

        ds.metadata["imputation"] = True

        return ds

    def rename(
        self,
        rename_dict: dict[str, str],
    ) -> Dataset:
        ds = self.clone()
        ds.response = ds.response.rename(rename_dict)
        if ds.indices is not None:
            ds.indices = ds.indices.rename(rename_dict)
        return ds

    def filter_columns(
        self,
        columns: list[str | pl.Expr] | list[str] | list[pl.Expr] | pl.Expr,
    ) -> Dataset:
        ds = self.clone()
        match columns:
            case pl.Expr():
                ds.response = self.response.select(columns).clone()
            case _:
                ds.response = self.response.select(*columns).clone()

        new_cols = ds.response.collect_schema().names()
        ds.item = self.item.filter(pl.col("item_name").is_in(new_cols))
        ds.question = self.question.filter(pl.col("item_name").is_in(new_cols))
        ds.codebook = self.codebook.filter(pl.col("item_name").is_in(new_cols))

        return ds

    def filter_waves(self, waves: list[int]) -> Dataset:
        # TODO: Also filter participants, questions, codebook accordingly
        ds = self.clone()
        ds.response = self.response.filter(pl.col("wave").is_in(waves))
        return ds

    def filter(self, expr: pl.Expr) -> Dataset:
        ds = self.clone()
        ds.response = ds.response.filter(expr)
        if ds.indices is not None:
            ds.indices = ds.response.select("participant_id", "wave").join(
                ds.indices, how="left", on=("participant_id", "wave")
            )

        # Recreate participant table
        participant = (
            ds.response.select("participant_id", "wave")
            .with_columns(
                pl.col("wave").min().over("participant_id").alias("wave_joined")
            )
            .with_columns(
                pl.col("wave").replace_strict({i: f"wave_{i}" for i in WAVES})
            )
            .with_columns(pl.lit(True).alias("participated"))
            .pivot(
                "wave",
                on_columns=[f"wave_{i}" for i in WAVES],
                index=["participant_id", "wave_joined"],
                values="participated",
                maintain_order=True,
            )
            .fill_null(False)
            .select("participant_id", "wave_joined", *[f"wave_{i}" for i in WAVES])
        )
        ds.participant = participant

        return ds

    def filter_no_nulls(
        self,
    ) -> Dataset:
        n_waves = self.response.select(pl.col("wave").n_unique()).collect().item()  # ty: ignore
        keep_pids = (
            self.response.group_by("participant_id")  # ty: ignore
            .agg(
                pl.all_horizontal(pl.all().is_not_null()).sum().alias("non_null_count")
            )
            .filter(pl.col("non_null_count") == n_waves)
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

        if self.indices is not None:
            ds.indices = self.indices.filter(
                pl.col("participant_id").is_in(keep_pids)
            ).clone()

        return ds

    def filter_at_least_one_resp(
        self,
        columns: list[str | pl.Expr] | list[str] | list[pl.Expr],
    ) -> Dataset:
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

    def reverse_coding(
        self,
        columns: list[str | pl.Expr] | list[str] | list[pl.Expr],
    ) -> Dataset:
        exprs = []

        for col in columns:
            if isinstance(col, str):
                exprs.append((-pl.col(col)).alias(col))
            elif isinstance(col, pl.Expr):
                exprs.append(-col)
            else:
                raise TypeError(f"Unsupported column type: {type(col)}")

        ds = self.clone()
        ds.response = self.response.with_columns(exprs).clone()

        return ds

    def standardise(
        self, columns: cs.Selector | pl.Expr, centre: bool = True
    ) -> Dataset:
        ds = self.clone()
        centred_cols = columns - columns.mean() if centre else columns

        ds.response = self.response.with_columns(centred_cols / columns.std())
        if self.indices is not None:
            ds.indices = self.indices.with_columns(centred_cols / columns.std())

        return ds

    def _validate(self):
        schema.OutputCodebookSchema.validate(self.codebook)
        schema.OutputItemSchema.validate(self.item)
        schema.OutputQuestionSchema.validate(self.question)
        schema.OutputItemColumnsSchema.validate(self.columns)
        schema.OutputParticipantSchema.validate(self.participant)
        schema.OutputResponseSchema.validate(self.response)

        self.metadata["validated"] = True

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
                pl.col(r"^ew3_(phy|mat|fin|men)$").fill_null(1),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_phy$"))
                .fill_null(1)
                .alias("ew3_phy_recent"),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_mat$"))
                .fill_null(1)
                .alias("ew3_mat_recent"),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_fin$"))
                .fill_null(1)
                .alias("ew3_fin_recent"),
                pl.coalesce(pl.col(r"^ew3_(apr|jun|nov)_men$"))
                .fill_null(1)
                .alias("ew3_men_recent"),
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

        # Propagate cc13 responses forward cumulatively
        sub_df = self.response.select(
            "participant_id",
            "wave",
            pl.col("cc13").list.set_difference(["None of the above"]),
        )
        new_cc13 = (
            sub_df.join(
                sub_df,
                how="left",
                on="participant_id",
            )
            .filter(pl.col("wave_right") <= pl.col("wave"))
            .drop("wave_right", "cc13")
            .rename({"cc13_right": "cc13"})
            .group_by("participant_id", "wave", maintain_order=True)
            .agg(
                pl.col("cc13")
                .list.explode()
                .drop_nulls()
                .unique()
                .sort()
                .alias("cc13_cumulative")
            )
        )
        self.response = self.response.join(
            new_cc13, how="left", on=("participant_id", "wave")
        )

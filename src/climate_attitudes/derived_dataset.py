from __future__ import annotations

import polars as pl
from sklearn.decomposition import PCA
from statsmodels.multivariate.factor import FactorResults

from climate_attitudes.dataset import Dataset
from climate_attitudes.schema.derived_dataset import DerivedDatasetSchema
from climate_attitudes.settings import Config


class DerivedDataset:
    codebook: pl.LazyFrame
    variable_names: dict[str, str]
    participant: pl.LazyFrame
    response: pl.LazyFrame
    indices: pl.LazyFrame | None = None
    index_result: (
        dict[str, PCA | FactorResults]
        | dict[str, PCA]
        | dict[str, FactorResults]
        | None
    ) = None

    schema: DerivedDatasetSchema

    def __init__(self, config: Config, dataset_schema: DerivedDatasetSchema):
        self.config = config
        self.schema = dataset_schema

        self.build()

    def build(self):
        """Construct derived dataset from base dataset according to schema."""

        base = Dataset.load(
            self.config,
            name="base",
            with_imputation=False,
            verbose=False,
        )

        # Filter to required waves and columns
        ds = base.filter_waves(self.schema.waves).filter_columns(
            self.schema.dependent_columns()
        )

        # Filter out null responses if required
        if self.schema.filter_null:
            ds = ds.filter_no_nulls()

        # For imputed variables, filter so that we have >=1 response per participant
        imputed_cols = self.schema.imputed_columns()
        if imputed_cols:
            ds = ds.filter_at_least_one_resp(imputed_cols)

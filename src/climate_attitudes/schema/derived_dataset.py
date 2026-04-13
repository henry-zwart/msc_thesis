from enum import StrEnum

import polars as pl
from pydantic import BaseModel

from climate_attitudes.indices import IndexMethod


class VariableKind(StrEnum):
    BELIEF = "belief"
    EXPERIENCE = "experience"
    ATTITUDE = "attitude"
    BEHAVIOUR = "behaviour"
    DEMOGRAPHIC = "demographic"
    EXTERNAL_FACTOR = "external factor"


class ImputationMethod(StrEnum):
    VITERBI = "viterbi"
    FILL = "fill"


class Variable(BaseModel):
    id: str
    name: str | None = None
    kind: VariableKind
    reverse_coding: bool = False
    remap_values: dict[int, int] | None = None
    imputation: ImputationMethod | None = None


class Index(BaseModel):
    id: str
    name: str
    variables: list[Variable]
    definition: IndexMethod


class DerivedDatasetSchema(BaseModel):
    name: str
    waves: list[int]
    filter_null: bool
    columns: list[Variable | Index]

    def variable_set(self) -> pl.Expr:
        return pl.col(*[col.id for col in self.columns])

    def variable_names(self) -> dict[str, str]:
        return {col.id: col.name for col in self.columns if col.name is not None}

    def imputed_columns(self) -> pl.Expr | None:
        cols = [
            col.id for col in self.dependent_variables() if col.imputation is not None
        ]

        return pl.col(*cols) if cols else None

    def dependent_variables(self) -> list[Variable]:
        variable_cols = [col for col in self.columns if isinstance(col, Variable)]
        index_cols = [
            var_col
            for col in self.columns
            if isinstance(col, Index)
            for var_col in col.variables
        ]
        return variable_cols + index_cols

    def dependent_columns(self) -> pl.Expr:
        cols = [col.id for col in set(self.dependent_variables())]
        return pl.col(*cols)

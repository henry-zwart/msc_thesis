from __future__ import annotations

from typing import Literal

import polars as pl
from pydantic import BaseModel


class PolarsTransform(BaseModel): ...


class PolarsReplace(PolarsTransform):
    mapping: dict[int, int]

    def to_expr(self, colname: str) -> pl.Expr:
        return pl.col(colname).replace(self.mapping)


class PolarsSubtract(PolarsTransform):
    amt: int

    def to_expr(self, colname: str) -> pl.Expr:
        return pl.col(colname).cast(pl.Int64) - self.amt


class Column(BaseModel):
    name: str
    display_name: str | None = None
    short_name: str | None = None
    abbrev: str | None = None
    category: str | None = None
    transform: PolarsTransform | None = None
    reverse_coding: bool = False
    kind: Literal["survey", "covariate", "measurement"]


class IndexColumn(Column):
    parts: list[str]


class DatasetSchema(BaseModel):
    columns: list[Column | IndexColumn]

    def pre_index(self) -> DatasetSchema:
        new_columns = [col for col in self.columns if not isinstance(col, IndexColumn)]
        return DatasetSchema(columns=new_columns)

    def post_index(self) -> DatasetSchema:
        remove_cols = []
        for col in self.columns:
            if not isinstance(col, IndexColumn):
                continue
            remove_cols.extend(col.parts)
        remove_cols = set(remove_cols)
        new_cols = [col for col in self.columns if col.name not in remove_cols]
        return DatasetSchema(columns=new_cols)

    def get_cols(
        self, kind: Literal["survey", "covariate", "measurement"]
    ) -> list[str]:
        return [col.name for col in self.columns if col.kind == kind]

    def get_short_names(
        self, kind: Literal["survey", "covariate", "measurement"]
    ) -> list[str]:
        short_names = []
        for col in self.columns:
            if col.kind != kind:
                continue
            for candidate in (col.short_name, col.abbrev, col.name):
                if candidate is not None:
                    short_names.append(candidate)
                break
        return short_names

    def get_abbrevs(
        self, kind: Literal["survey", "covariate", "measurement"]
    ) -> list[str]:
        abbrevs = []
        for col in self.columns:
            if col.kind != kind:
                continue
            for candidate in (col.abbrev, col.short_name, col.name):
                if candidate is not None:
                    abbrevs.append(candidate)
                break
        return abbrevs

from __future__ import annotations
import polars as pl


WAVES = [1, 2, 3, 4, 5, 6]


class ConditionColumn:
    def __init__(
        self,
        name: str,
        group: str | None = None,
        variant: str | int | None = None,
    ):
        self.name = name
        self.group_name = group
        self.variant = variant
        self.conditional_waves = set()
        self.conditions = []
        self.all_groups: set[str] = set()

    def add_cond(
        self, waves: int | list[int], groups: str | list[str]
    ) -> ConditionColumn:
        match waves:
            case int():
                waves_cond = pl.col("wave") == waves
                self.conditional_waves.add(waves)
            case list():
                waves_cond = pl.col("wave").is_in(waves)
                self.conditional_waves |= set(waves)

        if isinstance(groups, str):
            groups = [groups]

        self.conditions.append(waves_cond & pl.all_horizontal(*groups))
        self.all_groups |= set(groups)
        return self

    def condition(self) -> pl.Expr:
        return pl.any_horizontal(*self.conditions)


class ConditionGroup:
    def __init__(self, name: str, *column: ConditionColumn, allow_null: bool = False):
        self.name = name
        self.allow_null = allow_null
        self.orig_columns: list[str] = []
        self.group_conditions: dict[str, pl.Expr] = {}
        self.group_names: dict[str, str | None] = {}
        self.group_variants: dict[str, str | int | None] = {}
        self.waves = set()
        self.needs = set()
        for col in column:
            self.add_column(col)

    @property
    def group_col(self) -> str:
        return f"Group_{self.name}"

    @property
    def temp_group_cols(self) -> pl.Expr:
        return pl.col(f"^{self.name}_group_\\d+$")

    def add_column(self, column: ConditionColumn):
        if column.name in self.orig_columns:
            raise ValueError(f"Duplicate column: {column.name}.")
        if column.name.startswith(self.name):
            raise ValueError(
                f"Conditional column name `{self.name}` is a prefix of one of its "
                f"constituent columns: `{column.name}`."
            )
        self.orig_columns.append(column.name)
        self.waves |= column.conditional_waves
        self.needs |= {column.name, *column.all_groups}
        self.group_conditions[column.name] = column.condition()
        self.group_names[column.name] = column.group_name
        self.group_variants[column.name] = column.variant

    def validate_all_rows_have_group(self, lf: pl.LazyFrame):
        check = lf.select(pl.col(self.group_col).is_not_null().all()).collect().item()
        assert check, (
            "One or more rows has no assigned group for conditional "
            f"column: {self.name}"
        )

    def validate_exclusive_groups(self, lf: pl.LazyFrame):
        if self.allow_null:
            cond = pl.sum_horizontal(self.temp_group_cols.is_not_null()) <= 1
        else:
            cond = pl.sum_horizontal(self.temp_group_cols.is_not_null()) == 1

        check = lf.select(cond.all()).collect().item()

        assert check, (
            "One or more rows has more than one assigned group for conditional "
            f"column: {self.name}"
        )

    def validate_exclusive_responses(self, lf: pl.LazyFrame):
        if self.allow_null:
            cond = pl.sum_horizontal(pl.col(*self.orig_columns).is_not_null()) <= 1
        else:
            cond = pl.sum_horizontal(pl.col(*self.orig_columns).is_not_null()) == 1

        check = lf.select(cond.all()).collect().item()

        assert check, (
            "One or more rows has more than one non-null response for conditional "
            f"column: {self.name}"
        )

    def coalesce(self, lf: pl.LazyFrame) -> pl.LazyFrame:
        """Coalesce group-partitioned responses.

        There are several survey items for which respondents are assigned different
        questions depending on specific experimental conditions. In the raw data, these
        responses are typically recorded in separate group-specific columns, where group
        membership is typically described by an indicator column for each group.

        This makes analysis more complex, since (i) it increases the number of columns
        significantly, (ii) it is difficult to determine which groups are mutually
        exclusive, (iii) it can be difficult to compare across groups, particularly when
        null values are concerned.

        This function coalesces group-partitioned responses, replacing the response and
        group indicator columns with a single column for responses, and a separate column
        indicating group membership using an index (1..=M), represented as a
        human-readable enum value.
        """
        coalesced_lf = (
            # Filter to relevant waves, necessary columns
            lf.filter(pl.col("wave").is_in(self.waves))
            .select("response_id", "wave", *self.needs)
            # Coalesce responses into new combined response column
            .with_columns(pl.coalesce(*self.orig_columns).alias(self.name))
            # Create new indicator columns for group membership
            .with_columns(
                *[
                    (
                        self.group_conditions[orig_col]
                        # For rows where conditions met, record the group index
                        .replace_strict({True: i, False: None}, return_dtype=pl.Int64)
                        .alias(f"{self.name}_group_{i}")
                    )
                    for (i, orig_col) in enumerate(self.orig_columns)
                ]
            )
            # Coalesce group membership indicator columns to single index column
            .with_columns(
                pl.coalesce(pl.col(f"^{self.name}_group_\\d+$")).alias(self.group_col)
            )
        )

        # Check all okay (unique groups, responses, no unexpected nulls)
        if not self.allow_null:
            self.validate_all_rows_have_group(coalesced_lf)
        self.validate_exclusive_groups(coalesced_lf)
        self.validate_exclusive_responses(coalesced_lf)

        # Drop temporary columns
        coalesced_lf = coalesced_lf.select("response_id", self.name, self.group_col)

        # If all groups have names, convert group index to enum
        if all(self.group_names.values()):
            group_enum = pl.Enum(
                [self.group_names[orig_col] for orig_col in self.orig_columns]  # ty: ignore
            )
            coalesced_lf = coalesced_lf.with_columns(
                pl.col(self.group_col).cast(group_enum)
            )

        # If all groups have `variant` specified, create new column with these values
        if all(variant is not None for variant in self.group_variants.values()):
            group_to_variant = {
                i: self.group_variants[col] for i, col in enumerate(self.orig_columns)
            }
            variant_type = type(group_to_variant[0])
            coalesced_lf = coalesced_lf.with_columns(
                pl.col(self.group_col)
                .cast(pl.Int64)
                .replace_strict(group_to_variant, return_dtype=variant_type)
                .alias(f"Variant_{self.name}")
            )

        # Finally join with original data
        return lf.join(coalesced_lf, on="response_id", how="left")


class ExperimentConditions:
    def __init__(self, conditions: list[ConditionGroup]):
        self.conditions = conditions

    def coalesce(self, lf: pl.LazyFrame) -> pl.LazyFrame:
        """Combine condition-specific responses into singular columns."""
        for cond in self.conditions:
            lf = cond.coalesce(lf)

        # Remove old columns
        all_needs = {need for cond in self.conditions for need in cond.needs}
        lf = lf.drop(all_needs)

        return lf

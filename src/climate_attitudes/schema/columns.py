from __future__ import annotations
import polars as pl


class ConditionalColumn:
    def __init__(
        self,
        name: str,
        group: str | None = None,
        variant: str | int | None = None,
    ):
        self.name = name
        self.group = group
        self.variant = variant
        self.wave_conditions = dict()
        self.global_conditions = []
        self.survey_conditions: list[pl.Expr | bool] = []
        self.treatment_conditions: list[pl.Expr] = []
        self.treatment_classes: set[str] = set()

    def add_cond(
        self, waves: int | list[int] | None = None, *, expr: pl.Expr | bool
    ) -> ConditionalColumn:
        if waves is None:
            self.global_conditions.append(expr)
            return self

        if isinstance(waves, int):
            waves = [waves]

        for wave in waves:
            if wave not in self.wave_conditions:
                self.wave_conditions[wave] = {"survey": [], "treatment": []}
            self.wave_conditions[wave]["survey"].append(expr)

        return self

    def valid_waves(self, waves: int | list[int]) -> ConditionalColumn:
        if isinstance(waves, int):
            waves = [waves]

        self.survey_conditions.append(pl.col("wave").is_in(waves))
        return self

    def add_group_cond(
        self,
        waves: int | list[int],
        groups: str | list[str],
    ) -> ConditionalColumn:
        # TODO: Remove extra_condition part, since we are now separating over waves
        if isinstance(groups, str):
            groups = [groups]

        if isinstance(waves, int):
            waves = [waves]

        for wave in waves:
            if wave not in self.wave_conditions:
                self.wave_conditions[wave] = {"survey": [], "treatment": []}
            self.wave_conditions[wave]["treatment"] = list(
                set(self.wave_conditions[wave]["treatment"]) | set(groups)
            )

        # self.treatment_conditions.append(
        #     waves_cond
        #     & pl.all_horizontal(*[pl.col(g) == 1 for g in groups])
        #     & extra_condition
        # )

        # TODO: Maybe don't need this anymore since we store groups in conditions.
        self.treatment_classes |= set(groups)

        return self

    def treatment_condition(self) -> pl.Expr:
        # NOTE: This is still useful since we create the treatment groups by checking if the treatment is satisfied, which should be irrespective of the survey conditions being met.

        # TODO: Make this check === 1
        wave_treatments = [
            (pl.col("wave") == wave).and_(pl.all_horizontal(*conds["treatment"]))
            for wave, conds in self.wave_conditions.items()
            if conds["treatment"]
        ]
        return pl.any_horizontal(*wave_treatments)

    def condition(self) -> pl.Expr:
        # TODO: Refactor conditions to disjunction over waves.
        # i.e., wave 1 & survey conditions met for wave 1 & treatment conds met for ...
        wave_conditions = []
        for wave, conds in self.wave_conditions.items():
            condition_parts = [pl.col("wave") == wave]
            if conds["survey"]:
                condition_parts.append(pl.all_horizontal(*conds["survey"]))
            if conds["treatment"]:
                condition_parts.append(pl.all_horizontal(*conds["treatment"]))
            wave_conditions.append(pl.all_horizontal(*condition_parts))

        # Condition satisfied as disjunction over wave-specific conditions

        if wave_conditions and self.global_conditions:
            return pl.any_horizontal(*wave_conditions) & pl.all_horizontal(
                *self.global_conditions
            )
        elif wave_conditions:
            return pl.any_horizontal(*wave_conditions)
        elif self.global_conditions:
            return pl.all_horizontal(*self.global_conditions)
        else:
            return pl.lit(True)


class GroupColumn:
    def __init__(self, name: str, waves: int | list[int]):
        self.name = name
        self.waves = [waves] if isinstance(waves, int) else waves

    def valid(self) -> pl.Expr:
        return pl.col("wave").is_in(self.waves)


class ConditionGroup:
    def __init__(
        self,
        name: str,
        *column: ConditionalColumn,
        allow_null: bool = False,
        allow_multiple_groups: bool = False,
    ):
        self.name = name
        self.allow_null = allow_null
        self.allow_multiple_groups = allow_multiple_groups
        self.columns: list[ConditionalColumn] = []
        for col in column:
            self.add_column(col)

    def condition(self) -> pl.Expr:
        """True iff any of the columns' display conditions are met.

        In such cases we expect one of the columns to have a non-null response.
        """
        return pl.any_horizontal(*[col.condition() for col in self.columns])

    @property
    def response_columns(self) -> list[str]:
        """Get list of names for response columns."""
        return [col.name for col in self.columns]

    @property
    def group_columns(self) -> list[str]:
        """Get list of names for treatment group columns."""
        return list(
            {
                treatment_class
                for col in self.columns
                for treatment_class in col.treatment_classes
            }
        )

    @property
    def required_columns(self) -> list[str]:
        return list(
            {dep for col in self.columns for dep in (col.name, *col.treatment_classes)}
        )

    @property
    def group_col(self) -> str:
        return f"Group_{self.name}"

    @property
    def temp_group_cols(self) -> pl.Expr:
        return pl.col(f"^{self.name}_group_\\d+$")

    def add_column(self, column: ConditionalColumn):
        if column.name in self.response_columns:
            raise ValueError(f"Duplicate column: {column.name}.")
        if column.name.startswith(self.name):
            raise ValueError(
                f"Conditional column name `{self.name}` is a prefix of one of its "
                f"constituent columns: `{column.name}`."
            )
        self.columns.append(column)

    def validate_all_rows_have_group(self, lf: pl.LazyFrame):
        check = lf.select(pl.col(self.group_col).is_not_null().all()).collect().item()
        assert check, (
            "One or more rows has no assigned group for conditional "
            f"column: {self.name}"
        )

    def validate_exclusive_groups(self, lf: pl.LazyFrame):
        num_groups = (
            lf.select(pl.sum_horizontal(self.temp_group_cols.is_not_null()))
            .collect()
            .to_series()
        )
        if (num_groups == 0).any() and not self.allow_null:
            raise RuntimeError(
                f"One or more rows has no assigned group for conditional "
                f"column: {self.name}"
            )

        if (num_groups > 1).any():
            if self.name == "pol_vote_support":
                print(
                    lf.filter(pl.sum_horizontal(self.temp_group_cols.is_not_null()) > 1)
                    .select("participant_id", "wave", self.temp_group_cols)
                    .collect()
                )
            raise RuntimeError(
                f"One or more rows has more than one assigned group for conditional "
                f"column: {self.name}"
            )

    def validate_exclusive_responses(self, lf: pl.LazyFrame):
        num_responses = (
            lf.select(pl.sum_horizontal(pl.col(*self.response_columns).is_not_null()))
            .collect()
            .to_series()
        )

        if (num_responses == 0).any() and not self.allow_null:
            raise RuntimeError(
                "One or more rows has no non-null response for conditional "
                f"column: {self.name}"
            )

        if (num_responses > 1).any():
            raise RuntimeError(
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
            lf.filter(self.condition())
            # Coalesce responses into new combined response column
            .with_columns(pl.coalesce(*self.response_columns).alias(self.name))
            # Create new indicator columns for group membership
            .with_columns(
                *[
                    (
                        column.treatment_condition()
                        # For rows where conditions met, record the group index
                        .replace_strict({True: i, False: None}, return_dtype=pl.Int64)
                        .alias(f"{self.name}_group_{i}")
                    )
                    for (i, column) in enumerate(self.columns)
                ]
            )
            # Coalesce group membership indicator columns to single index column
            .with_columns(
                pl.coalesce(pl.col(f"^{self.name}_group_\\d+$")).alias(self.group_col)
            )
        )

        coalesced_lf.collect()

        # Check all okay (unique groups, responses, no unexpected nulls)
        if not self.allow_null:
            self.validate_all_rows_have_group(coalesced_lf)
        if not self.allow_multiple_groups:
            self.validate_exclusive_groups(coalesced_lf)
        self.validate_exclusive_responses(coalesced_lf)

        # Drop temporary columns
        coalesced_lf = coalesced_lf.select("response_id", self.name, self.group_col)

        # If all groups have names, convert group index to enum
        if all(column.group is not None for column in self.columns):
            group_enum = pl.Enum(
                [column.group for column in self.columns]  # ty: ignore
            )
            coalesced_lf = coalesced_lf.with_columns(
                pl.col(self.group_col).cast(group_enum)
            )

        # If all groups have `variant` specified, create new column with these values
        if all(col.variant is not None for col in self.columns):
            group_to_variant = {i: col.variant for i, col in enumerate(self.columns)}
            variant_type = type(group_to_variant[0])
            coalesced_lf = coalesced_lf.with_columns(
                pl.col(self.group_col)
                .cast(pl.Int64)
                .replace_strict(group_to_variant, return_dtype=variant_type)
                .alias(f"Variant_{self.name}")
            )

        # Finally join with original data
        return lf.join(coalesced_lf, on="response_id", how="left")

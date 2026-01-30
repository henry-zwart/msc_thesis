import polars as pl

from climate_attitudes.schema.columns import ConditionGroup


class ExperimentConditions:
    def __init__(self, conditions: list[ConditionGroup]):
        self.conditions = conditions

    def coalesce(self, lf: pl.LazyFrame) -> pl.LazyFrame:
        """Combine condition-specific responses into singular columns."""
        for cond in self.conditions:
            lf = cond.coalesce(lf)

        # Remove old columns
        old_cols = {col for cond in self.conditions for col in cond.required_columns}
        lf = lf.drop(old_cols)

        return lf

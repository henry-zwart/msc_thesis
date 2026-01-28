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
        all_needs = {need for cond in self.conditions for need in cond.needs}
        lf = lf.drop(all_needs)

        return lf

import arviz as az
import numpy as np
import numpy.typing as npt
import polars as pl
import pymc as pm

CC1_RESPONSES = ["No", "Yes", "Don't know"]


def init_model(data: pl.DataFrame, col: str, k: int):
    # Number of observations
    n = len(data)

    # Model dimensions
    coords = {
        "cutpoints": np.arange(1, k, dtype=int),  # Cutpoints between response options
        "observation": np.arange(n),
        "cc1_response": CC1_RESPONSES,
    }

    column = pl.col(col)
    variant_col_name = f"Variant_{col}"
    variant_col = pl.col(variant_col_name)

    age_mean = data.select(pl.col("dem_age").mean()).item()
    age_std = data.select(pl.col("dem_age").std()).item()

    model_data = (
        data
        # Map cc1 'dont know' option to '2' so values contiguous
        .with_columns(pl.col("cc1").replace({99: 2}))
        # Re-map 'zero' policy cost to None; question text not clear that cost is zero
        .with_columns(variant_col.replace({0: None}))
        # Filter out null `cc1`, null column of interest
        .filter(
            pl.col("cc1").is_not_null(),
            column.is_not_null(),
            variant_col.is_not_null(),
        )
        # Log transform policy cost
        .with_columns(variant_col.log())
        # Standardise numerical variables
        .with_columns(
            (variant_col - variant_col.mean()) / variant_col.std(),
            (pl.col("dem_age") - age_mean) / age_std,
        )
    )

    with pm.Model(coords=coords) as model:
        # Predictors
        policy_cost = pm.Data(
            "policy_cost", model_data.select(variant_col).to_numpy().flatten()
        )
        cc1 = pm.Data("cc1", model_data.select("cc1").to_numpy().flatten())
        age = pm.Data("age", model_data.select("dem_age").to_numpy().flatten())
        income = pm.Data("income", model_data.select("dem_income").to_numpy().flatten())

        # Model cutpoints between output response options
        # https://www.pymc.io/projects/examples/en/latest/statistical_rethinking_lectures/11-Ordered_Categories.html
        cutpoints = pm.Normal(
            "alpha",
            mu=0,
            sigma=1,
            transform=pm.distributions.transforms.ordered,
            shape=k - 1,
            initval=np.arange(k - 1)
            - 2.5,  # use ordering (with coarse log-odds centring) for init
            dims="cutpoints",
        )

        # Predictor coefficients
        beta_cost = pm.Normal("beta_cost", 0, 0.5)
        beta_age = pm.Normal("beta_age", 0, 0.5)
        beta_cc1 = pm.Normal("beta_cc1", 0, 0.5, dims="cc1_response")
        beta_income = pm.Normal("beta_income", 0, 0.5)

        eta = pm.Deterministic(
            "eta",
            beta_cost * policy_cost  # ty: ignore
            + beta_age * age  # ty: ignore
            + beta_cc1[cc1]  # ty: ignore
            + beta_income * income,  # ty: ignore
        )

        _policy_support = pm.OrderedLogistic(
            "policy_support",
            eta=eta,
            cutpoints=cutpoints,
            observed=model_data.select(column).to_numpy().flatten()
            - 1,  # Remap to 0..=k-1
        )

    standardisation_params = {
        "dem_age": {"mean": age_mean, "std": age_std},
    }

    return model, standardisation_params


class WTPModel:
    model: pm.Model
    standardisation_params: dict[str, dict[str, float]]
    trace: az.InferenceData | None

    def __init__(self, data: pl.DataFrame, col: str, k: int):
        self.model, self.standardisation_params = init_model(data, col, k)
        self.trace = None

    def sample(self, tune: int = 5000, n: int = 5000):
        with self.model:
            trace = pm.sample(n, tune=tune)
        self.trace = trace

    def wtp(self, data: pl.DataFrame | None = None) -> npt.NDArray[np.float64]:
        if self.trace is None:
            raise RuntimeError("Must fit model before wtp can be calculated.")

        samples = az.extract(self.trace.posterior)  # ty: ignore

        # Calculate from data if provided, otherwise from data used in model
        if data is not None:
            age = (
                data.select(
                    (pl.col("dem_age") - self.standardisation_params["dem_age"]["mean"])
                    / self.standardisation_params["dem_age"]["std"]
                )
                .to_numpy()
                .flatten()
            )
            cc1 = data.select("cc1").to_numpy().flatten()
            income = data.select("dem_income").to_numpy().flatten()
        else:
            age = self.trace.constant_data.age.values  # ty: ignore
            cc1 = self.trace.constant_data.cc1.values  # ty: ignore
            income = self.trace.constant_data.income.values  # ty: ignore

        # Calculate 'neutral' as midpoint between central cutpoints
        neutral_point = (samples.alpha[1] + samples.alpha[2]) / 2

        # Calculate log(WTP) as policy cost such that response is neutral
        log_wtp = (
            neutral_point.values
            - samples.beta_age.values * age[:, None]
            - samples.beta_cc1.values[cc1]
            - samples.beta_income.values * income[:, None]
        ) / samples.beta_cost.values

        # Convert to true scale and return mean for each row
        return np.exp(log_wtp).mean(axis=1)

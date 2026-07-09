from enum import StrEnum

import numpy as np
import numpy.typing as npt
import polars as pl
import polars.selectors as cs
from dcor import distance_correlation, partial_distance_correlation
from sklearn.covariance import GraphicalLassoCV
from sklearn.linear_model import MultiTaskLassoCV


class Correlation(StrEnum):
    PEARSON = "Pearson correlation"
    SPEARMAN = "Spearman correlation"
    PARTIAL = "partial correlation"
    PARTIAL_GLASSO = "partial correlation (graphical LASSO)"
    VAR_TEMPORAL = "VAR (Temporal)"
    VAR_CONTEMPORANEOUS = "VAR (Contemporaneous)"
    DISTANCE_CORR = "distance correlation"
    PARTIAL_DISTANCE_CORR = "partial distance correlation"

    def calculate(
        self,
        df: pl.DataFrame,
        assume_centered: bool = False,
        regularised: bool = False,
    ) -> npt.NDArray[np.float64]:
        match self:
            case Correlation.VAR_CONTEMPORANEOUS | Correlation.VAR_TEMPORAL:
                not_present = []
                for req_col in ("wave", "participant_id"):
                    if req_col not in df.columns:
                        not_present.append(req_col)
                if not_present:
                    raise ValueError(
                        f"One or more required columns were missing for VAR "
                        f"calculation: {not_present}"
                    )
            case (
                Correlation.PEARSON
                | Correlation.SPEARMAN
                | Correlation.PARTIAL
                | Correlation.PARTIAL_GLASSO
                | Correlation.DISTANCE_CORR
                | Correlation.PARTIAL_DISTANCE_CORR
            ):
                # Remove survey metadata columns
                found_cols = []
                for col in ("wave", "participant_id"):
                    if col in df.columns:
                        found_cols.append(col)
                if found_cols:
                    df = df.clone().drop(*found_cols)

        match self:
            case Correlation.PEARSON:
                return df.to_pandas().corr().values
            case Correlation.SPEARMAN:
                return df.to_pandas().corr(method="spearman").values
            case Correlation.PARTIAL:
                return pcorr(df).to_numpy()
            case Correlation.PARTIAL_GLASSO:
                X = df.to_numpy()
                glasso = GraphicalLassoCV(max_iter=100, assume_centered=assume_centered)
                glasso.fit(X)
                precision = glasso.precision_
                partial_corr = -precision / np.sqrt(
                    np.outer(np.diag(precision), np.diag(precision))
                )  # ty: ignore
                np.fill_diagonal(partial_corr, 1)
                return partial_corr
            case Correlation.VAR_TEMPORAL:
                B, _ = fit_var(
                    df, assume_centered=assume_centered, regularised=regularised
                )
                return B
            case Correlation.VAR_CONTEMPORANEOUS:
                _, K = fit_var(
                    df, assume_centered=assume_centered, regularised=regularised
                )
                return K
            case Correlation.DISTANCE_CORR:
                X = df.to_numpy().T.astype(np.float64)
                C = np.eye(X.shape[0], dtype=np.float64)
                for i in range(X.shape[0]):
                    for k in range(i):
                        dist_corr = distance_correlation(X[i], X[k])
                        C[i, k] = C[k, i] = dist_corr
                return C
            case Correlation.PARTIAL_DISTANCE_CORR:
                X = df.to_numpy().T.astype(np.float64)
                C = np.eye(X.shape[0], dtype=np.float64)
                for i in range(X.shape[0]):
                    for k in range(i):
                        Z = X[[j for j in range(X.shape[0]) if j not in (i, k)]]
                        partial_dist_corr = partial_distance_correlation(
                            X[i], X[k], Z.T
                        )
                        C[i, k] = C[k, i] = partial_dist_corr
                return C


def filter_vars_by_abs_corr(
    df: pl.DataFrame,
    lower: float = 0.0,
    upper: float = 1.0,
    predicate: str = "any",
    kind: Correlation = Correlation.PEARSON,
) -> npt.NDArray[np.str_]:
    corr = kind.calculate(df)

    # Remove survey metadata columns
    found_cols = []
    for col in ("wave", "participant_id"):
        if col in df.columns:
            found_cols.append(col)
    if found_cols:
        df = df.clone().drop(*found_cols)

    # Find column indexes where at least one non-diag is within range
    in_range = (abs(corr) >= lower) & (abs(corr) <= upper)
    in_range[np.diag_indices_from(in_range)] = True

    if predicate == "any":
        keep_idxes = (in_range.sum(axis=0)) > 1
    elif predicate == "all":
        keep_idxes = np.all(in_range, axis=0)
    else:
        raise ValueError(
            f"Unknown predicate: '{predicate}'. Expected one of ['any', 'all']."
        )

    return np.asarray(df.columns)[keep_idxes], keep_idxes


def cov(df: pl.DataFrame) -> pl.DataFrame:
    """Compute pairwise covariance between columns of a Polars DataFrame."""
    z = np.cov(df.to_numpy(), rowvar=False)
    if df.width == 1:
        z = np.array([z])
    return pl.DataFrame(z, schema=df.columns)


def pcorr(df: pl.DataFrame) -> pl.DataFrame:
    """Compute pairwise partial correlation between columns of a Polars DataFrame."""
    sigma = cov(df).to_numpy()
    sigma_inv = np.linalg.inv(sigma)
    denom = np.sqrt(np.outer(np.diag(sigma_inv), np.diag(sigma_inv)))
    z = -(sigma_inv / denom)
    if df.width == 1:
        z = np.array([z])
    z[np.diag_indices_from(z)] = 1.0
    return pl.DataFrame(z, schema=df.columns)


def fit_var(
    df: pl.DataFrame,
    assume_centered: bool = False,
    regularised: bool = False,
) -> tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    df = df.clone()

    # Determine which consecutive wave pairs exist in data
    # NOTE: Assume all consecutive waves, no null, for simplicity
    min_wave, max_wave = df.select(
        pl.col("wave").min().alias("min_wave"), pl.col("wave").max().alias("max_wave")
    ).row(0)

    # Centre to avoid dealing with intercepts
    if not assume_centered:
        df = df.with_columns(
            cs.exclude("participant_id", "wave")
            - cs.exclude("participant_id", "wave").mean()
        )

    # Extract regressors and responses (first wave, second wave for each participant)
    regressor_waves = df.filter(pl.col("wave") < max_wave).sort(
        by=("wave", "participant_id")
    )
    response_waves = df.filter(pl.col("wave") > min_wave).sort(
        by=("wave", "participant_id")
    )
    X = regressor_waves.select(cs.exclude("participant_id", "wave")).to_numpy()
    Y = response_waves.select(cs.exclude("participant_id", "wave")).to_numpy()

    # Regress on prev wave
    # B: Temporal network
    # Values in a column are the regression coefficients for that column's question
    if not regularised:
        B, *_ = np.linalg.lstsq(X, Y)
        B = B.T
    else:
        lasso = MultiTaskLassoCV()
        lasso.fit(X, Y)
        B = lasso.coef_

    # Calculate contemporaneous network (K)
    # 1. Variance-covariance matrix of residuals
    Y_hat = (B @ X.T).T
    res = Y - Y_hat
    theta = np.corrcoef(res.T)

    # 2. Invert and normalise to get K
    theta_inv = np.linalg.inv(theta)
    denom = np.sqrt(np.outer(np.diag(theta_inv), np.diag(theta_inv)))
    K = -(theta_inv / denom)
    K[np.diag_indices_from(K)] = 1.0

    return B, K

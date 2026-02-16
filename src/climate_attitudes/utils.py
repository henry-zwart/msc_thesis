import numpy.typing as npt
import numpy as np
import polars as pl


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


def calculate_proportion_response(
    df: pl.DataFrame, column: str, wave: int
) -> npt.NDArray[np.float64]:
    """Calculate proportion wave responses equal to each value for question."""
    props = (
        df.filter(wave=wave)
        .group_by(column)
        .agg(pl.len().alias("count"))
        .with_columns((pl.col("count") / pl.col("count").sum()).alias("proportion"))
        .sort(by=column)
        .select("proportion")
        .to_numpy()
        .flatten()
    )
    return props


def calculate_transition_probabilities(
    df: pl.DataFrame, column: str, start: int, end: int
) -> npt.NDArray[np.float64]:
    """Calculate response transition probabilities between two waves for a question."""
    probs = (
        df.select("participant_id", "wave", column)
        .filter(pl.col("wave").is_in((start, end)))
        .with_columns(
            pl.col("wave").replace_strict({start: "start_wave", end: "end_wave"})
        )
        .pivot("wave", index="participant_id", values=column)
        .sort(by=("start_wave", "end_wave"))
        # Group by unique (initial response, later response) pairs
        .group_by("start_wave", "end_wave", maintain_order=True)
        .agg(pl.len().alias("count"))
        .with_columns(
            (pl.col("count") / pl.col("count").sum())
            .over("start_wave")
            .alias("transition_prob")
        )
        .pivot("end_wave", index="start_wave", values="transition_prob")
        .with_columns(pl.all().fill_null(0.0))
        .drop("start_wave")
    )
    return probs.to_numpy()


def calculate_stationary_distribution(
    R: npt.NDArray[np.float64],
) -> npt.NDArray[np.float64]:
    """Calculate stationary distribution for a transition matrix.

    Matrix expected in row-transitions form. i.e., entry ij describes the
    probability of transitioning to state j at time t + 1, given that we are
    at state i at time t.

    The stationary distribution is the solution μ to the equation:

        μR = μ

    subject to the constraint that |μ| = 1.

    We solve the modified problem:

            μ(R - I) = 0

        ==> (R - I)^T . μ^T = 0
    """
    R = R.copy()

    # Form matrix from (R - I)^T, and normalisation constraint
    n = R.shape[0]
    A = np.vstack(
        (
            (R - np.eye(n)).T,
            np.ones(n)[None, :],
        )
    )

    # Solve for least-squares solution s.t. b = 0, except in normalisation constraint
    b = np.zeros(A.shape[0])
    b[-1] = 1
    mu = np.linalg.lstsq(A, b)[0]

    return mu


def relative_entropy(
    actual: npt.NDArray[np.float64], expected: npt.NDArray[np.float64]
) -> float:
    assert all((actual.ndim == 1, expected.ndim == 1)), "Expected 1D distributions"
    assert actual.shape == expected.shape, "Distributions do not have the same length"

    excess_surprise = [
        np.log2(p / q) if q > 0 else np.inf for p, q in zip(actual, expected)
    ]
    relative_entropy = sum(p * x for p, x in zip(actual, excess_surprise))

    return float(relative_entropy)

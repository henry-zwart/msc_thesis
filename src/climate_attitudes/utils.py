import numpy as np
import numpy.typing as npt
import polars as pl
import polars.selectors as cs


def standardise(expr: pl.Expr | cs.Selector) -> pl.Expr:
    return (expr - expr.mean()) / expr.std()


def rand_direction_fill(col: str | pl.Expr | cs.Selector) -> pl.Expr:
    """Fill null values with either forward or backward values, with p=1/2."""
    # Whatever 'col' is, make it an expression
    match col:
        case str():
            col = pl.col(col)
        case cs.Selector():
            col = col.as_expr()
        case _:
            col = col

    expr = (
        pl.when(col.is_null())
        .then(
            pl.when(pl.int_range(2).sample(pl.len(), with_replacement=True) == 1)
            .then(col.backward_fill().over("participant_id"))
            .otherwise(col.forward_fill().over("participant_id"))
        )
        .otherwise(col)
    )

    # Account for participants with non-null values in only one direction
    # First try filling forward (use previous values)
    expr = pl.when(expr.is_null()).then(col.forward_fill().over("participant_id"))
    # Then try filling backward (use future values)
    expr = pl.when(expr.is_null()).then(col.backward_fill().over("participant_id"))
    return expr


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


def sample_discrete_mc(
    R: npt.NDArray[np.float64],
    init_dist: npt.NDArray[np.float64] | None = None,
    n: int = 1,
    steps: int = 1,
    rng: np.random.Generator | None = None,
) -> npt.NDArray[np.int64]:
    n_states = R.shape[0]
    states = np.arange(n_states)

    if rng is None:
        print("No random number generator provided, using new random seed.")
        rng = np.random.default_rng()

    if init_dist is None:
        print("No initial distribution provided, using default (uniform).")
        init_dist = np.full(n_states, fill_value=1 / n_states, dtype=np.float64)

    # Initialise empty (-1) array for samples
    samples = np.full((steps + 1, n), fill_value=-1)

    # Sample initial state using initial distribution
    samples[0] = rng.choice(states, p=init_dist, size=n)

    # Iteratively sample next state using transition matrix
    for i in range(1, steps + 1):
        # Treat source states separately; rng.choice only accepts one distribution
        for m in states:
            prev_state_is_m = samples[i - 1] == m
            samples[i, prev_state_is_m] = rng.choice(
                states,
                p=R[m],
                size=prev_state_is_m.sum(),
            )

    return samples

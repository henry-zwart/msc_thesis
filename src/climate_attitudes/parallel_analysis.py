import polars as pl
import numpy as np
import numpy.typing as npt


def pa_random_eigs(
    data: pl.DataFrame,
    repeats: int = 1,
    rng: np.random.Generator | None = None,
) -> npt.NDArray[np.float64]:
    if rng is None:
        print("No random number generator provided; using new random seed.")
        rng = np.random.default_rng()

    # Remove survey metadata columns
    found_cols = []
    for col in ("wave", "participant_id"):
        if col in data.columns:
            found_cols.append(col)
    if found_cols:
        data = data.clone().drop(*found_cols)

    n_response_options = data.select(pl.all().rank("dense").max()).row(0)

    acc = np.empty((repeats, len(n_response_options)), dtype=np.float64)
    for r in range(repeats):
        X_rand = rng.integers(
            low=0,
            high=n_response_options,
            size=data.shape,
        )
        X_corr = np.corrcoef(X_rand.T)

        acc[r] = np.sort(np.linalg.eigvals(X_corr))[::-1]

    return np.median(acc, axis=0)


def pa_true_eigs(
    data: pl.DataFrame,
) -> npt.NDArray[np.float64]:
    # Remove survey metadata columns
    found_cols = []
    for col in ("wave", "participant_id"):
        if col in data.columns:
            found_cols.append(col)
    if found_cols:
        data = data.clone().drop(*found_cols)

    X = data.to_numpy().T
    X_corr = np.corrcoef(X)
    return np.sort(np.linalg.eigvals(X_corr))[::-1]

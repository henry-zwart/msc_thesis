import itertools

from tqdm import tqdm

import numpy as np
import numpy.typing as npt
import polars as pl


def count_observed_transitions(
    m: int, n: int, tau: int, obs: npt.NDArray[np.int64]
) -> np.int64:
    # t-window-shifted observations
    (x_t1, x_t2) = obs[:, :-tau], obs[:, tau:]

    # Count occurrences where t = m and (t+tau) = n
    return ((x_t1 == m) & (x_t2 == n)).sum()


def p_transition(
    T: npt.NDArray[np.float64], m: int, n: int, tau: int = 1
) -> np.float64:
    if tau == 1:
        return T[m, n]
    T_pow_tau = np.linalg.matrix_power(T, tau)
    return T_pow_tau[m, n]


def p_subtransition(
    T: npt.NDArray[np.float64],
    start: int,
    end: int,
    tau: int,
    sub_start: int,
    sub_end: int,
    sub_tau: int,
) -> np.float64:
    m, n, t = start, end, tau
    i, j, k = sub_start, sub_end, sub_tau
    p_mn = p_transition(T, m, n, tau=t)
    p_mi = p_transition(T, m, i, tau=k)
    p_ij = p_transition(T, i, j, tau=1)
    p_jn = p_transition(T, j, n, tau=(t - k - 1))

    numerator = p_mi * p_ij * p_jn
    denominator = p_mn + 1e-4

    return numerator / denominator


def expected_transitions(
    T: npt.NDArray[np.float64],
    start: int,
    end: int,
    chain_length: int,
    obs: npt.NDArray[np.int64],
) -> np.float64:
    M, N = T.shape
    i, j = start, end

    acc = np.float64(0)
    for m in range(M):
        for n in range(N):
            for tau in range(1, chain_length):
                o_mnt = count_observed_transitions(m, n, tau, obs)

                for k in range(tau):
                    p = p_subtransition(
                        T,
                        start=m,
                        end=n,
                        tau=tau,
                        sub_start=i,
                        sub_end=j,
                        sub_tau=k,
                    )

                    acc += o_mnt * p

    return acc


def estimate_transition_matrix(
    observations: npt.NDArray[np.int64],
    T_0: npt.NDArray[np.float64] | None = None,
    iters: int = 30,
) -> npt.NDArray[np.float64]:
    # Expected in (wave, participant) form
    observations = observations.T

    chain_length = observations.shape[-1]

    if T_0 is None:
        M = len(set(observations.flatten()) - set((-1,)))
        T_0 = np.full((M, M), fill_value=1 / M, dtype=np.float64)
    else:
        M = T_0.shape[0]

    def step_expectation(T_p: npt.NDArray[np.float64]) -> npt.NDArray[np.float64]:
        S_p = np.empty_like(T_p)
        for i, j in itertools.product(range(M), range(M)):
            S_p[i, j] = expected_transitions(T_p, i, j, chain_length, observations)
        return S_p

    def step_maximisation(S_p: npt.NDArray[np.float64]) -> npt.NDArray[np.float64]:
        denominator = S_p.sum(axis=1, keepdims=True) + 1e-4  # Smoothing
        T_p = S_p / denominator
        return T_p

    T_i = T_0
    for i in range(1, iters + 1):
        S_i = step_expectation(T_i)
        T_i = step_maximisation(S_i)

    return T_i


def viterbi(
    states: npt.NDArray[np.int64],
    R: npt.NDArray[np.float64],
    obs: npt.NDArray[np.int64],
    init_dist: npt.NDArray[np.float64] | None = None,
    quiet: bool = False,
):
    """Compute most probable sequence of states given observations.

    Uses vectorised operations; supports batched data.

    Assumes missing observations are recorded as -1 in `obs`.
    """

    assert states.ndim == 1, (
        f"Expected 1D `states` array, found dimension {states.ndim}"
    )

    S = states.size
    (T, N) = obs.shape

    if init_dist is None and np.any(obs[0] == -1):
        if not quiet:
            print("No initial distribution provided, using default (uniform).")
        init_dist = np.full(S, fill_value=1 / S, dtype=np.float64)

    # Calculate log(R); treat p=0 separate to avoid warning
    log_R = R.copy()
    log_R[np.isclose(R, 0)] = -np.inf
    log_R[R > 0] = np.log(R[R > 0])

    log_prob = np.full((T, N, S), fill_value=-np.inf, dtype=np.float64)
    prev = np.full((T, N, S), fill_value=-1, dtype=np.int64)

    # Initialise first prob entry with observed states or initial distribution
    first_obs_full = obs[0] != -1
    if np.any(first_obs_full):
        log_prob[0, first_obs_full, obs[0][first_obs_full]] = 0.0

    # `init_dist` may be undefined if no initial observations missing
    if np.any(~first_obs_full):
        log_prob[0, ~first_obs_full] = np.log(init_dist)  # ty: ignore

    # For each subsequent step, record maximal probability transition and state
    obs_mask = np.full((T, N, S), fill_value=-np.inf, dtype=np.float64)
    is_null = np.where(obs == -1)
    not_null = np.where(obs != -1)

    obs_mask[*not_null, obs[not_null]] = 0.0
    obs_mask[is_null] = 0.0

    # I = np.eye(S, dtype=np.bool_)
    for t in range(1, T):
        new_log_prob = log_prob[t - 1][:, :, None] + log_R

        # When state observed, mask other state probs to 0.0
        new_log_prob += obs_mask[t][:, None, :]

        log_prob[t] = np.max(new_log_prob, axis=1)
        prev[t] = np.argmax(new_log_prob, axis=1)
        prev[t][np.where(log_prob[t] == -np.inf)] = -1

    path = np.full((T, N), fill_value=-1, dtype=np.int64)
    final_state = np.argmax(log_prob[-1], axis=-1)
    path[T - 1] = final_state
    for t in range(T - 2, -1, -1):
        path[t] = prev[t + 1, np.arange(N), path[t + 1]]

    return path


def columns_with_nulls(df: pl.DataFrame) -> list[str]:
    return df.select(col for col in df if col.is_null().any()).columns


def impute_viterbi(
    df: pl.DataFrame | pl.LazyFrame,
    columns: list[str | pl.Expr],
    impute_waves: list[int] | None = None,
) -> pl.DataFrame:
    colnames = df.select(*columns).columns
    print(f"Viterbi imputation: {colnames}")

    if isinstance(df, pl.LazyFrame):
        df = df.collect()

    # Determine which waves to impute
    if impute_waves is None:
        impute_waves = df.select(pl.col("wave").unique()).to_series()

    # Add missing rows, i.e., when a participant is missing from entire wave
    pids = df.select(pl.col("participant_id").unique())
    all_combos = pids.join(pl.DataFrame(dict(wave=impute_waves)), how="cross")
    full_df = df.join(all_combos, how="right", on=("participant_id", "wave")).sort(
        by=("participant_id", "wave")
    )

    imputation_cols = columns_with_nulls(full_df.select(columns))

    def _impute(col: str) -> pl.Series:
        # (participant, wave)
        sub_df = (
            full_df.select("participant_id", "wave", col)
            .sort(by=("participant_id", "wave"))
            .with_columns((pl.col(col).rank("dense") - 1).alias("rank"))
        )
        obs = (
            sub_df.pivot("wave", index="participant_id", values="rank")
            .drop("participant_id")
            .fill_null(-1)
            .to_numpy()
            .T
        )

        rank_to_value = {
            r: v
            for (v, r) in sub_df.select(col, "rank").drop_nulls().unique().iter_rows()
        }

        col_dtype = sub_df.select(col).dtypes[0]

        R = estimate_transition_matrix(obs)

        # Impute missing responses
        est = viterbi(np.arange(R.shape[0]), R=R, obs=obs, quiet=True)

        return pl.Series(est.T.ravel()).replace_strict(
            rank_to_value, return_dtype=col_dtype
        )

    # Join back into DataFrame
    imputed_cols = [
        _impute(col).alias(col)
        for col in tqdm(imputation_cols, desc="Viterbi imputation:")
    ]
    imputed_df = (
        full_df.with_columns(*imputed_cols)
        # Re-order columns as in original dataframe
        .select(*df.columns)
    )

    return imputed_df

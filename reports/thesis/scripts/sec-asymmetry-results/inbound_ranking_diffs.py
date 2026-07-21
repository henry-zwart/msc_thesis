from __future__ import annotations

from pathlib import Path

import numpy as np
import numpy.typing as npt
import scipy as sp
from scipy.stats import rankdata

from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)


def load_data(
    data_dir: Path,
    delta_str: str,
    measure_time: int,
    target_idx: int,
) -> tuple[npt.NDArray[np.int64], npt.NDArray[np.int64], npt.NDArray[np.str_]]:
    null_sym = np.load(data_dir / "sym_ising_00.npz")
    null_asym = np.load(data_dir / "ising_00.npz")
    int_sym = np.load(data_dir / f"sym_ising_{delta_str}.npz")
    int_asym = np.load(data_dir / f"ising_{delta_str}.npz")

    # Calculate effects of intervention
    null_sym_outcomes = null_sym["measurements"][:, :, measure_time]
    null_asym_outcomes = null_asym["measurements"][:, :, measure_time]
    int_sym_outcomes = int_sym["measurements"][:, :, measure_time]
    int_asym_outcomes = int_asym["measurements"][:, :, measure_time]
    int_effect_sym = int_sym_outcomes - null_sym_outcomes
    int_effect_asym = int_asym_outcomes - null_asym_outcomes

    labels = int_asym["labels"]

    int_effect_sym = np.delete(int_effect_sym[..., target_idx], target_idx, axis=-1)
    int_effect_asym = np.delete(int_effect_asym[..., target_idx], target_idx, axis=-1)
    labels = np.delete(labels, target_idx)

    return int_effect_sym, int_effect_asym, labels


def count_inversions(measurements):
    collective_eff = measurements.mean(axis=1)
    higher_val_count = (collective_eff[:, :, None] > collective_eff[:, None, :]).sum(
        axis=0
    )
    rankings_per_repeat = rankdata(collective_eff, method="min", axis=-1)
    politics_is_rank_4 = rankings_per_repeat[:, 5] == 4
    # What are the expected ranks of CC Real and CC Human in such cases?
    print(rankings_per_repeat[politics_is_rank_4, 0].mean())
    print(rankings_per_repeat[politics_is_rank_4, 1].mean())

    cc_real_is_rank_3 = rankings_per_repeat[:, 0] == 3
    # What are the expected ranks of CC Human and Weather Worry in such cases?
    print(rankings_per_repeat[cc_real_is_rank_3, 1].mean())
    print(rankings_per_repeat[cc_real_is_rank_3, 4].mean())
    print()
    # return rankings_per_repeat
    # is_higher_rank = rankings_per_repeat[:, :, None] > rankings_per_repeat[:, None, :]
    # return is_higher_rank.astype(np.int64).mean(axis=0)
    return higher_val_count


def main(
    effect_sym: npt.NDArray[np.int64],
    effect_asym: npt.NDArray[np.int64],
    labels: npt.NDArray[np.str_],
):
    sym_count_higher = count_inversions(effect_sym)
    asym_count_higher = count_inversions(effect_asym)

    sym_test_idxes = [(5, 0), (0, 1)]
    asym_test_idxes = [(0, 1), (1, 4)]

    results = (sym_count_higher, asym_count_higher)
    models = ("Symmetric", "Asymmetric")
    all_idxes = (sym_test_idxes, asym_test_idxes)

    binomial = sp.stats.Binomial(n=effect_sym.shape[0], p=0.5)
    for model, idxes, count in zip(models, all_idxes, results, strict=True):
        print(f"Model: {model}")
        for idx1, idx2 in idxes:
            var1, var2 = labels[idx1], labels[idx2]
            p = 1 - binomial.cdf(count)
            if p[idx1, idx2] > 0.05:
                print(f"{var1} > {var2}: Not significant (p={p[idx1, idx2]:.4f})")
            else:
                print(f"{var1} > {var2}: Significant (p={p[idx1, idx2]:.4f})")
        print()


if __name__ == "__main__":
    configure_mpl()
    int_effect_sym, int_effect_asym, labels = load_data(
        data_dir=Path("reports/thesis/results/data/model/all_interventions"),
        delta_str="25",
        measure_time=5,
        target_idx=7,
    )
    main(int_effect_sym, int_effect_asym, labels)

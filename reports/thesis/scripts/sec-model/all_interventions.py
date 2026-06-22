import sys
from pathlib import Path

import numpy as np

from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)

DATA_PATH = Path("reports/thesis/results/data/model/all_interventions")


def main(delta_str):
    # Load data
    no_int_asym_measurements = np.load(DATA_PATH / "ising_0_use_covariates.npz")[
        "measurements"
    ]
    int_asym_measurements = np.load(
        DATA_PATH / f"ising_{delta_str}_use_covariates.npz"
    )["measurements"]
    no_int_sym_measurements = np.load(DATA_PATH / "sym_ising_0_use_covariates.npz")[
        "measurements"
    ]
    int_sym_measurements = np.load(
        DATA_PATH / f"sym_ising_{delta_str}_use_covariates.npz"
    )["measurements"]

    int_effect_asym = int_asym_measurements - no_int_asym_measurements
    int_effect_sym = int_sym_measurements - no_int_sym_measurements
    asym_effect = int_effect_asym - int_effect_sym

    print(f"Delta = {delta_str[0]}.{delta_str[1:]}")
    print(asym_effect.mean(axis=(0, 1)))
    print(asym_effect.std(axis=(0, 1), ddof=1))


if __name__ == "__main__":
    configure_mpl()
    delta_str = sys.argv[1]
    main(delta_str)

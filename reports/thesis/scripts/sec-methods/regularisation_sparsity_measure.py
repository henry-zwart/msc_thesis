import numpy as np
from ising.model import UpdateMethod
from tqdm import trange

from climate_attitudes.dataset import Dataset
from climate_attitudes.settings import Config
from ising import Ising

RANDOM_SEED = 202606221353


def main():
    config = Config(_env_file=".env")
    dataset = Dataset.load(
        config,
        name="reduced_no_imputation",
        with_imputation=False,
        verbose=False,
    )

    repeats = 5
    n_lambdas = 30
    λ = np.logspace(-3, -0.3, n_lambdas, base=10)

    replicates = 1

    k = np.empty((n_lambdas, repeats), dtype=np.int64)
    for i in trange(n_lambdas, desc="Measuring regularisation strength --> sparsity"):
        for repeat in range(repeats):
            _, Yj, _ = dataset.indices_to_numpy(
                "time-series", binarise=True, seed=RANDOM_SEED + repeat
            )
            model = Ising.fit(
                Yj,
                update_method=UpdateMethod.SYNCHRONOUS,
                w=λ[i],
                rng=RANDOM_SEED + repeat,
                self_loops=True,
            )
            k[i, repeat] = (abs(model.param_vector()) > 1e-2).sum()

    np.savez_compressed(
        "reports/thesis/results/data/methods/regularisation_sparsity.npz",
        k=k,
        λ=λ,
        replicates=replicates,
    )


if __name__ == "__main__":
    main()

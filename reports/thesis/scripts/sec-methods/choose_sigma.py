import json
from pathlib import Path

import numpy as np
import scipy as sp


def main():
    P_MAP_WEAK_OPPOSE_TO_SUPPORT = 0.05
    X = -1 / 3

    # Initialise standard normal distribution
    norm = sp.stats.Normal(mu=0, sigma=1)

    # Calculate reqd. standard deviation size
    std = np.round(X / norm.icdf(P_MAP_WEAK_OPPOSE_TO_SUPPORT), decimals=1)

    with Path("reports/thesis/results/data/methods/binarisation_sigma.json").open(
        "w"
    ) as f:
        json.dump(dict(x=X, p=P_MAP_WEAK_OPPOSE_TO_SUPPORT, sigma=std), f)


if __name__ == "__main__":
    main()

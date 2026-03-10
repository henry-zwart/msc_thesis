"""
Eskamp et al (2018) state that "when data are multivariate normal, ... conditional
independence would correspond to a partial correlation being equal to zero."

This script explores this claim, and how the partial correlation behaves for
non-multivariate-normal data.
"""

import numpy as np
import numpy.typing as npt

SEED = 202602181056


def pcorr(a: npt.NDArray, b: npt.NDArray, z: npt.NDArray) -> float:
    def residuals(x: npt.NDArray, y: npt.NDArray) -> npt.NDArray:
        A = np.vstack([x, np.ones(len(x))]).T
        (m, c), *_ = np.linalg.lstsq(A, y)
        y_pred = m * x + c
        return y - y_pred

    return np.corrcoef(residuals(z, a), residuals(z, b))[0, 1]


def mvnormal_pcorr(rng: np.random.Generator, size: int = 100000):
    common_cause = 10 * rng.binomial(n=1, p=0.1, size=size)
    a = rng.normal(loc=common_cause, scale=1)
    b = rng.normal(loc=common_cause, scale=1)
    print(f"MVNormal partial correlation: {pcorr(a, b, common_cause):.4f}")


def bernoulli_pcorr(rng: np.random.Generator, size: int = 100000):
    common_cause = rng.beta(a=5, b=1, size=size)
    a = rng.binomial(n=1, p=common_cause)
    b = rng.binomial(n=1, p=common_cause)
    print(f"Bernoulli partial correlation: {pcorr(a, b, common_cause):.4f}")


if __name__ == "__main__":
    rng = np.random.default_rng(SEED)
    mvnormal_pcorr(rng)
    bernoulli_pcorr(rng)

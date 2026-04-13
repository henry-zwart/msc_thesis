"""Example of problem inferring within-person belief system from cross-sectional data."""

import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as stats


def main():
    """Consider two beliefs. Make these be positively correlated in the population, but
    negatively correlated within each person.

    To be positively correlated in population, must have that generally A iff B.

    To be negatively correlated within people, must have that for each person, generally
    A iff ~B.
    """
    rng = np.random.default_rng(161020)

    # First, consider beliefs shared by majority of population, which fluctuate over time
    #   - At any point in time they have positive correlation in population
    #   - Over time they have zero correlation for each individual
    n = 10000
    timesteps = 2000
    ideology = rng.binomial(1, 0.5, size=n)
    b1 = rng.binomial(1, (1 - ideology) * 0.3 + ideology * 0.7, size=(timesteps, n))
    b2 = rng.binomial(1, (1 - ideology) * 0.3 + ideology * 0.7, size=(timesteps, n))
    within_corrs = stats.pearsonr(b1, b2, axis=0).statistic
    between_corrs = stats.pearsonr(b1, b2, axis=1).statistic

    fig, ax = plt.subplots(figsize=(5, 3), constrained_layout=True)
    ax.hist(within_corrs, density=True, alpha=0.7, label="Within-person")
    ax.hist(between_corrs, density=True, alpha=0.7, label="Between-person")
    ax.set_xlabel("Correlation")
    ax.set_ylabel("Probability density")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_xlim(-0.1, 0.25)
    ax.legend()

    plt.show()


if __name__ == "__main__":
    main()

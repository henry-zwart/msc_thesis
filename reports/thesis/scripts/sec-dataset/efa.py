import matplotlib.pyplot as plt
import numpy as np
import polars as pl
import polars.selectors as cs
import seaborn as sns
from statsmodels.multivariate.factor import Factor

from climate_attitudes import configure_mpl
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.parallel_analysis import pa_random_eigs, pa_true_eigs
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import (
    DIVERGING_CMAP,
)

RANDOM_SEED = 202607071803


def main(df: pl.DataFrame, labels: list[str]):
    X = df.drop("participant_id", "wave").to_numpy()

    # Parallel analysis to identify number of features
    rng = np.random.default_rng(RANDOM_SEED)
    true_eigs = pa_true_eigs(df)
    rand_eigs = pa_random_eigs(df, repeats=1_000, rng=rng)
    fig, ax = plt.subplots(figsize=(4, 2), constrained_layout=True)
    ax.plot(np.arange(len(true_eigs)), true_eigs, color="k", label="Data")
    ax.plot(
        np.arange(len(rand_eigs)),
        rand_eigs,
        color="k",
        linestyle="dashed",
        label="Random",
    )
    ax.set_xticks(np.arange(0, len(true_eigs), 2), np.arange(0, len(true_eigs), 2) + 1)
    ax.set_xlim(0, len(rand_eigs))
    ax.set_ylim(0, None)
    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)
    ax.set_xlabel("Sorted eigenvalue index (decreasing)")
    ax.set_ylabel("Eigenvalue")
    ax.legend()

    fig.savefig("reports/thesis/results/figures/dataset/parallel_analysis.pdf")

    n_factors = np.argmax(true_eigs < rand_eigs) + 1
    efa = Factor(X, n_factor=n_factors).fit()

    fig, ax = plt.subplots()
    sns.heatmap(
        efa.loadings.T,
        center=0,
        cmap=DIVERGING_CMAP,
        vmin=-1,
        vmax=1,
        linewidths=1,
        annot=True,
        fmt=".1f",
    )
    ax.set_xticks(
        np.arange(efa.loadings.shape[0]) + 0.5,
        labels,
        rotation=45,
        horizontalalignment="right",
    )
    fig.savefig("reports/thesis/results/figures/dataset/efa.pdf", bbox_inches="tight")

    # fig.savefig(
    #     "reports/thesis/results/figures/dataset/full_subset_partial_corr.pdf",
    #     bbox_inches="tight",
    # )


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    schema = schema.pre_index()
    survey_cols = schema.get_cols("survey")
    labels = schema.get_short_names("measurement")
    resp = (
        dataset.response.select(*survey_cols, *schema.get_cols("measurement"))
        .with_columns(cs.exclude(*survey_cols) / cs.exclude(*survey_cols).abs().max())
        .collect()
    )

    main(resp, labels)

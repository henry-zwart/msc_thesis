import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars.selectors as cs
import scipy as sp

from climate_attitudes import configure_mpl
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.feature_clustering import LinkageMethod, features_linkage
from climate_attitudes.settings import Config


def main(X: npt.NDArray[np.float64], labels: list[str]):
    linkage_mat = features_linkage(X, method=LinkageMethod.COMPLETE)
    fig, ax = plt.subplots(figsize=(4.5, 2.5), constrained_layout=True)
    sp.cluster.hierarchy.dendrogram(
        linkage_mat,
        labels=labels,
        orientation="top",
        ax=ax,
        leaf_font_size=8,
        leaf_rotation=90,
    )
    # ax.tick_params("x", rotation=35, horizontalalignment="right")
    ax.set_yticks([])
    ax.spines.left.set_visible(False)
    ax.spines.right.set_visible(False)
    ax.spines.top.set_visible(False)
    ax.spines.bottom.set_visible(False)
    fig.savefig(
        "reports/thesis/results/figures/dataset/full_subset_dendrogram.pdf",
        bbox_inches="tight",
    )


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

    main(resp.drop(*survey_cols).to_numpy(), labels)

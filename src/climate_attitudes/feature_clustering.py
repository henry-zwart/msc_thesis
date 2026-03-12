from enum import StrEnum

import numpy as np
import numpy.typing as npt
from sklearn.cluster import FeatureAgglomeration


class LinkageMethod(StrEnum):
    SINGLE = "single"
    COMPLETE = "complete"
    AVERAGE = "average"


def features_linkage(
    X: npt.NDArray[np.float64 | np.int64], method: LinkageMethod = LinkageMethod.SINGLE
) -> npt.NDArray[np.float64]:
    """Runs scikit-learn feature agglomeration, returning linkage matrix.

    X has shape M by N with M observations in N dimensions.
    """
    M, N = X.shape

    fa = FeatureAgglomeration(
        compute_distances=True, compute_full_tree=True, linkage=method
    )
    fa.fit(X)

    Z = np.empty((N - 1, 4), dtype=np.float64)
    for i in range(N - 1):
        merged_clusters = fa.children_[i]
        merge_dist = fa.distances_[i]

        left, right = merged_clusters
        left_n_obs = 1 if left < N else Z[left - N, 3]
        right_n_obs = 1 if right < N else Z[right - N, 3]
        cluster_n_obs = left_n_obs + right_n_obs

        Z[i, [0, 1]] = merged_clusters.astype(np.float64)
        Z[i, 2] = merge_dist
        Z[i, 3] = np.float64(cluster_n_obs)

    return Z

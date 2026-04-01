from dataclasses import dataclass
from enum import StrEnum

import numpy as np
import numpy.typing as npt
from sklearn.decomposition import PCA
from statsmodels.api import Factor
from statsmodels.multivariate.factor import FactorResults


@dataclass
class IndexResult:
    index: npt.NDArray[np.float64]
    result: PCA | FactorResults


class Index(StrEnum):
    PCA = "pca"
    EFA = "efa"

    def eval(self, X: npt.NDArray[np.float64]) -> IndexResult:
        # Standardise columns
        X = (X - X.mean(axis=0)) / X.std(axis=0)

        match self:
            case Index.PCA:
                pca = PCA(n_components=1)
                pca.fit(X)
                result = IndexResult(
                    index=pca.transform(X).flatten(),
                    result=pca,
                )
            case Index.EFA:
                efa = Factor(X, n_factor=1).fit()
                result = IndexResult(
                    index=efa.factor_scoring().flatten(),
                    result=efa,
                )
        return result

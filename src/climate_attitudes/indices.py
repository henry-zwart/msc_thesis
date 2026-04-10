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
    result: PCA | FactorResults | None


class IndexMethod(StrEnum):
    PCA = "pca"
    EFA = "efa"
    AVERAGE = "average"

    def eval(self, X: npt.NDArray[np.float64]) -> IndexResult:
        # Standardise columns
        X = (X - X.mean(axis=0)) / X.std(axis=0)

        match self:
            case IndexMethod.PCA:
                pca = PCA(n_components=1)
                pca.fit(X)
                result = IndexResult(
                    index=pca.transform(X).flatten(),
                    result=pca,
                )
            case IndexMethod.EFA:
                efa = Factor(X, n_factor=1).fit()
                result = IndexResult(
                    index=efa.factor_scoring(method="reg").flatten(),
                    result=efa,
                )
            case IndexMethod.AVERAGE:
                result = IndexResult(
                    index=X.mean(axis=1),
                    result=None,
                )
        return result

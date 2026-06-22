from pathlib import Path

import numpy as np

CHECK_DIR = Path("reports/thesis/results/data/model/all_interventions")


def main():
    MODELS = {"Ising": "ising", "Symmetric Ising": "sym_ising"}
    DELTAS = [0.0, 0.5, 1.0]
    COV_FLAGS = ["yes_use_covariates", "no_use_covariates"]
    check = {
        model: {delta: {cf: None for cf in COV_FLAGS} for delta in DELTAS}
        for model in MODELS
    }
    for model, model_fp_name in MODELS.items():
        for delta in DELTAS:
            delta_str = str(delta)
            if delta_str[1] != ".":
                raise ValueError(f"Expected delta < 10; found {delta}.")
            delta_fp_name = f"{delta_str[0]}{delta_str[2:]}"
            for cov_flag in COV_FLAGS:
                fp = CHECK_DIR / f"{model_fp_name}_{delta_fp_name}_{cov_flag}.npz"
                check[model][delta][cov_flag] = np.load(fp)["checks"]

    checks = {
        (model, delta, cov_flag): cf_checks
        for model, model_checks in check.items()
        for delta, delta_checks in model_checks.items()
        for cov_flag, cf_checks in delta_checks.items()
    }

    found_error = False
    for config, cks in checks.items():
        for other_config, other_cks in checks.items():
            if not np.isclose(cks, other_cks).all():  # ty: ignore
                print(f"RNG Error: {config} !~ {other_config}")
                found_error = True
    if found_error:
        raise RuntimeError(
            "All-interventions experiment: some runs used different RNGs."
        )

    with Path("reports/thesis/results/verification/model/all_interventions.txt").open(
        "w"
    ) as f:
        f.write("true")


if __name__ == "__main__":
    main()

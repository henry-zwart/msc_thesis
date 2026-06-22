import re
import sys

if __name__ == "__main__":
    # Skip filename
    param_string, extract_item = sys.argv[1:]
    mat = re.match(
        r"^(ising|sym_ising)_((yes|no)_use_covariates)_((yes|no)_structure)$",
        param_string,
    )
    if mat is None:
        raise RuntimeError(f"Invalid filename: {param_string}")

    match extract_item:
        case "model":
            print(mat.group(1))
        case "cov_flag":
            print(f"--{mat.group(2).replace('yes_', '').replace('_', '-')}")
        case "adj_flag":
            print(True)

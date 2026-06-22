import re
import sys

if __name__ == "__main__":
    # Skip filename
    param_string = sys.argv[1]
    mat = re.match(
        r"^(asym_ising|sym_ising)$",
        param_string,
    )
    if mat is None:
        raise RuntimeError(f"Invalid filename: {param_string}")

    if mat.group(1) == "asym_ising":
        print("ising")
    else:
        print(mat.group(1))

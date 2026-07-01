import re
import sys

if __name__ == "__main__":
    # Skip filename
    param_string, extract_item = sys.argv[1:]
    mat = re.match(r"^(ising|sym_ising)_(\d+).npz$", param_string)
    if mat is None:
        raise RuntimeError(f"Invalid filename: {param_string}")

    match extract_item:
        case "model":
            print(mat.group(1))
        case "delta":
            print(
                f"{mat.group(2)[0]}.{mat.group(2)[1:] if len(mat.group(2)) > 1 else 0}"
            )

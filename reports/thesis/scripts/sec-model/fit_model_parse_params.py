import re
import sys

if __name__ == "__main__":
    # Skip filename
    param_string, extract_item = sys.argv[1:]
    mat = re.match(
        r"^(.*)_(asym_ising|sym_ising)_((yes|no)_structure)$",
        param_string,
    )
    if mat is None:
        raise RuntimeError(f"Invalid filename: {param_string}")

    if mat.group(1) == "full":
        filter_resp = ""
    else:
        filter_mat = re.match(r"^(.*)_(\d+)$", mat.group(1))
        if filter_mat is None:
            raise RuntimeError(f"Invalid filter condition in filename: {mat.group(1)}")
        filter_col = filter_mat.group(1)
        filter_val = filter_mat.group(2)
        filter_resp = f"--filter-column {filter_col} --filter-value {filter_val}"

    match extract_item:
        case "filter":
            print(filter_resp)
        case "model":
            if mat.group(2) == "asym_ising":
                print("ising")
            else:
                print(mat.group(2))
        case "adj_flag":
            print(mat.group(3) == "yes_structure")

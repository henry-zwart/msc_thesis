from climate_attitudes.settings import Config, StaticAsset, BuiltAsset
import json
import polars as pl


def build_item_columns_table(config: Config) -> pl.DataFrame:
    # Load additional columns
    with StaticAsset.ItemColumns.filepath(config).open("r") as f:
        additional_columns = json.load(f)

    # Create DataFrame with each item_name and all corresponding columns
    data = {"item_name": [], "column_name": []}
    item_names = BuiltAsset.Codebook.load(config).select("item_name").to_series()
    for item in item_names:
        data["item_name"].append(item)
        data["column_name"].append(item)
        for extra_col in additional_columns.get(item, []):
            data["item_name"].append(item)
            data["column_name"].append(extra_col)

    return pl.DataFrame(data)

from climate_attitudes.schema.extract import OutputItemColumnsSchema
from climate_attitudes.settings import Config, StaticAsset, InterimAsset
import json
import polars as pl
import pandera.polars as pa
from pandera.typing.polars import DataFrame


@pa.check_types
def build_item_columns_table(config: Config) -> DataFrame[OutputItemColumnsSchema]:
    # Load additional columns
    with StaticAsset.ItemColumns.filepath(config).open("r") as f:
        additional_columns = json.load(f)

    # Create DataFrame with each item_name and all corresponding columns
    data = {"item_name": [], "column_name": []}
    item_names = InterimAsset.Codebook.load(config).select("item_name").to_series()
    for item in item_names:
        data["item_name"].append(item)
        data["column_name"].append(item)
        for extra_col in additional_columns.get(item, []):
            data["item_name"].append(item)
            data["column_name"].append(extra_col)

    # Add corresponding item_id column
    item = InterimAsset.Item.scan(config).select(
        pl.col("name").alias("item_name"), "item_id"
    )
    item_columns = pl.LazyFrame(data).join(item, on="item_name", how="left")

    # Re-order columns
    item_columns = item_columns.select("item_id", "item_name", "column_name")

    return item_columns.unique(maintain_order=True).collect()

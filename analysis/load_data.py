import polars as pl


def main():
    df = pl.read_parquet(
        "~/data/msc_thesis/climate-attitudes/w1w2w3w4w5_indices_weights_jul12_2022.parquet"
    )
    print(df.glimpse())

    # Collect columns according to category


if __name__ == "__main__":
    main()

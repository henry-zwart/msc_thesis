import polars as pl

import seaborn as sns


from climate_attitudes.settings import Config
from climate_attitudes.dataset import Dataset


def main():
    config = Config(_env_file="../../.env")
    data = Dataset.load(config)

    worry_dt = pl.Enum(
        ["Not at all", "Only a little", "A moderate amount", "A great deal"]
    )
    df = (
        data.response.select(
            (
                pl.col("ew1").is_not_null() & (pl.col("ew1") != ["None of the above"])
            ).alias("Recent extreme weather"),
            (pl.col("ew5") - 1).cast(worry_dt).alias("Extreme weather worry"),
            (pl.col("cc1").replace({1: 2, 99: 1}) / 2).alias("Belief: CC Happening"),
        )
    ).collect()

    fig1 = sns.lmplot(
        df.to_pandas(), y="Belief: CC Happening", x="Recent extreme weather"
    )
    fig1.savefig("figures/cc_collider_unbiased.pdf", bbox_inches="tight", dpi=300)

    fig2 = sns.lmplot(
        df.to_pandas(),
        y="Belief: CC Happening",
        x="Recent extreme weather",
        hue="Extreme weather worry",
    )

    fig2.savefig("figures/cc_collider_biased.pdf", bbox_inches="tight", dpi=300)


if __name__ == "__main__":
    main()

import polars as pl

# `cc_rank` and condition
# For all rows with a ranking, concat the ranks


def cc_rank():
    N_RANKS = 4

    def cc_rank_i(i: int):
        return (
            # Concat i'th rank columns across experimental conditions
            pl.concat_list(pl.col(f"^cc_rank\\d_{i}$"))
            # Drop the nulls (keeping only the true experiment condition rank)
            .list.drop_nulls()
            .list.first()
            .alias(f"cc_rank_{i}")
        )

    ith_rank_exprs = [cc_rank_i(i) for i in range(1, N_RANKS + 1)]
    return (
        pl.when(pl.all_horizontal(*[expr.is_not_null() for expr in ith_rank_exprs]))
        .then(pl.concat_list(ith_rank_exprs))
        .otherwise(None)
        .alias("cc_rank")
    )


def cc_rank_condition():
    return (
        pl.concat_list(pl.col(r"^ccrank\d$"))
        # Find index of unique column with "1"
        .list.arg_max()
        + 1
    ).alias("_cc_rank_condition")

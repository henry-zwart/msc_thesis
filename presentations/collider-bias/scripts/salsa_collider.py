import numpy as np
import matplotlib.pyplot as plt


def main():
    rng = np.random.default_rng(111321)

    n = 150

    good_at_fancy_moves = rng.beta(a=2, b=5, size=n)
    good_at_basic_moves = rng.beta(a=2, b=5, size=n)

    award = 0.65 * good_at_fancy_moves + 0.85 * good_at_basic_moves > 0.7

    me = 48

    is_me = np.full_like(award, fill_value=False)
    is_me[me] = True

    fig, ax = plt.subplots(figsize=(6, 4), constrained_layout=True)

    ax.scatter(
        x=good_at_basic_moves[~award & ~is_me],
        y=good_at_fancy_moves[~award & ~is_me],
        s=20,
        color="tab:grey",
        alpha=0.5,
        label="No award",
    )
    ax.scatter(
        x=good_at_basic_moves[award & ~is_me],
        y=good_at_fancy_moves[award & ~is_me],
        s=20,
        color="tab:orange",
        label="Award",
    )
    ax.scatter(
        x=good_at_basic_moves[is_me],
        y=good_at_fancy_moves[me],
        s=60,
        color="tab:red",
        marker="x",
        label="Me",
    )

    m, y0 = np.polyfit(good_at_basic_moves[award], good_at_fancy_moves[award], deg=1)
    xn = (0 - y0) / m

    ax.plot([0, xn], [y0, 0], color="grey", linestyle="dashed", linewidth=1, zorder=0)

    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_xlim(0, 0.8)
    ax.set_ylim(0, 0.8)

    ax.set_xlabel("Skill at basic moves")
    ax.set_ylabel("Skill at fancy moves")

    ax.legend()

    ax.set_title("Salsa awards")

    fig.savefig("figures/salsa_collider.pdf", bbox_inches="tight", dpi=300)

    # Re-plot, but for climate worry axes
    fig, ax = plt.subplots(figsize=(6, 4), constrained_layout=True)

    ax.scatter(
        x=good_at_basic_moves[~award],
        y=good_at_fancy_moves[~award],
        s=20,
        color="tab:grey",
        alpha=0.5,
        label="Not very worried",
    )
    ax.scatter(
        x=good_at_basic_moves[award],
        y=good_at_fancy_moves[award],
        s=20,
        color="tab:orange",
        label="Worried",
    )

    ax.plot([0, xn], [y0, 0], color="grey", linestyle="dashed", linewidth=1, zorder=0)

    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_xlim(0, 0.8)
    ax.set_ylim(0, 0.8)

    ax.set_xlabel("Recent extreme weather exposure")
    ax.set_ylabel("Belief that climate change is happening")

    ax.legend()

    fig.savefig("figures/ew_worry_collider.pdf", bbox_inches="tight", dpi=300)


if __name__ == "__main__":
    main()

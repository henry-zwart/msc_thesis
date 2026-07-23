from __future__ import annotations

import json
from collections import deque
from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import seaborn as sns
from matplotlib.figure import Figure
from sklearn.model_selection import RepeatedKFold, cross_validate
from sklearn.tree import DecisionTreeRegressor

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.visualisation import DIVERGING_CMAP, configure_mpl

ANNOTATIONS = {
    (-1.0, -1.0): "EL",  # Extremely low
    (-1.0, -0.5): "VL",  # Very low
    (-1.0, 0): "L",  # Low
    (-1.0, 0.5): "~VH",  # Not (very high)
    (-1.0, 1.0): "A",  # Any
    (-0.5, 0.0): "SL",  # Slightly low
    (-0.5, 0.5): "N",  # Neutral
    (-0.5, 1.0): "~VL",  # Not (very low)
    (0.0, 0.0): "VN",  # Very neutal
    (0.0, 0.5): "SH",  # Somewhat high
    (0.0, 1.0): "H",  # High
    (0.5, 1.0): "VH",  # Very high
    (1.0, 1.0): "EH",  # Extremely high
}


class InterventionStrength(StrEnum):
    NULL = "null"
    WEAK = "weak"
    MODERATE = "moderate"
    STRONG = "strong"

    def delta(self) -> float:
        match self:
            case InterventionStrength.NULL:
                return 0.0
            case InterventionStrength.WEAK:
                return 0.5
            case InterventionStrength.MODERATE:
                return 1.5
            case InterventionStrength.STRONG:
                return 2.5

    def delta_str(self) -> str:
        delta = self.delta()
        return str(delta).replace(".", "")


@dataclass
class Leaf:
    prediction: float | list[float]
    samples: int


@dataclass
class Node:
    feature_idx: int
    feature_name: str
    threshold: float
    samples: int
    children: tuple[Node | Leaf | None, Node | Leaf | None]


def make_tree_recursive(root_idx: int, clf_tree, labels: list[str]) -> Node | Leaf:
    left_child_idx = clf_tree.children_left[root_idx]
    right_child_idx = clf_tree.children_right[root_idx]

    match left_child_idx, right_child_idx:
        case (-1, -1):
            return Leaf(
                clf_tree.value[root_idx].item(), int(clf_tree.n_node_samples[root_idx])
            )
        case (_, -1):
            left_child = make_tree_recursive(left_child_idx, clf_tree, labels)
            right_child = None
        case (-1, _):
            left_child = None
            right_child = make_tree_recursive(right_child_idx, clf_tree, labels)
        case _:
            left_child = make_tree_recursive(left_child_idx, clf_tree, labels)
            right_child = make_tree_recursive(right_child_idx, clf_tree, labels)

    feature_idx = int(clf_tree.feature[root_idx])
    feature_name = str(labels[feature_idx])
    threshold = float(clf_tree.threshold[root_idx])
    samples = int(clf_tree.n_node_samples[root_idx])
    return Node(
        feature_idx, feature_name, threshold, samples, (left_child, right_child)
    )


def prune_tree(tree: Node | Leaf | None, le: float, ge: float) -> Node | Leaf | None:
    # If leaf and don't satisfy bounds, prune.
    if isinstance(tree, Leaf):
        if isinstance(tree.prediction, list):
            raise TypeError("Unexpected list prediction type.")
        if ge <= tree.prediction <= le:
            return tree
        else:
            return None
    elif tree is None:
        return None

    # If node, first recurse on children...
    new_left_child = prune_tree(tree.children[0], le, ge)
    new_right_child = prune_tree(tree.children[1], le, ge)

    # Then if both children have been pruned, prune the whole node
    if new_left_child is None and new_right_child is None:
        return None

    # Otherwise reassign the children, update sample count, and return self
    tree.children = (new_left_child, new_right_child)
    tree.samples = 0
    for child in tree.children:
        if child is not None:
            tree.samples += child.samples

    return tree


def merge_on_coverings(tree: Node | Leaf | None) -> Node | Leaf | None:
    # If leaf, return self. If node, merge subtrees.
    match tree:
        case None | Leaf():
            return tree
        case Node(children=(c1, c2)):
            tree.children = (merge_on_coverings(c1), merge_on_coverings(c2))

    # Then (if node), if both children are leaves, replace current node be leaf
    left, right = tree.children
    if isinstance(left, Leaf) and isinstance(right, Leaf):
        left_predictions = (
            [left.prediction]
            if isinstance(left.prediction, (float, int))
            else left.prediction
        )
        right_predictions = (
            [right.prediction]
            if isinstance(right.prediction, (float, int))
            else right.prediction
        )
        return Leaf(
            prediction=sorted(left_predictions + right_predictions),
            samples=tree.samples,
        )

    # Otherwise, return self
    return tree


def extract_rule_tree(
    clf, labels: list[str], le: float | None = None, ge: float | None = None
) -> Node | Leaf:
    _le = le or np.inf
    _ge = ge or -np.inf

    clf_tree = clf.tree_

    # Construct full tree
    tree = make_tree_recursive(0, clf_tree, labels)

    # Prune subtrees which don't satisfy bounds
    tree = prune_tree(tree, _le, _ge)

    # Merge subtrees where whole feature range is covered
    tree = merge_on_coverings(tree)

    if tree is None:
        raise RuntimeError("Tree is empty!")

    return tree


@dataclass
class Interval:
    lower: float = -1.0
    upper: float = 1.0

    def __hash__(self):
        return hash((self.lower, self.upper))

    def midpoint(self) -> float:
        return (self.lower + self.upper) / 2


@dataclass
class RuleNode:
    feature_idx: int
    feature_name: str
    interval: Interval

    def __hash__(self):
        return hash((self.feature_idx, self.feature_name, self.interval))


def extract_rules(
    clf, labels: list[str], le: float | None = None, ge: float | None = None
) -> list[tuple[RuleNode, ...]]:
    tree = extract_rule_tree(clf, labels, le, ge)

    if isinstance(tree, Leaf):
        return []

    # Create list of paths from root to leaves
    paths = []
    queue = deque()
    queue.append([(None, tree)])
    while queue:
        path = queue.popleft()
        _, head = path[-1]

        for pos, child in zip(("left", "right"), head.children, strict=True):
            new_path = path + [(pos, child)]
            if isinstance(child, Node):
                queue.append(new_path)
            elif isinstance(child, Leaf):
                paths.append(new_path)

    # Convert each path to a collection of rule nodes
    rules = []
    for path in paths:
        rule: dict[int, RuleNode] = dict()
        feature_idx = path[0][1].feature_idx
        feature_name = path[0][1].feature_name
        threshold = float(
            np.round(np.round(path[0][1].threshold / 0.5) * 0.5, decimals=1)
        )
        for pos, node in path[1:]:
            rule_node = rule.setdefault(
                feature_idx, RuleNode(feature_idx, feature_name, Interval())
            )
            if pos == "left":
                rule_node.interval.upper = min(rule_node.interval.upper, threshold)
            elif pos == "right":
                rule_node.interval.lower = max(rule_node.interval.lower, threshold)
            else:
                raise ValueError(f"Unexpected value for pos: {pos}.")

            if isinstance(node, Leaf):
                rules.append(list(rule.values()))
                break
            elif not isinstance(node, Node):
                raise TypeError(f"Unexpected node type: {type(node)}")
            feature_idx = node.feature_idx
            feature_name = node.feature_name
            threshold = float(
                np.round(np.round(node.threshold / 0.5) * 0.5, decimals=1)
            )

    # Sort rules by feature idx and convert to tuple
    rules = [tuple(sorted(rule, key=lambda r: r.feature_idx)) for rule in rules]
    return rules


@dataclass
class PersonaAnalysisRules:
    models: dict[InterventionStrength, DecisionTreeRegressor]
    rules: list[tuple[tuple[RuleNode, ...], list[InterventionStrength]]]
    prevalence: npt.NDArray[np.float64]
    prevalence_mask: npt.NDArray[np.bool]
    prevalence_low_eff: npt.NDArray[np.float64]
    prevalence_low_eff_mask: npt.NDArray[np.bool]
    effect: npt.NDArray[np.float64]
    high_effect_threshold: dict[InterventionStrength, float]


def calculate_upper_percentile_prevalence(
    initial_state: npt.NDArray[np.float64],
    effect: npt.NDArray[np.float64],
    threshold: float,
    rule: tuple[RuleNode, ...],
) -> float:
    x0_high_effect = initial_state[effect >= threshold]
    x0_satisfy = x0_high_effect.copy()
    for rule_node in rule:
        lower = rule_node.interval.lower if rule_node.interval.lower > -1 else -1.1
        upper = rule_node.interval.upper if rule_node.interval.upper < 1 else 1.1
        satisfies = (lower < x0_satisfy[:, rule_node.feature_idx]) & (
            x0_satisfy[:, rule_node.feature_idx] <= upper
        )
        x0_satisfy = x0_satisfy[satisfies]
    return x0_satisfy.shape[0] / x0_high_effect.shape[0]


def calculate_lower_percentile_prevalence(
    initial_state: npt.NDArray[np.float64],
    effect: npt.NDArray[np.float64],
    threshold: float,
    rule: tuple[RuleNode, ...],
) -> float:
    x0_low_effect = initial_state[effect < threshold]
    x0_satisfy = x0_low_effect.copy()
    for rule_node in rule:
        lower = rule_node.interval.lower if rule_node.interval.lower > -1 else -1.1
        upper = rule_node.interval.upper if rule_node.interval.upper < 1 else 1.1
        satisfies = (lower < x0_satisfy[:, rule_node.feature_idx]) & (
            x0_satisfy[:, rule_node.feature_idx] <= upper
        )
        x0_satisfy = x0_satisfy[satisfies]
    return x0_satisfy.shape[0] / x0_low_effect.shape[0]


def cross_validation_r2(X0, Y, seed):
    tree = DecisionTreeRegressor(max_depth=3)
    cv = RepeatedKFold(n_splits=10, n_repeats=5, random_state=seed)
    tree_scores = cross_validate(tree, X0, Y, cv=cv, scoring="r2")
    print(tree_scores["test_score"].mean())


def analyse_effective_interventions(
    initial_state: npt.NDArray[np.float64],
    effect: npt.NDArray[np.float64],
    intervention_strengths: list[InterventionStrength],
    max_tree_depth: int,
    labels: list[str],
    high_effect_percentile: int,
    minimum_prevalence: float,
    seed: int,
) -> PersonaAnalysisRules:
    models = {}
    rules = {}
    high_effect_threshold = {}

    for strength_idx, strength in enumerate(intervention_strengths):
        # Fit shallow decision tree to predict intervention effect from initial state
        cross_validation_r2(initial_state, effect[strength_idx], seed)

        model = DecisionTreeRegressor(max_depth=max_tree_depth, random_state=seed).fit(
            initial_state, effect[strength_idx]
        )

        # Extract rules describing the initial states which lead to high effects
        threshold = np.percentile(effect[strength_idx], high_effect_percentile)

        _rules = extract_rules(model, labels, ge=threshold)

        models[strength] = model
        high_effect_threshold[strength] = threshold

        # Store rules --> strengths dict; allows to see shared rules
        for rule in _rules:
            if rule not in rules:
                rules[rule] = []
            rules[rule].append(strength)

    rules = list(rules.items())

    # Calculate prevlanece of each rule within top percentile for each strength
    prevalence = np.zeros((len(rules), len(intervention_strengths)), dtype=np.float64)
    prevalence_mask = np.ones_like(prevalence, dtype=np.bool)
    for rule_idx, (rule, strengths) in enumerate(rules):
        for strength_idx, maybe_strength in enumerate(intervention_strengths):
            if maybe_strength not in strengths:
                continue
            prevalence[rule_idx, strength_idx] = calculate_upper_percentile_prevalence(
                initial_state,
                effect[strength_idx],
                high_effect_threshold[maybe_strength],
                rule,
            )
            prevalence_mask[rule_idx, strength_idx] = False

    prevalence_low_eff = np.zeros(
        (len(rules), len(intervention_strengths)), dtype=np.float64
    )
    prevalence_low_eff_mask = np.ones_like(prevalence_low_eff, dtype=np.bool)
    for rule_idx, (rule, strengths) in enumerate(rules):
        for strength_idx, maybe_strength in enumerate(intervention_strengths):
            if maybe_strength not in strengths:
                continue
            prevalence_low_eff[rule_idx, strength_idx] = (
                calculate_lower_percentile_prevalence(
                    initial_state,
                    effect[strength_idx],
                    high_effect_threshold[maybe_strength],
                    rule,
                )
            )
            prevalence_low_eff_mask[rule_idx, strength_idx] = False

    # Filter out rules which are below the minimum required prevalence in data
    keep_rules = prevalence.max(axis=1) >= minimum_prevalence
    prevalence = prevalence[keep_rules]
    prevalence_mask = prevalence_mask[keep_rules]
    prevalence_low_eff = prevalence_low_eff[keep_rules]
    prevalence_low_eff_mask = prevalence_low_eff_mask[keep_rules]
    rules = [r for i, r in enumerate(rules) if keep_rules[i]]

    return PersonaAnalysisRules(
        models,
        rules,
        prevalence,
        prevalence_mask,
        prevalence_low_eff,
        prevalence_low_eff_mask,
        effect,
        high_effect_threshold,
    )


@dataclass
class PlotData:
    intervention_idx: int
    intervention_label: str
    high_effect_threshold: dict[InterventionStrength, float]
    effect: npt.NDArray[np.float64]
    heatmap_vals: npt.NDArray[np.float64]
    heatmap_mask: npt.NDArray[np.bool]
    heatmap_annot: npt.NDArray[np.str_]
    prevalence: npt.NDArray[np.float64]
    prevalence_mask: npt.NDArray[np.bool]
    prevalence_low_eff: npt.NDArray[np.float64]
    prevalence_low_eff_mask: npt.NDArray[np.bool]
    labels: npt.NDArray[np.str_]


def make_plot_data(
    intervention_idx: int,
    analysis_results: PersonaAnalysisRules,
    labels: npt.NDArray[np.str_],
    use_labels: npt.NDArray[np.bool],
) -> PlotData:
    intervention_label = labels[intervention_idx]
    rules = analysis_results.rules

    # Calculate rule heatmap midpoints; determine annotations
    heatmap_vals = np.zeros((len(rules), len(labels)), dtype=np.float64)
    heatmap_mask = np.ones_like(heatmap_vals, dtype=np.bool)
    heatmap_annots = [["" for _ in range(len(labels))] for _ in range(len(rules))]
    for rule_idx, (rule, _) in enumerate(rules):
        for node in rule:
            heatmap_vals[rule_idx, node.feature_idx] = node.interval.midpoint()
            heatmap_annots[rule_idx][node.feature_idx] = ANNOTATIONS[
                (node.interval.lower, node.interval.upper)
            ]
            heatmap_mask[rule_idx, node.feature_idx] = False
    heatmap_annots = np.asarray(heatmap_annots)

    # Remove any columns which don't feature in any rules
    heatmap_vals = heatmap_vals[:, use_labels]
    heatmap_mask = heatmap_mask[:, use_labels]
    heatmap_annots = heatmap_annots[:, use_labels]
    labels = labels[use_labels]

    # Re-order rows such that prevalence is in decreasing binary order
    prevalence_mask = analysis_results.prevalence_mask
    weights = 2 ** np.arange(prevalence_mask.shape[1] - 1, -1, -1)
    values = prevalence_mask @ weights
    row_idxes = np.argsort(values)

    # Apply the re-orderings
    heatmap_vals = heatmap_vals[row_idxes]
    heatmap_annots = heatmap_annots[row_idxes]
    heatmap_mask = heatmap_mask[row_idxes]
    analysis_results.prevalence = analysis_results.prevalence[row_idxes]
    analysis_results.prevalence_mask = analysis_results.prevalence_mask[row_idxes]
    analysis_results.prevalence_low_eff = analysis_results.prevalence_low_eff[row_idxes]
    analysis_results.prevalence_low_eff_mask = analysis_results.prevalence_low_eff_mask[
        row_idxes
    ]

    return PlotData(
        intervention_idx,
        intervention_label,
        analysis_results.high_effect_threshold,
        analysis_results.effect,
        heatmap_vals,
        heatmap_mask,
        heatmap_annots,
        analysis_results.prevalence,
        analysis_results.prevalence_mask,
        analysis_results.prevalence_low_eff,
        analysis_results.prevalence_low_eff_mask,
        labels,
    )


def occurrence_entropy(vals: npt.NDArray[np.float64]) -> npt.NDArray[np.float64]:
    entropy = np.zeros(vals.shape[-1])
    for i in range(vals.shape[-1]):
        value_counts = np.unique_counts(vals[:, i])
        is_nonzero = ~np.isclose(value_counts.values, 0.0)
        counts = value_counts.counts[is_nonzero]
        props = counts / counts.sum()
        entropy[i] = -(props * np.log(props)).sum()
    return entropy


def order_rule_columns(plot_data: list[PlotData]) -> list[PlotData]:
    """Re-order columns in personas/rules.

    Order by:
    1. Decreasing proportion of occurrence across points of intervention
    2. Increasing entropy
    3. Decreasing upper quartile threshold
    """
    occurrence = np.asarray([~pd.heatmap_mask.all(axis=0) for pd in plot_data])
    occurrence = occurrence.sum(axis=0) / occurrence.shape[0]
    entropy = occurrence_entropy(np.concat([pd.heatmap_vals for pd in plot_data]))
    threshold = np.zeros_like(occurrence, dtype=np.float64)
    for i, label in enumerate(plot_data[0].labels):
        for pd in plot_data:
            if pd.intervention_label != label:
                continue
            threshold[i] = max(pd.high_effect_threshold.values())
    sort_vals = [
        (-occ, ent, -thresh)
        for occ, ent, thresh in zip(occurrence, entropy, threshold, strict=True)
    ]
    sort_idx = list(sorted(range(len(sort_vals)), key=lambda i: sort_vals[i]))

    for pd in plot_data:
        pd.heatmap_vals = pd.heatmap_vals[:, sort_idx]
        pd.heatmap_mask = pd.heatmap_mask[:, sort_idx]
        pd.heatmap_annot = pd.heatmap_annot[:, sort_idx]
        pd.labels = pd.labels[sort_idx]

    return plot_data


def make_figure(plot_data: list[PlotData]) -> Figure:
    # Determine max width of rule heatmap; trim matrices to size
    # n_heatmap_cols = max((~d.heatmap_mask.all(axis=0)).sum() for d in plot_data)
    # for d in plot_data:
    #     d.heatmap_vals = d.heatmap_vals[:, :n_heatmap_cols]
    #     d.heatmap_mask = d.heatmap_mask[:, :n_heatmap_cols]
    #     d.heatmap_annot = d.heatmap_annot[:, :n_heatmap_cols]
    #     d.labels = d.labels[:n_heatmap_cols]

    # Determine figure size from number of intervention idxes and rules
    n_heatmap_cols = plot_data[0].labels.size
    height_per_row = 0.525
    tick_height = 0.75
    H = height_per_row * sum(pd.heatmap_vals.shape[0] for pd in plot_data) + tick_height
    W = height_per_row * 9.0
    print(f"figsize=({W:.2f},{H:.2f})")
    # H = 1.3 * len(plot_data)
    # W = (H / len(plot_data)) * 5.5
    n_strength_cols = plot_data[0].prevalence.shape[-1]
    fig, grid_axes = plt.subplots(
        nrows=len(plot_data),
        ncols=3,
        figsize=(W, H),
        constrained_layout=True,
        gridspec_kw={
            "width_ratios": [2.75, n_heatmap_cols, n_strength_cols * 2],
            "height_ratios": [d.heatmap_vals.shape[0] for d in plot_data],
            "wspace": 0.15,
            "hspace": 0.01,
        },
    )

    # Plot KDEs in first column
    KDE_COLOUR = "#BB5566"

    max_intervention_strength = next(iter(plot_data[0].high_effect_threshold.keys()))
    for strength in InterventionStrength:
        if strength in plot_data[0].high_effect_threshold:
            max_intervention_strength = strength

    kde_xlims = [np.inf, -np.inf]
    for di, d in enumerate(plot_data):
        threshold = d.high_effect_threshold[max_intervention_strength]
        effect = d.effect[-1]
        colour = KDE_COLOUR
        sns.kdeplot(
            effect,
            clip=(None, threshold),
            color=colour,
            fill=True,
            alpha=0.3,
            ax=grid_axes[di, 0],
        )
        sns.kdeplot(
            effect,
            clip=(threshold, None),
            color=colour,
            fill=True,
            alpha=0.6,
            ax=grid_axes[di, 0],
        )
        grid_axes[di, 0].set_box_aspect(d.heatmap_vals.shape[0] / 3)

        kde_xlims[0] = min(kde_xlims[0], d.effect[-1].min())
        kde_xlims[1] = max(kde_xlims[1], d.effect[-1].max())

    for i in range(len(plot_data)):
        if i != (len(plot_data) - 1):
            grid_axes[i, 0].set_xticks([])
        else:
            grid_axes[i, 0].set_xticks([0.15, 0.3])
            # grid_axes[i, 0].set_xlabel("Int. Effect", fontsize=11)
        grid_axes[i, 0].set_xlim(*kde_xlims)
        grid_axes[i, 0].spines.top.set_visible(False)
        grid_axes[i, 0].spines.right.set_visible(False)
        grid_axes[i, 0].set_ylabel("")
    fig.supylabel("Density", fontsize=11)

    fig.align_ylabels(grid_axes[:, 0])

    # Display rules as heatmap
    for di, d in enumerate(plot_data):
        sns.heatmap(
            d.heatmap_vals,
            vmin=-0.7,
            vmax=0.7,
            center=0,
            annot=d.heatmap_annot,
            fmt="",
            annot_kws={"fontsize": 10},
            mask=d.heatmap_mask,
            linewidths=1,
            cmap=DIVERGING_CMAP,
            ax=grid_axes[di, 1],
            square=True,
            cbar=False,
        )
        grid_axes[di, 1].set_yticks([])
        grid_axes[di, 1].set_xticks([])

    grid_axes[-1, 1].set_xticks(
        np.arange(n_heatmap_cols) + 0.5,
        d.labels,
        rotation=90,
        # horizontalalignment="right",
    )

    # Display prevalence in top percentile
    for di, d in enumerate(plot_data):
        sns.heatmap(
            np.concat((d.prevalence_low_eff, d.prevalence), axis=1),
            annot=True,
            fmt=".0%",
            annot_kws={"fontsize": 10},
            vmin=0,
            vmax=1,
            cmap="crest",
            cbar=False,
            linewidths=1,
            ax=grid_axes[di, 2],
            square=True,
            mask=np.concat((d.prevalence_low_eff_mask, d.prevalence_mask), axis=1),
        )
        grid_axes[di, 2].set_yticks([])
        if len(d.high_effect_threshold) > 1:
            strengths = [s.title() for s in d.high_effect_threshold]
            grid_axes[di, 2].set_xticks(
                np.arange(len(strengths)) + 0.5,
                strengths,
                rotation=35,
                horizontalalignment="right",
            )
        else:
            grid_axes[di, 2].set_xticks([])
    grid_axes[-1, 2].set_xticks(
        np.arange(2) + 0.5,
        ["Low effect", "High effect"],
        rotation=90,
    )

    # Label rows with the intervention spin label
    for di, d in enumerate(plot_data):
        # grid_axes[di, 2].set_ylabel(
        #     d.intervention_label,
        #     rotation=0,
        #     labelpad=40,
        #     verticalalignment="center",
        #     fontsize=11,
        # )
        # grid_axes[di, 2].yaxis.set_label_position("right")
        grid_axes[di, 2].text(
            1.0
            + 40
            / grid_axes[di, 2].get_window_extent().width,  # roughly mimics labelpad
            0.5,
            d.intervention_label,
            transform=grid_axes[di, 2].transAxes,
            rotation=0,
            verticalalignment="center",
            horizontalalignment="left",
            fontsize=11,
        )

    # Add titles to each column
    grid_axes[0, 0].set_title(r"$\Delta P(S_i^5 = +1)$", pad=10, fontsize=12)
    grid_axes[0, 1].set_title("Persona", pad=10, fontsize=12)
    grid_axes[0, 2].set_title("Prevalence", pad=10, fontsize=12, clip_on=False)
    # grid_axes[-1, 2].set_xticks(
    #     [0.5],
    #     ["Prevalence"],
    #     rotation=90,
    # )

    return fig


class InterventionPersonasPlotCommand(BaseCommand):
    simulation_results: Path
    activation_probability_null: Path
    activation_probability_intervention: list[Path]
    intervention: list[InterventionStrength]
    target_spin_idx: int
    max_tree_depth: int
    high_effect_percentile: int = 75
    prevalence_threshold: float = 0.15
    min_effect_threshold: float = 0.1
    seed: int = 20260622
    output: Path

    def cli_cmd(self) -> None:
        configure_mpl()

        # Load data
        simulation_results = np.load(self.simulation_results)
        initial_state = simulation_results["Y0"][:, 1]
        labels = simulation_results["labels"]

        null_probability = np.load(self.activation_probability_null)["p"]
        if null_probability.ndim != 4:
            raise ValueError(
                f"Expected probability file with 4 dimensions, found "
                f"{null_probability.ndim}. Did you set measure-time?"
            )
        null_probability = null_probability[..., self.target_spin_idx]

        R, M, N = null_probability.shape

        # (repeat, individual, intervention spin)
        effect = np.empty((len(self.intervention), R, M, N), dtype=np.float64)
        for i, int_path in enumerate(self.activation_probability_intervention):
            int_probability = np.load(int_path)["p"]
            if int_probability.ndim != 4:
                raise ValueError(
                    f"Expected probability file with 4 dimensions, found "
                    f"{null_probability.ndim}. Did you set measure-time?"
                )
            int_probability = int_probability[..., self.target_spin_idx]
            effect[i] = int_probability - null_probability

        mean_effect = effect.mean(axis=1)

        # Determine high-effect rules for each intervention spin
        high_effect_rules = {
            i: analyse_effective_interventions(
                initial_state,
                effect=mean_effect[..., i],
                intervention_strengths=self.intervention,
                max_tree_depth=self.max_tree_depth,
                labels=labels,
                high_effect_percentile=self.high_effect_percentile,
                minimum_prevalence=self.prevalence_threshold,
                seed=self.seed,
            )
            for i in range(N)
        }

        # Disregard any low-effect intervention idxes, and the self-intervention
        del high_effect_rules[self.target_spin_idx]
        to_remove = []
        for i, analysis_results in high_effect_rules.items():
            threshold = analysis_results.high_effect_threshold[self.intervention[-1]]
            if threshold < self.min_effect_threshold:
                to_remove.append(i)
        high_effect_rules = {
            i: analysis_results
            for i, analysis_results in high_effect_rules.items()
            if i not in to_remove
        }

        # Identify columns which don't feature in any rules.
        column_present = np.zeros(len(labels), dtype=np.bool)
        for analysis_results in high_effect_rules.values():
            for rule, _ in analysis_results.rules:
                for rule_node in rule:
                    column_present[rule_node.feature_idx] = True
        missing_columns = labels[~column_present]

        # Calculate plotting values for each rule
        plot_data = sorted(
            [
                make_plot_data(i, analysis_results, labels, column_present)
                for i, analysis_results in high_effect_rules.items()
            ],
            key=lambda d: -d.high_effect_threshold[self.intervention[-1]],
        )

        plot_data = order_rule_columns(plot_data)

        fig = make_figure(plot_data)
        fig.savefig(self.output, bbox_inches="tight")
        fig.savefig(self.output.with_suffix(".png"), bbox_inches="tight")

        with self.output.with_suffix(".json").open("w") as f:
            json.dump(
                {
                    "missing_columns": [str(c) for c in missing_columns],
                },
                f,
            )

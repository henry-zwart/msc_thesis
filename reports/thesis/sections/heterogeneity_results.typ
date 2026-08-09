#import "@local/drifting-cls-thesis:0.1.0": caption

#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *
#show: show-theorion

In this chapter we investigate individual heterogeneity in both intervention behaviour
and belief system structure in asymmetric, non-equilibrium belief system models.

While the previous chapter was primarily concerned with the _collective_ effects of
intervention, the distribution of expected effect of intervention across individuals
for inbound interventions targeting 'Climate Action' shows substantial variation between
survey participants (@fig:heterogeneity-results-cc-action-distribution). We begin this
chapter with an investigation into the conditions under which different interventions
targeting beliefs about climate action are likely to be effective.

#figure(
  image("../results/figures/model/intervention_effect_distribution/asym_25_cc_action.pdf"),
  caption: caption(
    short: [Individual effective of 'Climate Action 'interventions],
    long: [
      The expected effect of intervention for strong interventions #box[($delta_h = 2.5$)]
      targeting 'Climate Action' exhibits substantial variation between
      individuals.
    ],
  ),
) <fig:heterogeneity-results-cc-action-distribution>

We then consider how inferred belief system structure varies between individuals, or
subgroups in a population. In the previous chapter we identified political ideology as
a particularly influential belief, both through asymmetric interactions with
other variables
(@subsec:asymmetry-results-existence) and as an effective point-of-intervention for
interventions targeting attitudes toward climate action (@subsec:asymmetry-results-impact).
Here, we investigate whether this influence extends beyond pairwise interactions with
other variables by comparing asymmetric belief systems calibrated to the (self-reported)
liberal and conservative subpopulations within the climate beliefs dataset.


== Heterogeneity in intervention effects <sec:heterogeneity-results-intervention-effects>

In the intervention simulations described in the previous chapter, the only
distinguishing factor between survey participants is their binarised initial state
derived from the final wave of the climate beliefs dataset. It follows
that any difference in belief system dynamics between distinct individuals---after
accounting for simulation stochasticity---is the result of their different initial
states. To identify the conditions under which an intervention is effective,
it then suffices to characterise the set of _initial states_ which yield effective
interventions, and distinguish them from those that do not.

// This fundamentally boils down to a regression problem. To make this clear, let's reframe
// the above task.
Our goal is to find a function which maps from an intervention effect to
sets of (unbinarised) states that yield that effect, $g: RR -> 2^X$, where
#box[$X = [-1,+1]^N subset RR^N$]. We'll call $g$ the *effect characterisation function*.

Consider a function which does the opposite, mapping initial states to a measure of
intervention effect, $f: X -> RR$. Given such a function, we can straightforwardly
construct the corresponding effect characterisation function as:

$
  g: y mapsto {x in plus.minus 1^N subset RR^N | f(x) = y}
$ <eqn:heterogeneity-results-effect-characterisation-function>

However, while technically satisfying the definition of the effect
characterisation function, such a function would be useless for qualitatively
determining the kinds of initial states which yield effective interventions.
The elements of the codomain have (potentially) infinite cardinality, and are
not immediately interpretable. For our purposes, we are less interested in the
_specific_ states that yield a given intervention effect, but more so in a
_concise description_ of that set of states.

Regression decision tree models can provide such descriptions, using inequality bounds
to partition the initial state space into regions, each of which is assigned a
predicted effect. Given a parameterised regression decision tree, we
may construct a concise effect characterisation function by identifying, for each
predicted effect, the combination of inequalities which define the corresponding
infinite set of initial states. When the parameter estimation algorithm is restricted
to shallow trees (e.g., depth 3 or 4, referring to the number of inequality bounds
defining each region), these combinations can also be interpretable as rules or
_personas_.


#figure(
  image("../results/figures/model/heterogeneous_effects/climate_policy_treedepth_3.pdf"),
  caption: caption(
    short: [Characterisation of responsiveness to intervention],
    long: [
      Characterisation of initial states ('personas'; middle panel) which yield
      effective interventions when targeting `CC Action` using different
      points-of-intervention (rows). Intervention effect is measured as the difference
      in `CC Action` activation probability between intervention ($delta_h = 2.5$) and
      null (no-intervention) models at $t=5$, for the asymmetric belief model calibrated
      to the climate beliefs dataset. Differences in the population upper quartile are
      'high-effect'. (*Left*) Distribution of intervention effect
      across survey participants. (*Centre*) Typical high-effect personas estimated
      using a depth-3 regression decision tree. Rows are distinct personas. Cells
      correspond to intervals of initial state dimensions ($L = [-1, 0]$, $H = [0, +1]$).
      (*Right*) Prevalence of each persona in the high-effect and low-effect
      subpopulations.
    ],
  ),
) <fig:heterogeneity-results-interventions-personas>

@fig:heterogeneity-results-interventions-personas shows the effect characterisation
functions for different interventions targeting `CC Action`, obtained from shallow
regression decision trees with depth 3. The response variable is the expected
difference between the activation probabilities for `CC Action` at $t=5$, in the
intervention and null models, estimated per-individual using the average probabilities
across 500 repeated simulations. Each model is calibrated to the full climate beliefs
dataset (see @sec:calibration for calibration details). As in the previous chapter, we
use a fixed intervention strength of $delta_h = 2.5$. The decision trees are fit using
a mean-squared error objective function, and each achieve $R^2$ values of at least $0.9$
(estimated using 10-fold cross-validation).

#let rounding-footnote = footnote[
  As our intention is to capture coarse patterns, we round the original `f64` values
  describing the interval boundaries extracted from the model to the nearest multiple
  of 0.5.
]

Each row in the figure corresponds to a different point-of-intervention (specified on
the right). The left-hand column shows the distribution of differences in activation
probabilities across individuals. The central column shows the personas which yield
intervention effects within the upper quartile. Each row is a separate persona, and the
columns refer to different dimensions (beliefs) in the initial state. The
personas themselves are specified using a compressed
representation#rounding-footnote: $"L" mapsto [-1, 0]$ and $"H" mapsto [0, +1]$. The
right-hand column displays the prevalence of each persona within/outside the upper
quartile of individuals, showing the proportional make-up of the high-effect population.
We exclude points-of-intervention with no sufficiently high-effect observations (e.g.,
`CC Others Worry` in @fig:heterogeneity-results-cc-action-distribution), classified as
an upper quartile less than 0.1 (`CC Human`, `CC Others Worry`, `Weather Worry`).
//We only include personas with at least 15% prevalence in the observed upper quartile.

Since the regression decision tree produces a full tree, all personas have size 3
by default. However, these can often be compressed. When two personas differ only
along one feature dimension, split at the same value, and both predict high-effect
interventions, we combine them into a single persona which omits that feature (i.e.,
spans the entire feature dimension). This is observed, for instance, in the persona
for interventions on `CC Worry`.

// TODO: Consider making this part of the text, since we refer to it in the discussion
#let incomplete-descriptions-footnote = footnote[
  Note that the personas are not necessarily complete. For instance, suppose that a pair
  of variables are highly correlated in the initial state, and are Low whenever
  the intervention effect is high. A complete characterisation includes both variables;
  however, a decision tree is likely to include only one, since after splitting on one
  of the two variables, the other is redundant. This is especially true for shallow
  decision trees.
]

The expected difference in activation probabilities between the intervention and null
models exhibits a clear bimodal distribution across survey
participants for each scenario, with the higher mode contained within the upper quartile
(indicated by the darker shaded regions). For each point-of-intervention we observe a
small set of personas. In each case these exhibit high prevelence among individuals with
high intervention effects, and considerably lower prevalence for other individuals,
indicating that the identified personas effectively characterise the conditions for
effective interventions#incomplete-descriptions-footnote <footnote:incomplete-descriptions>.
While prevalence among the high-effect individuals is generally high, this does vary
across points-of-intervention (e.g., 20% of effective interventions on beliefs about
climate impacts are not captured).

// Recall that the effect of intervention measures the difference in effects between the
// intervention model and the corresponding null (no-intervention) model
// (@def:asymmetry-results-effect-of-intervention).
For the present analysis, it is
important to recognise that the intervention effect measured here does not, in general,
reflect the resulting change in behaviour with respect to the initial state. It is
entirely possible that both intervention and null models lead to an increase, or
decrease, in the probability of desired behaviour for the target spin. Hence it is most
appropriate to view 'high-effect' interventions as those which achieve substantially
more desirable states than would be observed given no intervention.

With this in mind, we now consider several specific features of interest in the
identified personas. Firstly, we observe that all personas require a low initial
state for `CC Worry`. This may result from this variable's low inertia
and high connectivity --- in particular, its large outbound interaction effect
toward the target variable (see @fig:asymmetry-results-existence-interaction-matrix).
These factors result in `CC Worry` being relatively influential
and influentia#emph[ble], and therefore an effective indirect pathway for
various interventions targeting `CC Action`. The significance of the requirement
that `CC Worry` be _low_ is evident when comparing the implications for the null
and intervention models. Due to `CC Worry`'s considerable outbound interactions,
an intervention which successfully activates this variable has increased potential
for propagation. In the null model, however, these interactions work against the
desired result---if `CC Worry` remains low, it exerts this influence on all other
spins.

Second, we observe that for each point-of-intervention (with the exception of `CC Real`
on account of high correlation with `CC Human`@footnote:incomplete-descriptions),
a necessary condition for high effect is that the initial state of point of intervention
itself be low. That is, for an intervention on $X$ to be successful, $X$ must not already
be too high. This aligns with our prior expectations regarding the varied effects of
interventions with respect to pre-intervention state
(see @subsec:asymmetric-belief-system-modelling-interventions).


// With the exception of `CC Real`, the personas for each point-of-intervention require that
// the initial state of the point-of-intervention be low. This aligns with our expectations
// per our earlier discussion on the varied effects of interventions on the behaviour of the
// point-of-intervention, with respect to the pre-intervention state
// (@subsec:asymmetric-belief-system-modelling-interventions).
#let negative-cc-human-footnote = footnote[
  The negative state for `CC Human` is an aggregation of the beliefs that climate change
  is a natural phenomenon, and that climate change is not real (has no causes). See
  @sec:dataset for further details.
]

Finally, the `CC Real` scenario is unique in that it includes two prevalent personas.
The more prevalent persona corresponds to situations in which individuals are concerned
about the current/future effects of climate change, but do not believe that climate
change is human-caused#negative-cc-human-footnote. In the case where an individual does
believe that climate change is human-caused, this intervention may still be effective,
so long as they do not already have a positive attitude toward climate action.

// *Observations*
// - General observations
//   - Left panel:
//     - Effect of intervention is bimodal for all of the considered points of intervention
//     - The upper quartile captures the higher mode in each case
//   - Centre and right panels:
//     - High prevalence with a small number of personas.
// - Low `CC Worry` is a necessary condition for all interventions to be successful.
//   - `CC Worry` has inbound and outbound interactions with all other variables.
//   - Several of the outbound interaction effects are large ($J_(i,j) approx 0.2$)
//   - Also has the highest interaction effect toward `CC Action` ($J_(i,j) = 0.25$)
//   - `CC Worry` also has lower inertia than some other variables. e.g., `Politics` is also
//     well-connected but has high inertia---harder to change.
//   - Therefore, if `CC Worry` is low, it negatively influences many other variables, but
//     since it is also influenced by many variables, if an intervention can change its
//     state, this provides positive influence to other variables.
// - With the exception of `CC Real`, a low initial state on the point-of-intervention is
//   necessary for effective interventions.
//   - The potential impact of an intervention on the behaviour of a point-of-intervention
//     decreases when the initial is high (decreases monotonically for values above 0)
//     (@subsec:asymmetric-belief-system-modelling-interventions). i.e., the theoretical
//     limit on the effect of intervention is lower when the initial state is higher.
//   - One interpretation of the `CC Real` personas is that we require low `CC Worry` and
//     `CC Human` (in which case the intervention on `CC Real` propagates to these
//     variables, which then lend greater influence to the target), and if we don't have
//     this, i.e., if `CC Human` is high, then we also require that `CC Action` is low,
//     such that the potential effect of intervention is higher.
//     - Transition matrix analysis shows that this finding is due to the influence of
//       `CC Human` on `CC Real`. If `CC Human` is high, then this places pressure on
//       `CC Real` to be high, irrespective of the intervention, i.e., we also see a
//       positive shift in the null model. Supposing that `CC Human` is high, we actually
//       observe a higher absolute activation probability for `CC Action` when `CC Action`
//       is _not_ initially low. If `CC Action` is initially low, then the absolute
//       activation following the intervention is lower; however, the difference compared
//       to the _null model_ is larger.
//     - Why is this? Possibly because when `CC Action` is
//       low, it provides reinforcing negative influence on the other spins, negating
//       some of the upward pressure from `CC Human`, whereas if an intervention is applied
//       then the additional upward pressure from `CC Real` helps to offset this.
//       In comparison, if `CC Action` is not low, then `CC Human` being high provides
//       sufficient upward pressure in the null model as well.
//   - Key takeaway is that it is important to recall that the effect of intervention is
//     always measured with reference to the no-intervention scenario, and in particular,
//     the no-intervention scenario is not necessarily stable.
// - A subset of the POIs also require low `CC Action`



// We worked with a similar function in the definition of the effect of intervention
// itself (@def:asymmetry-results-effect-of-intervention), which accepts a _binarised_
// state and returns the effect of intervention after simulation on the belief system
// model. If we include the binarisation procedure, we obtain a function $f$ with the
// correct form.


// - *Overall goal of these experiments:* Characterise the groups of individuals in the
//   climate beliefs dataset for whom the interventions (targeting 'Climate Action') are
//   most effective.
//
// - *In broad strokes, how do we test this?*
//   - After running intervention simulations, we fit a decision-tree regression model for
//     the effect of intervention (for each point-of-intervention), using the
//     non-binarised initial state variables as predictors.
//   - We extract the decision paths to high-effect leaves as descriptors of the groups of
//     individuals for whom the intervention was effective.
//
// - *Specific experimental details:*
//   - We say that an intervention is highly effect when the effect of intervention is in
//     the upper quartile for the population. Note that this does not capture 'absolute
//     effectiveness', i.e., the upper quartile for a particular point-of-intervention may
//     be very low compared to others.
//   - We only consider decision rules with a prevalence of at least 15% in the high-effect
//     population.
//   - We exclude points-of-intervention with upper quartile of intervention effects lower
//     than 0.075, i.e., where almost all interventions are low-effect.
//   - We only consider weak and strong intervention scenarios, $delta_h in {0.5, 2.5}$.
//   - We fit the decision tree with a maximum depth of 4, corresponding to four decision
//     points between the root and the leaves.
//
// - *Results & figures:*
//   - Rules heatmap
//   - (*Maybe*) intervention rankings per-individual. i.e., we estimate the expected
//     effect of intervention per-individual, for each point-of-intervention, by taking
//     the average across repeats. We then rank the points of intervention, and show the
//     _population_ mean and CIs. Contrasts the rankings in the previous section, where
//     rankings were calculated over population-level average effect.

// In this section we investigate the conditions under which interventions targeting the
// 'Climate Action' attitude are likely to be successful, in asymmetric non-equilibrium
// models calibrated to the climate beliefs dataset.
//
// The intervention simulation procedure is identical to that described in the previous
// chapter. For each survey participant and point-of-intervention, we collect 500 repeated
// samples of the 'Climate Action' spin state at $t=5$. We simulate both _weak_ and
// _strong_ intervention scenarios, $delta_h in {0.5, 2.5}$.
//
// We first examine variation in the rankings over points of intervention between different
// individuals. For each participant, we estimate the expected effect of intervention by
// taking the average across repeated samples for each point-of-intervention and scenario.
// We then rank the points of intervention by expected effect, such that for each
// participant and scenario, we obtain a ranking over possible points of intervention.
// @fig:heterogeneity-results-interventions-ranking-variability shows the average rank
// across individuals for each possible point-of-intervention and scenario. The whiskers
// denote one standard deviation around the average.
//
// #figure(
//   image("../results/figures/model/intervention_individual_ranking/cc_action.pdf"),
//   caption: caption(
//     short: ['Climate Action' intervention rank variability],
//     long: [
//       Variability in point-of-intervention ranks across climate attitudes survey
//       participants, for interventions targeting 'Climate Action'. Bar height describes
//       mean rank across individuals; whiskers denote one standard deviation
//       around the mean. Bar colours indicate strong ($delta_h = 2.5$) and weak
//       ($delta_h = 0.5$) intervention scenarios.
//     ],
//   ),
// ) <fig:heterogeneity-results-interventions-ranking-variability>
//
// *TODO: Observations*
//
// We now proceed to characterise the conditions under which each intervention is
// effective. Recall that the model's initial state is the only distinguishing factor
// between survey participants in the intervention simulations. It follows, therefore,
// that any difference in intervention effectiveness between participants results from
// differences in their initial states. To characterise the conditions for successful
// intervention, it then suffices to characterise the set of _initial states_ which lead
// to effective interventions, and distinguish them from those that do not.
//
// We fit a shallow decision tree regression model for each
// point-of-intervention, taking the expected intervention effect for each survey
// participant as the response variable, and the non-binarised measurements from the final
// wave of the climate beliefs dataset as features. The parameterised model partitions the
// space of possible initial states, assigning a prediction value to each region, such that
// the mean-squared error with respect to the observed intervention effects is minimal.
// We characterise the _personas_ which lead to effective interventions using the rules
// which define high-effect regions of the initial state space.
//
// #let treedepth-footnote = footnote[
//   A tree with depth $n in NN$ partitions the initial state space into $2^n$ regions,
//   each described using $n$ feature rules.
// ]
// For this experiment, we use a tree depth of 3 so as to generate short
// rules#treedepth-footnote, and classify intervention effects within the upper quartile
// of observed values as 'high effect'. We only consider personas which are sufficiently
// prevalent in the observed data ($>= 15%$).
//
// @fig:heterogeneity-results-interventions-personas shows the high-effect personas for
// each intervention scenario and point-of-intervention, excluding points of intervention
// for which there are no sufficiently high-effect observations, where the upper quartile
// is below 0.1. Each row describes the results for a distinct point-of-intervention,
// indicated at the right of the figure. Let us step through the remaining columns:
//
// - The left-most column displays intervention effect
//   distribution for the strong intervention scenario, with upper quartile regions
//   indicated.
//
// - The central column describes the set of personas predicted to be most
//   susceptible to the given intervention. Each row describes a distinct persona. Each
//   cell described a subinterval of the range of possible feature values,
//   $I subset.eq [-1, 1]$, with 'L' referring to 'Low' and 'H' to 'High'. The modifiers
//   'V' and 'S' (not present) refer to 'Very' and 'Slightly', respectively. Entries with
//   the for '~$X$' refer to the complement of the interval named by $X$. The specific
//   interval mappings are defined in *REFERENCE TABLE*.
//
// - The rightmost column describes the prevalence of each persona within the 'high-effect'
//   population. Cell values are the proportion of individuals within the upper quartile
//   for each scenario who satisfy the persona. Missing entries indicate that a persona
//   was either not identified for the given scenario, or had prevalence below 15%.
//
//
// *TODO: Observations*


















// #figure(
//   image("../results/figures/model/intervention_individual_ranking/05_cc_action.pdf"),
//   caption: caption(
//     short: [Ranked intervention effects per-individual, weak, targeting climate action],
//     long: [Ranked intervention effects per-individual, weak, targeting climate action],
//   ),
// )
//
// #figure(
//   image("../results/figures/model/intervention_individual_ranking/25_cc_action.pdf"),
//   caption: caption(
//     short: [Ranked intervention effects per-individual, strong, targeting climate policy],
//     long: [Ranked intervention effects per-individual, strong, targeting climate policy],
//   ),
// )
//

== Heterogeneity in belief system structure <sec:heterogeneity-results-belief-system>

*To-do:*
- Discuss differences in baseline activations.

Until this point, we have considered belief systems as common to a population of
individuals. However, the relations between beliefs are inherently
individual in nature. The existence, direction, and degree of relation between
two beliefs is dependent on an individual's own beliefs regarding their relatedness.


#let liberal-metadata = json("../results/data/model/ideology_fit_liberal_metadata.json")
#let conservative-metadata = json("../results/data/model/ideology_fit_conservative_metadata.json")
#let nlib = liberal-metadata.dataset_size
#let ncons = conservative-metadata.dataset_size

#let smaller-dataset-footnote = footnote[
  Note that the total number of samples across the conservative and liberal subsets is
  smaller than the number of samples in the complete climate beliefs dataset, since we
  only retain data from participants whose ideology is with consistent across survey
  waves.
]

Here we investigate the extent to which belief systems may vary between groups of
individuals with different self-reported political ideologies. While this is still
far from representative of the differences between individuals
@brandtBetweenpersonMethodsProvide2022, it will allow us to examine differences in
general trends for these subpopulations. Using the parameter estimation approach
described in Chapters @subsec:methods-parameter-estimation[] and @sec:calibration,
we calibrate separate asymmetric belief systems to the subsets of the climate beliefs
dataset which consistently (i.e., in both waves) self-report conservative ($n=#ncons$)
and liberal #box[($n=#nlib$)] political ideologies#smaller-dataset-footnote.
We exclude the `Politics` variable
from the model, since this is captured by the partitioned datasets. The hyperparameters
used for regularisation strength and smoothing are listed in
@tab:methods-hyperparameter-values.

Figures related to model calibration can be found in @sec:appendix-extra-results. The
estimated parameters exhibit considerably higher uncertainty than in the model
calibrated to the complete dataset due to the smaller sample sizes
(@fig:apdx-extra-results-ideology-accuracy). We find only one significant case of
asymmetry, on $#raw("CC Worry") --> #raw("CC Impact")$ in the conservative model
(@fig:apdx-extra-results-ideology-differentials), and only a minority of
significant differences ($p < 0.05$) between interaction strengths, all for edges which
are stronger in the conservative model (@fig:apdx-extra-results-ideology-edge-diffs).

#figure(
  image(
    "../results/figures/model_fit/ideology_interaction_heatmap.pdf",
  ),
  caption: caption(
    short: [Conservative and liberal belief system interaction matrices],
    long: [
      Interaction effect matrices ($bold(J)$) for asymmetric belief
      systems calibrated to the conservative and liberal subsets of the climate beliefs
      dataset (@sec:dataset) using the parameter estimation method in
      @subsec:methods-parameter-estimation.
    ],
  ),
) <fig:heterogeneity-results-ideology-interaction-matrices>

@fig:heterogeneity-results-ideology-interaction-matrices shows the interaction effect
matrices, $bold(J)$, for the conservative and liberal subpopulations. We observe several
differences between the two models, as well as with comparison to the model calibrated
on the full dataset (@fig:asymmetry-results-existence-interaction-matrix). Notably, the
model calibrated to the liberal subpopulation has higher sparsity
(proportion of missing cross-interaction edges) and mean interaction effect over
cross-interactions than either the conservative model or the complete model
(@tab:heterogeneity-results-belief-systems-properties). Among the interactions present
in the liberal model, 82% also occur in the conservative model, contrasting the 54%
of conservative interactions which are also in the liberal model.

#figure(
  table(
    columns: (20%, 20%, 22%),
    align: (center, center, center),
    column-gutter: 1.5em,
    stroke: none,
    table.header[Data subset][Sparsity][Mean interaction],
    table.hline(stroke: 0.5pt),
    [Full], [0.30], [0.13],
    [Conservative], [0.38], [0.10],
    [Liberal], [0.60], [0.17],
  ),
  gap: 1.5em,
  caption: caption(
    short: [Comparison of ideological model properties],
    long: [
      Sparsity (proportion of missing cross-interactions) and mean
      interaction effect (over cross-interactions) for asymmetric models
      calibrated to the conservative and liberal subsets of the climate beliefs dataset,
      compared with the model calibrated on the complete dataset.
    ],
  ),
) <tab:heterogeneity-results-belief-systems-properties>

The conservative model displays broad (yet mostly weak) reinforcing interactions
between climate-related concerns, beliefs and others' concerns, and climate-impact
beliefs. This contrasts the liberal model, in which only `CC Worry` and `CC Impact`
are non-trivially related. Moreover, we observe that `CC Others Worry` and
`Weather Worry` in fact have _no_ incoming cross-interactions.

// NOTE: This may indicate that these variables are more stable in the liberal model,
// and therefore we don't observe any relations between them in the small dataset.

We also note differences in the interaction effects influencing `CC Action` between
the two models. While the liberal model expects attitudes toward climate action to
be influenced substantially by individuals' beliefs regarding the existence and nature
of climate change, these influences are absent or trivial in the conservative model.
Instead, we observe that concern about climate change (`CC Worry`) is the only
large cross-interaction toward `CC Action` in the conservative model.

Comparing now with the complete model (calibrated to the full dataset), we find that
interactions absent from the complete model are generally also absent from both smaller
models. The exceptions are
${#raw("CC Others Worry"), #raw("Weather Worry")} --> #raw("CC Action")$, which are
present in the conservative model, albeit with small effect sizes.

The converse does
not hold; in several cases edges are absent from the smaller models, yet included in
the complete model (e.g., $#raw("CC Human") --> #raw("CC Action")$ in the conservative
model, #box[$#raw("CC Worry") --> #raw("Weather Worry")$] in the liberal model). While
it is tempting to interpret these as differences in the ideology-specific belief
systems, this inference is not necessarily valid.
Given the smaller datasets used to calibrate these models---and the slow-moving dynamics
of the measured variables---these edges may be excluded on the basis that we do not
observe their effects. This is less likely for effects which are more substantial in
the complete model, and thus supported better by the dataset.

// especially when the corresponding
// effect size in the complete model is small (e.g.,
// $#raw("CC Others Worry") --> #raw("Weather Worry")$ has effect size
// $J_(i,j) approx 0.06$ in the complete model, and is absent from the liberal model).




// In the complete model, the spins with the highest outbound connectivity are `CC Worry`
// and `CC Impact`. While `CC Worry` remains influential in both of the smaller models,
// `CC Impact` exhibits greater sparsity in the liberal model. We observe also that
// `CC Others Worry` and `Weather Worry` have no inbound interactions in the liberal model,
// i.e., they are not influenced by any other variables. This reflects the relatively
// small inbound interactions seen in the complete model.

// Cross-interactions which are not included in the complete model are generally also
// excluded from both the conservative and liberal models, with the exception of
// ${#raw("CC Others Worry"), #raw("Weather Worry")} --> #raw("CC Action")$ which are
// present in the conservative model. Conversely, each of smaller models excludes some
// interactions which _are_ present in the complete model (e.g.,
// $#raw("CC Human") --> #raw("CC Action")$ in the conservative model,
// $#raw("CC Worry") --> #raw("Weather Worry")$ in the liberal model). In a small number
// of cases, we observe interactions in the complete model which are missing from both
// of the smaller models ($#raw("CC Real") --> #raw("CC Impact")$,
// $#raw("CC Human") --> #raw("CC Worry")$, $#raw("CC Impact") --> #raw("CC Human")$).
// These all correspond to small interactions in the complete model ($|J_(i,j)| < 0.1$),
// suggesting they are only weakly supported by the complete dataset,
// and are likely excluded from the smaller models due to the reduced sample sizes.



// Observations:
// - Relative sparsity. Proportion of non-diagonal interactions which are zero.
//   Conservative: 38%, Liberal: 60%. Compared with the belief system fit to the full dataset: 30%.
// - Strength of interactions compared to one another, compared to the full model.
// - Comparison wrt the full model:
//   - Which variables are influential/have lots of interactions/are very sparse?
//   - Significant interactions which are weak in the full model?
// - Similarities:
//   - Diagonals
//   - Which (significant) non-diagonal interactions are shared?
//     - Very few, if any, bidirectional ones.
//     - One-directional:
//       - $"CC Worry" --> {"CC Real", "CC Impact","CC Action"}$
//       - $"CC Impact" --> {"CC Action"}$
//       - $"CC Action" --> {"CC Real", "CC Human", "CC Impact"}$
// - What are the most significant interactions in each model?
//   - Conservative:
//     - $"CC Worry" --> {"Weather Worry", "CC Impact", "CC Action"}$
//     - $"Weather Worry" --> {"CC Worry"}$
//     - $"CC Action" --> {"CC Worry"}$
//   - Liberal:
//     - $"CC Real" --> {"CC Worry", "CC Action"}$
//     - $"CC Human" --> {"CC Action"}$
//     - $"CC Worry" --> {"CC Impact"}$
//     - $"CC Impact" --> {"CC Worry"}$
//     - $"CC Action" --> {"CC Real", "CC Human", "CC Impact"}$
// - What interactions are symmetric/asymmetric in each model?
//   - Symmetric:
//     - Conservative:
//     - Liberal:
//   - Asymmetric:
//     - Conservative:
//     - Liberal:




// - *Overall goal of these experiments:* Understand how the belief system inferred from
//   the full climate beliefs dataset may differ from those inferred from subsets.
//
// - *In broad strokes, how do we test this?*
//   - We partition the climate beliefs dataset into self-reported conservative and liberal
//     individuals. We then calibrate separate asymmetric belief system models for each
//     group.
//   - We compare the observed belief system structures, and contrast with the belief
//     system calibrated to the full dataset.
//
// - *Specific experimental details:*
//   - Since we subset the data by political ideology, we remove the `Politics` variable
//     from the climate beliefs dataset. So the models are calibrated with only seven
//     spins, as opposed to eight.
//   - We apply regularisation to the model calibration, with regularisation strength
//     determined independently for each group (@tab:methods-hyperparameter-values).
//
// - *Results & figures:*
//   - Belief system networks


// #figure(
//   image(
//     "../results/figures/model/ideology_fit/network.pdf",
//   ),
//   caption: caption(
//     short: [_Conservative_ and _Liberal_ belief networks],
//     long: [
//       Prefixes: A (attitude), B (belief); node labels: CC (climate change), CCA (climate
//       change anthropogenic), CCW (climate change worry), CCWO (climate change worry
//       others), CCI (climate change impacts), CCP (climate change policies), WW (weather
//       worry).
//     ],
//   ),
// ) <fig:results-rq22-ideology-networks>


// - *RQ2.2:* Fit models to conservative and liberal subsets of the data; compare and
//   contrast. Compare with the model from the previous section, i.e., fit on the entire
//   dataset.
// - *RQ3.2:*
//   - Distribution of intervention effectiveness by individual.
//   - How does intervention ranking vary across individuals?
//   - Characterising how different initial states affect intervention success.
//   - Looking at how other theory-driven features affect success, e.g.:
//     - How receptive is the individual to the intervention?
//
//       The effective baseline ($h_i + sum_j J_(j i) s_j$) determines the probability
//       that $S_i^(t+1) = s$ for a state $s in plus.minus 1$. Evaluating this after
//       intervening provides a measurement for the success of the intervention on the
//       intervention spin itself.
//
//       We could look at how this changes with different intervention strengths (it
//       follows a logistic curve).
//
//     - How consistent is the individual's belief state, as measured by the total system
//       energy?
//
//     - How 'entrenched' is the target attitude?
//
//       Measure $h_k s_k + sum_(j) J_(j k) s_j s_k$, where $k$ is the target attitude.

// #line(length: 100%)
//
// - Intro section blah blah blah
//
// - Differences in effects of intervention
//
// - Differences in belief systems: conservative vs. liberal
//
// == RQ2.2: differences between belief systems for different (types of) individuals

// Do for both symmetric and asymmetric. Use L1 regularisation to shrink parameters. Use
// bootstrapping to estimate uncertainty around inferred parameters. Characterise relations
// as symmetric, bidirectional, unidirectional.
//
// Consider network features, model features (correlation length, etc.)




// == RQ3.2: Intervention strategy and effectiveness across individuals
//
// Examine distributions of expected outcome effects (per individual) for different
// interventions. Characterise the individuals found at different parts of the
// distribution (personas, average magnetisation).
//
//
// === Intervention ranking
//
// For each individual, compute ranking over the expected effects of each possible
// intervention.
//
//
// === Who is intervention effective for?
//

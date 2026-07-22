#import "@local/drifting-cls-thesis:0.1.0": caption

In this chapter we investigate individual heterogeneity in both intervention behaviour
and belief system structure in asymmetric, non-equilibrium belief system models.

While the previous chapter was primarily concerned with the _collective_ effects of
intervention, the distribution of expected effect of intervention across individuals
for inbound interventions targeting 'Climate Action' shows substantial variation between
survey participants (@fig:heterogeneity-results-cc-action-distribution). We begin this
chapter with an investigation into the conditions under which different interventions
targeting attitudes on climate action are likely to be effective.

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
a particularly influential attitude dimension, both through asymmetric interactions with
other variables
(@subsec:asymmetry-results-existence) and as an effective point-of-intervention for
interventions targeting attitudes on climate action (@subsec:asymmetry-results-impact).
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

Consider a function which does the opposite, mapping initial states to intervention
effects, $f: X -> RR$. Given such a function, we can straightforwardly construct the
corresponding effect characterisation function as:

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
predicted effect of intervention. Given a parameterised regression decision tree, we
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
    long: [*TODO*],
  ),
) <fig:heterogeneity-results-interventions-personas>

@fig:heterogeneity-results-interventions-personas shows the effect characterisation
functions for different interventions targeting `CC Action`, obtained from shallow
regression decision trees with depth 3. The response variable is the expected
effect of intervention for each individual, estimated using the average effect across 500
repeated simulations of the asymmetric belief system model calibrated to the full
climate beliefs dataset (see @sec:calibration for calibration details). As in the
previous chapter, we use a fixed intervention strength of $delta_h = 2.5$.

*To-do:* Mention the model details, criterion, etc.
*To-do:* State the $R^2$ values for the regression models.

#let rounding-footnote = footnote[
  As our intention is to capture coarse patterns, we round the original `f64` values
  describing the interval boundaries extracted from the model to the nearest multiple
  of 0.5.
]

Each row in the figure corresponds to a different point-of-intervention (specified on
the right). The left-hand column shows the distribution of intervention effects across
individuals. The central column shows the personas which yield intervention effects
within the upper quartile. Each row is a separate persona, and the columns refer to
different dimensions (beliefs/attitudes) of the initial state. The personas themselves
are specified using a compressed representation#rounding-footnote: $"L" mapsto [-1, 0]$
and $"H" mapsto [0, +1]$. The right-hand column displays the prevalence of each persona
within the upper quartile of individuals, showing the proportional make-up of the
high-effect population.


We exclude points-of-intervention with no sufficiently high-effect observations (e.g.,
`CC Others Worry` in @fig:heterogeneity-results-cc-action-distribution), classified as
an upper quartile less than 0.1. We only include personas with at least 15% prevalence
in the observed upper quartile.

*Observations*
- General observations
  - Left panel:
    - Effect of intervention is bimodal for all of the considered points of intervention
    - The upper quartile captures the higher mode in each case
  - Centre and right panels:
    - High prevalence with a small number of personas.
- Low `CC Worry` is a necessary condition for all interventions to be successful.
  - `CC Worry` has inbound and outbound interactions with all other variables.
  - Several of the outbound interaction effects are large ($J_(i,j) approx 0.2$)
  - Also has the highest interaction effect toward `CC Action` ($J_(i,j) = 0.25$)
  - `CC Worry` also has lower inertia than some other variables. e.g., `Politics` is also
    well-connected but has high inertia---harder to change.
  - Therefore, if `CC Worry` is low, it negatively influences many other variables, but
    since it is also influenced by many variables, if an intervention can change its
    state, this provides positive influence to other variables.
- With the exception of `CC Real`, a low initial state on the point-of-intervention is
  necessary for effective interventions.
  - The potential impact of an intervention on the behaviour of a point-of-intervention
    decreases when the initial is high (decreases monotonically for values above 0)
    (@subsec:asymmetric-belief-system-modelling-interventions). i.e., the theoretical
    limit on the effect of intervention is lower when the initial state is higher.
  - One interpretation of the `CC Real` personas is that we require low `CC Worry` and
    `CC Human` (in which case the intervention on `CC Real` propagates to these
    variables, which then lend greater influence to the target), and if we don't have
    this, i.e., if `CC Human` is high, then we also require that `CC Action` is low,
    such that the potential effect of intervention is higher.
- A subset of the POIs also require low `CC Action`


If the initial state of the point-of-intervention is already high,
have little impact on




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

#figure(
  image(
    "../results/figures/model_fit/ideology_interaction_heatmap.pdf",
  ),
  caption: caption(
    short: [TODO],
    long: [*TODO*],
  ),
) <fig:heterogeneity-results-ideology-interaction-matrices>

#line(length: 100%)

- *Overall goal of these experiments:* Understand how the belief system inferred from
  the full climate beliefs dataset may differ from those inferred from subsets.

- *In broad strokes, how do we test this?*
  - We partition the climate beliefs dataset into self-reported conservative and liberal
    individuals. We then calibrate separate asymmetric belief system models for each
    group.
  - We compare the observed belief system structures, and contrast with the belief
    system calibrated to the full dataset.

- *Specific experimental details:*
  - Since we subset the data by political ideology, we remove the `Politics` variable
    from the climate beliefs dataset. So the models are calibrated with only seven
    spins, as opposed to eight.
  - We apply regularisation to the model calibration, with regularisation strength
    determined independently for each group (@tab:methods-hyperparameter-values).

- *Results & figures:*
  - Belief system networks


#figure(
  image(
    "../results/figures/model/ideology_fit/network.pdf",
  ),
  caption: caption(
    short: [_Conservative_ and _Liberal_ belief networks],
    long: [
      Prefixes: A (attitude), B (belief); node labels: CC (climate change), CCA (climate
      change anthropogenic), CCW (climate change worry), CCWO (climate change worry
      others), CCI (climate change impacts), CCP (climate change policies), WW (weather
      worry).
    ],
  ),
) <fig:results-rq22-ideology-networks>


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

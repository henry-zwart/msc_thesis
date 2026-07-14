#import "@local/drifting-cls-thesis:0.1.0": caption

== Plan

Second results section, on individual heterogeneity in belief system structure, and
intervention dynamics.

Introduction:
- State broad goals of this section
  + When are interventions effective/ineffective for particular individuals?
    - Figure showing distribution of intervention effects across individuals for
      experiments in previous section.
  + How do belief systems differ between individuals/groups of individuals?

#line(length: 100%)

In this chapter we investigate individual heterogeneity in both intervention behaviour
and belief system structure in asymmetric, non-equilibrium belief system models.

While the previous chapter was primarily concerned with the _collective_ effects of
intervention, a brief look at the distribution of expected effects across individuals
for interventions targeting 'Climate Action' shows substantial variation between survey
participants (@fig:heterogeneity-results-cc-action-distribution). In
@sec:heterogeneity-results-intervention-effects we investigate the conditions under
which a given intervention is likely to be effective.

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

Our subsequent investigation in @sec:heterogeneity-results-belief-system considers how
inferred belief system structure varies between individuals, or subgroups in a
population. Specifically, we compare belief systems calibrated to conservative and
liberal subpopulations in the climate beliefs dataset.


== Heterogeneity in intervention effects <sec:heterogeneity-results-intervention-effects>

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

In this section we investigate the conditions under which interventions targeting the
'Climate Action' attitude are likely to be successful, in asymmetric non-equilibrium
models calibrated to the climate beliefs dataset.

The intervention simulation procedure is identical to that described in the previous
chapter. For each survey participant and point-of-intervention, we collect 500 repeated
samples of the 'Climate Action' spin state at $t=5$. We simulate both _weak_ and
_strong_ intervention scenarios, $delta_h in {0.5, 2.5}$.

We first examine variation in the rankings over points of intervention between different
individuals. For each participant, we estimate the expected effect of intervention by
taking the average across repeated samples for each point-of-intervention and scenario.
We then rank the points of intervention by expected effect, such that for each
participant and scenario, we obtain a ranking over possible points of intervention.
@fig:heterogeneity-results-interventions-ranking-variability shows the average rank
across individuals for each possible point-of-intervention and scenario. The whiskers
denote one standard deviation around the average.

#figure(
  image("../results/figures/model/intervention_individual_ranking/cc_action.pdf"),
  caption: caption(
    short: ['Climate Action' intervention rank variability],
    long: [
      Variability in point-of-intervention ranks across climate attitudes survey
      participants, for interventions targeting 'Climate Action'. Bar height describes
      mean rank across individuals; whiskers denote one standard deviation
      around the mean. Bar colours indicate strong ($delta_h = 2.5$) and weak
      ($delta_h = 0.5$) intervention scenarios.
    ],
  ),
) <fig:heterogeneity-results-interventions-ranking-variability>

*TODO: Observations*

We now proceed to characterise the conditions under which each intervention is
effective. Recall that the model's initial state is the only distinguishing factor
between survey participants in the intervention simulations. It follows, therefore,
that any difference in intervention effectiveness between participants results from
differences in their initial states. To characterise the conditions for successful
intervention, it then suffices to characterise the set of _initial states_ which lead
to effective interventions, and distinguish them from those that do not.

We fit a shallow decision tree regression model for each
point-of-intervention, taking the expected intervention effect for each survey
participant as the response variable, and the non-binarised measurements from the final
wave of the climate beliefs dataset as features. The parameterised model partitions the
space of possible initial states, assigning a prediction value to each region, such that
the mean-squared error with respect to the observed intervention effects is minimal.
We characterise the _personas_ which lead to effective interventions using the rules
which define high-effect regions of the initial state space.

#let treedepth-footnote = footnote[
  A tree with depth $n in NN$ partitions the initial state space into $2^n$ regions,
  each described using $n$ feature rules.
]
For this experiment, we use a tree depth of 3 so as to generate short
rules#treedepth-footnote, and classify intervention effects within the upper quartile
of observed values as 'high effect'. We only consider personas which are sufficiently
prevalent in the observed data ($>= 15%$).

@fig:heterogeneity-results-interventions-personas shows the high-effect personas for
each intervention scenario and point-of-intervention, excluding points of intervention
for which there are no sufficiently high-effect observations, where the upper quartile
is below 0.1. Each row describes the results for a distinct point-of-intervention,
indicated at the right of the figure. Let us step through the remaining columns:

- The left-most column displays intervention effect
  distribution for the strong intervention scenario, with upper quartile regions
  indicated.

- The central column describes the set of personas predicted to be most
  susceptible to the given intervention. Each row describes a distinct persona. Each
  cell described a subinterval of the range of possible feature values,
  $I subset.eq [-1, 1]$, with 'L' referring to 'Low' and 'H' to 'High'. The modifiers
  'V' and 'S' (not present) refer to 'Very' and 'Slightly', respectively. Entries with
  the for '~$X$' refer to the complement of the interval named by $X$. The specific
  interval mappings are defined in *REFERENCE TABLE*.

- The rightmost column describes the prevalence of each persona within the 'high-effect'
  population. Cell values are the proportion of individuals within the upper quartile
  for each scenario who satisfy the persona. Missing entries indicate that a persona
  was either not identified for the given scenario, or had prevalence below 15%.

#figure(
  image("../results/figures/model/heterogeneous_effects/climate_policy_treedepth_3.pdf"),
  caption: caption(
    short: [Characterisation of responsiveness to intervention],
    long: [*TODO*],
  ),
) <fig:heterogeneity-results-interventions-personas>

*TODO: Observations*


















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

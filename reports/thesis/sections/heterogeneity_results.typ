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

#figure(
  image("../results/figures/model/intervention_effect_distribution/asym_05_cc_action.pdf"),
  caption: caption(
    short: [Intervention effects per-individual: Weak, targeting 'Climate Action'],
    long: [
      Distribution of intervention effects per-individual: Weak, targeting
      'Climate Action'
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_effect_distribution/asym_25_cc_action.pdf"),
  caption: caption(
    short: [Intervention effects per-individual: Strong, targeting 'Climate Action'],
    long: [
      Distribution of intervention effects per-individual: Strong, targeting
      'Climate Action'
    ],
  ),
)

== Heterogeneity in intervention effects

- *Overall goal of these experiments:* Characterise the groups of individuals in the
  climate beliefs dataset for whom the interventions (targeting 'Climate Action') are
  most effective.

- *In broad strokes, how do we test this?*
  - After running intervention simulations, we fit a decision-tree regression model for
    the effect of intervention (for each point-of-intervention), using the
    non-binarised initial state variables as predictors.
  - We extract the decision paths to high-effect leaves as descriptors of the groups of
    individuals for whom the intervention was effective.

- *Specific experimental details:*
  - We say that an intervention is highly effect when the effect of intervention is in
    the upper quartile for the population. Note that this does not capture 'absolute
    effectiveness', i.e., the upper quartile for a particular point-of-intervention may
    be very low compared to others.
  - We only consider decision rules with a prevalence of at least 15% in the high-effect
    population.
  - We exclude points-of-intervention with upper quartile of intervention effects lower
    than 0.075, i.e., where almost all interventions are low-effect.
  - We only consider weak and strong intervention scenarios, $delta_h in {0.5, 2.5}$.
  - We fit the decision tree with a maximum depth of 4, corresponding to four decision
    points between the root and the leaves.

- *Results & figures:*
  - Rules heatmap
  - (*Maybe*) intervention rankings per-individual. i.e., we estimate the expected
    effect of intervention per-individual, for each point-of-intervention, by taking
    the average across repeats. We then rank the points of intervention, and show the
    _population_ mean and CIs. Contrasts the rankings in the previous section, where
    rankings were calculated over population-level average effect.

#figure(
  image("../results/figures/model/heterogeneous_effects/climate_policy.pdf"),
  caption: caption(
    short: [Characterisation of responsiveness to intervention],
    long: [*TODO*],
  ),
)

#figure(
  image("../results/figures/model/intervention_individual_ranking/05_cc_action.pdf"),
  caption: caption(
    short: [Ranked intervention effects per-individual, weak, targeting climate action],
    long: [Ranked intervention effects per-individual, weak, targeting climate action],
  ),
)

#figure(
  image("../results/figures/model/intervention_individual_ranking/25_cc_action.pdf"),
  caption: caption(
    short: [Ranked intervention effects per-individual, strong, targeting climate policy],
    long: [Ranked intervention effects per-individual, strong, targeting climate policy],
  ),
)


== Heterogeneity in belief system structure

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

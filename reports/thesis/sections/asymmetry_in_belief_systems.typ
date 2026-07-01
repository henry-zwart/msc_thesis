#import "@local/drifting-cls-thesis:0.1.0": caption

== Plan

First results section, for experiments on the effect of asymmetry

- *RF1:* Show asymmetric model fit
- *RQ2.1:* Existence of asymmetric relations. Some, but not all, are significant.
  Categorising relations into types: symmetric, asymmetric (both directions exist,
  with different effect sizes), and unidirectional (only one direction exists).
- *RQ3.1:* Differences between symmetric and asymmetric models, with regards to
  intervention strategy (which intervention to do) and effectiveness (magnitude of
  change compared to the no-intervention case).

== Fitting model

// *Regularisation:*
//
// - Motivate: dealing with small sample size + large parameter count
// - Theory: How is it implemented?
// - Effects: How does regularisation affect sparsity?
// - Parameter choice: Largest $lambda$ with EBIC within 2 of minimum EBIC.
//
// The number of estimated parameters is relatively large compared to the number of
// observations (1700). This is particularly true for the asymmetric model, which features
// $n(n+1)$ parameters (72 for $n=8$ beliefs). This can easily result in unreliable
// parameter estimates with high variance. To reduce the impact of the small sample size
// on model reliability, we employ a variation of *LASSO* (#strong[L]east #strong[a]bsolute
// #strong[s]hrinkage and #strong[s]election #strong[p]parameter) regularisation, which
// penalises non-zero parameter values which do not contribute significantly to the
// optimal likelihood. We use the following adjusted objective function:
//
// $
//   f(bold(theta)) = cal(L)_D (bold(theta)) - lambda sum_(theta in bold(theta)) sqrt(theta^2 + epsilon)
// $ <eqn:results-regularisation>
//
// where $epsilon$ is chosen to be small, such that the order of magnitude of
// $sqrt(epsilon)$ is less than that of the smallest desired value of $theta$. We take
// $epsilon = 10^(-8)$. The parameter $lambda in RR^+$ determines the regularisation
// strength. Higher values result in sparser models, and $lambda = 0$ corresponds to
// no regularisation.
//
// We select the $lambda$ which minimises the EBIC (extended bayesian information
// criterion) for the fit model, while maximising the amount of regularisation.
// Specifically we select the maximum $lambda$ which is close to the minimal EBIC:
//
// $
//   lambda = max {hat(lambda) in RR^+ : |op("EBIC")(hat(lambda)) - op("EBIC")_"min"| < 2 }
// $ <eqn:results-regularisation-strength>
//
//
//
// #figure(
//   image("../results/figures/model_fit/regularisation_ebic.pdf"),
//   caption: caption(short: [Regularisation strength EBIC (duplicate)], long: [TODO]),
// ) <fig:results-regularisation-ebic>
//
// #let regularisation-lambda = json("../results/data/model_fit/optimised_regularisation.json")
//
// #regularisation-lambda.ising

#figure(
  image("../results/figures/model/network/full_asym_ising_no_structure.pdf"),
  caption: caption(
    short: [Climate belief system network (asymmetric)],
    long: [TODO],
  ),
)


== RQ2.1: Asymmetry in estimated models

// Fit asymmetric model. Use L1 regularisation to shrink parameters. Use bootstrapping to
// estimate uncertainty.
//
// Plot directional differences. Characterise relations as symmetric, bidirectional,
// unidirectional.

#figure(
  image("../results/figures/model/interaction_matrix/full_asym_ising_no_structure.pdf"),
  caption: caption(
    short: [Climate belief system interaction effect matrix],
    long: [Climate belief system interaction effect matrix.],
  ),
)

#figure(
  image("../results/figures/model/directional_differentials/rank_no_structure.pdf"),
  caption: caption(
    short: [Directional interaction differentials.],
    long: [TODO],
  ),
) <fig:asymmetry-in-belief-systems-directional-differentials>

== RQ3.1: Intervention strategy and effectiveness under sym/asym assumptions

Fit models using bootstrapping. Consider both effects of intervention (how does
intervening at $S$ affect other spins) and strategies (how does intervening at
different spins affect this _one_). Repeat for varying levels/strengths of
intervention.

For strategy, estimate expected ranking of interventions at both collective and
individual levels. For the former, measure collective effect, then rank interventions,
then take mean across repeats. For the latter, measure expected individual effect, rank
interventions, then take mean across individuals.

=== Ranking interventions

#figure(
  image("../results/figures/model/intervention_collective_ranking/05_climate_policy.pdf"),
  caption: caption(
    short: [Intervention ranking targeting climate policy support (weak intervention)],
    long: [
      Expected ranking for weak interventions ($delta h_i = 0.5$) targeting
      individuals' support for climate-related policies. A higher rank indicates that
      an intervention is more effective, as measured by the proportion of the
      population who support climate policy after 30 months in simulation time.
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_collective_ranking/10_climate_policy.pdf"),
  caption: caption(
    short: [
      Intervention ranking targeting climate policy support (medium intervention)
    ],
    long: [
      Expected ranking for medium interventions ($delta h_i = 1.0$) targeting
      individuals' support for climate-related policies. A higher rank indicates that
      an intervention is more effective, as measured by the proportion of the
      population who support climate policy after 30 months in simulation time.
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_collective_ranking/80_climate_policy.pdf"),
  caption: caption(
    short: [
      Intervention ranking targeting climate policy support (perfect intervention)
    ],
    long: [
      Expected ranking for perfect interventions ($op("do")(S_i = +1)$) targeting
      individuals' support for climate-related policies. A higher rank indicates that
      an intervention is more effective, as measured by the proportion of the
      population who support climate policy after 30 months in simulation time.
    ],
  ),
)

=== Intervention effect

Measures the average difference in state between intervention and no-intervention scenarios

#figure(
  image("../results/figures/model/intervention_collective_effect/05_climate_policy.pdf"),
  caption: caption(
    short: [Effect of weak interventions targeting climate policy support],
    long: [
      Expected effect of weak interventions ($delta h_i = 0.5$) targeting
      individuals' support for climate-related policies. Effect is calculated as the
      difference in state after 30 months, as observed in the intervention scenario,
      compared to the no-intervention scenario.
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_collective_effect/10_climate_policy.pdf"),
  caption: caption(
    short: [
      Effect of medium interventions targeting climate policy support
    ],
    long: [
      Expected effect of medium interventions ($delta h_i = 1.0$) targeting
      individuals' support for climate-related policies. Effect is calculated as the
      difference in state after 30 months, as observed in the intervention scenario,
      compared to the no-intervention scenario.
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_collective_effect/80_climate_policy.pdf"),
  caption: caption(
    short: [
      Effect of perfect interventions targeting climate policy support
    ],
    long: [
      Expected effect of perfect interventions ($op("do")(S_i = +1)$) targeting
      individuals' support for climate-related policies. Effect is calculated as the
      difference in state after 30 months, as observed in the intervention scenario,
      compared to the no-intervention scenario.
    ],
  ),
)


#import "@local/drifting-cls-thesis:0.1.0": caption
#import "@preview/algorithmic:1.0.7"
#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm

// == Plan
//
// First results section, for experiments on the effect of asymmetry
//
// - *RF1:* Show asymmetric model fit
// - *RQ2.1:* Existence of asymmetric relations. Some, but not all, are significant.
//   Categorising relations into types: symmetric, asymmetric (both directions exist,
//   with different effect sizes), and unidirectional (only one direction exists).
// - *RQ3.1:* Differences between symmetric and asymmetric models, with regards to
//   intervention strategy (which intervention to do) and effectiveness (magnitude of
//   change compared to the no-intervention case).
//
// #line(length: 100%)

Belief system models based on the Ising model, inspired by the cognitive dissonance
theory of belief system dynamics, demonstrate impressive descriptive and explanatory
capacities for various observed cognitive phenomena at both individual and collective
scales. The currently prevalent view within the modelling community is that influence
relations between beliefs or attitudes are symmetric --- the pressure for $X$ to align
with $Y$ is equal to that placed on $Y$ to align with $X$. The present chapter places
this assumption on trial.

We begin, in @subsec:asymmetry-results-existence, by calibrating the non-equilibrium
belief system model to the climate beliefs dataset described in
@subsec:dataset-dataset-construction. We demonstrate that belief system relations
cannot be universally classified as symmetric, that some influence relations are
recognisably asymmetric, and that relational asymmetry can vary in degree. In
@subsec:asymmetry-results-impact, we then show that this finding is not
inconsequential. Asymmetric models exhibit different dynamics in experiments on
belief-level interventions, with the potential to affect conclusions drawn about
the relative effectiveness of interventions.


== Existence of asymmetric relations <subsec:asymmetry-results-existence>
// - Observations from figures:
//   - Existence of _non-symmetric_ relations:
//     - $"Politics" --> {"CC Action", "CC Worry", "CC Real"}$
//     - $"CC Worry" --> {"CC Impact", "CC Human"}$
//   - Within the non-symmetric relations, there exist different categories:
//     - Unidirectional (arrow only one way): Politics --> CC Real
//     - Remainder: Asymmetric (arrows each way; different strengths)
//     - Potentially some complexity in interpreting this, since we use regularisation

To investigate the existence of asymmetric relations in the asymmetric model calibrated
to the climate beliefs dataset, we examine the differences in directional interaction
effects for the asymmetric models calibrated using bootstrapping in the previous
section.

// To investigate the existence of asymmetric relations we calibrate the non-equilibrium
// belief system model to the climate beliefs dataset using the parameter estimation
// method outlined in @subsec:methods-parameter-estimation, and then compare the
// inferred directional intervention strengths between each pair of spins.
//
// #let dataset-size-footnote = footnote[
//   In the climate beliefs dataset we have $M = 1693$, $T=2$, and $N=8$
// ]
// We use bootstrapping to estimate the uncertainty in our parameter estimates due to
// sampling error. Let $bold(D) in RR^(M times T times N)$ be the complete dataset, where
// $M$, $T$, and $N$ denote the number of participants, observations, and spins
// respectively#dataset-size-footnote. We construct 500 bootstrapped
// datasets by sampling rows (participants) with replacement from $bold(D)$,
// such that each bootstrapped dataset has the same shape as the complete dataset.
//
// For each bootstrapped dataset $bold(D)_((i))$ we calibrate a model $cal(M)_((i))$
// with parameters
// $
//   chevron bold(A), bold(J)_((i)), bold(h)_((i)) chevron.r =: bold(theta)^*_((i)) in RR^p
// $
//
// where $p in NN$ is the number of model parameters, and we take the adjacency matrix
// $bold(A)$ as fully-connected, permitting influence relations to be inferred between
// each pair of beliefs or attitudes.

For each bootstrapped model, $cal(M)_((i))$ with parameters
$chevron bold(A), bold(J)_((i)), bold(h)_((i)) chevron.r$, we obtain an estimate for
the directional differential matrix:

$
  Delta_J^((i)) = bold(J)_((i)) - bold(J)^T_((i))
$ <eqn:asymmetry-results-existence-directional-differential-matrix>

Recall that the $k$'th row of $bold(J)_((i))$ (for #box[$k in {1, ..., N}$])
describes the strength and direction of influence _from_ the
spin $S_k$ _toward_ each other spin. Hence for $k, ell in {1, ..., N}$ we should
interpret the element $Delta_(J)^((i))|_(k,ell)$ of the directional differential matrix
as the excess influence of spin $S_k$ on $S_ell$. A positive value indicates that
$S_k$ exerts greater influence on $S_ell$ than $S_ell$ does on $S_k$.

@fig:asymmetry-results-existence-ranked-differentials shows the median directional
differential for each pair of spins in the asymmetric model, in decreasing order.
The 90% confidence intervals are calculated as the 5th and 95th percentiles across
bootstrap samples of the directional differential matrix elements. For each pair of
spins we display only the directional differential for which the median is positive
(since $Delta_J$ is symmetric), and we exclude diagonal entries (which are zero by
definition).

In @sec:calibration we cautioned against using bootstrapped confidence intervals to
test for the _existence_ of edges by comparison with
zero when regularisation is used during calibration---this caution does not apply to
the _comparison_ of edge weights via the mean difference
@epskampEstimatingPsychologicalNetworks2018.
// In @fig:asymmetry-results-existence-ranked-differentials, a confidence interval which
// excludes zero indicates that we observe the corresponding asymmetry in most bootstrapped
// models; if the confidence interval contains zero, we cannot (within the confidence
// bounds) say that the two effects are different. This interpretation applies even when
// regularisation is used. Suppose, for instance,
// that the confidence interval for a relation $A --> B$ excludes zero because
// regularisation pushes the opposite relation, $B --> A$, to zero in most bootstrapped
// models. If the relation were symmetric, then $A --> B$ would also have been pushed to
// zero in a majority of models. Conversely, if




// NOTE:
// For a directional pairwise
// relation $A --> B$, if the corresponding confidence interval is consistently above
// zero this indicates that we observe asymmetry in most bootstrapped models. Conversely,
// if the corresponding confidence interval contains zero, then we cannot say (within the
// confidence bounds) that the two interaction effects are different. This interpretation
// applies even when regularisation is used in model calibration. Suppose, for instance,
// that the confidence intervals are consistently above zero because regularisation pushes
// the opposite relation, $B --> A$, to zero in most bootstrapped models. If the relation
// were symmetric, then $A --> B$ would also have been pushed to zero in a majority of
// models.


#figure(
  image("../results/figures/model/directional_differentials/rank_no_structure.pdf"),
  caption: caption(
    short: [Directional interaction differentials.],
    long: [TODO],
  ),
  placement: auto,
) <fig:asymmetry-results-existence-ranked-differentials>

// By repeating this process for each bootstrapped dataset we obtain an approximation to
// the sampling distribution of $Delta_J$, i.e., that of the true directional differential
// matrix for datasets of the same size.
// @fig:asymmetry-results-existence-ranked-differentials shows the median directional
// differential for each pair of spins. The 90% confidence intervals are calculated using
// the 5th and 95th percentiles. For each pair of spins we only display the directional
// differential for which the median is positive, since $Delta_J$ is symmetric. We exclude
// diagonal entries, which are zero by definition.


// @fig:asymmetry-results-existence-interaction-matrix shows the interaction effects,
// $J_(i j)$, between each pair of spins $S_i$, $S_j$, averaged across the calibrated
// bootstrapped models.


#figure(
  image("../results/figures/model/interaction_matrix/full_asym_ising_no_structure.pdf"),
  caption: caption(
    short: [Climate belief system interaction effect matrix],
    long: [Climate belief system interaction effect matrix.],
  ),
  placement: auto,
) <fig:asymmetry-results-existence-interaction-matrix>

@fig:asymmetry-results-existence-ranked-differentials shows a majority of symmetric
relations between spins (characterised by confidence intervals containing zero), with
a small number of asymmetric relations. Most directional differentials display
substantial uncertainty, with large confidence intervals ($> 0.1$ on average),
reflecting the uncertainty in parameter estimates seen in the previous chapter
(@fig:calibration-edge-accuracy).

We can partition the asymmetric relations into two groups through examination of the
interaction matrix for the model calibrated on the full dataset
(@fig:asymmetry-results-existence-interaction-matrix, also shown in
@fig:calibration-interaction-matrices of the previous chapter). The first group
comprises pairs of spins for which both interaction effects are nonzero, shown with
blue confidence intervals: $#raw("Politics") -> {#raw("CC Action"), #raw("CC Worry")}$
and $#raw("CC Worry") -> {#raw("CC Impact"), #raw("CC Human")}$. The second group
comprises pairs for which the interaction effect is nonzero in only one direction,
shown with orange confidence intervals: $#raw("Politics") -> #raw("CC Real")$.
// Note that
// we also observe nonzero interaction effects in only one direction for some
// _symmetric_ relations as well (e.g., $#raw("Politics") -> #raw("CC Human")$), we still
// consider these symmetric, as the bootstr


// #figure(
//   image("../results/figures/model/directional_differentials/pairwise_no_structure.pdf"),
//   caption: caption(
//     short: [Pairwise directional differential heatmap],
//     long: [*TODO*],
//   ),
//   placement: auto,
// ) <fig:asymmetry-results-existence-heatmap-differentials>


== Asymmetry affects intervention dynamics <subsec:asymmetry-results-impact>
// - $checkmark$ *Overall goal of these experiments:* understand how belief system behaviour under
//   intervention differs between symmetric and asymmetric models calibrated to the
//   climate beliefs dataset. _Re-state the corresponding research question_.
//
// - $checkmark$ *In broad strokes, how do we test this?*
//   - Two-pronged approach.
//     + We first consider how intervention effects propagate from a single point of
//       intervention for varying intervention strengths. We measure: (i) effect of
//       intervention at each other spin, and (*maybe*) (ii) the effect of asymmetry at
//       each other spin.
//     + We then consider targeted interventions, in which we wish to change the state of
//       a particular belief or attitude, and want to know where is best to intervene. We
//       measure: (i) the effect of intervention for each possible intervention point, and
//       (ii) the expected ranking of interventions, scored by collective effect.
//
// - $checkmark$ *Specific experimental details:*
//   - We calibrate the models on the full (non-bootstrapped) dataset.
//   - We use intervention strengths $delta_h in {0.5, 1.5, 2.5}$ (weak, medium, strong).
//   - We take each survey participant's binarised measurements from Wave 4 as the initial
//     state of the model, then draw samples using parallel Glauber dynamics until $t=5$
//     (2.5 years in simulation time).
//   - Since both the binarisation and sampling procedures are stochastic we repeat this
//     500 times for each individual.
//
// - *First set of results:*
//   - Figures showing how intervention effects propagate from $X$ and $Y$.
//   - Effect of asymmetry figure(s)
//
// - *Second set of results:*
//   - Target variable: 'Climate Action'
//   - Effect of interventions
//   - Ranked interventions
//     - Explaining the occasional wider error bars in ranked interventions.

We now investigate how the behaviour of belief systems under intervention differs
between symmetric and asymmetric models calibrated on the climate beliefs dataset.
Specifically, we consider this question from two angles:

+ Given a single _point-of-intervention_, how do intervention effects propagate to other
  beliefs and attitudes, and how does this differ between the two models?

+ Given a single _target_ belief or attitude, how do intervention effectiveness, and
  therefore intervention strategy, differ between the two models?

For the first angle, we model interventions on the $X$ and $Y$ variables. We measure the
effect of intervention, as well as the effect of asymmetry (*TODO: Define or
reference*). For the second angle we consider interventions aimed at affecting the
'Climate Action' attitude. Alongside the effect of intervention, we also investigate the
relative effectiveness of interventions by examining the expected ranking, measured with
respect to collective change in attitude.

The symmetric and asymmetric models are calibrated to the full (non-bootstrapped)
climate beliefs dataset using the parameter estimation method described in
@subsec:methods-parameter-estimation (@fig:calibration-interaction-matrices). For
each model, we consider a range of intervention scenarios, with different intervention
strengths, to understand how this may affect the results. We use
$delta_h in {0.5, 1.5, 2.5}$, corresponding to weak, moderate, and strong interventions
respectively (@subsec:asymmetric-belief-system-modelling-interventions).



We simulate interventions as being applied to the climate beliefs dataset survey
participants themselves. For a given intervention model and participant, we initialise
the model state using the participant's binarised measurements from the final wave of
the dataset, and draw subsequent samples from the model using glauber dynamics
@subsec:methods-glauber-dynamics. For each experiment, we draw samples until $t=5$. This
corresponds to approximately two and a half years in the calibrated model's
timescale#footnote[The climate beliefs dataset spans two waves, which are roughly six months apart.].
Since both the binarisation procedure and model dynamics are stochastic, we repeat
the simulation process 500 times for each individual, model type, and intervention
strength.

// NOTE:
// Figures:
// - Outbound intervention effects: For each repeat and possible _target_ spin, calculate
//   the difference between the observed state in the intervention model and that in the
//   null model (with no intervention). Calculate the average difference across
//   individuals and repeats as an estimate of the expected effect that intervening on $X$
//   has on each other spin $Y$. Shows differences between the symmetric and
//   asymmetric models with regards to how interventions propagate through the network.
//   - Remember to observe: heterogeneity in absolute effects on different spins,
//     differences between symmetric and asymmetric models.
// - Inbound intervention effects: For each repeat and possible _intervention_ spin, again
//   estimate the expected effect; however, this time the effect that intervening on each
//   $X$ has on a particular target spin $Y$. Shows how interventions targeting a
//   particular spin vary between the symmetric and asymmetric models, and between
//   intervention spins, in absolute terms. Compared to ranked plot, this shows actual
//   differences between interventions, while the ranking shows which interventions are
//   typically better.
// - Ranked interventions: For each repeat and possible intervention spin, calculate the
//   resulting average state of the target variable across individuals at $t=5$. Rank the
//   interventions for each repeat, such that interventions which yield a higher average
//   state receive a high rank. Interventions which yield the same average state are
//   assigned the same rank. Calculate the average rank across repeats as an estimate for
//   the expected ranking over interventions.
//   - Remember to observe:
//     - Differences in error bars between this and the inbound effect plot. For strong
//       interventions most error bars shrink to near-zero for ranking plot but stay large
//       in other plot. Means that either: (i) when the inbound effect from one spin
//       is lower for a particular binarisation it is also lower for the other spin, such
//       that the relative ordering of the effects is preserved. This would indicate that
//       the spins are susceptible in similar ways to variation due to binarisation. Or
//       (ii) that all other spins are just significantly more/less effective than this
//       one, such that the variation in effectiveness across binarisations is insufficient
//       to change its ranking. In some cases the error bars stay larger in the ranking
//       plot (symmetric: politics, CC real, CC human; asymmetric: CC real, CC human,
//       weather worry). This means that different binarisations cause these variables to
//       be ranked differently. Analogously, this could either result from: (i) variables
//       which respond differently to different binarisations (e.g., one variable increases
//       in effect, or is unaffected, while the other decreases), or (ii) variables whose
//       collective effects are sufficiently close together so as to be ranked differently
//       due to randomness.
// - (Maybe) something with effect of asymmetry? e.g., for each intervention spin, plot
//   the effect of asymmetry for varying intervention strengths.
// - (Maybe) explore the above idea in ranked interventions. Look at the variables with
//   large error bars in the strong/perfect ranked intervention plot. Can we determine
//   which of the two cases they are?
//   - We can use an independence test for this. If the error bars are large because for
//     specific binarisations the effects differ (type A) then the probability
//     distributions over the collective effects for the two variables should be
//     non-independent. If they are large because of random variation (type B), they
//     should be independent (maybe? or perhaps we can't say for certain in this case).
//     The samples we've drawn approximate a distribution over collective effect sizes.
//     We can: (1) simply estimate the probability that one collective effect is less than
//     the other under an independence assumption (e.g., by drawing random samples from
//     the approximate distribution) and compare this to the observed proportion of such
//     cases, or (2) do some sort of statistical test.

*Angle 1 Figures*

#figure(
  image("../results/figures/model/intervention_effects/05_cc_worry.pdf"),
  caption: caption(
    short: [Outbound intervention effect: CC Worry (weak)],
    long: [Outbound intervention effect: CC Worry (weak)],
  ),
)

#figure(
  image("../results/figures/model/intervention_effects/25_cc_worry.pdf"),
  caption: caption(
    short: [Outbound intervention effect: CC Worry (strong)],
    long: [Outbound intervention effect: CC Worry (strong)],
  ),
)

#figure(
  image("../results/figures/model/intervention_effects/05_politics.pdf"),
  caption: caption(
    short: [Outbound intervention effect: Politics (weak)],
    long: [Outbound intervention effect: Politics (weak)],
  ),
)

#figure(
  image("../results/figures/model/intervention_effects/25_politics.pdf"),
  caption: caption(
    short: [Outbound intervention effect: Politics (strong)],
    long: [Outbound intervention effect: Politics (strong)],
  ),
)

#figure(
  image("../results/figures/asymmetry_results/effect_of_asymmetry_politics.pdf"),
  caption: caption(
    short: [Outbound effect of asymmetry: Politics],
    long: [Outbound effect of asymmetry: Politics],
  ),
)

#figure(
  image("../results/figures/asymmetry_results/effect_of_asymmetry_cc_worry.pdf"),
  caption: caption(
    short: [Outbound effect of asymmetry: Climate Worry],
    long: [Outbound effect of asymmetry: Climate Worry],
  ),
)

*Angle 2 Figures*

#figure(
  image("../results/figures/model/intervention_collective_effect/05_cc_action.pdf"),
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
  image("../results/figures/model/intervention_collective_effect/15_cc_action.pdf"),
  caption: caption(
    short: [
      Effect of medium interventions targeting climate policy support
    ],
    long: [
      Expected effect of medium interventions ($delta h_i = 1.5$) targeting
      individuals' support for climate-related policies. Effect is calculated as the
      difference in state after 30 months, as observed in the intervention scenario,
      compared to the no-intervention scenario.
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_collective_effect/25_cc_action.pdf"),
  caption: caption(
    short: [
      Effect of strong interventions targeting climate policy support
    ],
    long: [
      Expected effect of perfect interventions ($delta h_i = 2.5$) targeting
      individuals' support for climate-related policies. Effect is calculated as the
      difference in state after 30 months, as observed in the intervention scenario,
      compared to the no-intervention scenario.
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_collective_ranking/cc_action.pdf"),
)

#figure(
  image("../results/figures/model/intervention_collective_ranking/05_cc_action.pdf"),
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
  image("../results/figures/model/intervention_collective_ranking/15_cc_action.pdf"),
  caption: caption(
    short: [
      Intervention ranking targeting climate policy support (medium intervention)
    ],
    long: [
      Expected ranking for medium interventions ($delta h_i = 1.5$) targeting
      individuals' support for climate-related policies. A higher rank indicates that
      an intervention is more effective, as measured by the proportion of the
      population who support climate policy after 30 months in simulation time.
    ],
  ),
)

#figure(
  image("../results/figures/model/intervention_collective_ranking/25_cc_action.pdf"),
  caption: caption(
    short: [
      Intervention ranking targeting climate policy support (strong intervention)
    ],
    long: [
      Expected ranking for strong interventions ($delta h_i = 2.5$) targeting
      individuals' support for climate-related policies. A higher rank indicates that
      an intervention is more effective, as measured by the proportion of the
      population who support climate policy after 30 months in simulation time.
    ],
  ),
)



// While the above results demonstrate the existence of asymmetric influence relations
// in a belief system inferred from real data, it does not automatically follow that
// asymmetry is an important modelling consideration. If the symmetric model behaves
// identically in all scenarios of interest, then why should we bother with modelling
// asymmetric relations. Indeed, asymptotically, the asymmetric model uses twice as many
// parameters as the symmetric variation, increasing both computational and data burdens.
// In this section we compare the intervention dynamics of symmetric and asymmetric models
// calibrated on the climate beliefs dataset (@subsec:dataset-dataset-construction).
//
// We first calibrate the symmetric and asymmetric models using the complete
// (non-bootstrapped) dataset. This yields the belief system networks shown in *reference
// the below figure*.
//
//
//
// #let intervention-strength-footnote = footnote[
//   The chosen intervention strengths correspond, qualitatively, to _weak_, _moderate_,
//   and _strong_ interventions, respectively.
// ]
// #let timeframe-footnote = footnote[
//   Since the time between observations in the climate beliefs dataset is roughly six
//   months, this corresponds to approximately two and a half years in the calibrated
//   model's timescale.
// ]
//
// Taking the 'Climate Action' spin as the target of our intervention (i.e., the attitude
// we wish to affect), we simulate interventions of varying strengths#intervention-strength-footnote,
// $delta_h in {0.5, 1.5, 2.5}$, on each other spin separately using the method described
// in @subsec:asymmetric-belief-system-modelling-interventions. For each survey
// participant we then measure the effect of intervention at the target spin after $t=5$
// samples#timeframe-footnote (*reference definition in methods section*). For each such
// simulation we initialise the model using each participant's binarised observations from
// the final wave of the climate beliefs dataset. Since both the binarisation process and
// model dynamics are stochastic in nature, we repeat this measurement process 500 times
// for each participant.
//
//
// Intervention experiment: Intervening on $S_i$ with intervention strength $delta$.
// - Construct intervention model from calibrated model using method described in
//   @subsec:asymmetric-belief-system-modelling-interventions
// - For each survey participant in the climate beliefs dataset:
//   - Sample a binarisation of their measurements at the final timestep in the dataset
//   - Initialise the model state with this binarisation
//   - Draw $Q$ consecutive samples from the model using parallel glauber dynamics
//     (@eqn:asymmetric-belief-system-glauber-dynamics)
//   - At each timestep, record the state of the target spin
// - Repeat this process 300 times. For each repeat, sample a new binarisation.
// - We take $Q=5$, which reflects approximately 2.5 years in simulation time.
//
// Comparability across models and intervention strengths:
// - For a given repeat $r in {1, ..., 300}$, we use identical random number generation
//   contexts for both the symmetric and asymmetric model simulations, and for each
//   intervention strength.
// - This ensures that any difference in results is due to differences in either the
//   model or the intervention strength.
//




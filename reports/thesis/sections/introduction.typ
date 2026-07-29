#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

#emph-block[
  *Note:* This section is currently just a collection of mostly-unrelated thoughts and
  ramblings. Disregard it :)
]

*TODO:*
- Address the specific variables we look at in the outbound/inbound experiments.
  Are the variables interesting independently of the asymmetry results/theoretically
  motivated?
- Mention our hypotheses, where they exist.
  - RQ3: That interventions can only be effective when the target and the
    point-of-intervention are both low.


== Plan

- Motivate the problem
- Contributions
- Research questions (thinking these are perhaps better left to later, in favour of
  contributions here)

#emph-block[
  The probable existence of directed causal relations between beliefs and attitudes, as
  well as their potential implications for endogenous dynamics, is widely acknowledged
  in recent studies on belief system modelling. In spite of this, empirical evidence for
  the existence and impacts of such directed relations remains scarce, likely due,
  in-part, to a historical focus on bidirectional (i.e., symmetric) models in theories of
  belief dynamics (*CITE*), as well as the additional data requirements associated with
  inferring directional relations @nguyenInverseStatisticalProblems2017[p.~35] (*CITE*).

  These unknowns, _existence_ and _impact_, are the primary subjects of this
  thesis, and of our first two research questions, introduced back in
  @sec:introduction:

  *RQ1:* To what extent are causal relations _symmetric_ or _asymmetric_, in models
  of climate change belief systems inferred from the climate beliefs dataset?

  *RQ2:* How do asymmetric and symmetric beliefs systems differ with regards to
  intervention strategy and effectiveness, in models inferred from the climate
  beliefs dataset?

  The _climate beliefs dataset_, here, refers to the reduced longitudinal dataset
  whose construction we describe in @subsec:dataset-dataset-construction. These research
  questions are concerned with population-level belief systems and intervention effects.
  However, while some aspects of belief system structure are likely shared within a
  population, the notion of a belief system is inherently individual. We also expect
  differences in individuals' responses to interventions. Our final research questions
  address these two topics, specifically for asymmetric belief systems:

  *RQ3:* How do intervention outcome and effectiveness vary between individuals with
  different initial conditions in asymmetric belief systems inferred from the
  climate beliefs dataset?

  *RQ4:* How do asymmetric belief systems inferred from the climate beliefs dataset
  vary between conservative and liberal individuals?
]

== Motivation

Issue support on climate policies in US driven by political identification and climate
beliefs @bumannWhatAreDeterminants2021 @shaoApprovalPoliticalLeaders2020
@zieglerPoliticalOrientationEnvironmental2017 @roser-renoufGenesisClimateChange2014
@unsworthItsPoliticalHow2014.

But political identification is often not consistent with policy attitudes
@iyengarAffectNotIdeology2012 @huddyExpressivePartisanshipCampaign2015. More often
identity-driven (symbolic) than issue-driven (operational)
@masonIdeologuesIssuesPolarizing2018. Also @eganIdentityDependentVariable2020.

Suggestions of asymmetric/causal directionality in belief systems:
- So far reviewed in Zotero: Belief Networks, Papers from Sara
- @brandtWhatCentralPolitical2019[p.~2,9,10]
- @brandtMeasuringBeliefSystem2022[p.~3,22]
- @keskinturkOrganizationPoliticalBelief2022[p.~10]
- @vannoordNatureStructureEuropean2025[p.~4]
- @brandtEvaluatingBeliefSystem2021[p.~2]: Belief system _dynamics_ require causal connections.
  - Constraint, causality, exogenous factors all necessary for any theory of BS dynamics.
  - Though still interprets edges as undirected/bi-directional
- @brandtEvaluatingBeliefSystem2021[p.~22]: "In some cases ... assume that causal influence
  for some elements (e.g., partisan identification) is primarily in one direction".
- @converseNatureBeliefSystems2006[p.~208] (mentioned in @brandtEvaluatingBeliefSystem2021[p.~2])
- @coppockBeliefSystemsExhibit2022: Referenced in @brandtEvaluatingBeliefSystem2021

Self-interaction effects:
- @brandtEvaluatingBeliefSystem2021[p.~22]: "we made the simplifying assumption that a node
  does not affect itself".


Variation in belief systems between individuals:
- @brandtEvaluatingBeliefSystem2021[p.~4,20] "connections will likely vary between people,
  time, and political contexts", "Although ... belief systems are at the individuals level,
  this does not mean that structure is not shared"


Stability of belief dynamics:
- @osborneDoesOpennessExperience2020
- @kileyMeasuringStabilityChange2020
  - Most observed change in beliefs and behaviours is short-term (or measurement error)
  - This is consistent with the cognitive dissonance theory

== Asymmetry example

Suppose thin arrows have weight 1, thick arrows have weight 2, and a belief/attitude
adopts the dominant state in its neighbourhood, weighted by the incoming edge weights.
If your support for non-climate-related policies and your social circle are
Republican-aligned, you adopt that political ideology. Suppose that you believe in
human-caused climate change, then that reinforces your support for climate action;
however, the net support is $-1$, so you flip, taking the support for Republican
politics to $+4$. If you then become concerned about extreme weather, and believe
that the impacts of climate change are high, your support for climate action flips
to positive with a net support of $+1$. However, this is not sufficient to shift
your Republican alignment, which stays at $-1$. In the extreme case, where there is
no feedback to Politics, your change in attitude has no bearing on your political
alignment.

Asymmetry is then best thought of as the weight imposed on one belief/attitude by
another being different from the opposite direction. To overcome Republican alignment,
we need at least two pro-Democrat attitudes. To overcome negative `CC Action`,
we require at least three other pro-climate attitudes.



#figure(
  image("../diagrams/draft/asymmetry_example.png"),
  placement: none,
)

== Research questions

*Theoretical contributions:*
- *RF1.1:* Extending the causal attitude network model of belief systems to: (i)
  support asymmetric causal effects between beliefs and attitudes, and (ii) model
  intervention dynamics.

*Inferring belief systems:*
- *RQ2.1:* To what extent are causal relations _symmetric_ or _asymmetric_ in models
  of climate change belief systems inferred from observational data?

- *RQ2.2:* How do (symmetric or asymmetric) belief systems relating to climate change
  vary between conservative and liberal individuals?

*Intervention dynamics:*
- *RQ3.1:* How do asymmetric and symmetric beliefs systems inferred from the climate
  attitudes dataset differ with regards to intervention strategy and effectiveness?

- *RQ3.2:* How do intervention outcome and effectiveness vary between individuals with
  different initial conditions, or between conservative and liberal individuals?


== Contributions
+ We present a mathematical model for belief system dynamics that does not assume
  equilibrium and does not assume symmetric influence between cognitive aspects
  (@sec:asymmetric-belief-systems)
+ We describe a novel parameter estimation method for fitting binary Ising models to
  continuous data (@sec:methods).
+ We calibrate said model to data from a recent longitudinal survey including items on
  beliefs and attitudes regarding climate change
  (@sec:results-asymmetry-in-belief-systems).
+ We demonstrate, by way of the calibrated model, the existence of asymmetric influence
  relations between beliefs and attitudes. Furthermore we show that influence relations
  are not _necessarily_ asymmetric, may vary in the degree of asymmetry, and can be
  unidirectional (@sec:results-asymmetry-in-belief-systems).
+ We demonstrate that the decision to represent asymmetric relations in belief system
  models can change intervention dynamics, and therefore conclusions one draws
  regarding intervention effect and effectiveness
  (@sec:results-asymmetry-in-belief-systems).
+ We then show that belief systems may vary significantly between individuals, by
  fitting the proposed model to subsets of the climate attitudes dataset comprising
  conservative and liberal individuals
  (@sec:heterogeneity-in-belief-systems-and-intervention-effects).
+ Finally, we show that reasoning about the effects of interventions on _individuals_
  is, in general, non-trivial. How an individual responds to an intervention typically
  depends on their prior belief system state, including beliefs and attitudes other
  than the target and goal of intervention
  (@sec:heterogeneity-in-belief-systems-and-intervention-effects).


// == Proposed thesis structure
//
// - *Terminology and notation*
//
// - *Introduction:*
//   - Motivate the problem,
//   - Outline contributions (research questions)
//
// - *Asymmetric belief system:*
//   - Define and illustrate the model
//   - Model simulation with Glauber dynamics
//   - How do we model interventions?
//
// - *Methods:*
//   - Counterfactual intervention experiments --- comparing against the no-intervention
//     scenario, measuring differences in effects.
//   - Parameter estimation:
//     - Maximum likelihood estimation
//       - Conditional on a specific binarisation
//       - Marginalising over binarisation process
//     - Regularisation
//
// - *Existence and impacts of asymmetry in belief systems*
//   - Results for:
//     - *RF1:* Show asymmetric model fit
//     - *RQ2.1:* Existence of asymmetric relations. Some, but not all, are significant.
//       Categorising relations into types: symmetric, asymmetric (both directions exist,
//       with different effect sizes), and unidirectional (only one direction exists).
//     - *RQ3.1:* Differences between symmetric and asymmetric models, with regards to
//       intervention strategy (which intervention to do) and effectiveness (magnitude of
//       change compared to the no-intervention case).
//
// - *Individual heterogeneity in belief systems and intervention dynamics*
//   - Second results section
//   - *RQ2.2:* Fit models to conservative and liberal subsets of the data; compare and
//     contrast. Compare with the model from the previous section, i.e., fit on the entire
//     dataset.
//   - *RQ3.2:*
//     - Distribution of intervention effectiveness by individual.
//     - How does intervention ranking vary across individuals?
//     - Characterising how different initial states affect intervention success.
//     - Looking at how other theory-driven features affect success, e.g.:
//       - How receptive is the individual to the intervention?
//
//         The effective baseline ($h_i + sum_j J_(j i) s_j$) determines the probability
//         that $S_i^(t+1) = s$ for a state $s in plus.minus 1$. Evaluating this after
//         intervening provides a measurement for the success of the intervention on the
//         intervention spin itself.
//
//         We could look at how this changes with different intervention strengths (it
//         follows a logistic curve).
//
//       - How consistent is the individual's belief state, as measured by the total system
//         energy?
//
//       - How 'entrenched' is the target attitude?
//
//         Measure $h_k s_k + sum_(j) J_(j k) s_j s_k$, where $k$ is the target attitude.
//
// - *General discussion*
//   - Draw out the key findings from the above two results sections
//   - Make clear the implications for our theory of belief system dynamics
//   - Sensitivity of parameter estimation to unmeasured factors or incorrect structural
//     assumptions. i.e., what happens when we cannot include an influential belief, or
//     when we falsely assume that a relation does or does not exist?
//   - Representational limitations of our model:
//     - Pairwise relations limit what can be modelled. Demonstrate using vaccination
//       example --- we can't capture relations between pairs of attitudes, whose effect
//       sign or magnitude depends on a third belief/attitude.
//     - Polar ($-1, +1$) spin state assumption; some beliefs may be better treated as
//       'on/off', where the 'off' state has _no_ effect on other spins, rather than a
//       negative effect.
//     - More generally, effect sizes may vary depending on specific spin states.
//
// - *Dataset*
//   - Introduce the (insert name here) dataset, give context, survey details
//   - Validation, cleaning, transformations
//   - Question selection, indexes
//   - Binarisation
//
// - *Literature review/related work*
//
// - *Conclusions and future work*

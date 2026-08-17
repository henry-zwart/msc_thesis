#import "@local/drifting-cls-thesis:0.1.0": caption
#import "./discussion.typ": internal-link
#import "@preview/zero:0.6.1": num

#import "@preview/theorion:0.6.0": *
//#import cosmos.simple: *
#import cosmos.clouds: *

#show: show-theorion

We now shift to the second half of this study, which addresses the research
questions outlined in the first chapter. We will employ a combination of data-driven
and simulation-based methods, using the models calibrated to the climate beliefs
dataset (@sec:dataset) in the previous chapter. This chapter outlines our
experimental approach and the key quantities measured in the following chapters.

// To address RQ1. and RQ4., concerning the prevalence of asymmetric influence in climate
// change belief systems and the differences between conservative and liberal climate
// change belief systems, we examine the
// To address RQ1., concerning the prevalence of asymmetric influence in climate change
// belief systems, we compare the directional interaction effects between each pair
// of beliefs in the calibrated asymmetric model, using bootstrapping to assess
// uncertainty (@sec:methods-directional-differential).
// In the first instance, we assess the existence and prevalence of asymmetric influence
// relations among climate-related beliefs by comparing the directional interaction effects
// between each pair of beliefs in the calibrated asymmetric model (@)
//
//
// This chapter outlines our experimental approach
// and the key quantities used in the following chapters.
//
// We employ a combination of data-driven and simulation-based methods, using the models
// calibrated to the climate beliefs dataset (@sec:dataset) in the previous chapter.
//


// The climate beliefs dataset describes a subset of beliefs relating to
// climate change, collected in the United States in recent years.

Note that our use of the climate beliefs dataset imposes a specific interpretive context of
interpretation on our findings. In particular, we do not claim that the set of beliefs
considered here comprehensively reflects the range of possible climate-related beliefs,
and we expect that our results are likely to be sensitive to the (geographic and
situational) contexts underlying the climate beliefs dataset.

//This chapter introduces the experimental methods we will use to address these questions.

// We now shift to the second half of this study, in which we will address the research
// questions outlined in the first chapter using the models calibrated in @sec:calibration.
// This chapter introduces the experimental methods we will use to address these questions.


// In @sec:methods-directional-differential we describe the use of directional differentials
// to identify significant cases of asymmetry in the KBS model. We then outline our approach
// to modelling interventions in belief systems in @sec:methods-modelling-interventions.
// Following this, Sections @sec:methods-inbound-outbound[] and @sec:methods-qois[] describe
// the experimental approach and quantities-of-interest, respectively, used in our simulated
// intervention experiments. Finally, in @sec:methods-effect-characterisation-function we
// describe how regression decision trees may be used to characterise, at a high level, the
// conditions under which a given intervention is likely to be effective


== Assessing asymmetric influence using the KBS model <sec:methods-directional-differential>

To investigate the prevalence of asymmetric relations in the asymmetric model calibrated
to the climate beliefs dataset, we examine differences in directional interaction
effects between each pair of beliefs in the asymmetric models calibrated via
bootstrapping in the previous chapter.

For each bootstrapped model, $cal(M)_((i))$ with parameters
$chevron bold(J)_((i)), bold(h)_((i)) chevron.r$, we obtain an estimate for
the directional differential matrix:

$
  Delta_J^((i)) = bold(J)_((i)) - bold(J)^T_((i))
$ <eqn:methods-directional-differential-matrix>

Recall that the $k$'th row of $bold(J)_((i))$, for #box[$k in [N]$],
describes the strength and direction of influence _from_ the
belief $S_k$ _toward_ each other belief. Hence for $k, ell in [N]$ we should
interpret the element $(Delta_(J)^((i)))_(k,ell)$ of the directional differential matrix
as the excess influence of belief $S_k$ on $S_ell$. A positive value indicates that
$S_k$ exerts greater influence on $S_ell$ than $S_ell$ does on $S_k$.

Note that, while in the previous chapter (#internal-link(<edge-existence-warning>)) we
cautioned against using bootstrapped confidence intervals to test for the _existence_ of
edges by comparison with zero in regularised models, this caution does not apply to
the _comparison_ of edge weights via the mean difference
@epskampEstimatingPsychologicalNetworks2018.

Degree centrality and strength centrality are commonly used to assess the _importance_
or _position_ of a belief within a belief system @brandtWhatCentralPolitical2019
@bringmannWhatCentralityMeasures2019 @chambonTailoredInterventionsBroad2022
@brandtInterattitudeCentralityDoes2023. Degree centrality measures the number of
edges adjacent to a node in a network. Strength centrality measures the sum of
absolute edge weights. In directed networks, however, these centrality indices can be
calculated using either incoming or outgoing edges, and the resulting values may differ.
To understand the potential impact of symmetric-influence assumptions on judgements
regarding belief importance, we therefore additionally compare the incoming and outgoing
values of both centrality indices for each belief that exhibits significant asymmetric
influence.


== Modelling interventions <sec:methods-modelling-interventions>

#let structural-intervention-footnote = footnote[
  Although not considered here, we implement such structural interventions in the
  Ising Python package, which is published alongside this study. We discuss this topic in
  @sec:discussion.
]

We now outline our approach to modelling interventions in the KBS model. In this study,
we consider interventions which affect a belief system's _state_. Notably, this excludes
interventions which affect the structure of a belief system, for instance, by changing
the existence, sign, direction, or effect size of influence relations between
beliefs.#structural-intervention-footnote


Let $cal(M)$ be a belief system model with parameters
$chevron bold(J), bold(h) chevron.r$.
We can consider an intervention as an
auxiliary node, $I$, in the belief system network, with state fixed at a particular
value and outgoing edges toward a subset of beliefs:

#figure(
  outlined: false,
  placement: none,
  image("../diagrams/modelling_interventions/intervention.svg", width: 45%),
)

In the diagram above, the intervention node $I$ influences the beliefs
$A$ and $B$. Consider the effective baseline activation for belief $A$ at
time $t+1$, as defined in @eqn:model-effective-activation, given a previous configuration
$bold(s)^t$:

$
  h_A^"eff" (bold(s)^t) = h_A + sum_("node" j) J_(j A) s^t_j
$ <eqn:asymmetric-belief-system-int-example-eff-baseline>

Since the state of $I$ is fixed (in this case, at $+1$), the intervention node's
contribution to $A$'s effective activation baseline is simply $J_(I A)$.
We can then rewrite @eqn:asymmetric-belief-system-int-example-eff-baseline,
interpreting the intervention effect as an adjustment to the baseline activation
$h_A$:

$
  h_A^"eff" (bold(s)^t) = (h_A + J_(I A)) + sum_("node" j != I) J_(j A) s^t_j
$

It follows that we can equivalently model interventions more simply as adjustments
to the baseline activations of particular beliefs:

#figure(
  outlined: false,
  placement: none,
  image("../diagrams/modelling_interventions/intervention_baseline_activation.svg", width: 35%),
)

Let us define this more formally. For a belief system model $cal(M)$ as defined above
with #box[$N in NN$] nodes, an *intervention* is the function
$phi_cal(M): bold(delta)_h mapsto cal(M)'$, where $bold(delta)_h in RR^N$ is a vector of offsets to
the baseline activations, and the model $cal(M)'$ has parameters
$chevron bold(J), bold(h)' chevron.r$, where

$
  bold(h)' = bold(h) + bold(delta)_h
$

Our approach is analogous to the method described by
#cite(<dalegeNetworkAnalysisAttitudes2017>, form: "prose") for modelling interventions in
symmetric belief system models, variants of which have been used in other
simulated-intervention studies
@schlicht-schmalzleAttitudeNetworkAnalysis2018 @lunanskyInterveningPsychopathologyNetworks2022
@berteroConsolidationChangeExploring2025 @wuSimulatingNodeManipulations2026.

The principles underlying this approach can also be used to model other exogenous factors
that influence belief system dynamics but are not influenced by them. For instance,
#cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose") use an analogous mechanism
in a social network context, to represent how an individual's actual belief state infuences
another individual's second-order belief about that state (i.e., their
belief about what the first individual believes).

=== Intervention strength <sec:methods-intervention-strength>

Recall that in @chp:kinetic-belief-system, we defined the probability distribution over
states for a given belief as a non-linear (specifically, logistic) function of that
belief's effective baseline activation (@eqn:model-activation-probability). Since
interventions adjust the baseline activation linearly, an intervention
with fixed strength $delta_h in RR$ will affect individuals differently depending on
their pre-intervention states.

@fig:methods-intervention-strengths-probability illustrates how the probability of
activation of an intervention belief (@eqn:model-activation-probability) varies
across different intervention scenarios as a function of the effective baseline
activation. Since interventions constitute offsets to the effective baseline activation,
they are reflected as horizontal shifts in the logistic curve.

#figure(
  image("../results/figures/methods/intervention_strengths.pdf"),
  caption: caption(
    short: [Impact of intervention on activation probability],
    long: [
      Impact of different intervention strengths ($delta_h in {0, 0.5, 1.5, 2.5}$) on
      activation probability for the intervention belief. Activation probability is
      calculated using @eqn:model-activation-probability.
    ],
  ),
) <fig:methods-intervention-strengths-probability>

The solid line denotes the null scenario in which no intervention is applied. Consider
two individuals, positioned at different locations on this base curve:

+ $h_"eff" = 0$: Ambivalent disposition toward the intervention belief, and

+ $h_"eff" = -2$: Strong negative disposition toward the intervention belief.

To understand the impacts of intervention strength on each individual, we draw a
vertical line upward from the solid curve at each location, and read off the activation
probability at each intersection with the other intervention curves. Under the null
scenario ($delta_h = 0$), the first individual exhibits an equal tendency toward each
state, while the second is almost certain to adopt the state $-1$.

Notice that interventions are not experienced equally by the two individuals. For
a weak intervention ($delta_h = 0.5$), the first individual sees a substantial jump in
activation probability, while the corresponding increase for the second individual is
negligible. The stakes are reversed under a strong intervention ($delta_h = 2.5$).
//We can understand this difference in effect both conceptually and analytically.
Prior to intervention, the first's indifference makes them maximally
susceptible to interventions, while the second's strong negative stance is only
affected by large interventions. On the other hand, the second individual's state
has the _potential_ to change more than the first individual's. Consider that
the interventions can, at best, shift the first individual from indifference to support,
whereas the second individual could shift from opposition to support.

// *TODO:* Quantitative explanation:
// - Take derivative of the difference in activation probabilities between intervention
//   and null scenario; solve for derivative equal to zero. Corresponds to the unique
//   maximum since for $h_"eff" -> plus.minus infinity$ the second derivative is strictly
//   positive.
// - We find that maximum is at $h_"eff" = -delta_h / 2$.
// - i.e., for a given intervention strength, the maximum change in activation probability
//   occurs when the intervention causes $h_"eff"$ to increase to same magnitude on the
//   other side of zero.
// - Individuals below this point require a stronger intervention to move the same amount.
// - Individuals above this point experience ceiling effect. A smaller intervention could
//   achieve almost the same effect.


== Outbound and Inbound interventions <sec:methods-inbound-outbound>

For the experiments in the following chapters, we distinguish between *outbound* and
*inbound* interventions, illustrated below with arrows denoting (a subset of) the
pathways through which interventions may propagate.
#{
  set text(size: 12pt)
  figure(
    grid(
      columns: (1fr, 1fr),
      rows: 2,
      row-gutter: 0.8em,
      align: (center, center),
      [*Outbound*], [*Inbound*],
      grid.cell(colspan: 2, image("../diagrams/modelling_interventions/inbound_outbound.svg", width: 85%)),
    ),
    outlined: false,
    placement: none,
  )
}
Outbound
intervention experiments (left) examine how interventions on a particular belief propagate
to other beliefs. On the other hand, inbound intervention experiments
(right) consider how a focal belief's behaviour is differently affected by interventions
elsewhere in the network. We refer to the belief on which an intervention is applied as
the *point of intervention* (marked 'P' in the diagram) and the belief whose
resulting state is measured as the *target* (marked 'T' in the diagram).

== Choice of points-of-intervention and targets <subsec:methods-choice-of-pois-and-targets>

Since our outbound intervention experiments are intended to assess differences in
intervention propagation between symmetric and asymmetric belief systems, we select
points of intervention that are likely to highlight these differences. So that
interventions can propagate, we prioritise beliefs that are reasonably influential in
both belief system models. Additionally, we attempt to select beliefs with varying
degrees of asymmetry, conditional on the models featuring such beliefs.

// Points of intervention:
// - Want to understand difference in how interventions propagate in symmetric and
//   asymmetric belief systems
// - Choose variables which are somewhat influential. Choose some which have substantial
//   asymmetric influences (i.e., which are at the 'center' of the belief system asymmetry)
//   and some which do now. If such variables exist.

For the inbound experiments, our intention is to assess differences
in intervention strategy and the relative effectiveness of different interventions.
In this case, ideal target beliefs are those which are reasonable targets in actual
interventions. We select `CC Action` (attitudes toward climate action) for all inbound
intervention experiments. Compared with the other variables in the climate beliefs
dataset (for instance, beliefs about the existence of climate change or climate-related
worry), we expect this belief to correlate most directly with climate-related behavioural
choices, and hence be a justifiable intervention target.

== Counterfactual experiments with Common Random Numbers <subsec:methods-common-random-numbers>

Most of our experiments involve comparing simulated behaviour across different KBS
models, either to examine the impact of an intervention by comparing with a null
(i.e., no-intervention) model, or to assess the impact of interaction symmetry
assumptions by comparing symmetric and asymmetric models. The KBS model
dynamics are inherently stochastic, with different trajectories reflecting differences
in experimental conditions characterised by unmeasured, exogenous influencing factors.

We use Common Random Numbers (CRN) @lawSimulationModelingAnalysis2015[pp.~588--604] to
ensure that measured differences in such experiments reflect differences between the compared
models, rather than differences in the stochastic conditions under which they are
simulated. Specifically, in every situation where we compare observables between two models, we:
(i) initialise the models using identical random seeds, and (ii) for each stochastic
operation, we use the same random numbers for each model. The second point follows
directly from the first in the KBS model, since the number of stochastic operations per
simulation timestep is fixed, and these occur in a pre-specified order.

As a safeguard, we verify each use of CRN in our experiments by comparing
final floating-point samples drawn for each model after each simulation. We write these
to disk and compare the sampled values after all simulations are complete. An error
is raised if any differences are found.

== Measuring the effects of interventions and asymmetry  <sec:methods-qois>

We now define three quantities of interest that we will use to assess the impacts
of interventions and the impacts of assumptions about asymmetry. The first two are used in
@sec:results-asymmetry-in-belief-systems to investigate population-level model
behaviour, while the third is used in
@sec:heterogeneity-in-belief-systems-and-intervention-effects to examine individual-level
intervention impacts.
All three quantities are computed using Common Random Numbers, as discussed above.

First, let us establish some shared notation. For a KBS model $cal(M)$, we denote the
result of simulating $cal(M)$ for $t in NN$ timesteps (as in
@subsec:methods-glauber-dynamics) from an initial state $bold(s)_0$, as
$cal(M)^t (bold(s)_0)$. Also, we denote the activation probability (as defined in
@eqn:model-activation-probability) for a belief $S_i$ following this simulation as
$p_i^t (bold(s)_0, cal(M))$.

The *effect-of-intervention (on state)* and the *effect-of-asymmetry*, respectively, measure
the impact of an intervention on observed belief system behaviour with reference to our
expectations in a no-intervention scenario (@def:asymmetry-results-effect-of-intervention),
and the difference in observed behaviour in the asymmetric KBS model, compared with our
expectations in the symmetric model (@def:asymmetry-results-effect-of-asymmetry).

#definition[Effect-of-intervention (on state)][
  For an intervention (KBS) model $cal(M)_delta$ with an arbitrary point of intervention, we
  define the *effect-of-intervention (on state)* for $cal(M)_delta$ as the change in outcome at
  time $t in NN$, with respect to the null (no-intervention) model, $cal(M)_0$:

  $
    f_"state" (cal(M)_delta) = cal(M)_delta^t (bold(s)_0) - cal(M)_0^t (bold(s)_0)
  $
] <def:asymmetry-results-effect-of-intervention>

#definition[Effect-of-asymmetry][
  Let $cal(M)_"asym"$ be a calibrated asymmetric KBS model
  with an arbitrary intervention applied, and $cal(M)_"sym"$ be a corresponding
  symmetric KBS model calibrated to the same dataset.
  We define the *effect-of-asymmetry* for $cal(M)_"asym"$ as the difference
  in the effect-of-intervention (on state) with respect to the symmetric model:
  $
    f_"asym" (cal(M)_"asym") = f_"int" (cal(M)_"asym") - f_"int" (cal(M)_"sym")
  $
] <def:asymmetry-results-effect-of-asymmetry>

Finally, the *effect-of-intervention (on influence)* measures the impact of an
intervention on the total influence experienced by a given belief, with reference
to our expectations under the no-intervention scenario (@def:methods-effect-on-influence).
Note that this is richer than the effect-of-intervention (on state), which derives
from the activation probabilities. We can make use of this richness in individual-level
experiments, while in population-level experiments,
@def:asymmetry-results-effect-of-intervention is more straightforwardly applicable.

#definition[Effect-of-intervention (on influence)][
  For an intervention (KBS) model $cal(M)_delta$ with an arbitrary point of intervention, we
  define the *effect-of-intervention (on influence)* for $cal(M)_delta$ as the change in
  activation probability at time $t in NN$, with respect to the null (no-intervention)
  model, $cal(M)_0$:

  $
    f_"influence" (cal(M)_delta) = p_i^t (bold(s)_0; cal(M)_delta) - p_i^t (bold(s)_0; cal(M)_0)
  $
] <def:methods-effect-on-influence>

== Identifying the conditions for effective interventions  <sec:methods-effect-characterisation-function>

In the simulated interventions described above, the only
distinguishing factor between individuals is their pre-intervention state. It follows
that any difference in belief system dynamics between distinct individuals---after
accounting for simulation stochasticity---is the result of their different initial
states. Therefore, to identify the conditions under which an intervention is effective,
it then suffices to characterise the set of _initial states_ which yield effective
interventions and distinguish them from those that do not.

Our goal is to find a function which maps from an intervention effect to
sets of (unbinarised) states that yield that effect, $g: RR -> 2^X$, where
#box[$X = [-1,+1]^N subset RR^N$]. We will call $g$ the *effect characterisation function*.
We measure intervention effects here using the effect-of-intervention on influence
(@def:methods-effect-on-influence).

Consider a function which does the opposite, mapping initial states to a measure of
intervention effect, $f: X -> RR$. Given such a function, we can straightforwardly
construct the corresponding effect characterisation function as:

$
  g: y mapsto {x in plus.minus 1^N subset RR^N | f(x) = y}
$ <eqn:heterogeneity-results-effect-characterisation-function>

However, while technically satisfying the definition of the effect
characterisation function, such a function would likely be useless for qualitatively
determining the kinds of initial states which yield effective interventions.
The elements of the codomain have (potentially) infinite cardinality, and are
not immediately interpretable. For our purposes, we are less interested in the
specific states that yield a given intervention effect, and more interested in a
_concise description_ of that set of states.

=== Method: Shallow regression decision-tree <subsec:methods-effect-characterisation-function-decision-tree>

Regression decision-tree models can provide such descriptions, using inequality bounds
to partition the initial state space into regions, each of which is assigned a
predicted effect. Given a parameterised regression decision-tree, we
may construct a concise approximation to the effect characterisation function by
identifying, for each predicted effect, the combination of inequalities which define
the corresponding infinite set of initial states. When the parameter estimation algorithm
is restricted to shallow trees (e.g., depth 3 or 4, where depth refers to the number of
inequality bounds defining each region), these combinations can also be interpreted as
rules or _personas_.

Since the regression decision-tree produces a full tree, all personas for a tree with
depth $d in NN$ have size $d$ by default. However, these can often be compressed. When
two personas differ in only one feature dimension, split at the same value, and both
predict high-effect interventions, we can combine them into a single persona that omits
that feature (i.e., spans the entire feature dimension).

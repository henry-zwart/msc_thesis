#import "@local/drifting-cls-thesis:0.1.0": caption
#import "@preview/zero:0.6.1": num

#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *

#show: show-theorion

== Identifying asymmetric relations with the KBS model <sec:methods-directional-differential>

To investigate the existence of asymmetric relations in the asymmetric model calibrated
to the climate beliefs dataset, we examine the differences in directional interaction
effects for the asymmetric models calibrated using bootstrapping in the previous
section.

For each bootstrapped model, $cal(M)_((i))$ with parameters
$chevron bold(J)_((i)), bold(h)_((i)) chevron.r$, we obtain an estimate for
the directional differential matrix:

$
  Delta_J^((i)) = bold(J)_((i)) - bold(J)^T_((i))
$ <eqn:methods-directional-differential-matrix>

Recall that the $k$'th row of $bold(J)_((i))$ (for #box[$k in {1, ..., N}$])
describes the strength and direction of influence _from_ the
spin $S_k$ _toward_ each other spin. Hence for $k, ell in {1, ..., N}$ we should
interpret the element $Delta_(J)^((i))|_(k,ell)$ of the directional differential matrix
as the excess influence of spin $S_k$ on $S_ell$. A positive value indicates that
$S_k$ exerts greater influence on $S_ell$ than $S_ell$ does on $S_k$.


== Modelling interventions <sec:methods-modelling-interventions>

#let structural-intervention-footnote = footnote[
  Although not considered here, we implement such structural interventions in the
  Ising Python package published alongside this study. We discuss this topic in
  @sec:discussion.
]

We now outline our approach to modelling interventions in the asymmetric belief
system model. In this study we consider interventions which affect the _state_ of a
belief system. Notably, this excludes interventions intended to influence the structure
of a belief system, for instance, by changing the existence, sign, direction, or
effect size of influence relations between beliefs#structural-intervention-footnote.


Let $cal(M)$ be a belief system model with parameters
$chevron bold(A), bold(J), bold(h) chevron.r$.
We can consider an intervention as an
auxiliary node, $I$, in the belief system network, with state fixed at a particular
value and outgoing edges toward a subset of beliefs:

#figure(
  outlined: false,
  placement: none,
  image("../diagrams/modelling_interventions/intervention.svg", width: 45%),
)

In the diagram above, the intervention node $I$ exerts influence on the beliefs
$A$ and $B$. Consider the effective baseline activation for belief $A$ at
time $t+1$, as defined in @eqn:model-effective-activation, given a previous configuration
$bold(s)^t$:

$
  h_A^"eff" (bold(s)^t) = h_A + sum_("node" j) J_(j A) s^t_j
$ <eqn:asymmetric-belief-system-int-example-eff-baseline>

Since the state of $I$ is fixed (in this case, at $+1$), the contribution of the
intervention node to $A$'s effective activation baseline is simply $J_(I A)$.
We can then re-write @eqn:asymmetric-belief-system-int-example-eff-baseline, interpreting the
intervention effect as an adjustment to the baseline activation $h_A$:

$
  h_A^"eff" (bold(s)^t) = (h_A + J_(I A)) + sum_("node" j != I) J_(j A) s^t_j
$

It follows that we can then equivalently model interventions more simply as an adjustment
to the baseline activation of certain beliefs:

#figure(
  outlined: false,
  placement: none,
  image("../diagrams/modelling_interventions/intervention_baseline_activation.svg", width: 35%),
)

Let us define this more formally. For a belief system model $cal(M)$ with $N in NN$
nodes, and parameters $chevron bold(A), bold(J), bold(h) chevron.r$, an _intervention_,
is the function $phi_cal(M): delta_h mapsto cal(M)'$, where $delta_h in RR^N$ is a vector
of offsets to the baseline activations, and the model $cal(M)'$ has parameters
$chevron bold(A), bold(J), bold(h)' chevron.r$, where

$
  bold(h)' = bold(h) + delta_h
$

Our approach is analogous to the method for modelling interventions in symmetric
belief system models, described by
#cite(<dalegeNetworkAnalysisAttitudes2017>, form: "prose"), variants of which have been
used in other simulated-intervention studies
@schlicht-schmalzleAttitudeNetworkAnalysis2018 @lunanskyInterveningPsychopathologyNetworks2022
@berteroConsolidationChangeExploring2025 @wuSimulatingNodeManipulations2026.

The principles underlying this approach can also be used to model other exogenous factors
which influence, but are not influenced by, belief system dynamics. For instance,
#cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose") use the same mechanism
in a social network context, to represent the influence of an individual's actual belief
state on another individual's second-order belief regarding this state (i.e., their
belief about what the other person believes).

=== Intervention strength <sec:methods-intervention-strength>
@fig:methods-intervention-strengths-probability illustrates how the probability of
activation for the intervention spin (@eqn:model-activation-probability) changes
for different intervention scenarios. Recall that a spin's activation probability is
a function of it's effective local field. Since interventions constitute offsets to the
effective local field, they are reflected as horizontal shifts in the logistic curve.

#figure(
  image("../results/figures/methods/intervention_strengths.pdf"),
  caption: caption(
    short: [Impact of intervention on activation probability],
    long: [
      Impact of different intervention strengths ($delta_h in {0, 0.5, 1.5, 2.5}$) on
      activation probability for the intervention spin. Activation probability is
      calculated using @eqn:model-activation-probability.
    ],
  ),
) <fig:methods-intervention-strengths-probability>

The solid line denotes the null scenario in which no intervention is applied. Consider
two individuals, positioned at different locations on this base curve:

+ $h_"eff" = 0$: Ambivalent disposition toward the intervention spin, and

+ $h_"eff" = -2$: Strong negative disposition toward the intervention spin.

To understand the impacts of intervention strength on each individual, we draw a
vertical line upward from the solid curve at each location, and read off the activation
probability at each intersection with the other intervention curves. Under the null
scenario ($delta_h = 0$) the first individual exhibits an equal tendency toward each
state, while the second is almost certain to adopt the state $-1$.

Notice that interventions are not experienced equivalently by the two individuals. For
a weak intervention ($delta_h = 0.5$), the first individual sees a substantial jump in
activation probability, while the corresponding increase for the second individual is
negligible. The stakes are reversed under a strong intervention ($delta_h = 2.5$).
//We can understand this difference in effect both conceptually and analytically.
Prior to intervention, the first's indifference makes them maximally
susceptible to interventions, while the second's strong negative stance is only
affected by large interventions. On the other hand, the second individual's state
has the _potential_ to change more than that of the first individual. Consider that
the interventions can, at best, shift the first individual from indifference to support,
in contrast to the potential shift from opposition to support in the case of the second
individual.

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
*inbound* interventions, illustrated below. Outbound
intervention experiments (left) examine how interventions on a particular spin propagate
to other beliefs. On the other hand, inbound intervention experiments
(right) consider how a focal belief's behaviour is differently affected by interventions
elsewhere in the network. We refer to the belief on which an intervention is applied as
the *point-of-intervention* (marked 'P' in the diagram) and the belief whose
resulting state is measured as the *target* (marked 'T' in the diagram).

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

== Counterfactual interventions <sec:methods-counterfactual-interventions>

Individuals have different belief systems. Influence relations between beliefs reflect
heterogeneity in individual experiences and perception. Often these
relations can themselves be considered beliefs --- whether or not support for climate
change mitigation leads to support for any specific policy depends in-part on an
individual's belief regarding the policy's relevance. An individual's
baseline activations, in turn, reflect a culmination of factors which determine their
tendency toward certain beliefs.

Our approach to parameter estimation, however, fundamentally assumes that the inferred
belief system is shared by all individuals in the dataset from which the model is
estimated. We note that this is not strictly a limitation of the parameter estimation
method, nor of the model itself. Rather this assumption is imposed by data limitations.
Fitting individual models requires substantial data from each individual, which is not
available in the climate beliefs dataset. Moreover, even with substantial
observational data, we are unlikely to observe all state transitions necessary to
understand the _potential_ dynamics of an individual system, owing to the relatively
slow-moving nature of beliefs.

For any given individual, the inferred models may thus not accurately reflect the
stability of belief system states. A configuration which is stable in a given
individual's own belief system may be considered unstable in the shared model. When
simulating interventions, we take the most recent measurement for each individual
as their initial state. However, due to this perceived instability, we expect to
observe natural dynamics away from this initial state, even in null-intervention
scenarios.

We thus consider intervention effects as relative to the null-intervention
counterfactual baseline rather than relative to the initial state. For each
intervention we run both intervention and null ($delta_h = 0$) scenarios with identical
random number generation settings, and define the _intervention effect_ as the
difference between the observed outcomes.

== Assessing intervention effects and the impact of asymmetry <sec:methods-qois>

We define two quantities of interest: the *effect of intervention*, and *effect of
asymmetry*. These are used, respectively, to assess an intervention's impact on a given
spin's behaviour with reference to our expectations in a no-intervention scenario
(@def:asymmetry-results-effect-of-intervention),
and the difference in a spin's behaviour in the asymmetric model, compared to our
expectations in the symmetric model (@def:asymmetry-results-effect-of-asymmetry).
Note that the
effect of asymmetry is not inherently concerned with intervention, but is a general
measure for the difference between asymmetric and symmetry model dynamics.

Both quantities compute a difference in effects between two distinct models: the
intervention and null models for the effect of intervention, and the asymmetric
and symmetric models for the effect of asymmetry. To ensure outcome
comparability, differences are computed between models with identical random number
generation contexts.

#definition[Effect of Intervention][
  Let $cal(M)$ be a non-equilibrium belief system model, and denote the result of
  simulating the model for $t in NN$ timesteps with initial state $bold(s)_0$ as
  $cal(M)^t (bold(s)_0)$.

  For an intervention model $cal(M)_delta$ with an arbitrary point-of-intervention, we
  define the *effect of intervention* for $cal(M)_delta$ as the change in outcome at
  time $t in NN$, with respect to the null (no-intervention) model, $cal(M)_0$:

  $
    f_"int" (cal(M)_delta) = cal(M)_delta^t (bold(s)_0) - cal(M)_0^t (bold(s)_0)
  $
] <def:asymmetry-results-effect-of-intervention>

#definition[Effect of Asymmetry][
  Let $cal(M)_"asym"$ be a calibrated asymmetric non-equilibrium belief system model
  with an arbitrary intervention applied, and $cal(M)_"sym"$ be a corresponding
  symmetric model calibrated to the same dataset.
  We define the *effect of asymmetry* for $cal(M)_"asym"$ as the difference
  in the effect of intervention with respect to the symmetric model:
  $
    f_"asym" (cal(M)_"asym") = f_"int" (cal(M)_"asym") - f_"int" (cal(M)_"sym")
  $
] <def:asymmetry-results-effect-of-asymmetry>

== The Effect Characterisation Function <sec:methods-effect-characterisation-function>

In the simulated interventions described above, the only
distinguishing factor between individuals is their pre-intervention state. It follows
that any difference in belief system dynamics between distinct individuals---after
accounting for simulation stochasticity---is the result of their different initial
states. To identify the conditions under which an intervention is effective,
it then suffices to characterise the set of _initial states_ which yield effective
interventions, and distinguish them from those that do not.

In this case, we define the intervention effect
(at time $t$) as the expected difference in activation probability
(@eqn:model-activation-probability) between the intervention model and the null model
when simulated using common random numbers. By defining this quantity with
respect to the activation probability, we capture how an intervention changes
the influence on a belief. In contrast, the _effect of intervention_ defined
above measures the change in state, which derives from the change in activation
probability.

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
characterisation function, such a function would likely be useless for qualitatively
determining the kinds of initial states which yield effective interventions.
The elements of the codomain have (potentially) infinite cardinality, and are
not immediately interpretable. For our purposes, we are less interested in the
_specific_ states that yield a given intervention effect, but more so in a
_concise description_ of that set of states.

=== Method: Shallow regression decision tree <subsec:methods-effect-characterisation-function-decision-tree>

Regression decision tree models can provide such descriptions, using inequality bounds
to partition the initial state space into regions, each of which is assigned a
predicted effect. Given a parameterised regression decision tree, we
may construct a concise approximation to the effect characterisation function by
identifying, for each predicted effect, the combination of inequalities which define
the corresponding infinite set of initial states. When the parameter estimation algorithm
is restricted to shallow trees (e.g., depth 3 or 4, referring to the number of inequality
bounds defining each region), these combinations can also be interpretable as rules or
_personas_.

Since the regression decision tree produces a full tree, all personas for a tree with
depth $d in NN$ have size $d$ by default. However, these can often be compressed. When
two personas differ only along one feature dimension, split at the same value, and both
predict high-effect interventions, we can combine these into a single persona which omits
that feature (i.e., spans the entire feature dimension).

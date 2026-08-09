#import "@local/drifting-cls-thesis:0.1.0": caption

#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

In this chapter, we define the *Kinetic Belief System* model (*KBS*) as a model of
belief system dynamics which supports (but does not assume) asymmetric influence
relations between beliefs.


The KBS model builds on the Causal Attitude Network (CAN) model
by #cite(<dalegeFormalizedAccountAttitudes2016>, form: "prose"), extending their
formulation of an _attitude network_ (which we call a _belief system_) to a kinetic
Ising model framework @glauberTimeDependentStatisticsIsing1963
@fredricksonKineticIsingModel1984. Our treatment of belief system dynamics
in the KBS model mirrors the approach used by
#cite(<haslbeckInterpretingIsingModel2021>, form: "prose") and
#cite(<brandtEvaluatingBeliefSystem2021>, form: "prose") to model belief dynamics
in symmetric belief system models (similar to the CAN model).


We begin the chapter by formalising belief system _dynamics_ as a modelling problem,
after which we present the KBS model as a solution to this problem which permits
asymmetric influence relations. Finally, we outline one approach to simulating the
KBS model using Glauber dynamics.

#note-block[
  In this study, we use the inclusive definition of beliefs
  proposed by #cite(<galesicIntegratingSocialCognitive2021>, form: "prose"), also
  adopted by #cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose"). This includes
  "beliefs as assumptions about states of the world, ... views on moral and political
  issues, ... evaluations or cognitive aspects of attitudes or as own preferences".
]

// TODO: Discussion on interpreting asymmetric relations in terms of the
// mathematical/conceptual models
//


// - Interdependent beliefs and attitudes; state of one affects the state of another:
//   - Cognitive dissonance
//   - Causal effects(?)
// - Individual belief systems:
//   - Degree of influence depends on individual experience, perception, meta-level
//     beliefs.
// - Formalising dynamics:
//   - Discrete beliefs, attitudes which take on values in some domain
//   - State of each one depends on previous in a Markov process
//   - Broader Markov process describes the state of the belief system as a whole
//

== Modelling belief system dynamics

Our theory of belief system dynamics rests on three main assumptions. First, we assume
that beliefs can be represented as discrete random variables. This allows
us to consider beliefs as entities characterised by an instantaneous
state. In particular, this assumption is not compatible with the perspective that beliefs
are contextual, with no singular internal state of their own
@bendanaFragmentationBelief2021 @riemerPreferencesDontHave2014.

Second, we assume that the state
distribution for any given belief (potentially) depends on the previous
states of all others, formalising the idea that past beliefs influence present
ones. Finally, we assume that these conditional distributions are time-invariant. While
belief _states_ may change over time, the dynamics by which this happens do
not.

// For instance, they  sensitive to context (e.g., being in a certain location or
// talking to a specific person), physical state (e.g., tiredness), or
// such as
#important-block[
  The term *belief* is presently ambiguous. It can refer
  to generic concepts (e.g. belief regarding the contents of a box) or specific instances
  of those concepts (e.g., 'I believe that the box is empty').

  For the remainder of this thesis, unless stated otherwise, we adopt the
  _generic_ sense. That is to say that we use the term 'belief' without assuming any
  particular epistemic state, view, evaluation, or preference.
]




// We will now formalise the dynamics of an individual belief system, under the following
// three assumptions:
//
//
// + Each belief or attitude can be treated as a distinct entity,   .
//
// + The state of a belief or attitude depends only on the previous configuration of beliefs
//   and attitudes.
//
// + The transition probability is time-invariant.
//
// The first assumption includes two key points. Firstly, that it makes sense to consider
// beliefs and attitudes as _entities_, or _objects_. This contrasts, for instance,
// alternative interpretations of attitudes as emissions from an underlying structure.
// (*TODO:* review CAN paper for further discussion on this matter). Secondly, that
// beliefs and attitudes can be considered _discrete_ or _separable_. This is to say
// that there are no absolute physical constraints on the combinations of states which
// may be observed (although certain combinations may be highly unlikely). In particular,
// this captures the requirement that each belief or attitude can be represented using a
// single state variable.
//
// Our second assumption concerns the treatment of beliefs and attitudes as Markovian.
// - Harder to justify conceptually, since individuals have memory and can recall prior
//   states beyond the previous second.

Consider a set of beliefs $bold(S) = {S_1, S_2, ..., S_N}$.
Given the above assumptions, we can describe the trajectory of a belief $S_i$ with domain
$Omega_i$ as a sequence of states
$
  {s_i^t}_(t=1)^infinity quad "where" quad s_i^t in Omega_i
$ <eqn:methods-belief-system-dynamics-belief-markov-process>
characterised by the family of conditional distributions $P(sigma_i^(t+1) | bold(sigma)^t)$ for
$1 < t in NN$ and an initial state $P(sigma_i^1)$.

Noting that the state of a belief $S_i$ depends only on the previous states of all other
beliefs, it follows that any pair of beliefs $S_i$ and $S_j$
are conditionally independent at a given timestep given all previous belief
states. In particular, this means we can describe the evolution of the complete set
of beliefs as a Markov process:

$
  {bold(s)^t}_(t=1)^infinity quad "where" bold(s)^t in Omega_1 times dots.c times Omega_N
$ <eqn:methods-belief-system-dynamics-belief-system-markov-process>

with transition probability
$P(bold(sigma)^(t+1) | bold(sigma)^t) = product_i^N P(sigma_i^(t+1) | bold(sigma)^t)$ for
$1 < t in NN$ and initial state probability
$P(bold(sigma)^1) = product_(i=1)^N P(sigma_i^1)$.

We use the term *belief system* to refer to the combination of a collection of beliefs
$bold(S)$ and its associated transition probability distribution
$P(bold(sigma)^(t+1) | bold(sigma)^t)$.
In this
conceptualisation, the task of modelling a belief system reduces to describing how the
instantaneous configuration of belief states affects the distribution over
possible future states.

// NOTE:
// Although the above definitions do not specify the duration of a single timestep, in
// practice this time between ,While the above definition does not specify a time-scale,   In practice, the time For the purposes of




// Consider a belief or attitude $S_i$ with domain $Omega_(S_i)$. The state of $S_i$
// at time $t$ depends on the previous states of other beliefs and attitudes, and
// we can therefore describe the trajectory of $S_i$ as a Markov process:
//
//
// with conditional state probability $P(S_i^(t+1) | bold(S)^1, ..., bold(S)^t)) = P(S_i^(t + 1) | bold(S)^t)$ for $t in NN$.
//
// Since the state of $S_i^(t+1)$ depends only on the previous belief system state, it
// follows that for any other belief or attitude $S_j$, the states $S_i^(t+1)$ and
// $S_j^(t+1)$ are conditionally independent given $bold(S)^t$. We can therefore
// straightforwardly describe the evolution of the entire belief system as the Markov
// process:
//
//
// with associated transition probability given by the conditional distribution
// $P(bold(S)^(t+1) | bold(S)^t)$ and initial state probability $P(bold(S)^0)$.



== Kinetic Belief Systems <subsec:theory-nonequilibrium-belief-system-model>

// *TODO:*
// - Builds on the CAN model, also known as the 'Ising model of attitudes'
//   @vandermaasPolarizationIndividualsHierarchical2020
//   - Also @brandtEvaluatingBeliefSystem2021
// - Points of contrast:
//   - Asymmetric interactions
//   - Self-interactions
// - @brandtEvaluatingBeliefSystem2021 also uses transition probabilities like ours
//   - Also @haslbeckInterpretingIsingModel2021


// *NOTE:*
// Self-interaction effects:
// - @brandtEvaluatingBeliefSystem2021[p.~22]: "we made the simplifying assumption that a node
//   does not affect itself".



// - Why we can't use the boltzmann distribution and Hamiltonian, like in the symmetric
//   Ising model:
//   - Boltzmann gives distribution over states at equilibrium
//   - Asymmetric edges break detailed balance assumption, so the model may not be at
//     equilibrium.
//   - Furthermore, for purposes of studying intervention dynamics, we are interested
//     in out-of-equilibrium behaviour.
//
// - Instead take each spin state as sampled from a logistic distribution, parameterised
//   by the previous spin states as well as a baseline activation level.
//
// - Allow self-loops to capture inertia in belief/attitude states; introduces a natural
//   timescale for belief change.

// Goal:
// - Motivate the Kinetic Ising model
//   - CAN model to describe attitudes (belief systems)
//   - Assumes equilibrium --- this requires detailed balance
//   - We define the KBS as variation based on the Kinetic Ising Model
// - Describe the Kinetic Ising model
//   - How does it differ from the CAN model?
//     - Directed interaction effects (introduce parameters)
//     - Self-interaction effects
//   - How does it overcome the non-equilibrium problem?
//     - Defines transition probability explicitly (as in the other papers)
// - Define it:
//   - Dynamics
//
// - *A:* CAN model as theory of belief systems; assumes equilibrium dynamics

The Causal Attitude Network (CAN) model considers an attitude as represented by an
Ising-style network of beliefs (in the inclusive sense defined above)
which are related via bi-directional edges reflecting reinforcing ($+$) or cognitive
dissonance ($-$) relations @dalegeFormalizedAccountAttitudes2016. Each node, or _spin_,
in the network takes on values in the domain ${-1, +1}$, representing two opposing states.
Since the underlying Ising model contains only symmetric edges, the CAN model satisfies
detailed balance, so is an equilibrium model of belief system dynamics
@christensenComplexityCriticality2005 @cardyScalingRenormalizationStatistical1996. As
such, it's associated transition probability is stationary and is described by the
Boltzmann distribution (ibid.).

We define the *Kinetic Belief System* model (*KBS*) as a variation on the Causal Attitude
Network, based on the kinetic Ising model @glauberTimeDependentStatisticsIsing1963
@fredricksonKineticIsingModel1984. Structurally, the KBS model differs from the CAN model
in two key respects: (i) interaction effects between a given pair of beliefs are not
necessarily bi-directional or equal in strength, and (ii) self-interaction effects are
permitted.

Formally, letting $bold(S) = {S_1, ..., S_N}$ be a collection of beliefs, a kinetic
belief system model for $bold(S)$ is described by parameters
$bold(theta) = chevron bold(J), bold(h) chevron.r$, where $bold(J) in RR^(N times N)$
is a weighted adjacency matrix of directed _interaction effects_ (or _influence effects_), and
$bold(h) in RR^N$ is a vector of _baseline activation_ effects for the elements of
$bold(S)$.

A baseline activation effect, $h_i in RR$, describes the tendency for the belief $S_i$ to
take on the value $+1$ in the absence of interactions with other spins, or, more generally,
when pairwise spin interactions have a net-effect of zero. $S_i$ tends to adopt the value
$+1$ under these circumstances, iff, $h_i > 0$, and $-1$ iff $h_i < 0$. This tendency
increases with the magnitude of $h_i$.

Other spins influence $S_i$'s state through alignment or opposition relations. For
a spin $S_j$, we define an interaction effect $J_(j i)$ (read _'influence of $j$ on
$i$'_). When $J_(j i)$ is positive or negative, $S_i$ is influenced to adopt the state
$S_j^t$ or $-S_j^t$ respectively. In the special case when $j = i$, we refer
to $J_(i i)$ as a _self-influence_ of _self-interaction_ effect. Positive self-influence
effects reflect the inertia of $S_i$, i.e., the tendency to sustain a particular belief
irrespective of other beliefs. Negative self-influence effects
are not clearly interpretable. In addition to modelling differences in inertia, the
inclusion of self-interaction effects allows us to capture the timescale at which
the system, as a whole, evolves.


In contrast with the CAN model, we define the KBS model's dynamics explicitly using the
conditional distribution $P(bold(sigma)^(t+1) | bold(sigma)^t)$. There are (at least)
two reasons for this. First, critically, unlike in the CAN model, we cannot
assume that the KBS model will exhibit equilibrium dynamics, as asymmetric interaction
effects violate detailed balance, so the state transition probability is not necessarily
stationary @nguyenInverseStatisticalProblems2017. Second, by describing the model
dynamics explicitly we are forced to consider how each variable in the belief system
system responds to the states of all other beliefs (including itself). As
such, temporal dynamics are 'baked into' the KBS model, making it straightforward to
simulate forward in time to investigate potential model dynamics. We make extensive use
of this property during our simulated intervention experiments in the second half of
this study.

The conditional distribution $P(bold(sigma)^(t+1) | bold(sigma)^t)$ describes the
dynamics of the entire KBS model; however, rather than defining this directly, we will
instead stitch it together from the dynamics of the individual beliefs using
Relation @eqn:methods-belief-system-dynamics-belief-system-markov-process[].

Let $S_i in bold(S)$ be an arbitrary belief, and let $bold(s) in {-1, +1}^N$
describe the states of all beliefs in $bold(S)$ at time $t$. We define the *effective
baseline activation* of $S_i$ at time $t$ as the net pressure on this belief to adopt the
state $+1$, resulting from the combined forces of its own baseline activation and
inertia, as well as influence effects received from other beliefs:

$
  h_i^"eff" (bold(s)) := h_i + sum_j J_(j i) s_j
$ <eqn:model-effective-activation>

We then define the conditional probability that $S_i$ takes on the value $+1$ at
time $t+1$ as the logistic transform of the effective baseline activation:

$
  P(sigma_i^(t+1) = +1 | bold(sigma)^t = bold(s)) = op("logistic")(2 h_i^"eff" (bold(s)))
$ <eqn:model-activation-probability>

We obtain the probability that $S_i$ takes on the value $-1$ directly via
the complement.

Notice that the behaviour of @eqn:model-activation-probability is
consistent with our earlier interpretations of the baseline activation and interaction
effects; the probability that $S_i$ adopts the value $+1$ increases with the
baseline activation, $h_i$, through positive (reinforcing) influences from
beliefs with state $+1$ or negative (opposing) influences from beliefs with state $-1$,
and when $S_i$ previously had the state $+1$.

Finally, using Relation @eqn:methods-belief-system-dynamics-belief-system-markov-process[],
we can now describe the complete conditional transition probability for the KBS model
in terms of those belonging to the individual beliefs:

$
  P(bold(sigma)^(t+1) = bold(s)^(t+1) | bold(sigma)^t = bold(s)^t) = product_(i=1)^N P(bold(sigma)_i^(t+1) = s_i^(t+1) | bold(sigma)^t = bold(s)^t)
$ <eqn:model-kbs-dynamics>

Where the initial distribution $P(bold(sigma)^1)$ is specified directly.


== Symmetric and asymmetric belief systems

In the special case when $bold(J)$ is symmetric, we say that the kinetic belief system
model is *symmetric*, and otherwise that it is *asymmetric*. In an asymmetric KBS model,
for any pair of distinct beliefs $S_i != S_j in bold(S)$, it may be the case that an
influence relation exists in only one direction, or that the directed relations differ
in sign and/or magnitude. On the other hand, all influence relations in a symmetric KBS
model are directionally-equivalent.

The symmetric KBS model can be considered a simple extension of the symmetric Ising model
with self-interaction effects and temporal dynamics. As such, the symmetric model _does_
satisfy detailed balance, so tends toward an equilibrium steady state.

// Let $cal(M)$ be a kinetic belief system model defined as in the preceding section.
//
// with
// parameters $$, comprising
// $N in NN$ beliefs or attitudes, with adjacency matrix $bold(A) in {0,1}^(N times N)$,
// interaction effect matrix $bold(J) in RR^(N times N)$, and baseline activations
// $bold(h) in RR^N$.
//
// When each entry in $bold(J)$ is independent of all others, we say
// that $cal(M)$ is an *asymmetric belief system*. The term _asymmetric_ here refers to the
// directed relations between a pair of nodes. In an asymmetric belief system, for any pair
// of distinct nodes $S_i != S_j$, it may be the case that an influence relation exists
// only in one direction, or that the directed relations differ in magnitude.

// In the special case where we constrain $A_(i j) = A_(j i)$ and $J_(i j) = J_(j i)$ for
// all $i, j in [1, N]$, we instead say that $cal(M)$ is a *symmetric belief system*. In
// a symmetric belief system all interactions are directionally-equivalent. This can be
// considered a simple extension of the symmetric Ising model with (i) self-interaction
// terms and (ii) temporal dynamics, thus the symmetric belief system model tends toward
// an equilibrium steady state.

== Simulation via Glauber dynamics <subsec:methods-glauber-dynamics>

It is straightforward to draw samples from a belief system model using Glauber
dynamics, given the conditional probability distribution defined in
@eqn:model-kbs-dynamics.

Given an initial state $bold(s)^1 in {-1, +1}^N$, we sample a sequence of $T in NN$
subsequent configurations:

$
  {bold(s)^t}_(t=1)^T, quad "where each" bold(s)^(t+1) ~ P(bold(sigma)^(t+1) | bold(sigma)^t)
$ <eqn:asymmetric-belief-system-glauber-dynamics>

Each belief has the opportunity to update during every time interval. This
update routine is referred to as _synchronous_ Glauber dynamics, contrasting
_asynchronous_ Glauber dynamics, in which only one spin can update during a given
interval @glauberTimeDependentStatisticsIsing1963 @nguyenInverseStatisticalProblems2017.

== Modelling interventions <subsec:asymmetric-belief-system-modelling-interventions>



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

// #figure(
//   image("../diagrams/modelling_interventions/belief_system.svg", width: 30%),
// )



#figure(
  outlined: false,
  placement: none,
  image("../diagrams/modelling_interventions/intervention.svg", width: 45%),
)

The intervention node $I$ exerts influence on the belief system nodes $A$ and $B$. Let
us consider the effective baseline activation at node $A$ and time $t+1$, as defined in
@eqn:model-effective-activation, given a previous configuration $bold(s)^t$:

$
  h_A^"eff" (bold(s)^t) = h_A + sum_("node" j) A_(j A) J_(j A) s^t_j
$ <eqn:asymmetric-belief-system-int-example-eff-baseline>

Since the state of $I$ is fixed (in this case, at $+1$), the contribution of the
intervention node to $A$'s effective activation baseline is constant. We can then
re-write @eqn:asymmetric-belief-system-int-example-eff-baseline, interpreting the
intervention effect as an adjustment to the baseline activation $h_A$:

$
  h_A^"eff" (bold(s)^t) = (h_A + J_(I A)) + sum_("node" j != I) A_(j A) J_(j A) s^t_j
$

It follows then that we can model interventions more simply as an adjustment to the
baseline activation of certain beliefs:

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

// *TODO:*
// - Discuss @dalegeNetworksBeliefsIntegrative2025, which is somewhat analogous.
//
//   In the NB model exogenous changes (other peoples' beliefs) affect your belief
//   system via an interaction term to the belief about that state. Our approach is
//   analogous. The exogenous change affects our belief (say, about the state of climate
//   change) via an interaction term.
//
// Other intervention studies:
// - Simulation-based approaches that mirror ours:
//   - @dalegeNetworkAnalysisAttitudes2017
//   - @schlicht-schmalzleAttitudeNetworkAnalysis2018
//   - @lunanskyInterveningPsychopathologyNetworks2022
//   - @berteroConsolidationChangeExploring2025
//   - @wuSimulatingNodeManipulations2026
//   All use symmetric models. AFAIK none use glauber dynamics, i.e., assume equilibrium
//   right after intervention. So don't account for temporal dynamics, belief stability,
//   individual effects, etc.
// - Control theory approach @henryControlPsychologicalNetworks2022
// - Continuous-time approach (avoids the discrete time problem) @ryanTimeInterveneContinuousTime2022

== Intervention strength
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



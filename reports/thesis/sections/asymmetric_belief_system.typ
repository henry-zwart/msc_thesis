#import "@local/drifting-cls-thesis:0.1.0": caption

#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

// TODO: Discussion on interpreting asymmetric relations in terms of the
// mathematical/conceptual models
//
*TODO:* "The DT-VAR model suffers from the problem of time-interval
dependency @gollobTakingAccountTime1987" @ryanTimeInterveneContinuousTime2022
- Ours does not(?) because we use temporal data, and include self-interaction
  effects which set timescale.


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


Our theory of belief system dynamics rests on three main assumptions. First, we assume
that beliefs and attitudes can be represented as discrete random variables. This allows
us to consider beliefs and attitudes as entities characterised by an instantaneous
state. In particular, this assumption contrasts alternative views that beliefs and
attitudes are dispositional or the result of interactions with the environment, with no
associated state of their own (*CITATIONS*).

Second, we assume that the state
distribution for any given belief or attitude is conditional on the previous states
of all others, formalising the idea that past beliefs and attitudes influence present
ones. Finally, we assume that these conditional distributions are time-invariant. While
belief and attitude _states_ may change over time, the dynamics by which this happens do
not.

// For instance, they  sensitive to context (e.g., being in a certain location or
// talking to a specific person), physical state (e.g., tiredness), or
// such as
*TODO: Make clear that when we say attitude we mean evaluative state, not precise
definition used in @dalegeFormalizedAccountAttitudes2016*.

#important-block[
  The terms *belief* and *attitude* are presently ambiguous. They can refer
  to generic concepts (e.g. belief regarding the contents of a box, or attitude toward
  ...) or specific instances of those concepts (e.g., 'I believe that the box is empty',
  or '...').

  For the remainder of this thesis, unless stated otherwise, we adopt the
  _generic_ sense. That is to say that we use the term 'belief' without assuming any
  particular epistemic state, and 'attitudes' without assuming any particular
  disposition.

  For simplicity, we will also typically use the term *belief* to refer to both beliefs
  and attitudes, except when the distinction is important.
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

Consider a set of belief $bold(S) = {S_1, S_2, ..., S_N}$, where for each
$i in 1..N$, the belief $$
which takes values from .
Given the above assumptions, we can describe the trajectory of a belief or
attitude $S_i$ with domain $Omega_i$ as a sequence of states
$
  {s_i^t}_(t=1)^infinity quad "where" quad s_i^t in Omega_i
$ <eqn:methods-belief-system-dynamics-belief-markov-process>
characterised by the family of conditional distributions $P(sigma_i^(t+1) | bold(sigma)^t)$ for
$1 < t in NN$ and an initial state $P(sigma_i^1)$.

Noting that the state of a belief $S_i$ depends only on the previous states of all other
beliefs and attitudes, it follows that any pair of beliefs or attitudes $S_i$ and $S_j$
are conditionally independent at a given timestep given all previous belief and attitude
states. In particular, this means we can describe the evolution of the complete set
of beliefs and attitudes as a Markov process:

$
  {bold(s)^t}_(t=1)^infinity quad "where" bold(s)^t in Omega_1 times dots.c times Omega_N
$ <eqn:methods-belief-system-dynamics-belief-system-markov-process>

with transition probability
$P(bold(sigma)^(t+1) | bold(sigma)^t) = product_i^N P(sigma_i^(t+1) | bold(sigma)^t)$ for
$1 < t in NN$ and initial state probability
$P(bold(sigma)^1) = product_(i=1)^N P(sigma_i^1)$.

We use the term *belief system* to refer to the combination of a collection of attitudes
$bold(S)$ and its associated transition probability distribution
$P(bold(S)^(t+1) | bold(S)^t)$.
In this
conceptualisation, the task of modelling a belief system reduces to describing how the
instantaneous configuration of belief and attitude states affects the distribution over
possible future states.



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



== Non-equilibrium belief system model <subsec:theory-nonequilibrium-belief-system-model>

*TODO:*
- Builds on the CAN model, also known as the 'Ising model of attitudes'
  @vandermaasPolarizationIndividualsHierarchical2020
  - Also @brandtEvaluatingBeliefSystem2021
- Points of contrast:
  - Asymmetric interactions
  - Self-interactions
- @brandtEvaluatingBeliefSystem2021 also uses transition probabilities like ours
  - Also @haslbeckInterpretingIsingModel2021

// - Self-interaction term. Has two roles:
//   + Captures the timescale of the data; how quickly/slowly beliefs change
//   + Allows beliefs to be persistent in and of themselves. Consider that without
//     self-interactions, a node with only outbound edges would be entirely set be
//     its baseline activation. Self-interactions allow beliefs to be sticky, independently
//     of others.

*NOTE:*
Self-interaction effects:
- @brandtEvaluatingBeliefSystem2021[p.~22]: "we made the simplifying assumption that a node
  does not affect itself".



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

When studying the _symmetric_ Ising model it is common to assume that the model is
at equilibrium, such that the transition probability is stationary and given by the
Boltzmann distribution @christensenComplexityCriticality2005
@cardyScalingRenormalizationStatistical1996.

For the purposes of this study, however, we are interested in intervention dynamics, which are
inherently non-equilibrium. To see why this is the case, notice that the purpose of
intervention is to change the distribution of observed states. This is true both
interventions intended to change the dominant state (e.g., to promote a sustainable
alternative to a typical unsustainable behaviour) or reinforce it. Any belief system
model intended for studying intervention dynamics therefore cannot assume equilibrium,
and cannot define model dynamics using the Boltzmann distribution.

We instead define the conditional distribution $P(bold(S)^(t+1) = bold(s) | bold(S)^t)$
explicitly. Recall that the states of each pair of spins $S_i, S_j$ at time $t$ are
conditionally independent random variables, given knowledge of the previous
configuration $bold(S)^t$. It therefore
suffices for us to describe the distribution over spin states for an individual spin
$S_i$ at time $t+1$, as conditional on $bold(S)^t$.

As in the standard Ising model formulation, we will assume that the model typically
evolves in the direction of lower energy; however, rather than defining the energy
at the level of the model using the Hamilonian, we consider the energy experienced
by $S_i$ as a result of its baseline activation (also known as a _local field effect_),
and interactions with other spins.

The baseline activation $h_i in RR$ describes the tendency for $S_i$ to take on the
value $+1$ in the absence of interactions with other spins, or, more generally, when
pairwise spin interactions have a net-effect of zero. $S_i$ tends to adopt the value
$+1$ under these circumstances, iff, $h_i > 0$, and $-1$ iff $h_i < 0$. This tendency
increases with the magnitude of $h_i$.

Other spins influence $S_i$'s state through alignment or opposition relations. For
a spin $S_j$, we define an interaction effect $J_(j i)$ (read _'influence of $j$ on
$i$'_). When $J_(i j)$ is positive or negative, $S_i$ is influenced to adopt the state
$S_j^t$ or $-S_j^t$ respectively. In the special case when $j = i$, we refer
to $J_(i i)$ as a _self-influence_ of _self-interaction_ effect. Positive self-influence
effects reflect the inertia of $S_i$, i.e., the tendency to sustain a particular belief
or attitude irrespective of other beliefs and attitudes. Negative self-influence effects
are not clearly interpretable. In addition to modelling differences in inertia, the
inclusion of self-interaction effects allows us to capture the timescale at which
the system, as a whole, evolves.

The energy experienced by $S_i$ for a particular spin state $s in {-1,+1}$ is then the
result of $s$ in combination with the baseline activation and influence effects from
all spins with edges to $S_i$:

$
  H_i (s | bold(s)^t) = h_i dot s + sum_(j) A_(j i) J_(j i) s_j^t dot s
$ <eqn:methods-model-local-energy>

where $bold(A) in {0,1}^(n times n)$ is a pairwise adjacency matrix, with $A_(j i) = 1$,
iff, $S_j$ influences $S_i$. Dividing the common factor of $s$, we can equivalently
write @eqn:methods-model-local-energy as

$
  H_i (s | bold(s)^t) = s dot h_i^"eff" (bold(s)^t)
$ <eqn:methods-model-local-energy-eff-field>

where $h_i^"eff" (bold(s)^t) = h_i + sum_j A_(j i) J_(j i) s_j^t$ is the
effective baseline activation experienced by $S_i$ at time $t$. We then define the
probability that $S_i$ adopts the state $s$ at time $t$ as:

$
  P(S_i^(t+1) = s | bold(S)^t = bold(s)) &= e^(1/T H_i (s | bold(s)))/(sum_(s' in {0,1}) e^(1/T H_i (s' | bold(s)))) \
  &= e^(1/T H_i (s | bold(s)))/(e^(1/T H_i (s | bold(s))) + e^(-1/T H_i (-s | bold(s)))) \
  &= e^(1/T s dot h_i^"eff" (bold(s)))/(e^(1/T s dot h_i^"eff" (bold(s))) + e^(-1/T s dot h_i^"eff" (bold(s))))
$

For $s = +1$, this reduces to the logistic function:

$
  p_i^bold(s) := P(S_i^(t+1) = +1 | bold(S)^t = bold(s)) &= e^(1/T dot h_i^"eff" (bold(s)))/(e^(1/T dot h_i^"eff" (bold(s))) + e^(-1/T dot h_i^"eff" (bold(s)))) \
  &= 1/(1 + e^(-2 dot 1/T dot h_i^"eff" (bold(s)))) \
  &= op("logistic")(2 h_i^"eff" (bold(s))\/T )
$ <eqn:methods-model-logistic-probability>

Therefore the complete conditional distribution is given by:

$
  P(bold(S)^(t+1) = bold(s)^(t+1) | bold(S)^t = bold(s)^t) &= product_(i=1)^n P(S_i^(t+1) = s_i | bold(S)^t = bold(s)^t) \
  &= product_(i=1)^n [((1 + s_i)/2) p_i^bold(s)^t + ((1 - s_i)/2) (1 - p_i^bold(s)^t)]
$ <eqn:methods-model-conditional-prob-definition>

Where the initial distribution $P(bold(S)^0)$ is specified explicitly.

== Symmetric and asymmetric belief systems

Let $cal(M)$ be a belief system model defined as in the preceding section, comprising
$N in NN$ beliefs or attitudes, with adjacency matrix $bold(A) in {0,1}^(N times N)$,
interaction effect matrix $bold(J) in RR^(N times N)$, and baseline activations
$bold(h) in RR^N$.

When each entry in $bold(J)$ is independent of all others, we say
that $cal(M)$ is an *asymmetric belief system*. The term _asymmetric_ here refers to the
directed relations between a pair of nodes. In an asymmetric belief system, for any pair
of distinct nodes $S_i != S_j$, it may be the case that an influence relation exists
only in one direction, or that the directed relations differ in magnitude.

In the special case where we constrain $A_(i j) = A_(j i)$ and $J_(i j) = J_(j i)$ for
all $i, j in [1, N]$, we instead say that $cal(M)$ is a *symmetric belief system*. In
a symmetric belief system all interactions are directionally-equivalent. This can be
considered a simple extension of the symmetric Ising model with (i) self-interaction
terms and (ii) temporal dynamics, thus the symmetric belief system model tends toward
an equilibrium steady state.

== Simulation via Glauber dynamics <subsec:methods-glauber-dynamics>

It is straightforward to draw samples from a belief system model using Glauber
dynamics, given the conditional probability distribution defined in
@eqn:methods-model-conditional-prob-definition.

Given an initial state $bold(s)^0 in {-1, +1}^N$, we sample a sequence of $T in NN$
subsequent configurations:

$
  {bold(s)^t}_(t=0)^T, quad "where each" bold(s)^(t+1) ~ P(bold(S)^(t+1) | bold(S)^t)
$ <eqn:asymmetric-belief-system-glauber-dynamics>

Each belief or attitude has the opportunity to update during every time interval. This
update routine is referred to as _synchronous_ Glauber dynamics, contrasting
_asynchronous_ Glauber dynamics, in which only one spin can update during a given
interval.

== Modelling interventions <subsec:asymmetric-belief-system-modelling-interventions>

*TODO:*
- Discuss @dalegeNetworksBeliefsIntegrative2025, which is somewhat analogous.

  In the NB model exogenous changes (other peoples' beliefs) affect your belief
  system via an interaction term to the belief about that state. Our approach is
  analogous. The exogenous change affects our belief (say, about the state of climate
  change) via an interaction term.

Other intervention studies:
- Simulation-based approaches that mirror ours:
  - @dalegeNetworkAnalysisAttitudes2017
  - @schlicht-schmalzleAttitudeNetworkAnalysis2018
  - @lunanskyInterveningPsychopathologyNetworks2022
  - @berteroConsolidationChangeExploring2025
  - @wuSimulatingNodeManipulations2026
  All use symmetric models. AFAIK none use glauber dynamics, i.e., assume equilibrium
  right after intervention. So don't account for temporal dynamics, belief stability,
  individual effects, etc.
- Control theory approach @henryControlPsychologicalNetworks2022
- Continuous-time approach (avoids the discrete time problem) @ryanTimeInterveneContinuousTime2022



We now outline our approach to modelling interventions in the asymmetric belief
system model. In this study we consider interventions which affect the _state_ of a
belief system. Notably, this excludes interventions intended to influence the structure
of a belief system, for instance, by changing the existence of effect size of influence
relations between beliefs and attitudes.

Let $cal(M)$ be a belief system model with parameters
$chevron bold(A), bold(J), bold(h) chevron.r$.
We can consider an intervention as an
auxiliary node, $I$, in the belief system network, with state fixed at a particular
value and outgoing edges toward a subset of beliefs and attitudes:

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
@eqn:methods-model-local-energy, given a previous configuration $bold(s)^t$:

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
baseline activation of certain beliefs and attitudes:

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

@fig:methods-intervention-strengths-probability illustrates how the probability of
activation for the intervention spin (@eqn:methods-model-logistic-probability) changes
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
      calculated using @eqn:methods-model-logistic-probability.
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
scenario the first individual exhibits an equal tendency toward each state, while the
second is almost certain to adopt the state $-1$.

Notice that interventions are not experienced equivalently by the two individuals. For
a weak intervention ($delta_h = 0.5$), the first individual sees a substantial jump in
activation probability, while the corresponding increase for the second individual is
negligible. The stakes are reversed under a strong intervention ($delta_h = 2.5$).

We can understand this difference in effect both conceptually and analytically. From
a conceptual perspective, we can explain the large shift of the first individual under
a weak intervention as resulting from their prior indifference, making them maximally
susceptible to intervention. Prior to intervention, the second individual has a strong
negative stance on this belief/attitude; weak interventions are insufficient to change
their view. On the other hand, the second individual's negative stance provides more
space for their attitude or belief to shift under a successful intervention. Compare
this to the first individual, who is shifting from a place of indifference.


*TODO:* Quantitative explanation:
- Take derivative of the difference in activation probabilities between intervention
  and null scenario; solve for derivative equal to zero. Corresponds to the unique
  maximum since for $h_"eff" -> plus.minus infinity$ the second derivative is strictly
  positive.
- We find that maximum is at $h_"eff" = -delta_h / 2$.
- i.e., for a given intervention strength, the maximum change in activation probability
  occurs when the intervention causes $h_"eff"$ to increase to same magnitude on the
  other side of zero.
- Individuals below this point require a stronger intervention to move the same amount.
- Individuals above this point experience ceiling effect. A smaller intervention could
  achieve almost the same effect.


// Interventions on a belief system $cal(M) = chevron S, bold(A), bold(J), bold(h) chevron.r$
// can manifest as either influence toward a particular state for a given belief
// or attitude, or as a 'rewiring' of the causal interactions between cognitive axes.
//
// The first category of intervention, which we refer to as a *threshold intervention*, is
// modelled as an adjustment to the threshold vector $bold(h)$. For a spin $S_i in S$,
// we model a threshold intervention toward the state $+1$ as the adjusted model
// $cal(M)' = chevron S, bold(A), bold(J), bold(h)' chevron.r$, where for $j in [1, N]$
// and an intervention level $delta_i$:
//
// $
//   h'_j = cases(h_j + delta_i quad &"if" j = i, h_j quad &"otherwise")
// $
//
// The second category, which we refer to as a *structural intervention*, is modelled
// as an adjustment to the relational structure or causal influences between spins.
// For a pair of spins $S_i, S_j in S$ and an intervention level $delta_(i j)$, a
// structural intervention is modelled as the adjusted model
// $cal(M)' = chevron S, bold(A), bold(J)', bold(h) chevron.r$ where
//
// $
//   J'_(k ell) = cases(J_(i j) + delta_(i j) quad &"if" (k, ell) = (i, j), J_(k ell) quad &"otherwise")
// $
//


#import "@local/drifting-cls-thesis:0.1.0": caption

#import "@preview/theorion:0.6.0": *
#import cosmos.fancy: *
#show: show-theorion


A collection of notes, to-do items, discussion points, and snippets taken from old
drafts. This section is temporary, and for my own benefit :)

== Questions for Vítor

- Is it correct to acknowledge Sara directly in the dataset validation section?
- How much do I need to say about the climate beliefs dataset in the calibration section?

== Additional things to maybe discuss somewhere

#emph-block[
  Individual belief dynamics are important to understanding behavioural influences
  between individuals: @rodriguezCollectiveDynamicsBelief2016
  @aiyappaEmergenceSimpleComplex2024
  - "Models of internal belief networks generally disregard external social networks, although a number of classic social-cognitive theories recognise the importance of social environments in changing individual beliefs and behaviours (Ajzen, 1991; Cialdini & Trost, 1998; Festinger, 1954; Fishbein & Ajzen, 1975; Petty & Cacioppo, 1986)" @dalegeNetworksBeliefsIntegrative2025
]


To include in discussion on RQ4?:
- @brandtEvaluatingBeliefSystem2021[p.~4,20] "connections will likely vary between people,
  time, and political contexts", "Although ... belief systems are at the individuals level,
  this does not mean that structure is not shared"

#emph-block[
  Practical considerations for designing empirical studies for psychological networks.
  Discusses limitations of cross-sectional studies for teasing apart within-person and
  between-person effects @chambonNetworkPsychometricsPractice2026.
]

== Politics --> Policy narrative

Issue support on climate policies in US driven by political identification and climate
beliefs @bumannWhatAreDeterminants2021 @shaoApprovalPoliticalLeaders2020
@zieglerPoliticalOrientationEnvironmental2017 @roser-renoufGenesisClimateChange2014
@unsworthItsPoliticalHow2014.

But political identification is often not consistent with policy attitudes
@iyengarAffectNotIdeology2012 @huddyExpressivePartisanshipCampaign2015. More often
identity-driven (symbolic) than issue-driven (operational)
@masonIdeologuesIssuesPolarizing2018. Also @eganIdentityDependentVariable2020.


== General notes, to-do items

Modularity clustering for correlation networks @masudaIntroductionCorrelationNetworks2025

Intervention studies with belief system models:
- Looks at dynamics constraint. Uses symmetric network, doesn't fit individual models.
  Applies persuasive experimental condition and predicts how attitudes will change.
  Finds that attitudes generally change most when close to the point-of-intervention
  @turner-zwinkelsBeliefSystemNetworks2022
- Finds that (counter to their hypothesis) peripheral attitudes changed less than
  central ones (no 'straightforward association between inter-attitude centrality and
  persuasion'). Also uses symmetric model. 'such a process is often assumed to be
  bi-directional'. @brandtInterattitudeCentralityDoes2023
  - Possible explanation for their findings: attitudes found to be peripheral may not
    actually be peripheral. They may be asymmetric, with different
    influence/influentiability.
- Looks at temporal network of behavioural compliance in COVID-19
  @chambonHowComplianceBehavioural2023. Says they measure within-person effects, but
  not clear that this is true (they use temporal and contemporaneous networks).
  - Their context is expected to have non-stable beliefs and attitudes. Early stages
    of pandemic.
  - They find cases of asymmetry, but these are typically in the other direction.
    Variables which are mostly influenced by others. We find variables which mostly
    influence others.
  - Their focus is primarily on bi-directional reinforcing effects. They also don't
    compare with symmetric model.
- @chambonTailoredInterventionsBroad2022

Causality in psychological networks @kossakowskiSearchCausalityComparison2021

See @epskampEstimatingPsychologicalNetworks2018 for discussion on the use of
bootstrapping in assessing edge weight variability. Also argument against the use of
bootstrap CIs to test for edges being non-zero; particularly in LASSO-regularised
models.

The general Markov description of belief system dynamics in methods doesn't assume that
belief/attitude states are numerical or even 1-dimensional. But we do assume this in
our model.

Under equilibrium assumption (e.g. CAN model) there is no additional representational
power to be gained by allowing interaction weights to be directionally independent.

Mention inferring the adjacency matrix $bold(A)$ as an additional task in model
reconstruction.

Existence and uniqueness of the solution to the MLE problem. Uniqueness depends on the
specific binarisation --- motivates marginalisation over binarisation process.

Conditional probabilities --- how does the specific state of $X$ affect the distribution of $Y$?

Discuss problem of fitting individual models. Two issues:
+ Requires sufficient data. We have only a handful of measurements per individual.
+ Disregards shared aspects of belief systems. Even with sufficient data, we may not
  observe all transitions required to understand the _potential_ dynamics of the system
  in states which we don't observe. If we assume that individuals share some aspects,
  then we can pool information.

== Discussion points

- *RQ1.1:* What is the representational capacity of a pairwise belief system model?

- *RQ1.2:* How do belief system dynamics differ between models assuming symmetric relations,
  and those assuming asymmetric relations? If the asymmetric model reaches a steady
  state, is this an equilibrium state? Should we expect the steady state to be similar
  to the ESS of the symmetric model? Under what conditions do we expect the asymmetric
  model to converge to a steady state monotonically? How does the steady state depend
  on the initial conditions of the belief system?

- *RQ1.3:* How is the process of inferring belief systems from observational data
  sensitive to unmeasured factors, or incorrect structural assumptions? What is the
  impact of excluding true relations --- or including false ones --- on an inferred
  model?

== Future work

- Intentionally-derived indices: theoretically-motivated variables, as opposed to
  averaged indices. e.g., psychological distance as difference in beliefs about climate
  impacts elsewhere and local.

== Scratch notes
Potentially-useful sections I've pulled from old drafts

=== Defining beliefs and attitudes ('cognitive axes')

Cognitive axes are either:

- *Beliefs:* Epistemic positions regarding states of affairs (e.g., 'climate change is
  real' or 'extreme weather events are becoming more frequent'), or

- *Attitudes:* Evaluative positions (e.g., policy support or opposition or emotive
  states such as 'happy' or 'sad').

=== Cognitvie axes with polarity rather than binary
As implied by the name, for the purposes of this study we consider cognitive _axes_ with
polarity, i.e., with contrasting possible states representing opposite ends of a
spectrum. For instance, consider the epistemic position:

#align(center)[
  #block[_Believes that climate change is happening._]
]

If we consider the 'opposite' position, there are at least two reasonable choices:

#align(center)[
  #block[_*Does not* believe that climate change is happening._]
]

and

#align(center)[
  #block[_Believes that climate change is *not* happening._]
]

Let $cal(b)(p)$ denote the belief that the predicate $p$
is true. For simplicity, we will assume here that $cal(b)(p)$ and $cal(b)(not p)$ are
mutually exclusive, such that an individual cannot simultaneously hold two conflicting
epistemic positions#footnote[There is evidence to suggest that in reality individuals
  do often hold conflicting epistemic positions, with only one being 'active' at any
  given point in time, depending on contextual factors.]. The first choice is then
equivalently stated as $not cal(b)(p)$, and the second choice as $cal(b)(not p)$,
where $p := "climate change is happening"$.

Observe that in the first choice, $not cal(b)(p)$, the
action of believing _per se_ is negated. Thus the statement is satisfied so
long as the individual does not hold the belief $p$. Due to the mutual exclusivity of
$cal(b)(p)$ and $cal(b)(not p)$, this is of course realisable when the individual holds
the belief $cal(b)(not p)$; however, it is also realised when the individual holds _no_
belief on this statement whatsoever. Hence the first choice does not have the desired
polarity property, since it allows for the absence of belief (or analogously,
an ambivalent attitude).

In the second choice, since the belief itself is not negated, we require at least one
of $cal(b)(p)$ or $cal(b)(not p)$ to be true. By the mutual exclusivity of these
options, it follows that the second choice has our desired polarity property.


=== Cross-sectional correlations can be zero in time-series model

Unlike in the equilibrium (symmetric) Ising model, two spins may be uncorrelated within
a given timestep, even though their behaviour is highly correlated in time. For example,
consider the model shown in @fig:model-no-cs-correlation, comprising two cognitive axes,
$s_A$ and $s_B$. The behaviour of $s_A$ is entirely unconstrained by $s_B$, yet the
large magnitude relation $s_A -> s_B$ ensures the behaviour of $s_B$ is almost entirely
set by $s_A$. In particular, at each timestep, $s_B$ adopts the previous state of $s_A$
with high probability.

#figure(
  image("../diagrams/draft/model_no_cs_correlation.png", width: 40%),
  caption: caption(
    short: [Example: zero-valued instantaneous correlation],
    long: [
      A two-spin asymmetric belief system in which the instantaneous correlation
      between spins is zero, but the time-delayed correlation is non-zero.
    ],
  ),
) <fig:model-no-cs-correlation>

Let ${bold(s)}_(t=1)^m$ be a sequence of samples drawn from this model, with $m$
sufficiently large, and define ${s_A}_(t=1)^m$ and ${s_B}_(t=1)^m$ as the sequences of
$s_A$ and $s_B$ components respectively. Since the behaviour of $s_A$ is unconstrained,
we find that the instantaneous correlation between $s_A$ and $s_B$ is zero:

$ op("Corr")({s_A}_(t=1)^m, {s_B}_(t=1)^m) = 0 $

yet the time-delayed correlation between $s_B$ and the _previous state_ of $s_A$ is
close to its maximum possible value:

$ op("Corr")({s_A}_(t=1)^(m-1), {s_B}_(t=2)^m) approx 1 $

=== Conditional non-independence interpretation of directed relations

#definition[Direct causal relation][
  Let $cal(M)$ be a pairwise belief system, and
  $s_i, s_j in S$ be a pair of cognitive items. We say there is a *direct causal
  relation* $s_i -> s_j$ if, and only if, given a configuration
  $bold(s)^t$, for some possible value $s$ of $s_j$,
  $ PP[s_j^(t+dif t) = s | bold(s)^t] != PP[s_j^(t+dif t) = s | bold(s)_(-i)^t] $
] <def:model-direct-influence>

An alternative interpretation of the causal relations between cognitive axes is as
conditional non-independence relations.

#conjecture[
  Let $cal(M)$ be a pairwise belief system with cognitive axes $S$, and suppose that
  all configurations of the belief system state occur with non-zero probability. For
  any pair of cognitive axes $s_i, s_j in S$, there exists a directed causal relation
  $s_i -> s_j$ if, and only if, $s_j^(t + dif t)$ and $s_i^t$ are conditionally
  non-independent.
] <conjecture:model-relations-conditional-non-independence>

#proof[
  #set math.equation(numbering: none)
  Let $bold(s)^t$ be the instantaneous configuration of cognitive axes in
  the belief system at time $t$. Applying Bayes' rule to the conditional
  probability distribution over $s_j^(t+dif t)$ given the previous system
  configuration, we find
  $
    PP[s_j^(t+dif t) | bold(s)^t] &= PP[s^(t+dif t), bold(s)^t]/PP[bold(s)^t] &&"Bayes rule" \
    &= (PP[s_j^(t+dif t), s_i^t | bold(s)_(-i)^t] PP[bold(s)_(-i)^t])/(PP[s_i^t | bold(s)_(-i)^t] PP[bold(s)_(-i)^t]) #h(5em) &&"Bayes rule (again)"\
    &= PP[s_j^(t+dif t), s_i^t | bold(s)_(-i)^t]/PP[s_i^t | bold(s)_(-i)^t] &&0 < PP[bold(s_i^t)] \
  $

  Combining this result with @def:model-direct-influence, it follows that $s_i$
  _does not_ directly influence $s_j$ if, and only if,
  $
    PP[s_j^(t+dif t), s_i^t | bold(s)_(-i)^t] & = PP[s_i^t | bold(s)_(-i)^t] dot PP[s_j^(t+dif t) | bold(s)^t]
  $
  i.e., when $s_j^(t + dif t)$ is independent of $s_i^t$ conditional on
  $bold(s)_(-i)^t$. The main result then follows directly by taking the converse.
]

=== Trade-off between synchronous and asynchronous updates

At each timestep, we allow _every_ spin the opportunity to update. This is known as
*synchronous updating*. The alternative is *asynchronous updating*, in which a singular
spin is randomly sampled to update on each timestep. Asynchronous updates are typically
preferrered, both for model realism in case the real phenomenon exhibits continuous-time
updates, and to avoid degenerate behaviours such as all spins fluctuating between two
system configurations. We use synchronous updates here for two reasons. Firstly,
the likelihood of such degenerate behaviour is unlikely due to the inclusion of
self-interaction effects, which provide inherent, heterogeneous timescales to the
modelled cognitive axes. Secondly, assuming synchronicity significantly simplifies
the inverse problem, as will be discussed in (reference section on parameter estimation).

=== Example motivating influence between beliefs and attitudes

This notion of direct influence is presently ambiguous, and so it is worthwhile to
clarify exactly what is meant here. We say that $s$ *influences* $s'$ if the
instantaneous state of $s$ affects the subsequent state distribution of $s'$.
For instance, if I expect that it will rain this afternoon, then my attitude toward
bringing an umbrella to work is positive. On the other hand, if I expect fine weather,
then bringing an umbrella to work is an unnecessary nuisance. Hence my attitude toward
the umbrella is influenced by my expectations about the weather. If I live relatively
close to the office, then my attitude toward commuting on public transport may be
similarly influenced by these expectations; however, if I live far away, such that
biking to work isn't feasible, then this influence relation may no longer obtain.

An influence relation is said to be *direct* if it persists after conditioning on all
other relevant factors. If I expect poor weather this afternoon, and consequently
consider taking my umbrella to work, I may conceivably worry about leaving my umbrella
on the bus. My expectations about the weather therefore influence my concern about
losing my umbrella, but this influence is indirect; after conditioning on my attitude
toward taking my umbrella to work, my concern is independent of my expectations about
the weather. We formalise this notion in @def:model-direct-influence.

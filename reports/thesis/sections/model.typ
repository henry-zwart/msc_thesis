#import "@preview/theorion:0.6.0": *
#import "@preview/equate:0.3.3": equate
#import cosmos.fancy: *
#show: show-theorion
#show: equate.with(breakable: true, sub-numbering: true)

Potentially useful things:
- Defining beliefs and attitudes @subsubsec:model-cognitive-axes
- Trade-off, using polarity instead of binary variables @subsubsec:model-cognitive-axes
- Explaining why cross-sectional correlations can be zero for the time-series model @subsec:model-belief-system-interactions
- Motivating directed relations as conditional non-independence relations @subsec:model-belief-system-interactions
- Trade-off between synchronous and asynchronous updates @subsubsubsec:system-transitions
- Mention inferring $bold(A)$ as an additional task in model reconstruction
- Motivating the notion of beliefs and attitudes influencing one another, and of
  direct influences using example, start of @subsec:belief-system-interactions
- "Under an equilibrium assumption, there is no representational power to be gained by
  allowing interaction weights to be directionally independent."
- Existence and uniqueness of the solution to the MLE problem.
  - Uniqueness depends on specific binarisation -- motivates expectation approach.
- Model simulation via Glauber dynamics

== Summary

In the following pages I summarise the current state of the project and our intentions
going forward. I begin by outlining the (revised) research questions, followed by our
tentative experimental plan for answering these questions. Finally I provide theoretical
details regarding the asymmetric belief system model, including simulation and
intervention dynamics, and methods for inferring belief systems from observational data.


== Asymmetric belief system model

We consider a belief system as comprises a collection of *cognitive axes*, arranged in
a directed network, with edges describing pairwise causal relations. Since the directed
edges are permitted to vary in effect strength, standard methods for solving the
inverse Ising problem at equilibrium at not applicable here. Instead we adopt a
maximum-likelihood parameter reconstruction method using time-series data to identify
a maximum-entropy model which matches the (pairwise) time-lagged correlations observed
in the data.

=== Cognitive axes <subsubsec:model-cognitive-axes>

Cognitive axes are either:

- *Beliefs:* Epistemic positions regarding states of affairs (e.g., 'climate change is
  real' or 'extreme weather events are becoming more frequent'), or

- *Attitudes:* Evaluative positions (e.g., policy support or opposition or emotive
  states such as 'happy' or 'sad').

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

=== Belief system interactions <subsec:model-belief-system-interactions>

Directed edges describe the direct causal relations between cognitive axes.
These causal relations operate across timesteps, such that the instantaneous state of a
belief system influences the subsequent state. We formally define a direct causal
relation $a -> b$ as a conditional dependence in the distribution over possible states
of $b$ on the previous value of $a$.

#definition[Direct causal relation][
  Let $cal(M)$ be a pairwise belief system, and
  $s_i, s_j in S$ be a pair of cognitive items. We say there is a *direct causal
  relation* $s_i -> s_j$ if, and only if, given a configuration
  $bold(s)^t$, for some possible value $s$ of $s_j$,
  $ PP[s_j^(t+dif t) = s | bold(s)^t] != PP[s_j^(t+dif t) = s | bold(s)_(-i)^t] $
]

Consider an $a -> b$ between cognitive axes $a$ and $b$, with weight $w_(a -> b)$. The
sign of $w_(a->b)$ describes the tendency for $b$ to adopt the same ($+$) or opposite
($-$) polarity that $a$ exhibited in the previous timestep. The magnitude $|w_(a->b)|$
describes the degree to which this relation influences the behaviour of $b$. Even if
$|w_(a->b)|$ is relatively large in absolute terms, if it is small compared to another
relation $|w_(c->b)|$, then the influence of $a$ on $b$ may be limited.

Unlike in the equilibrium (symmetric) Ising model, two spins may be uncorrelated within
a given timestep, even though their behaviour is highly correlated in time. For example,
consider the model shown in @fig:model-no-cs-correlation, comprising two cognitive axes,
$s_A$ and $s_B$. The behaviour of $s_A$ is entirely unconstrained by $s_B$, yet the
large magnitude relation $s_A -> s_B$ ensures the behaviour of $s_B$ is almost entirely
set by $s_A$. In particular, at each timestep, $s_B$ adopts the previous state of $s_A$
with high probability.

// #figure(
//   image("../diagrams/draft/model_no_cs_correlation.png", width: 40%),
//   caption: [
//     A two-spin asymmetric belief system in which the instantaneous correlation
//     between spins is zero, but the time-delayed correlation is non-zero.
//   ],
// ) <fig:model-no-cs-correlation>

Let ${bold(s)}_(t=1)^m$ be a sequence of samples drawn from this model, with $m$
sufficiently large, and define ${s_A}_(t=1)^m$ and ${s_B}_(t=1)^m$ as the sequences of
$s_A$ and $s_B$ components respectively. Since the behaviour of $s_A$ is unconstrained,
we find that the instantaneous correlation between $s_A$ and $s_B$ is zero:

$ op("Corr")({s_A}_(t=1)^m, {s_B}_(t=1)^m) = 0 $

yet the time-delayed correlation between $s_B$ and the _previous state_ of $s_A$ is
close to its maximum possible value:

$ op("Corr")({s_A}_(t=1)^(m-1), {s_B}_(t=2)^m) approx 1 $


We permit self-interaction relations which operate in the same fashion, representing the
inertia of a cognitive axis. Negative weights for self-interaction relations
reflect an inherent tendency for a cognitive axis to fluctuate. As we have defined
cognitive axes as having polarity, such fluctuations would reflect dramatic shifts in
beliefs or attitudes, which we do not expect to observe in reality. Thus we expect
self-interaction weights to be non-negative in general. A large positive
self-interaction weight describes a tendency for the corresponding cognitive axis to
retain its previously-measured state, even under pressure from other cognitive axes.
This captures the notion that some beliefs or attitudes have inherently slower
timescales than others, e.g., an individual's political ideology may be expected to vary
more slowly than their attitudes toward particular policies or political candidates.


An alternative interpretation of the causal relations between cognitive axes is as
conditional non-independence relations.

#conjecture[
  Let $cal(M)$ be a pairwise belief system with cognitive axes $S$, and suppose that
  all configurations of the belief system state occur with non-zero probability. For
  any pair of cognitive axes $s_i, s_j in S$, there exists a directed causal relation
  $s_i -> s_j$ if, and only if, $s_j^(t + dif t)$ and $s_i^t$ are conditionally
  non-independent.
]

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

=== Belief system dynamics

==== Model components
Let $S$ be a set of $n in NN$ cognitive axes, arranged as nodes on a directed network
with adjacency matrix $bold(A) in {0,1}^(n times n)$ and edge weights
$bold(J) in RR^(n times n)$. At time $t$, each node (spin) $S_i in S$ adopts a state
$S_i^t = s$ for $s in {-1, +1}$.

For a pair of nodes (spins) $s_i, s_j in S$, the
existence of an edge $s_i -> s_j$ reflects a directed causal relationship, such that
the instantaneous state of $S_i$ influences the subsequent state of $S_j$. The sign of
$J_(i j)$ determines the nature of this influence. In particular,
#box[$S_j^(t+1) = op("sign")(J_(i j)) dot S_i^t$] with increased probability. The degree of
increase in probability increased with $|J_(i j)|$, both in absolute terms, and relative
to the weights of other edges into $S_j$.

For each spin we define a *threshold* which captures unmeasured
influences on individuals' tendences toward particular states $s in {-1, +1}$.
In reality, individuals have different experiences, interact
with different social crowds, and have different states on unmeasured (but conceivably
relevant) cognitive axes. As such, we would expect a high degree of heterogeneity
between individuals in the threshold for any given cognitive axis. On the other hand,
we expect to observe commonalities between individuals from similar contexts. When
per-individual observational data is limited, allowing thresholds to vary as a function
of individual context provides a reasonable middle-ground between ignoring individual
differences and fitting per-individual thresholds.

To model the thresholds, we define a vector of baseline effects $bold(h)_0 in RR^n$ and
a matrix of contextual adjustment coefficients $bold(B) in RR^(n times k)$, where
$k in NN$ is the number of covariates parameterising the thresholds. For an individual
with covariates $bold(x) in RR^k$, we then define their threshold vector as:

$
  bold(h)(bold(x)) := bold(h)_0 + bold(B)x
$

For clarity, we will often omit explicit mention of the covariate vector, instead
referring directly to $bold(h)$ as a vector of thresholds.

//
// ==== Model components
// Let $S$ be a set of $n in NN$ cognitive axes, with directed causal relational structure
// described by $bold(A) in {0,1}^(n times n)$ with $A_(i j) = 1$ if, and only if,
// $s_i -> s_j$ for $s_i, s_j in S$. Let $bold(J) in RR^(n times n)$ be a matrix
// of interaction weights, with $w_(s_i -> s_j) := J_(i j)$.
//
// We also include a vector, $bold(h) in RR^n$, of *threshold* effects, also referred to
// as *local field* effects in the context of the Ising model. The threshold $h_i$ for a
// cognitive axis $s_i in S$ describes the tendency for $s_i$ to adopt a positive or
// negative state, irrespective of incoming interaction effects. A large positive
// (negative) value reflects a tendency to adopt a positive (negative) state in the absence
// of interaction effects, or when the net effect of interaction effects is small.
//
// The thresholds capture unmeasured influences on individuals' tendencies toward
// particular states. In reality, individuals have different experiences, interact
// with different social crowds, and have different states on unmeasured (but conceivably
// relevant) cognitive axes. As such, we would expect a high degree of heterogeneity
// between individuals in the threshold for any given cognitive axis. On the other hand,
// we expect to observe commonalities between individuals from similar contexts. Thus given
// limited observational data per-individual, allowing the thresholds to vary as a function
// of individual context provides a reasonable middle-ground between ignoring individual
// differences and fitting per-individual thresholds.
//
// We allow thresholds to vary as a
// linear function of individual covariates. Given a set of $k in NN$ covariates which
// reflect individual context (e.g., age or education), we define a matrix of threshold
// adjustment coefficients, $bold(B) in RR^(n times k)$. For an individual $i$ with
// covariates $bold(x)^i in RR^k$, we then take their thresholds to be defined as:
//
// $
//   bold(h)^i := bold(h) + bold(B)x
// $


==== System transitions <subsubsubsec:system-transitions>
The probability of a spin $S_i in S$ adopting a particular state $s in {-1, +1}$ is set
by the energy differential with the alternative state, where lower-energy states are
preferred. We define the local energy experienced by $S_i$ when adopting
the value $s$, given the previous belief system configuration, as:

$
  H(S_i^(t + dif t) = s|bold(s)^t) & = - h_i s - sum_(j=1)^n A_(j i) J_(j i) s_j s \
                                   & = -s dot h_i^"eff" (bold(s)^t)
$

Where $h_i^"eff" (bold(s)^t)$ is the effective local field imposed on $s_i$ at time
$t$, comprising the accumulation of effects which result in an overall tendency toward
$s_i^(t+dif t) in {-1, +1}$, and is defined as

$
  h_i^"eff" (bold(s)^t) = h_i + sum_(j=1)^n A_(j i) J_(j i) s_j
$

The dynamics of $S_i$ are succinctly described through a conditional probability
distribution given the previous system state @nguyenInverseStatisticalProblems2017

$
  PP[S_i^(t + dif t) = s | bold(S)^t = bold(s)] = exp[-1/T dot s dot h_i^"eff" (bold(s))]/(exp[1/T dot h_i^"eff" (bold(s))] + exp[-1/T dot h_i^"eff" (bold(s))])
$ <eqn:model-conditional-distribution-single-spin>

Where the temperature parameter $T in RR_(>0)$ controls the degree of stochasticity. At
high temperatures @eqn:model-conditional-distribution-single-spin converges to a
uniform distribution over ${-1, +1}$ (i.e., maximum stochasticity), whereas as
$T -> 0^+$ it converges in probability (*TODO: double-check this statement*) to a
distribution over the restricted set of states with minimum energy.

At each timestep, we allow _every_ spin the opportunity to update. This is known as
*synchronous updating*. The alternative is *asynchronous updating*, in which a singular
spin is randomly sampled to update on each timestep. Asynchronous updates are typically
preferrered, both for model realism in case the real phenomenon exhibits continuous-time
updates, and to avoid degenerate behaviours such as all spins fluctuating between two
system configurations. We use synchronous updates here for two reasons. Firstly,
the likelihood of such degenerate behaviour is unlikely due to the inclusion of
self-interaction effects, which provide inherent, heterogeneous timescales to the
modelled cognitive axes. Secondly, assuming synchronicity significantly simplifies
the inverse problem, as will be discussed in @subsec:model-inverse-problem.

// The symmetry of possible states $s in {-1, +1}$ allows us to simplify the denominator in
// @eqn:model-conditional-distribution-single-spin as follows:

// $
//   PP[S_i^(t + dif t) = s | bold(S)^t = bold(s)] = exp[-1/T dot s dot h_i^"eff" (bold(s))]/(2 cosh[-1/T dot h_i^"eff" (bold(s))])
// $ <eqn:model-conditional-distribution-single-spin-simplified>

Observe that for $s_i != s_j in S$, the respective conditional distributions over
$S_i^(t + dif t)$ and $S_j^(t + dif t)$ depend only on the _previous_ timestep, so are
conditionally independent given $bold(S)^t = bold(s)$. Thus, given the synchronous update
assumption, we can straightforwardly extend
@eqn:model-conditional-distribution-single-spin to a conditional distribution over the
entire belief system configuration given the previous configuration:

$
  PP[bold(S)^(t + dif t) = bold(s)' | bold(S)^t = bold(s)] &= product_(i=1)^n PP[S_i^(t + dif t) = s'_i | bold(S)^t = bold(s)]\
  &= product_(i=1)^n exp[-1/T dot s'_i dot h_i^"eff" (bold(s))]/(exp[1/T dot h_i^"eff" (bold(s))] + exp[-1/T dot h_i^"eff" (bold(s))]) \
$ <eqn:model-conditional-distribution-full>

Furthermore, recognising @eqn:model-conditional-distribution-single-spin as a logistic
function with codomain ${-1, +1}$, we can write for each spin $s_i in S$:

$
  1/2 (S_i^(t + dif t) + 1) ~ op("logistic")[-1/T dot h_i^"eff" (bold(s)^t)]
$


=== Inverse problem <subsec:model-inverse-problem>

Consider a belief system comprising $n in NN$ cognitive axes $S$, and a dataset
$bold(D)$ with observations from $k in NN$ individuals, with each row containing
measurements for each of the $n$ cognitive axes. The inverse problem consists in
identifying parameters
#box[$bold(A) in {0,1}^(n times n), bold(J) in RR^(n times n), arrow(h) in RR^n$] such
that the resulting model is a plausible candidate for the mechanism which generated
$bold(D)$. In other words, the inverse problem is the task of inferring the belief
system which generated the observed data.

This process consists in two parts: (i) determining the belief system relational
structure $bold(A)$, and (ii) estimating the effect sizes $bold(J)$ and $arrow(h)$.

// Recall that, per @conjecture:model-relations-conditional-non-independence, the
// directed relations between cognitive axes are equivalent to conditional non-independence
// relations. This is precisely the realm of causal discovery, and thus we use this to
// determine the relational structure.

To infer the effect sizes for interactions and thresholds, we use maximum likelihood
estimation, choosing a model parameterisation which maximises the probability of
observing the dataset $D$. Maximum likelihood estimation using cross-sectional
observational data is commonly used to solve the inverse problem for the symmetric
(equilibrium) Ising model.

In the case of the asymmetric belief system model described above, the model dynamics
are defined in terms of a conditional probability distribution over system states,
given the previous state. As such, we instead need to maximise the conditional
likelihood:

$
  cal(L)_(bold(S)^(t+1) | bold(S)^t)(bold(A), bold(J), arrow(h)) := 1/(k m) sum_(r=1)^k sum_(tau=1)^(m - 1) ln PP[bold(S)_r^(tau + 1) = D_(r,tau + 1) | bold(S)_r^tau = D_(r, tau)]
$ <eqn:model-conditional-likelihood>

However, cross-sectional data is not sufficient for this task, as computing (let alone
maximising) the conditional likelihood requires repeated observations from each
individual. Thus to solve the inverse Ising problem for the asymmetric belief system
model, we require time-series observational data.


#pagebreak()











// - Define the cognitive items in our belief system model:
//   - Beliefs (epistemic positions) and attitudes (evaluative positions)
//   - Have 'polarity', i.e., two contrasting states representing opposite end of a
//     spectrum. So belief in climate change is not 'does believe' vs. 'does not believe',
//     but rather 'believes that climate is happening' vs. 'believes that climate change is
//     not happening'. So all beliefs and attitudes are _active_ in a sense. Not possible
//     in the model to represent ambivalence or absence of belief.
// - Motivate interactions: causal relations between cognitive items. Positive creates
//   pressure for items to share same polarity; negative to have opposing polarity. We
//   don't assume equilibrium, so the causality acts across timesteps. This is to say that
//   the current state of $A$ influences the _next_ state of $B$. In particular this means
//   that, unlike in the equilibrium Ising model, two spins may be uncorrelated in a
//   cross-sectional analysis, but correlated in time. Self-interaction effects reflect
//   the inertia or stickiness of a cognitive item. A large positive self-interaction
//   effect describes a tendency for the cognitive item to retain its previously-measured
//   value, even under pressure from other related items.
// - Define dynamics:
//   - Synchronous updates (can further discuss this decision and its implications later)
//   - Spin transition probabilities are set by energy differential between possible
//     states.
//   - Give the transition conditional probability equation.
// - Inverse problem:
//   - Two parts: determine the structure ($bold(A)$), determine the effect sizes
//     ($bold(J)$, $arrow(h)$).
//   - Determining $bold(A)$: causal discovery. Direct influences in the model are
//     equivalent to conditional non-independence.
//   - Determining $bold(J), arrow(h)$: maximum likelihood estimation. In symmetric Ising
//     model we can fit cross-sectionally by assuming an equilibrium steady state. In this
//     model cross-sectional fitting does not work for two reasons:
//     + Self-interaction terms are defined by the inertia of a cognitive item, so require
//       measurements at multiple timepoints.
//     + With asymmetric interaction effects, we have too many parameters for the number
//       of observables. The instantaneous correlation matrix is symmetric.
//     Instead we can use time-delayed correlation terms, which are non-1 on the diagonal,
//     and not necessarily symmetric.

== Belief system interactions <subsec:belief-system-interactions>

We now formalise the notion of a pairwise-interaction belief system. Consider a finite
set of cognitive items, $S$, which may include a mixture of belief and attitude axes,
and let $S$ form the set of vertices in a directed _pairwise belief system network_
$G_cal(M) = chevron S, E chevron.r$. For each ordered pair of vertices $s, s' in S$,
there exists an edge $(s, s') in E$ if, and only if, the state of the cognitive item
$s'$ is subject to *direct influence* from $s$.

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

// #definition[Direct influence][
//   Let $G_cal(M) = chevron S, E chevron.r$ be a pairwise belief system network, and
//   $sigma_i != sigma_j in S$ be a pair of distinct cognitive items. We say $sigma_i$
//   *directly influences* $sigma_j$ if, and only if, given an instantaneous configuration
//   $bold(sigma)^t$, for some possible value $s$ of $sigma_j$,
//   $ PP[sigma_j^(t+delta t) = s | bold(sigma)^t] != PP[sigma_j^(t+delta t) = s | bold(sigma)_(-i)^t] $
// ] <def:model-direct-influence>

Under this interpretation it is straightforward to show that, if we assume all belief
system configurations occur with non-zero probability, then the direct influence
relation $sigma_i -> sigma_j$ is equivalent to $sigma_j^(t+delta t)$ being conditionally
non-independent of $sigma_i^t$, given all other cognitive items at time $t$.

#conjecture[
  Let $G_cal(M) = chevron S, E chevron.r$ be a pairwise belief system network, and
  suppose that all belief system state configurations have non-zero probability of
  occurring. For any pair of cognitive items $sigma_i != sigma_j in S$, $sigma_i$
  directly influences $sigma_j$ if, and only if,
  $sigma_j^(t+delta t) cancel(tack.t.double) sigma_i^t | bold(sigma)_(-i)^t$
]

#proof[
  #set math.equation(numbering: none)
  Let $bold(sigma)^t$ be the instantaneous configuration of cognitive item states in
  the belief system network at time $t$, then applying Bayes' rule to the conditional
  probability distribution over $sigma_j^(t+delta t)$ given the previous system
  configuration, we find
  $
    PP[sigma_j^(t+delta t) | bold(sigma)^t] &= PP[sigma_j^(t+delta t), bold(sigma)^t]/PP[bold(sigma)^t] &&"Bayes rule" \
    &= (PP[sigma_j^(t+delta t), sigma_i^t | bold(sigma)_(-i)^t] PP[bold(sigma)_(-i)^t])/(PP[sigma_i^t | bold(sigma)_(-i)^t] PP[bold(sigma)_(-i)^t]) #h(5em) &&"Bayes rule (again)"\
    &= PP[sigma_j^(t+delta t), sigma_i^t | bold(sigma)_(-i)^t]/PP[sigma_i^t | bold(sigma)_(-i)^t] &&0 < PP[bold(sigma_i^t)] \
  $
  Combining this result with @def:model-direct-influence, it follows that $sigma_i$
  _does not_ directly influence $sigma_j$ if, and only
  if,
  $
    PP[sigma_j^(t+delta t), sigma_i^t | bold(sigma)_(-i)^t] &= PP[sigma_i^t | bold(sigma)_(-i)^t] dot PP[sigma_j^(t+delta t) | bold(sigma)_(-i)^t]
  $
  i.e., when $sigma_j^(t + delta t)$ is independent of $sigma_i^t$ conditional on
  $bold(sigma)_(-i)^t$. The main result then follows directly by taking the converse.
]

We associate a signed weight with each direct influence relation, with the sign
specifying whether the head tends to assume the same value ($+$) as the tail or the
opposite value ($-$), and the magnitude describing the degree to which a relation
influences the behaviour of the head. Finally, we include a signed baseline effect
for each cognitive item, which describes the tendency for that item to assume a positive
or negative state in the case that the combined incoming direct influence relations have
a net-zero influence. With the conceptual foundations now laid, we present our formal pairwise-interaction
belief system model in @def:model-belief-system-model.

#definition[Pairwise-interaction belief system][
  A *pairwise-interaction belief system* of size $N in NN$ is any
  tuple $cal(M) = chevron S, bold(A), bold(J), arrow(h) chevron.r$, where

  - $S$ is a set of $N$ cognitive items,

  - $bold(A) in {0,1}^(N times N)$ specifies the direct influence relations among
    elements of $S$ as an adjacency matrix,

  - $bold(J) in RR^(N times N)$ contains the weights of the influence relations, and

  - $arrow(h) in RR^N$ is a vector of baseline effects for the elements in $S$.
] <def:model-belief-system-model>


== Reviewing belief system models



== Asymmetric belief systems

We now introduce our belief system model as an extension on the Causal Attitude Network
model (*REFERENCE*). Our model diverges from this theory in
two key aspects: we consider (i) belief systems that are not at equilibrium, and in
which (ii) the pairwise interactions between cognitive items may be non-reciprocal, or
have different degrees of influence.

#definition[Asymmetric Causal Attitude Network][
  A (pairwise) *asymmetric causal attitude network* (*ACAN*) of size $N in NN$ is any
  tuple $cal(M) = chevron S, bold(A), bold(J), bold(h) chevron.r$, where

  - $S$ is a set of $N$ cognitive items,

  - $bold(A) in {0,1}^(N times N)$ specifies direct influence relations among the
    elements of $S$ as a directed adjacency matrix,

  - $bold(J) in RR^(N times N)$ contains the weights of the influence relations, with
    $J_(i j) = 0$ iff. #box[$A_(i j) = 0$], and

  - $bold(h) in RR^N$ is a vector of threshold effects for the cognitive items in $S$.
]

For $N in NN$, $cal(M) = chevron S, bold(A), bold(J), bold(h) chevron.r$ models a belief
system over the cognitive items in $S$, whose temporal dynamics are conditionally
defined with respect to the previous state configuration of cognitive items. Each
cognitive item updates probabilistically with transition probabilities in accordance
with the resulting relative change in energy. The change in energy experienced by a
cognitive item $i in S$ transitioning from $s_i^t$ to $s$, for $s_i^t, s in {-1, +1}$,
is a combination of the threshold $tau_i$ and incoming interaction effects:

$
  H_i (s | bold(s)^t) = - tau_i s - sum_(j=1)^N (A_(j i) J_(j i)) s_j^t s
$

The common factor $s$ allows us to rewrite this equivalently as a product of  $s$ with
a term not depending on $s$. We may consider this latter term as an *effective local
field* acting on the cognitive item $i$ at time $t$:

$
  H_i (s | bold(s)^t) = - s dot h_i^"eff" (bold(s)^t)
  //"where" h_i^"eff" (bold(s)^t) & = tau_i + sum_(j=1)^N A_(j i) J_(j i) s_j^t
$
where $h_i^"eff" (bold(s)^t) & = tau_i + sum_(j=1)^N A_(j i) J_(j i) s_j^t$. That is to
say that we may instead consider the simpler, equivalent scenario in which interaction
effects on $i$ from other cognitive items are replaced by a single locally-acting
field term.

*Derivation?*

The probability distribution over possible next states for the cognitive item $i$ is
then given by:

$
  PP[S_i^(t + dif t) = s | bold(S)^t = bold(s)] = exp[-1/T dot s dot h_i^"eff" (bold(s))]/(exp[-1/T dot h_i^"eff" (bold(s))] + exp[1/T dot h_i^"eff" (bold(s))])
$
where $T in RR_(>0)$ is a temperature parameter as in
(Equation: symmetric ising boltzmann). The symmetry of possible values for $s in {-1, +1}$
allows us to further simplify this expression as follows:

$
  PP[S_i^(t + dif t) = s | bold(S)^t = bold(s)] = exp[-1/T dot s dot h_i^"eff" (bold(s))]/(2 cosh [1/T h_i^"eff" (bold(s))])
$ <eq:model-asymmetric-transition-probability>

We illustrate the behaviour of this probability distribution for a cognitive item $i$,
for varying effective local field strengths and temperature parameters in
(Figure: transition probability example). Observe that for high-magnitude
negative effective local fields --- corresponding to a large positive threshold $h_i$,
and/or strong influences toward positive values from other spins ($J_(j i) s_j > 0$)
--- the probability that $i$ transitions to $S_i^(t + dif t) = 1$ converges to $1$.
The opposite effect is observed for high-magnitude positive effective local fields.


Additionally, we clearly see the effect of the temperature parameter on the
distribution. In the low-temperature scenario ($T = 1.0$), for effective local field
magnitudes #box[$|h_i^"eff" (s)| gt.approx 1.5$], the distribution over possible next
states for $i$ is close to constant. As $T -> 0^+$, the curve approaches a
step function with a threshold at 0. On the other hand, in the high-temperature
scenario ($T = 3.0$), the probability of a transition to $S_i^(t + dif t) = -1$ is
non-trivial even for high-magnitude negative values of $h_i^"eff" (bold(s))$. For
a fixed effective local field, higher temperatures incur transition probability closer
to $0.5$ (*can include derivation showing entropy $-> 1$*). Since in any finite model
each cognitive item has a bounded effective local field strength, it follows that as
$T -> infinity$ the transition probability is decreasingly influenced by the effective
local field.


*Motivate the differences between this model and the CAN model*

Unlike the CAN model, our asymmetric belief system model does not assume equilibrium
dynamics. @eq:model-asymmetric-transition-probability defines transition probabilities
for a given cognitive item as conditional on the previous system state, with no
assumption that this state was at equilibrium, nor at a steady state. As such this
formulation is suitable for studying out-of-equilibrium dynamics such as those occurring
during interventions.

Let us briefly discuss two aspects of the ACAN model which differ functionally from the
symmetric variant. Firstly, we permit interactions between a pair of cognitive items
to vary directionally. It may be the case that the relation $A -> B$ exists, yet
$B -> A$ does not, or that both exist but with different strengths. How then should we
interpret interaction effects in the asymmetric model?

In the symmetric formulation,





*Discuss how the dynamics differ*

#line(length: 100%)

The CAN model, as outlined in @dalegeFormalizedAccountAttitudes2016b, is conceptualised
as a symmetric (network) Ising model, characterised by its behaviour at equilibrium. In
the present study we are interested in questions regarding intervention, in which the
goal is to shift an individual's configuration of beliefs and attitudes such that a
particular 'target' cognitive item assumes a desired value, e.g., belief in climate
change. These dynamics are inherently non-equilibrium. In the case that an individual's
belief system configuration is in an equilibrium steady state, our goal is to disrupt
this. If instead their belief system configuration is _not_ at equilibrium, then our
goal is to influence its dynamics toward our desired steady state. In either case we
are fundamentally concerned with the dynamics of belief systems away from equilibrium.

Under this equilibrium assumption it is reasonable to treat interactions between
cognitive items as *symmetric*, such that for any pair of cognitive items $i,j$, the
influnece of $i$ on $j$'s behaviour is equal to that of $j$ on $i$'s behaviour. To see
why this is the case, suppose that for cognitive items $i,j$, we have
$omega_(i j) != omega_(j i)$. If the system is at equilibrium, then the probability
distribution over states is described by the Boltzmann distribution with
(Equation: CAN hamiltonian) as its Hamiltonian. Consider the contribution to the
Hamiltonian from the interactions between $i$ and $j$:

$
  H_(i j)(bold(s)) = - omega_(i j) s_i s_j - omega_(j i) s_j s_i
$

Since multiplication commutes, $s_i s_j = s_j s_i$, and we may equivalently write this
contribution using a single interaction effect:

$
  H_(i j)(bold(s)) = -(omega_(i j) + omega_(j i)) s_i s_j
$

Thus when assuming equilibrium there is no representative power to be gained by
permitting interaction weights to vary directionally. However, as discussed above, in
the present study we are concerned with out-of-equilibrium dynamics, in which the
distribution over belief system configurations at time $t + dif t$ is not described by
the Boltzmann distribution, but is rather conditional on the configuration observed at
time $t$. In this setting, asymmetric interaction weights do not necessarily have an
equivalent symmetric formulation.

For example, consider the simple asymmetric network shown in *REF FIGURE*, comprising
two cognitive items, $A$ and $B$, which are related by a directed edge $A -> B$ with
weight 1. Note that this formulation is equivalent to including a directed edge
$B -> A$ with weight 0. For simplicity we assume that $tau_A = tau_B = 0$.

At time $t + dif t$, for either possible state $s_A in {-1, +1}$, the contribution of
$A$ to the system energy is $0$, since it has no incoming interaction effects, and has
a threshold of zero. On the other hand, $B$'s contribution to the system energy when
adopting the state $s in {-1, +1}$ depends
on the previous state of $A$, and is given by $-s_A^t dot s$, such that $B$ achieves
lower energy when it adopts the previous state of $A$. Therefore $B$'s behaviour
depends on that of $A$, which in turn is independent of the state of $B$.


*Discuss how this asymmetry should be interpreted.*
- In symmetric model: interactions are holding each spin in place.
- In asymmetric model: interactions are reinforcing or damping the future
  state of other spin.



// We relax this assumption, permitting
// $omega_(i j)$ and $omega_(j i)$ to vary in magnitude and sign, and allowing unidirec
// In this work, we adopt a broader
// causal perspective on the nature of influences between cognitive items. In particular,
// we

*Introduce formal model*

Our model, formally outlined in *REF DEFINITION*, relaxes these assumptions. We redefine
interactions as temporal causal effects which positively or negatively reinforce the
state of the cognitive item at the head of the relation. We allow for self-interactions,
which are interpreted in the same way. Positive self-interactions reflect the _inertia_
or _stickiness_ of a cognitive item, as seen through a reluctance to change state, with
increased interaction weight corresponding to increased inertia. Negative
self-interaction weights would reflect unstable cognitive items whose state inherently
repels itself in future timesteps. Such negative self-interactions are thus not expected
to be observed in reality.


*Adjacency matrix makes the asymmetry explicit*

== Inverse problem

- Problem with cross-sectional model fitting: show figure of example from above. $A$'s
  instantaneous behaviour is independent of $B$'s, but $B$ depends on the previous value
  of $A$. If we assume asynchronous updating, then perhaps we capture some of this, but
  not completely accurately. Moreover we cannot infer self-interactions.
- Introduce time-series model fitting.

#line(length: 100%)




We first explicate what we mean by the term 'belief system', and then present the formal
belief system model which forms the basis for the subsequent chapters.


- Elucidate the core components of a belief system: cognitive items, relations between
  them
- In a nutshell, what is a belief system?
- Belief systems are individual, but components are likely shared between individuals.
- What is a belief system _not_? i.e., a particular instantiation of beliefs or
  attitudes.
- What is the nature of the interactions between cognitive items? Why would there be, or
  not be, a relation between two items?
- What are the dynamics?


Formal model:
- Describe the key components: cognitive items and relations
- Dynamics: maximum entropy model.









#line(length: 100%)



A pairwise belief system of size $N in NN$ is described by a tuple
$cal(M) = chevron bold(A), bold(J), arrow(h) chevron.r$, where:

- $bold(A) in {0,1}^(N times N)$ is a (possibly directed) adjacency matrix over the $N$
  cognitive items, with $A_(i j) = 1 <==> i -> j$,

- $bold(J) in RR^(N times N)$ describes the weights of the pairwise relations, with the
  weight of a relation $i -> j$ given by $J_(i j)$. $J_(i j) = 0 <==> A_(i j) = 0$.

- $arrow(h) in RR^N$ describes the cognitive item baselines, i.e., the weights of
  relations with empty tails.


$cal(M)$ confers a conditional probability distribution on the future states of an
individual's cognitive items, given their current states. For a cognitive item
$i in [1,N]$, this distribution is:

$
  P(S_i^(t+1) = s|bold(s)^t) = exp[-1/T dot -(s dot h_i + sum_(j=1)^N A_(j i) J_(j i) s_j s) ]/(sum_(s in S) exp[-1/T dot -(s' dot h_i + sum_(j=1)^N A_(j i) J_(j i) s_j s') ])
$



#line(length: 100%)


A relation between The relations between cognitive items reflect a tendency for
. The cognitive items comprise a collection of $N$ cognitive items which are related in
a pairwise faashion (e.g., beliefs or
attitudes). A network of pairwise relations

In the forthcoming chapters, we


A belief system of size $N in NN$ comprises a collection of cognitive items, such as
beliefs and attitudes, whose states vary temporally with respect to underlying
preferences, external pressures, and other cognitive items. Belief systems are defined
at the level of individuals; two individuals within a population may have different
belief systems, which exhibit different states.

The notion of a belief system in psychology is open to interpretation. We begin this
chapter by explicating our particular interpretation, and clarifying assumptions which
underlie our modelling decisions and subsequent analysis. We then present a formal
definition for a *computational belief system* which we use in this thesis, and argue
that this captures the relevant aspects of the examined phenomena. We additionally
discuss and justify our approach to modelling interventions in such computational belief
systems.

Finally, we consider practical experimental matters, discussing methods for inferring belief
systems from data.

- Introduce chapter: What will we discuss?
- Storytime: What is a belief system? What are the key components, dynamics? What
  behaviour do they exhibit? What assumptions are we making?
- Modelling belief systems:
  - Common approaches
  - Our assumptions
  - Defining dynamics
  - Interventions
  - Justifying model w.r.t. actual phenomenon.
- Inverse problem: how do we recover belief systems from data?
- Limitations: what is our model incapable of capturing? Where does it differ from
  phenomenon? What can/can't we infer with our inverse solving approach?


We now present our belief system model. Letting $N in NN$, a belief system of size $N$
comprises $N$ cognitive items, such as beliefs and attitudes, which vary temporally
through interactions with one another and with respect to underlying preferences or
external pressures.


Consider a particular cognitive item, $sigma_i$ for $i in [1,N]$, the specific referrent
of which is not important. For instance, $sigma_i$ might represent an individual's
attitude toward travelling or eating meat, emotions such as happiness or anxiety, or
a belief, for instance, about tomorrow's weather. Suppose that at time $t$ we measure
the state of this cognitive item for a particular individual, and find that
$sigma_i (t) = s$, for $s in {-1, +1}$. We may then reasonably ask what sequence of
events has resulted in this state.

- External influences (local fields):
  - Social norms (descriptive, injunctive)
  - Events, experiences (which update knowledge, or affect attitudes)
  - Cost, accessibility, or relevance/context (i.e., states of affairs, can change
    attitudes)
- Other cognitive items (interactions, adjacency):
  - Beliefs influence beliefs (e.g., implication, overlapping themes)
  - Beliefs influence attitudes (belief that it will be rainy tomorrow $-->$ negative
    attitude).
  - Indirectly: cognitive items affect behaviour (cf. game theory); behaviour reinforces
    or damps cognitive items, e.g., when enjoyed, or when behaviour causes learning
  - ...?
  - Influences may not be symmetric. For instance, an individual who believes that
    tomorrow will be rainy may be predisposed to a gloomy mood, but it would be
    unreasonable to assume that an individual with a gloomy mood is predisposed to
    particular beliefs about tomorrow's weather. At least not to the same degree of
    influence. Gloomy moods are multiply-realised, and can fluctuate quickly, often
    with a time-scale of days or less. Symmetric relations would imply a system in
    which a bad day could result in a total update to an individual's other beliefs.
- Previous self-state (inertia):
  - Cognitive items may self-reinforce
  - Some are stickier than others, have different natural timescales. e.g., political
    leanings vs. beliefs about the weather.


== Model description

We now outline the theoretical belief system model adopted in this thesis. In line
with existing literature our conceptualisation has its roots in an Ising-style model,
operating under the assumption that the temporal dynamics of interest are driven by
an individual's efforts --- active or otherwise --- to reduce cognitive dissonance
among their attitudes and beliefs. Our work diverges from existing studies, however,
in that we consider the possibility of asymmetric, or directed, interactions between
cognitive items.

For $N in NN$, we conceptualise a belief system of size $N$ as a (possibly directed)
network with $N$ nodes. In general we allow for reflexive edges. Each node is
considered as referring to a distinct cognitive item. Edges and nodes are weighted
with values in $RR$. The sign of an edge's weight describes the tendency ($+$) or
reluctance ($-$) for the edge's head to align with the tail, with the magnitude
specifying the strength of this effect. This captures the notion of cognitive
dissonance among items. If two items are connected via the positive edge $A -> B$, and
the individual holds different states (for instance $A = -B$), then they are said to
experience cognitive dissonance on these items.

Likewise, the sign and magnitude of a node weight describe the general tendency for an
individual to exhibit a particular state on a given cognitive item. For instance, if
we consider the cognitive item _'attitude toward owning pets'_ where a positive state
indicates a preference for owning pets, then a negative node weight on this item would
indicate that, all else equal, the individual would prefer not to own a pet. We will
often refer to node weights as the *baseline* for a cognitive item, or, in the Ising
model context, as the *local field effect* on a spin.

With conceptual groundwork now laid, we are in a position to define this model more
formally. Letting $N in NN$, we define a belief system of size $N$ as any tuple
$cal(M) = chevron bold(A), bold(J), arrow(h) chevron.r$. $bold(A) in {0,1}^(N times N)$
describes the adjacency matrix of a network on $N$ nodes, with $A_(i j) = 1$ if, and
only if, there exists a directed edge $i -> j$. $J in RR^(N)$ and $arrow(h) in RR^N$
describe the edge and node weights of the network.

Consider a given spin $i in [1,N]$. $cal(M)$ imposes a conditional probability
distribution on the temporal dynamics of the state of $i$ with respect to the
instantaneous states of other spins. Assuming that in general individuals' belief
systems tend toward a state of lower cognitive dissonance, $i$ will evolve such that
its future state exhibits (at least) no greater dissonance with the individual's
baseline tendencies ($h_i$), nor with the states of their other cognitive items.

$
  P(S_i^(t+1) = s|bold(s)^t) = exp[-1/T dot -(s dot h_i + sum_(j=1)^N A_(j i) J_(j i) s_j s) ]/(sum_(s in S) exp[-1/T dot -(s' dot h_i + sum_(j=1)^N A_(j i) J_(j i) s_j s') ])
$

Rearrange, pull out the value of $s$. Remainder is the effective local field. Can show
in figures how that varies with different temperatures/effect sizes.

For $S = {-1, +1}$, the denominator simplifies to ...



For a given spin $i in [1,N]$, we define the effective local field on $i$ at time $t$
in terms of the instantaneous states of other spins with edges into $i$.

$
  theta_i (bold(s)^t) = h_i + sum_(j=1)^N A_(j i) J_(j i) dot s_j
$

Through this effective local field, $cal(M)$ imposes a conditional probability
distribution on the temporal dynamics of the state of $i$:

$
  P(s_i^(t+1)|bold(s)^t) = exp[-1/T ]/a
$












== Main points

For Kyuri + Vítor:

- Model definition:
  - Generic/Asymmetric: Energy of a configuration
  - Symmetric: Hamiltonian, Boltzmann
  - Glauber dynamics: sequential, parallel

- Model reconstruction:
  - Causal discovery
  - Parameter estimation: cross-sectional likelihood, time-delayed likelihood
  - Add note about observables, why cross-sectional only works for Symmetric
    without self-loops
  - Assumptions:
    - Same structure for everyone
  - Summarise, with diagram:
    - Causal discovery to restrict structure ($bold(A)$)
    - Maximum likelihood to estimate parameters ($bold(J), arrow(h)$)

- Intervention:
  - Method: Change $h_i$, continue simulation from last measured state
  - Considerations:
    - Model reconstruction assumes homogeneous belief structure among individuals.
      If some individual has an 'unstable' configuration according to this, they will
      tend toward the population average regardless of intervention. Instead consider
      behaviour directly after intervention, and look at the difference between
      intervention behaviour and non-intervention behaviour.

=== Introducing/motivating our model decisions

Is this the same as the cognitive dissonance framework generally assumed?
With asymmetric interactions can we adopt a more general 'causal' interpretation?

Still have cognitive dissonance. Consider a belief system which includes the directed
relation $a -> b$ with positive weight. If:

- $s_a = 1$, then $b$ updates preferentially toward $s_b = 1$.
- $s_a = -1$, then $b$ updates preferentially toward $s_b = -1$.

(Continue reading from pg 7 in orig. causal discovery book).

=== Assumptions

Cognitive axes are linearly independent. i.e., the information contained in 'belief in climate change' is non-overlapping with 'belief about the causes of climate change'. The alternative, that they are linearly dependent, could lead to a restriction on possible values. For instance, if two items each depend on a set of lower-level beliefs, a subset of shared low-level beliefs could impose a strict structure on the values that can be obtained. This might not actually be a problem --- is this just what we're modelling?

=== Belief system dynamics

Let us first explicate what it is that we mean by the term *belief system*.
Consider a collection of $N$ cognitive items, comprising beliefs, attitudes (...?).








=== Configuration energy

Local field energy:
$
  H_h (bold(s)|bold(x)) = -sum_(i =1)^N s_i dot h_i (bold(x))
$

Where $h_i: RR^N -> RR$ is defined as $bold(alpha)_i^T bold(x)$. When no covariates are
used this is equivalent to the standard definition of the local field energy.

Interaction energy:

$
  H_j (bold(s)|bold(x)) = -sum_(chevron i j chevron.r) A_(i j) dot J_(i j) (bold(x)) dot s_i s_j
$

We take $J_(i j)$ as a constant function of $bold(x)$. In other words, the coupling constants
do not depend on individual covariates.

Total energy:

$
  H(bold(s)|bold(x)) = H_h (bold(s)|bold(x)) + H_j (bold(s)|bold(x))
$

=== Probability of transition



We first derive the effective local field experienced by $s_i$ at time $t$. Consider
the probability that $s_i^t = 1$, given that $S_(t-1) = bold(s)_(t-1)$
Effective local field at spin $i$:
$
  theta_i (t|bold(s)_(t-1), bold(x)_(t-1)) = h_i (bold(x)_(t-1))
$

$
  P(S_(t+1) = bold(s)_(t+1)|S_t = bold(s)_t) =
$




== Problem statement

- Capture the endogenous dynamics of belief systems, such that we can test the effects
  of intervention.

== Model definitions

#definition[Symmetric Ising model][
  For $N in NN$, the Symmetric (network) Ising model of size $n$ comprises $N$
  interacting binary variables $s_i in S$, termed *spins*, where typically $S$ is
  ${0,1}$ or ${-1, +1}$. Formally, the Symmetric Ising model is described by the
  tuple $M = chevron bold(A), bold(J), arrow(h) chevron.r$, where:
  - $bold(A) in {0,1}^(N times N)$ is a symmetric adjacency matrix, describing the
    connectivity between spins,
  - $bold(J) in RR^(N times N)$ is a symmetric matrix of pairwise spin *interaction
    constants*, and
  - $arrow(h) in RR^N$ is a vector of *local field constants*.

  The *energy* (or *hamiltonian*) of $M$ for a spin configuration $arrow(s) in S^N$ is
  given by:
  $
    H_M (arrow(s)) = -sum_(i=1)^N h_i s_i - sum_(i=1)^N sum_(j=i)^n A_(i j) J_(i j) s_i s_j
  $

  At equilibrium $M$ emits a spin configuration $arrow(s) in S^N$ with probability
  described by the Boltzmann distribution:

  $
    p_M (S^N = arrow(s)) &= exp(-1/(k_B T) dot H_M (arrow(s)))/(sum_(arrow(s)' in S^N) exp(-1/(k_B T) dot H_M (arrow(s)'))) \
    &= 1/Z exp(-1/(k_B T) dot H_M (arrow(s)))
  $
]

#definition[Asymmetric Ising model][
  For $N in NN$, the Asymmetric (network) Ising model of size $n$ is relaxation on the
  Symmetric Ising model definition, which permits $bold(A)$ and $bold(J)$ to be
  non-symmetric.

  For distinct spins $1 <= i != j <= N$:
  - Interactions may exist in only one direction ($A_(i j) != A_(j i)$, or
  - The coupling constants may vary directionally ($J_(i j) != J_(j i)$).

  Self-interactions are identical to those in the Symmetric Ising model, since these are
  uniquely described by the diagonals of $bold(A)$ and $bold(J)$.
]

== Inverse Ising problem

Let $bold(Y) in {-1, +1}^(K times N)$ be a collection of $K in NN$ observations of
$N in NN$ binary variables, which are assumed to be independent emissions from some
unknown Ising model $M$. The inverse Ising problem consists in identifying a model
$tilde(M)$ such that $tilde(M) approx M$.

Here we consider the existence and uniqueness of solutions to the inverse Ising problem,
and review methods for solving it. We primarily discuss models with configurations in
${-1, +1}^N$, though we make clear when the results differ for models over ${0, 1}^N$.
We first consider Symmetric Ising models with no self-interaction terms (i.e.,
#box[$A_(i i) = J_(i i) = 0$] for all $i in [N]$), and then expand more generally
to Asymmetric Ising models, and models with self-interaction terms.

=== Symmetric Ising models without self-interactions

==== Maximum likelihood estimation

The probability that a model $M$ with parameterisation $bold(theta)$ produces the
dataset $bold(y)$ is more known as the *likelihood*:

$
  P(bold(Y) = bold(y) | bold(theta)) = product_(arrow(y) in bold(y)) 1/Z exp(-1/(k_B T) H_M(arrow(y)))
$ <eq:model-symmetric-likelihood>

Maximisation of the likelihood over possible parameterisations is a commonly-used
method for solving the inverse Ising problem. In general, even for relatively small $N$,
@eq:model-symmetric-likelihood is often a product over many small probabilities, so its
calculation is subject to loss in precision due to underflow. As such, we instead
typically maximise the *log-likelihood*:

$
  cal(L)_bold(y) (bold(theta)) & = log P(bold(Y) = bold(y) | bold(theta))
$ <eq:model-log-likelihood>

The optimisation problem is then:

$
  bold(tilde(theta)) = op("argmax")_bold(theta) cal(L)_bold(y) (bold(theta))
$

For the Symmetric Ising model (with cross-sectional data $bold(y)$), the log-likelihood
is:

$
  cal(L)_bold(y) (bold(theta)) &= log product_(arrow(y) in bold(y)) 1/Z^(bold(theta)) exp(-1/(k_B T) H_M^(bold(theta)) (arrow(y))) \
  &= - sum_(arrow(y) in bold(y)) 1/(k_B T) H_M^(bold(theta)) (arrow(y)) + log(Z^(bold(theta)))
$

- Maybe derive all of this for the more general asymmetric model including self-loops,
  then come to the conclusion that this is insufficient for models outside the symmetric
  Ising. Because the log-likelihood derivation should be the same.
- Re-write as sum over possible configurations
- Derive the partial derivatives w.r.t. $h_i$ and $J_(i j)$







==== Existence

==== Uniqueness













== The Ising model

#definition[Spin-domain; spin-configuration][
  Let $S$ be a set of literals and $n in NN$. The set $S^n$ comprising
  all length-$n$ vectors with elements in $S$ is referred to as the as the
  $(S, n)$-domain.
  Where the values of $S$ and $n$ are evident or not relevant, we refer
  to $S^n$ simply as the _spin-domain_.

] <def:model-spin-domain-configuration>

#definition[Spin-configuration][
  Let $S$ be a set of literals and $n in NN$. We refer to an element $arrow(s) in S^n$
  as an #box[$(S,n)$-configuration]. If $S$ and $n$ are evident or not relevant, we
  instead refer more simply to $arrow(s)$ as a _spin-configuration_.
] <def:model-spin-domain-configuration>

#example[$(S,n)$-domain][
  Let $S={a,b}$ and $n=3$, then the $(S,n)$-domain comprises the following
  #box[$(S,n)$-configurations]:

  #block(
    grid(
      align: center,
      columns: (1fr, 1fr, 1fr, 1fr),
      rows: 2,
      row-gutter: 1.5em,

      [$arrow(s)_1 = [a, a, a]^T$],
      [$arrow(s)_2 = [a, a, b]^T$],
      [$arrow(s)_3 = [a, b, a]^T$],
      [$arrow(s)_4 = [a, b, b]^T$],

      [$arrow(s)_5 = [b, a, a]^T$],
      [$arrow(s)_6 = [b, a, b]^T$],
      [$arrow(s)_7 = [b, b, a]^T$],
      [$arrow(s)_8 = [b, b, b]^T$],
    ),
  )
]

- Introduce the Ising model and its variants in prose, describing the system of spins
  etc. Refer to other texts for more extensive treatments.
- Then provide formal definitions.



#definition[Symmetric $(-1,1)$-Ising model][
]<def:model-symmetric-ising>

#definition[Kinetic $(-1,+1)$-Ising model][
]

== Simulation

- Symmetric Ising model at equilibrium: sample using analytic equilibrium probabilities.
  - Show why this works, given detailed balance.
- Non-equilibrium models: Glauber dynamics, parallel glauber dynamics.
  - Give counter-example to detailed balance.


Glauber dynamics new spin state probability:

$
  p(s_i (t+1)|bold(s)(t)) = exp(1/T dot s_i (t+1) dot [h_i + sum_(j eq.not i) J_(i,j) dot s_j (t)])/(2 cosh(h_i + sum_(j eq.not i) J_(i,j) dot s_j (t)))
$


Equivalent form in terms of logistic function:
$
  p(s_i (t+1)|bold(s)(t)) = op("logistic")(-2/T dot s_i (t+1) dot [h_i + sum_(j eq.not i) J_(i,j) dot s_j^t])
$


== Inverse Ising problem

- What is the inverse Ising problem?
- What is required to solve the inverse Ising problem (existence, uniqueness)?
  - Observables
- Symmetric Ising model: cross-sectional maximum likelihood estimation
- Asymmetric and non-equilibrium models: cross-sectional doesn't work (in general;
  show conditions for when it does?). Can use time-delayed maximum likelihood
  estimation. Equivalent to fitting logistic equation for each spin.
- Discuss regularisation?
- Show examples. Including how fit quality varies with number of samples.
- Can only fit self-loops with time-delayed estimation

=== Constraining allowed interactions

- Causal discovery to: (i) identify likely directional relations between spins, and (ii)
  prune interactions which are not significant.


// == Modelling individual differences
//
// In the simplest problem formulation, we treat all individuals as replicates of the same
// underlying belief system. This is commonly referred to as a _total-pooling_ approach.
// Total pooling allows us to use a maximal amount of data to fit a minimal number of
// parameters. In the case where the homogeneity assumption holds, total pooling is
// optimal.
//
// // TODO: Define total pooling
//
// However, if the homogeneity assumption does not hold, then some individuals will not be
// well-represented by the inferred belief system. This is particularly critical when
// considering the stability of observed belief system configurations.
//
// Suppose we have belief system measurements from individuals for a system comprising
// three beliefs. After fitting the model using total pooling, we find that $s_1$ tends
// to be `OFF` in absence of interactions. However, suppose that for a subset of
// individuals $s_1$ is more typically `ON`; due to differences in their context, perceived
// norms, or knowledge, their tendencies differ from the general population. For these
// individuals we are likely to observe $s_1$ as being `ON` more often than otherwise
// expected. This is a stable configuration for these individuals; however, assessing
// stability with reference to the total pooling model will tell us that they are unstable,
// and likely to transition to a new configuration in future.
//
// // TODO: Draw the above graph
//
// At the other extreme, termed _no-pooling_, we can fit a separate model for each
// individual. However, it is unlikely that we would have adequate data to achieve a robust
// fit, and since beliefs and attitudes are often quite stable, we would likely not observe
// key interaction effects between certain beliefs, even over extended measurement periods.
//
// We can instead make the intermediate assumption that many belief system aspects are
// shared between individuals, but that there exists some individual variation. For
// instance, we expect certain directed belief interactions to be present for the majority
// of individuals, particularly when these reflect logical conditions, or widespread
// societal understandings.







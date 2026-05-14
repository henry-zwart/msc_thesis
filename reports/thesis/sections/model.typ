#import "@preview/theorion:0.6.0": *
#import cosmos.fancy: *
#show: show-theorion


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







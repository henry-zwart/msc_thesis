#import "@local/drifting-cls-thesis:0.1.0": caption

== Belief system dynamics <subsec:methods-belief-system-dynamics>

- Interdependent beliefs and attitudes; state of one affects the state of another:
  - Cognitive dissonance
  - Causal effects(?)
- Individual belief systems:
  - Degree of influence depends on individual experience, perception, meta-level
    beliefs.
- Formalising dynamics:
  - Discrete beliefs, attitudes which take on values in some domain
  - State of each one depends on previous in a Markov process
  - Broader Markov process describes the state of the belief system as a whole


We will now formalise the dynamics of an individual belief system, under the following
assumptions:

+ Beliefs and attitudes can be treated as discrete entities.

+ The state of a belief or attitude is Markovian with respect to the previous system
  configurations.

+ The probability distribution relating current and future belief states does not
  change over time.

The first assumption includes two key points. Firstly, that it makes sense to consider
beliefs and attitudes as _entities_, or _objects_. This contrasts, for instance,
alternative interpretations of attitudes as emissions from an underlying structure.
(*TODO:* review CAN paper for further discussion on this matter). Secondly, that
beliefs and attitudes can be considered _discrete_ or _separable_. This is to say
that there are no absolute physical constraints on the combinations of states which
may be observed (although certain combinations may be highly unlikely). In particular,
this captures the requirement that each belief or attitude can be represented using a
single state variable.

Our second assumption concerns the treatment of beliefs and attitudes as Markovian.
- Harder to justify conceptually, since individuals have memory and can recall prior
  states beyond the previous second.

Consider a belief or attitude $S_i$ with domain $Omega_(S_i)$. The state of $S_i$
at time $t$ depends on the previous states of other beliefs and attitudes, and
we can therefore describe the trajectory of $S_i$ as a Markov process:

$
  {s_i^t}_(t=1)^infinity quad "where" quad s_i^t in Omega_(S_i)
$ <eqn:methods-belief-system-dynamics-belief-markov-process>

with conditional state probability $P(S_i^(tau+1) | bold(S)^1, ..., bold(S)^(tau)) = P(S_i^(tau + 1) | bold(S)^tau)$ for $tau in NN$.

Since the state of $S_i^(t+1)$ depends only on the previous belief system state, it
follows that for any other belief or attitude $S_j$, the states $S_i^(t+1)$ and
$S_j^(t+1)$ are conditionally independent given $bold(S)^t$. We can therefore
straightforwardly extend @eqn:methods-belief-system-dynamics-belief-markov-process to
describe the evolution of the entire belief system as a Markov process,

$
  {bold(s)^t}_(t=1)^infinity quad "where" bold(s)^t in Omega_(S_1) times dots.c times Omega_(S_n)
$ <eqn:methods-belief-system-dynamics-belief-system-markov-process>

with the probability of each belief system configuration given by the conditional
distribution $P(bold(S)^(t+1) | bold(S)^t)$.

Under this conceptualisation, the task of modelling a belief system thus reduces to
describing how the instantaneous configuration of belief states affects the probability
distribution over possible future states.


== Non-equilibrium belief system model <subsec:methods-nonequilibrium-belief-system-model>

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
at equilibrium, such that
$P(bold(S)^t = bold(s) | bold(S)^(t-1)) = P(bold(S) = bold(s))$ for all configurations
$bold(s)$ and observation times $t$. The probability of
observing $bold(s)$ is then time-invariant and given by the Boltzmann probability
parameterised by the Hamiltonian $H(bold(s))$ @christensenComplexityCriticality2005
@cardyScalingRenormalizationStatistical1996:

$
  P(bold(S) = bold(s)) = (e^(-1/(k_b T) dot H(bold(s))))/(sum_(bold(s)') e^(-1/(k_b T) dot H(bold(s)')))
$ <eqn:methods-model-boltzmann>

where $k_b$ is the Boltzmann constant, and the temperature parameter $T in RR^+$
controls stochasticity. @eqn:methods-model-boltzmann converges to a uniform
distribution over all configurations when $T -> +infinity$, and a uniform
distribution over the restricted set of configurations for which $H(bold(s'))$ is
minimised when $T -> 0^+$.

For the purposes of this study, we are interested in intervention dynamics, which are
inherently non-equilibrium. To see why this is the case, notice that the purpose of
intervention is to change the distribution of observed states. This is true both
interventions intended to change the dominant state (e.g., to promote a sustainable
alternative to a typical unsustainable behaviour) or reinforce it. Any belief system
model intended for studying intervention dynamics therefore cannot assume equilibrium,
and cannot define model dynamics using the Boltzmann distribution.

We instead define the conditional distribution $P(bold(S)^t = bold(s) | bold(S)^(t-1))$
explicitly. Recall that the states of each pair of spins $S_i, S_j$ at time $t$ are
conditionally independent random variables, given knowledge of the previous
configuration $bold(S)^(t-1)$ (@subsec:methods-belief-system-dynamics). It therefore
suffices for us to describe the distribution over spin states for an individual spin
$S_i$ at time $t$, as conditional on $bold(S)^(t-1)$.

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
$i$'_). When $J_(i j)$ if positive or negative, $S_i$ is influenced to adopt the state
$S_j^(t-1)$ or $-S_j^(t-1)$ respectively. In the special case when $j = i$, we refer
to $J_(i i)$ as a _self-influence_ effect. Positive self-influence effects reflect
the inertia of $S_i$, i.e., the tendency to sustain a particular belief or attitude
irrespective of other beliefs and attitudes. Negative self-influence effects are not
clearly interpretable. The inclusion of self-influence effects allows us to capture
the timescales of different beliefs or attitudes independently.

The energy experienced by $S_i$ for a particular spin state $s in {0,1}$ is then the
result of $s$ in combination with the baseline activation and influence effects from
all spins with edges to $S_i$:

$
  H_i (s | bold(s)^(t-1)) = h_i dot s + sum_(j) A_(j i) J_(j i) s_j^(t - 1) dot s
$ <eqn:methods-model-local-energy>

where $bold(A) in {0,1}^(n times n)$ is a pairwise adjacency matrix, with $A_(j i) = 1$,
iff, $S_j$ influences $S_i$. Dividing the common factor of $s$, we can equivalently
write @eqn:methods-model-local-energy as

$
  H_i (s | bold(s)^(t-1)) = s dot h_i^"eff" (bold(s)^(t-1))
$ <eqn:methods-model-local-energy-eff-field>

where $h_i^"eff" (bold(s)^(t-1)) = h_i + sum_j A_(j i) J_(j i) s_j^(t-1)$ is the
effective baseline activation experienced by $S_i$ at time $t$. We then define the
probability that $S_i$ adopts the state $s$ at time $t$ as:

$
  P(S_i^t = s | bold(S)^(t-1) = bold(s)) &= e^(1/T H_i (s | bold(s)))/(sum_(s' in {0,1}) e^(1/T H_i (s' | bold(s)))) \
  &= e^(1/T H_i (s | bold(s)))/(e^(1/T H_i (s | bold(s))) + e^(-1/T H_i (-s | bold(s)))) \
  &= e^(1/T s dot h_i^"eff" (bold(s)))/(e^(1/T s dot h_i^"eff" (bold(s))) + e^(-1/T s dot h_i^"eff" (bold(s))))
$

For $s = +1$, this reduces to the logistic function:

$
  p_i^bold(s) := P(S_i^t = +1 | bold(S)^(t-1) = bold(s)) &= e^(1/T dot h_i^"eff" (bold(s)))/(e^(1/T dot h_i^"eff" (bold(s))) + e^(-1/T dot h_i^"eff" (bold(s)))) \
  &= 1/(1 + e^(-2 dot 1/T dot h_i^"eff" (bold(s)))) \
  &= op("logistic")(2 h_i^"eff" (bold(s))\/T )
$

Therefore the complete conditional distribution is given by:

$
  P(bold(S)^t = bold(s)^t | bold(S)^(t-1) = bold(s)^(t-1)) &= product_(i=1)^n P(S_i^t = s_i | bold(S)^(t-1) = bold(s)^(t-1)) \
  &= product_(i=1)^n [((1 + s_i)/2) p_i^bold(s)^(t-1) + ((1 - s_i)/2) (1 - p_i^bold(s)^(t-1))]
$ <eqn:methods-model-conditional-prob-definition>

*NOTE:* The initial distribution must be specified, since the model only captures
transition probabilities.

=== Simulation via Glauber dynamics

=== Modelling interventions

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


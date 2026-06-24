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


== Non-equilibrium belief system model

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
  P(S_i^t = s | bold(S)^(t-1) = bold(s)) &= e^(-1/T H_i (s | bold(s)))/(sum_(s' in {0,1}) e^(-1/T H_i (s' | bold(s)))) \
  &= e^(-1/T H_i (s | bold(s)))/(e^(-1/T H_i (s | bold(s))) + e^(-1/T H_i (-s | bold(s)))) \
  &= e^(-1/T s dot h_i^"eff" (bold(s)))/(e^(-1/T s dot h_i^"eff" (bold(s))) + e^(1/T s dot h_i^"eff" (bold(s))))
$

For $s = +1$, this reduces to the logistic distribution:

$
  p_i^bold(s) := P(S_i^t = +1 | bold(S)^(t-1) = bold(s)) &= e^(-1/T dot h_i^"eff" (bold(s)))/(e^(-1/T dot h_i^"eff" (bold(s))) + e^(1/T dot h_i^"eff" (bold(s)))) \
  &= 1/(1 + e^(2 dot 1/T dot h_i^"eff" (bold(s)))) \
  &= op("logistic")(2 h_i^"eff" (bold(s))\/T )
$

Therefore the complete conditional distribution is given by:

$
  P(bold(S)^t = bold(s)^t | bold(S)^(t-1) = bold(s)^(t-1)) &= product_(i=1)^n P(S_i^t = s_i | bold(S)^(t-1) = bold(s)^(t-1)) \
  &= product_(i=1)^n [((1 + s_i)/2) p_i^bold(s)^(t-1) + ((1 - s_i)/2) (1 - p_i^bold(s)^(t-1))]
$ <eqn:methods-model-conditional-prob-definition>






== Experimental plan

== Dataset

=== Variable selection

=== Binarisation

Prior to model fitting, we binarise all variables, mapping data values to the
domain ${-1, +1}$. Before binarising, we shift each variable such that the _survey
midpoint_ (e.g., '3' on a 5-point Likert scale) aligns with 0, and rescale each
variable such that the minimum and maximum possible values map to $-1$ and $+1$
respectively. For variables with no well-defined midpoint, such as those with an even
number of possible responses, we shift such that the minimal and maximal values are at
equal distance from 0.

We use a smooth binarisation process to robustly handle data points which are zero, or
close to zero. This involves perturbing each data value $x in RR$ by an independent
noise term $epsilon ~ cal(N)(0, sigma)$ before thresholding. @fig:methods-binarisation
illustrates this process for a negative value of $x$ and given choice of $sigma$.

#figure(
  image(
    "../results/figures/methods/binarisation/distribution.pdf",
  ),
  caption: [
    $x in RR$ is smoothly binarised to ${-1, +1}$ by
    thresholding #box[$x' = (x + epsilon)$] where $(x + epsilon) ~ cal(N)(x, sigma)$. Negative values
    are mapped to $+1$ with probability #box[$P(x' > 0) = "A" = "B" = P(epsilon < x)$], which
    increases with $sigma$ and $|x|^(-1)$.
  ],
) <fig:methods-binarisation>

Observe that $x$ is mapped to $+1$ if, and only if, $epsilon$ is sufficiently large,
such that $x + epsilon > 0$ (region A), or equivalently when $epsilon < x$ (region B).
The probability that $x$ is mapped to $+1$ is then

$
  P(x mapsto +1) = Phi(x/sigma)
$ <eqn:methods-dataset-binarisation-probability-map-to-1>

#let binarisation_sigma = json("../results/data/methods/binarisation_sigma.json").sigma
where $Phi$ is the standardised normal cumulative distribution function. This
probability is small when $x$ has large magnitude, or when $sigma$ is small.
For the purposes of our experiments, we choose $sigma = #binarisation_sigma$ such that
a 'weakly oppose' response to a 7-point Likert scale
#footnote[The oppose/support 7-point Likert scale has possible responses: strongly oppose, oppose, weakly oppose, neutral, weakly support, support, strongly support.]
(value $1\/3$) is mapped to $+1$ with probability 0.05.


== Parameter estimation <subsec:methods-parameter-estimation>

- Define the inverse problem
- Introduce MLE as method for solving
- Derive the likelihood and derivatives

Given a collection of observations $D$ from a system assumed to be described by a
model $cal(M)$, but for which the true parameters are unknown, the _inverse problem_,
or _parameter recovery_, is the task of inferring the parameterisation responsible for
generating $D$. Maximum likelihood estimation is a commonly-used technique for parameter
recovery, which identifies the parameterisation $bold(theta) in Theta$ which maximises
the likelihood of the observed data:

$
  bold(hat(theta)) = op("argmax", limits: #true)_(bold(theta) in Theta) P(D | bold(theta))
$ <eqn:methods-parameter-recovery-mle-problem>

-
- Define variables for our specific MLE problem
Given a collection of observations $D$ from a belief system $cal(M)$ comprising
$m in NN$ spins, for which the true parameters are unknown, the inverse problem is the
task of inferring the parameterisation that generated $D$. Maximum likelihood estimation
is commonly-used, which identifies the parameters
$bold(theta)$seeksFor the purposes of the
experiments described in the following sections, we use maximum likelihood estimation

Given a belief system $cal(M)$ comprising $m in NN$ spins, for which the model
parameters are unknown, and a set of observations $D$ produced by $cal(M)$, the
_inverse problem_ is the task of inferring the model parameters which

Let $cal(M)$ be a belief system comprising $m in NN$ spins, for which the model
parameters $bold(h)$, $bold(J)$ are unknown, and let
$D = [{bold(s)^t}_(1, t=1)^(t'), ..., {bold(s)^t}_(m, t=1)^(t')]$ be a
dataset of observed configurations of $cal(M)$, collected from each of $n in NN$
individuals at $t' in NN$ uniformly-spaced timepoints.

The inverse problem is the task of finding parameters

=== Regularisation

// - Motivate: dealing with small sample size + large parameter count
// - Theory: How is it implemented?

Both the symmetric and asymmetric belief system models contain a relatively large
number of parameters to be estimated compared to the number of observations in the
dataset, which poses an issue for obtaining reliable parameter estimates
@epskampEstimatingPsychologicalNetworks2018. In line with standard practice, we apply
regularisation during estimation to encourage model sparsity, using a variation of
LASSO regularisation @tibshiraniRegressionShrinkageSelection1996 for which the first
derivative is smooth.

LASSO regularisation (#strong[l]east #strong[a]bsolute #strong[s]hrinkage and
#strong[s]election #strong[o]perator) is implemented as an additional summand in the
objective function. Rather than maximising the log-likelihood directly, we choose
parameters $bold(hat(theta)) in RR^p$ such that

$
  bold(hat(theta)) = op("argmax", limits: #true)_(bold(theta)' in RR^p) {cal(L)_D (bold(theta)') - lambda sum_(i=1)^p |theta'_i|}
$ <eqn:methods-regularisation-mle-problem>

This has the effect of penalising non-zero parameters with negligible contribution to
the log-likelihood. The parameter $lambda in RR^+$ controls regularisation strength,
with larger values resulting in sparser models.

This formulation of LASSO regularisation has a discontinuous first-derivative at
#box[$theta'_i = 0$] due to the absolute value function. Instead, we use the following
smooth variation, where $epsilon in RR^+$:

$
  bold(hat(theta)) = op("argmax", limits: #true)_(bold(theta)' in RR^p) lr({cal(L)_D (bold(theta)') - lambda sum_(i=1)^p sqrt(theta'_i^2 + epsilon)})
$ <eqn:methods-smooth-regularisation-mle-problem>

@eqn:methods-smooth-regularisation-mle-problem converges to
@eqn:methods-regularisation-mle-problem as $epsilon -> 0^+$, and has a well-defined
first-derivative for $epsilon > 0$, namely:

$
  dif/(dif theta'_i) (- lambda sum_(j=1)^p sqrt(theta'_j^2 + epsilon)) = (lambda theta'_i)/(sqrt(theta'_i^2 + epsilon))
$

For the purposes of this study, we will consider parameters as 'effectively non-zero'
if their magnitude exceeds $10^(-2)$. We thus choose $epsilon = 10^(-8)$, such that
$sqrt(epsilon)$ is two orders of magnitude smaller than the minimal parameter size
of interest, ensuring that @eqn:methods-smooth-regularisation-mle-problem is a
reasonable approximation to @eqn:methods-regularisation-mle-problem for parameter
values smaller than $10^(-2)$.


- Effects: How does regularisation affect sparsity?

#figure(
  image(
    "../results/figures/methods/regularisation_sparsity.pdf",
  ),
  caption: [
    Model sparsity increases with regularisation strength ($lambda$). Error bars display
    95% confidence intervals around expected number of non-zero parameters, measured
    across different stochastic binarisations of observed data.
  ],
) <fig:methods-regularisation-sparsity-plot>

We use the Extended Bayesian Information Criterion (EBIC, @eqn:methods-ebic)
@chenExtendedBayesianInformation2008 to select an appropriate regularisation strength,
as recommended in #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose").
The EBIC is an evaluative criterion for model selection, which balances maximisation of
the log-likelihood with model complexity, as measured by the number of parameters.
Compared to the original Bayesian Information Criterion, EBIC tends to be more
conservative when the number of parameters and observatons are comparable
@foygelExtendedBayesianInformation2010.

For a model with $p$ parameters, $k$ of which
are non-zero, fit using a dataset with $n$ observations, the EBIC is defined as:

$
  op("EBIC")(bold(theta)) = k dot [ln(n) + 2 gamma ln(p)] - 2cal(L)_D (bold(theta))
$ <eqn:methods-ebic>

We take $gamma = 0.25$, which has been shown to work well for network inference in the
inverse Ising problem @barberHighdimensionalIsingModel2015.

#let regularisation_strengths = json("../results/data/model_fit/optimised_regularisation.json")
In general, models with a smaller EBIC are preferred, as this indicates a reasonable
trade-off between model fit and complexity. We fit each of the symmetric and asymmetric
models for candidate regularisation strengths $lambda in RR subset [10^(-4), 10^(-1)]$,
and select the values for which the resulting EBIC is minimal
(@fig:methods-regularisation-ebic). This yields symmetric and asymmetric regularisation
strengths of #calc.round(regularisation_strengths.sym_ising.full, digits: 3) and
#calc.round(regularisation_strengths.ising.full, digits: 3) respectively.

#figure(
  image(
    "../results/figures/model_fit/regularisation_ebic.pdf",
  ),
  caption: [*TODO*],
) <fig:methods-regularisation-ebic>

=== Replicated binarisation

- Two sources of uncertainty in parameter estimates: sample size and binarisation
- Given fixed dataset, distribution over binarised datasets is fixed --> can marginalise
  over binarisation to get expected _maximum_ likelihood given dataset. Removes the
  uncertainty due to binarisation. Variance decreases as $S/sqrt(n)$.
- Re-frame log-likelihood using the conditional probability of spin $s$ given
  binarisation of the original value $x$.
- Can improve on the estimated log-likelihood by doing monte carlo samples of the
  LL.
- Show improvement to variance. MLE recovers parameters which maximise the expected
  LL given binarisation of the original dataset.

== Toy models (?)



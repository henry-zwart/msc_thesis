== Belief system dynamics

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
  {s_i^t}_(t=0)^infinity quad "where" quad s_i^t in Omega_(S_i)
$ <eqn:methods-belief-system-dynamics-belief-markov-process>

with conditional state probability $P(S_i^(tau+1) | bold(S)^1, ..., bold(S)^(tau)) = P(S_i^(tau + 1) | bold(S)^tau)$ for $tau in NN$.

Since the state of $S_i^(t+1)$ depends only on the previous belief system state, it
follows that for any other belief or attitude $S_j$, the states $S_i^(t+1)$ and
$S_j^(t+1)$ are conditionally independent given $bold(S)^t$. We can therefore
straightforwardly extend @eqn:methods-belief-system-dynamics-belief-markov-process to
describe the evolution of the entire belief system as a Markov process,

$
  {bold(s)^t}_(t=0)^infinity quad "where" bold(s)^t in Omega_(S_1) times dots.c times Omega_(S_n)
$ <eqn:methods-belief-system-dynamics-belief-system-markov-process>

with the probability of each belief system configuration given by the conditional
distribution $P(bold(S)^(t+1) | bold(S)^t)$.

Under this conceptualisation, the task of modelling a belief system thus reduces to
describing how the instantaneous configuration of belief states affects the probability
distribution over possible future states.


== Asymmetric belief system model


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


== Parameter recovery

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
strengths of #calc.round(regularisation_strengths.sym_ising, digits: 3) and
#calc.round(regularisation_strengths.ising, digits: 3) respectively.

#figure(
  image(
    "../results/figures/model_fit/regularisation_ebic.pdf",
  ),
  caption: [*TODO*],
) <fig:methods-regularisation-ebic>

== Toy models (?)



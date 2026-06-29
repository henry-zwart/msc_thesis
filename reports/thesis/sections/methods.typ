#import "@local/drifting-cls-thesis:0.1.0": caption

== Plan


- Counterfactual intervention experiments --- comparing against the no-intervention
  scenario, measuring differences in effects.
- Parameter estimation via MLE:
  - Marginalising over binarisation process
  - Regularisation




// == Experiment plan
//
// *RF1.1* is a theoretical contribution and is addressed in the following section on model
// details.
//
// ==== *RQ2.1*
// // *RQ2.1* concerns the variation in belief systems on climate change between individuals.
// // Belief system models fit using cross-sectional data have limited applicability to
// // understanding the belief systems of individuals (cf.
// // @brandtBetweenpersonMethodsProvide2022). While we do not use cross-sectional data, it
// // is nonetheless important to investigate the degree to which our inferred models capture
// // potential variation between individuals. To this end, I propose two experiments:
// //
// Investigate differences between models fit on different subsets of
// the population; e.g., age groups; democrat vs. republican; male vs. female; urban vs.
// rural:
//
// - Qualitative differences in model structure
// - Stability of individuals' measured configurations compared to: model fit on
//   whole dataset; model fit on whole dataset with varying spin thresholds
//
// Compare these results under symmetric/asymmetric model assumptions.
//
// ==== *RQ2.2*
//
// Fit asymmetric model to data. For each pair of items, $S_i, S_j in S$, calculate the
// directional differential:
//
// $
//   delta_(i j) = J_(i j) - J_(j i)
// $
//
// If $delta_(i j) > 0$, this indicates that the influence of $S_i$ on $S_j$ is stronger
// than in the opposite direction.
//
// Use bootstrapping to quantify uncertainty around the estimate for each $delta_(i j)$.
// Repeatedly resample the dataset with replacement. For each resampled dataset, fit the
// asymmetric model and calculate the directional differential. Use the estimates to
// calculate confidence bounds around each $delta_(i j)$.
//
// ==== *RQ3.1*
//
// Fit asymmetric and symmetric models to the observed data. For each pair of spins,
// $S_i, S_j in S$, designate $S_i$ the *intervention* spin and $S_j$ the *target spin*.
// Simulate an intervention on $S_i$ in the asymmetric model, and measure $S_j$ after
// $t in NN$ timesteps. Repeat this simulation on the same model with _no_ intervention,
// using the same random seed.
//
// We define the *effect of intervention* as the difference between the measured states
// of $S_j$ under the intervention and no-intervention scenarios, reflecting the change
// in behaviour resulting from intervening on $S_i$.
//
// Repeat this process for the symmetric model, again using the same random seed, to
// obtain the effect of intervention under a symmetric relation assumption. We now
// define the *effect of asymmetry* as the difference between the effects of intervention
// in the asymmetric and symmetric models respectively. A positive effect of asymmetry
// indicates that in the asymmetric model, intervening on $S_i$ results in a greater
// shift in the behaviour on $S_j$ toward $+1$ than in the symmetric model.
//
// Note that if 'backlash' dynamics are observed, such that intervening on $S_i$ can result
// in a reduction in the desired behaviour on $S_j$, then a positive effect of asymmetry
// _does not_ necessarily imply that the intervention is effective. Indeed, it may simply
// result in a lower level of backlash, such that not intervening is still a more rational
// strategy.
//
// With this in mind, we propose the following experiments:
//
// - *Goal:* Understand the degree to which intervention dynamics differ, at a general
//   level, between the symmetric and asymmetric models.
//
//   Estimate the effect of asymmetry for each pair of spins $S_i, S_j in S$, quantifying
//   uncertainty around the estimates by repeating the estimation process for $r in NN$ repeats.
//
// - *Goal:* Investigate how intervention strategy differs between models fit under
//   asymmetric and symmetric asummptions.
//
//   For each possible target spin $S_j$, determine the intervention spin $S_i$ for which,
//   after $t in NN$ timesteps, the average target state (across individuals) is maximal,
//   for both the asymmetric and symmetric models. This tells us which interventions
//   result in the highest rate of adoption of the desired behaviour at the target spin.
//   Compare the most effective strategies between symmetric and asymmetric models.
//
// - *Goal:* Investigate differences in intervention effectiveness between models fit
//   under asymmetric and symmetric assumptions.
//
//   For each 'most effective strategy', compare the effect of intervention with that
//   observed in the alternative assumption (e.g., if 'belief in climate change' is most
//   effective for targeting 'climate policy' in the asymmetric model, how does the
//   effect of intervention for this pair compare with that of the symmetric model?).
//
//
//
// ==== *RQ3.2*
//
// Investigating the varied impacts of intervention among different individuals, with
// different initial conditions and contextual factors.
//
// For each individual, and each pair of intervention and target spins $S_i, S_j in S$,
// estimate the expected effect of intervention in the asymmetric model by taking the
// average state of $S_j$ across repeats at time $t in NN$.
//
// Examine the distributions of expected effects of intervention across individuals for
// each pair of intervention and target spins. If we observe cases of backlash, or where
// intervention effectiveness is highly variable, investigate why this is the case.
//
// _Note:_ Should we consider all participants for these experiments, or only those who do
// not previously hold the desired belief/attitude state? For instance, interventions on
// 'belief in climate change' often show low effectiveness because most individuals are
// already marked as believing in climate change. However, how does this change for
// individuals who do not believe in climate change?
//
// Conversely, 'climate policy' is often found to be an effective intervention because
// it is a good predictor of other pro-environmental attitudes at later timesteps. However,
// the causal directionality on this relationship is incorrect (support for climate policies
// can reinforce other spins, but is fundamentally a result of these).


== Parameter estimation <subsec:methods-parameter-estimation>


For the purposes of the experiments described in the following sections, we
calibrate the parameters of the belief system model described in
@subsec:theory-nonequilibrium-belief-system-model to the climate attitudes dataset
(@sec:dataset). Here we will formally define the parameter estimation problem, and
outline how we solve this using maximum likelihood estimation. We will also discuss
the problem of fitting to probabilistically-binarised data, and how we handle sample
size uncertainty in parameter estimation.

First, let us describe the parameter estimation context. Consider a population of
$M in NN$ individuals, with a shared belief system $cal(M)$ comprising $N in NN$
beliefs or attitudes, but for which the parameters (i.e., the baseline activations
and interaction effects) are unknown. Suppose that for each individual $m in [1,M]$ we
have observed a series of measurements, reflecting $m$'s belief system state at each
of $t in [1, T]$ uniformly spaced timesteps:

$
  {bold(x)_((m))^t}_(t=1)^T, quad "where each" bold(x)_((m))^t in RR^N
$

The collection of such measurements across all individuals forms a dataset $D$. The
parameter estimation problem consists in using $D$ to identify a parameterisation
$bold(theta)^* in RR^p$ for the model $cal(M)^*$, where $p in NN$ is the number of
parameters in $cal(M)$, such that $cal(M)^*$ is (at least approximately) equal
to $cal(M)$.

Let $D_B ~ op("Bin")(D)$ be a binarisation of the dataset, with values mapped to
${-1, +1}$. Maximum likelihood estimation (MLE) chooses $bold(theta)^*$ such
that $D_B$ is most probable given the resulting model, i.e., the parameterisation
which maximises the log-likelihood:
$
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) L_(D_B) (bold(hat(theta)))
$ <eqn:methods-parameter-estimation-naive-mle>

When fitting the asymmetric belief system model to the climate attitudes dataset,
the parameters inferred using @eqn:methods-parameter-estimation-naive-mle are subject
to two sources of uncertainty: (i) due to the (possibly-stochastic) binarisation
process, and (ii) due to sampling error. We will treat these issues in turn.

Under the stochastic binarisation process described in @subsec:dataset-binarisation
data values are mapped to the ${-1, +1}$ prior to parameter estimation by first
applying gaussian noise to the original value and then thresholding the result. This
induces a probability distribution over possible binarisations. Performing MLE on
any specific binarisation $D_B ~ op("Bin")(D)$ yields a parameterisation which best
explains $D_B$, but which may not optimally explain $D$.

When the sampling distribution $op("Bin")(D)$ is known (as is the case in
@subsec:dataset-binarisation), we can avoid this issue entirely by marginalising
over the binarisation process when evaluating the log-likelihood, choosing
$bold(theta)^*$ which maximises the _expected_ log-likelihood:

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) cal(L)_D (bold(hat(theta)))
$ <eqn:methods-parameter-estimation-expected-ll-mle>

where the conditional expectation is defined in the usual way, as

$
  cal(L)_D (bold(hat(theta))) = EE[L_(D_B) (bold(hat(theta))) | cal(D) = D] = sum_(D_B) P(D_B | cal(D) = D) dot L_(D_B) (bold(hat(theta)))
$ <eqn:methods-parameter-estimation-conditional-expectation>

Secondly, while the number of beliefs and attitudes considered in the following
sections is relatively small ($N in {7,8}$), the number of model parameters
grows as $p in O(N^2)$ for both the symmetric and asymmetric belief system models.
This is roughly of the same order of magnitude as the size of the climate attitudes
dataset ($M = 1693$ individuals, $T=2$ timesteps). Therefore we expect moderate
uncertainty in $bold(theta)^*$ due to sampling error and overfitting.

To mitigate this issue, we regularise the optimisation objective function, penalising
nonzero parameters which do not meaningfully contribute to the log-likelihood. Such
parameters are thus deemed unimportant for explaining the observed data, and are pushed
to zero. We  define the $epsilon$-LASSO penalty function as
$op("lasso")_epsilon: RR^N -> RR^+$ where:

$
  op("lasso")_epsilon (bold(hat(theta))) = -lambda sum_(theta in bold(hat(theta))) sqrt(theta^2 + epsilon)
$ <eqn:methods-parameter-estimation-smooth-lasso>

where the hyperparameter $lambda in RR^+$ moderates regularisation strength.
@eqn:methods-parameter-estimation-smooth-lasso has a well-defined first
derivative for $epsilon > 0$, and as $epsilon -> 0^+$ converges to the
standard LASSO penalty.

We include the $epsilon$-LASSO penalty as an extra summand in the objective function.
This counteracts overfitting by requiring parameters to be sufficiently
supported only are nonzero, but which apply a variation of LASSO regularisation during
parameter estimation, which penalises non-zero parameters which do not meaningfully
contribute to the likelihood.

In combination, these solutions _remove_ the uncertainty in parameter estimates which
arises from stochastic binarisation, and _reduce_ the uncertainty due to sampling error.
We obtain our parameter estimation solution as $bold(theta)^*$ such that

$
  bold(theta)^* = op("argmax", limits: #true) { cal(L)_D (bold(hat(theta))) - lambda sum_(theta in bold(hat(theta))) sqrt(theta^2 + epsilon) quad : quad bold(hat(theta)) in RR^p}
$

The exact forms of the expected log-likelihood and its derivatives with respect
to each parameter type for the asymmetric belief system model are states here
without derivation. Derivation details are (*TODO*) included in the appendix. For
$bold(theta) = chevron bold(J), bold(h) chevron.r$, where $bold(J) in RR^(N times N)$
is the pairwise interaction matrix and $bold(h) in RR^N$ is the vector of baseline
activations:

$
  cal(L)_D (bold(theta)) = sum_(m=1)^M sum_(t=1)^T sum_(bold(s) in plus.minus 1^N) P(D_((m))^t = bold(s) | cal(D) = D) sum_(i=1)^N EE[D_((m),i)^(t+1)] h_i^"eff" (bold(s)) - log 2 cosh (h_i^"eff" (bold(s)))
$

=== Hyperparameters <subsubsec:methods-parameter-estimation-hyperparameters>

For the purposes of this study we will consider parameters with
magnitude less than $10^(-2)$ as 'effectively zero'. We choose $epsilon = 10^(-8)$ such
that $sqrt(epsilon)$ is significantly smaller than this threshold, and thus
@eqn:methods-parameter-estimation-smooth-lasso remains a good approximation to the
standard formulation.

We use the Extended Bayesian Information Criterion (EBIC, @eqn:methods-ebic)
@chenExtendedBayesianInformation2008 to select $lambda$,
as recommended in #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose").
The EBIC is an evaluative criterion for model selection, which balances maximisation of
the log-likelihood with model complexity, as measured by the number of parameters.
Compared to the original Bayesian Information Criterion, EBIC tends to be more
conservative when the number of parameters and observatons are comparable
@foygelExtendedBayesianInformation2010. We select $lambda$ which minimises the
EBIC for the symmetric and asymmetric models (independently), the results of which
are displayed in @fig:methods-regularisation-ebic.

#figure(
  image(
    "../results/figures/model_fit/regularisation_ebic.pdf",
  ),
  caption: caption(
    short: [Regularisation strength EBIC],
    long: [*TODO*],
  ),
) <fig:methods-regularisation-ebic>














*Rough plan:*

1. We estimate parameters using maximum likelihood estimation.

2. Naïve maximum likelihood estimation identifies parameterisaion $bold(theta)^*$ such that

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) cal(L)_(D_B) (bold(hat(theta)))
$

for a binarisation $D_B ~ op("Bin")(D)$, where
$cal(L)_(D_B) (bold(hat(theta))) = log P(D_B | bold(hat(theta)))$. This is subject
to two sources of uncertainty: (i) due to sample size, and (ii) due to fitting to the
particular binarisation $D_B$.

3. We introduce measures to counteract each of these forms of uncertainty. First, we
  apply regularisation to counteract sample size uncertainty. Second, we marginalise
  over all possible binarisations of the dataset.

4. We instead choose $bold(theta)^*$ such that

$
  bold(theta)^* = op("argmax", limits: #true) { bb(E)_(D_B)[cal(L)_(D_B) (bold(hat(theta))) | cal(D) = D] - sum_(theta in bold(hat(theta))) sqrt(theta^2 + epsilon) quad : quad bold(hat(theta)) in RR^p}
$

The first term is the expected log-likelihood of a binarised dataset given the candidate
parameterisation $bold(hat(theta))$:

$
  bb(E)_(D_B)[cal(L)_(D_B) (bold(hat(theta))) | cal(D) = D] = sum_(D_B) P(op("Bin")(D) = D_B | cal(D) = D) dot cal(L)_(D_B) (bold(hat(theta)))
$

and the second term is a variation on L1 regularisation, for which the first derivative
is continuous, and thus amenible to gradient-based optimisation. We choose $epsilon$
small, such that this remains a good approximation to the standard formulation of L1
regularisation.

#line(length: 100%)

#rect()[
  *Note:* this section was written prior to the above plan. I think it spends too much
  time on the non-marginalised log-likelihood derivation, so I'm considering moving this
  to the appendix, and keeping this section short.
]

// *TODO:* There are a couple of other things to discuss here, which I am still working on.
// Notably:
// + That time-series observations are required to infer self-interaction effects, and
// + That attempting to do non-conditional maximum likelihood estimation also fails with
//   cross-sectional data, because the problem is underdetermined (we have more unknowns
//   than observables).

For a collection of observations $D$ drawn from a system assumed to be described
by a model $cal(M)$ with $p in NN$ parameters, but for which the true parameter
values are unknown, parameter estimation is the task of inferring the
parameterisation responsible for generating $D$. For the purposes of this study
we use maximum likelihood estimation to identify the belief system model
parameterisation which maximises the likelihood of the observed data.

First, let us formally outline the setting. We consider a population of $M in NN$
individuals, assumed to share a common belief system $cal(M)$ comprising $N in NN$
spins (beliefs and attitudes). Suppose that for each individual we have observed the
(possibly continuous) states of their beliefs and attitudes at each of $Q in NN$
uniformly-spaced points in time:

$
  D = [{bold(x)_(1)^t}_(t=1)^Q, ..., {bold(x)_(M)^t}_(t=1)^Q]
$ <eqn:methods-parameter-estimation-dataset>

from which we have sampled a binarised dataset:

$
  D_B = [{bold(s)_(1)^t}_(t=1)^Q, ..., {bold(s)_(M)^t}_(t=1)^Q] ~ op("Binarise")(D)
$ <eqn:methods-parameter-estimation-dataset>

For the time being will consider the task of parameter estimation with respect to the
particular binarisation $D_B$, but will return to the more general problem of
estimating parameters with respect to $D$ itself in (reference section on marginalised
MLE optimisation).

Given a parameterisation $bold(hat(theta)) in RR^p$ for $p in NN$ model parameters, the
_likelihood_ of $D_B$ given $bold(hat(theta))$ is:

$
  L_(D_B)(bold(hat(theta))) &= P(cal(D) = D_B | bold(Theta) = bold(hat(theta))) \
  &= product_(m=1)^M P_({bold(S)_(m)^t}|bold(Theta)) ({bold(s)_(m)^t}_(t=1)^Q | bold(hat(theta))) \
  &= product_(m=1)^M P_(bold(S)_m^1 ... bold(S)_m^Q|bold(Theta)) (bold(s)_m^1, ..., bold(s)_m^Q | bold(hat(theta))) \
  &= product_(m=1)^M product_(t=1)^Q P_(bold(S)_m^t|bold(S)_m^1 ... bold(S)_m^(t-1) bold(Theta))(bold(s)_m^t | bold(s)_m^1, ..., bold(s)_m^(t-1), bold(hat(theta))) \
  &= product_(m=1)^M P_(bold(S)_m^1 | bold(Theta)) (bold(s)_m^1 | bold(hat(theta)))product_(t=1)^Q P_(bold(S)_m^t|bold(S)_m^(t-1) bold(Theta))(bold(s)_m^t | bold(s)_m^(t-1), bold(hat(theta))) #h(2em) (*) \
  &= P_0(D_B) product_(m=1)^M product_(t=1)^Q P_(bold(S)_m^t|bold(S)_m^(t-1) bold(Theta))(bold(s)_m^t | bold(s)_m^(t-1), bold(hat(theta))) \
$

where $P_0(D_B) = product_(m=1)^M P(bold(S)_m^1 = bold(s)_m^1)$ is a pre-specified
initial condition which is independent of the parameterisation, and $(*)$ follows
from the Markov assumption in our belief system model.

Maximum likelihood estimation identifies the parameterisation
$bold(theta)^* in RR^p$ which maximises the likelihood. In practice, however,
to avoid potential numerical instability in evaluating $L_(D_B)(bold(hat(theta)))$,
arising from the multiplication of many small conditional probabilities, we instead
maximise the _log-likelihood_:

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) cal(L)_(D_B)(bold(hat(theta)))
$ <eqn:methods-parameter-estimation-mle-problem>

Where $cal(L)_(D_B)(bold(hat(theta))) &= log L_(D_B)(bold(hat(theta)))$ is given by

$
  cal(L)_(D_B)(bold(hat(theta))) &= sum_(m=1)^M sum_(t=1)^Q log P(bold(S)_m^t = bold(s)_m^t | bold(S)_m^(t-1) = bold(s)_m^(t-1), bold(Theta) = bold(hat(theta)))
$ <eqn:methods-parameter-estimation-log-likelihood-abstract>

We omit $P_0(D_B)$ from
@eqn:methods-parameter-estimation-log-likelihood-abstract since it is independent
of $bold(hat(theta))$ and therefore does not affect the value of $bold(theta)^*$.

Substituting the conditional transition probability from
@eqn:methods-model-conditional-prob-definition, we obtain a concrete form for the
log-likelihood:

$
  cal(L)_(D_B)(bold(hat(theta))) &= sum_(m=1)^M sum_(t=1)^Q log(product_(i=1)^N P_(bold(Theta) = bold(hat(theta)))(S_(i, (m))^t = s_(i, (m))^t | S_(i, (m))^t = s_(i, (m))^t)) \
  &= sum_(m=1)^M sum_(t=1)^Q sum_(i=1)^N log P_(bold(Theta) = bold(hat(theta)))(S_(i, (m))^t = s_(i, (m))^t | S_(i, (m))^t = s_(i, (m))^t) \
  &= sum_(m=1)^M sum_(t=1)^Q sum_(i=1)^N log[exp(s_(i, (m))^t dot h_i^"eff" (bold(s)_(m)^(t-1)))/(exp(h_i^"eff" (bold(s)_(m)^(t-1))) + exp(-h_i^"eff" (bold(s)_(m)^(t-1))))] \
  &= sum_(m=1)^M sum_(t=1)^Q sum_(i=1)^N log[exp(s_(i, (m))^t dot h_i^"eff" (bold(s)_(m)^(t-1)))/(2 cosh(h_i^"eff" (bold(s)_m^(t-1))))] \
  &= sum_(m=1)^M sum_(t=1)^Q sum_(i=1)^N s_(i, (m))^t dot h_i^"eff" (bold(s)_(m)^(t-1)) - log(2 cosh h_i^"eff" (bold(s)_m^(t-1))) \
$ <eqn:methods-parameter-estimation-log-likelihood-exact>

where $h_i^"eff" (bold(s))$ is the effective baseline activation
(@eqn:methods-model-local-energy-eff-field), and the reduction of the denominator
follows from the identity $cosh(x) = (e^(x) + e^(-x))/2$, as also used in
@nguyenInverseStatisticalProblems2017.

@eqn:methods-parameter-estimation-mle-problem is maximised when
$(partial cal(L)_(D_B))/(partial hat(theta)_i)(bold(hat(theta))) = 0$ for each parameter
$theta_i$. Recall that the model defined in
@subsec:theory-nonequilibrium-belief-system-model includes two kinds of parameters:
baseline activations $h_i$ and influence effects $J_(j i)$, such that
$bold(hat(theta)) = chevron bold(h), bold(J) chevron.r$. The partial derivative
of the log-likelihood with respect to an arbitrary parameter $theta$ in $bold(h)$ or
$bold(J)$ is:

$
  (partial cal(L)_(D_B) (bold(hat(theta))))/(partial theta) = sum_(m=1, t=1, n=1)^(M,Q,N) ...
$


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
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) {cal(L)_D (bold(hat(theta))) - lambda sum_(i=1)^p |hat(theta)_i|}
$ <eqn:methods-regularisation-mle-problem>

This has the effect of penalising non-zero parameters with negligible contribution to
the log-likelihood. The parameter $lambda in RR^+$ controls regularisation strength,
with larger values resulting in sparser models.

This formulation of LASSO regularisation has a discontinuous first-derivative at
#box[$hat(theta)_i = 0$] due to the absolute value function. Instead, we use the following
smooth variation, where $epsilon in RR^+$:

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) lr({cal(L)_D (bold(hat(theta))) - lambda sum_(i=1)^p sqrt(hat(theta)_i^2 + epsilon)})
$ <eqn:methods-smooth-regularisation-mle-problem>

@eqn:methods-smooth-regularisation-mle-problem converges to
@eqn:methods-regularisation-mle-problem as $epsilon -> 0^+$, and has a well-defined
first-derivative for $epsilon > 0$, namely:

$
  dif/(dif hat(theta)_i) (- lambda sum_(j=1)^p sqrt(hat(theta)_j^2 + epsilon)) = (lambda hat(theta)_i)/(sqrt(hat(theta)_i^2 + epsilon))
$

For the purposes of this study, we will consider parameters as 'effectively non-zero'
if their magnitude exceeds $10^(-2)$. We thus choose $epsilon = 10^(-8)$, such that
$sqrt(epsilon)$ is two orders of magnitude smaller than the minimal parameter size
of interest, ensuring that @eqn:methods-smooth-regularisation-mle-problem is a
reasonable approximation to @eqn:methods-regularisation-mle-problem for parameter
values smaller than $10^(-2)$.


- Effects: How does regularisation affect sparsity? (In progress; planning a different figure)

#figure(
  image(
    "../results/figures/methods/regularisation_sparsity.pdf",
  ),
  caption: caption(
    short: [Effect of regularisation on model sparsity],
    long: [
      Model sparsity increases with regularisation strength ($lambda$). Error bars display
      95% confidence intervals around expected number of non-zero parameters, measured
      across different stochastic binarisations of observed data.
    ],
  ),
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
  op("EBIC")(bold(theta)^*) = k dot [ln(n) + 2 gamma ln(p)] - 2cal(L)_D (bold(theta)^*)
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
  caption: caption(
    short: [Regularisation strength EBIC],
    long: [*TODO*],
  ),
)

// === Replicated binarisation <subsubsec:marginalising-binarisation>
//
//
// - Two sources of uncertainty in parameter estimates: sample size and binarisation
// - Given fixed dataset, distribution over binarised datasets is fixed --> can marginalise
//   over binarisation to get expected _maximum_ likelihood given dataset. Removes the
//   uncertainty due to binarisation. Variance decreases as $S/sqrt(n)$.
// - Re-frame log-likelihood using the conditional probability of spin $s$ given
//   binarisation of the original value $x$.
// - Can improve on the estimated log-likelihood by doing monte carlo samples of the
//   LL.
// - Show improvement to variance. MLE recovers parameters which maximise the expected
//   LL given binarisation of the original dataset.
//
// == Toy models (?)



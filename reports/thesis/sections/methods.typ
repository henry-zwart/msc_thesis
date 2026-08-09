#import "@local/drifting-cls-thesis:0.1.0": caption
#import "@preview/zero:0.6.1": num

#import "@preview/algorithmic:1.0.7"
#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm

#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

// TODO:
// - Parameter estimation: Discussion on why we can't estimate from cross-sectional data,
//   even when excluding self-loops.
//   - If we could, this would simplify dataset. Wouldn't need to rely on repeating
//     participants.

// == Plan
//
//
// - Counterfactual intervention experiments --- comparing against the no-intervention
//   scenario, measuring differences in effects.
// - Parameter estimation via MLE:
//   - Marginalising over binarisation process
//   - Regularisation


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

// #algorithm-figure(
//   [Measure spin state],
//   vstroke: .5pt + luma(200),
//   {
//     import algorithmic: *
//     let glauber = Call.with("SampleGlauber")
//     Function(
//       "Measure-Spin-State",
//       ([$bold(s)_0$], [$j$], [$cal(M)$], [$Q$], [rng]),
//       {
//         Assign[$bold(s)$][$bold(s)_0$]
//         For($1 <= t <= Q$, {
//           Assign([$bold(s)$], glauber($cal(M), bold(s), "rng"$))
//         })
//
//         Return[$bold(s)[j]$]
//       },
//     )
//   },
// )
//
// #algorithm-figure(
//   [Effect of Intervention ($S_i -> S_j$)],
//   vstroke: .5pt + luma(200),
//   {
//     import algorithmic: *
//     Procedure(
//       "Effect-of-Intervention",
//       ([$cal(M)$], [$i$], [$j$], [$delta_h$], [$Q$], [$bold(x)_0$], [$"rng"$]),
//       {
//         Assign([$cal(M)_"int"$], FnInline[Intervene][$cal(M), delta_h, i$])
//         Assign([$bold(s)_0$], FnInline[Binarise][$bold(x)_0, "rng"$])
//         LineBreak
//
//         Comment[Clone RNG for identical intervention & null contexts]
//         Assign([$"rng"_"null"$], FnInline[Clone][rng])
//         Assign([$"rng"_"int"$], FnInline[Clone][rng])
//         LineBreak
//
//         Assign([$s_"null"$], CallInline[Measure-Spin-State][$bold(s)_0, j, cal(M), Q, "rng"_"null"$])
//         Assign([$s_"int"$], CallInline[Measure-Spin-State][$bold(s)_0, j, cal(M)_"int", Q, "rng"_"int"$])
//         LineBreak
//
//         Return[$s_"int" - s_"null"$]
//       },
//     )
//   },
// ) <algo:methods-effect-of-intervention>
//



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

== Soft Binarisation <subsec:dataset-binarisation>

Prior to model fitting, we binarise all variables, mapping data values to the
domain ${-1, +1}$. Before binarising, we shift each variable such that the _survey
midpoint_ (e.g., '3' on a 5-point Likert scale) aligns with 0, and rescale each
variable such that the minimum and maximum possible values map to $-1$ and $+1$
respectively.
For variables with no well-defined midpoint, such as those with an even
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
  caption: caption(
    short: [Binarisation using gaussian noise with thresholding],
    long: [
      $x in RR$ is smoothly binarised to ${-1, +1}$ by
      thresholding #box[$x' = (x + epsilon)$] where $(x + epsilon) ~ cal(N)(x, sigma)$. Negative values
      are mapped to $+1$ with probability #box[$P(x' > 0) = "A" = "B" = P(epsilon < x)$], which
      increases with $sigma$ and $|x|^(-1)$.
    ],
  ),
  placement: auto,
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
#footnote[
  The oppose/support 7-point Likert scale has possible responses: strongly oppose,
  oppose, weakly oppose, neutral, weakly support, support, strongly support.
] <fn:likert-7-scale-responses>
(value $1\/3$) is mapped to $+1$ with probability 0.05.

#figure(
  image("../results/figures/dataset/likert_7_binarisation_probability.pdf"),
  placement: auto,
  caption: caption(
    short: [Likert-7 binarisation distribution],
    long: [
      The probability of binarisation to $+1$ for each possible response to a Likert-7
      scale survey question@fn:likert-7-scale-responses, given
      $sigma approx #calc.round(binarisation_sigma, digits: 1)$.
    ],
  ),
)



== Parameter estimation <subsec:methods-parameter-estimation>


// - Introduce section; derivations can be found in the appendix
// - Describe parameter estimation problem
// - We choose $bold(theta)^*$ such that ... (state objective function)
// - Elaborate on the components of the objective function:
//   - Expected log-likelihood --- avoid overfitting model to any particular binarisation
//   - Regularisation --- mitigate sampling error uncertainty
// - Objective function is maximised when derivatives are zero --- give the derivatives
// - Hyperparameters: subsection on how we choose values
// - Technical model-fitting details: optimisation algorithm, settings

For the purposes of the experiments in the following sections, we perform parameter
estimation to calibrate the belief system model described in
@subsec:theory-nonequilibrium-belief-system-model to the climate beliefs dataset
(@sec:dataset). We first outline the context of the parameter estimation problem,
and then present our approach. We omit derivation details in this section;
however, the curious reader can find these in Appendix A (*TODO*).

Consider a population of
$M in NN$ individuals with a shared belief system $cal(M)$ comprising $N in NN$
beliefs with pre-defined adjacency matrix $bold(A) in {0,1}^(N times N)$,
for which the parameters (i.e., the baseline activations and interaction effects) are
unknown. Suppose that for each individual $m in [1, M]$ we have observed a series of
measurements, reflecting that individual's belief system state at each of $t in [1, T]$
uniformly spaced timesteps:

$
  {bold(x)_((m))^t}_(t=1)^T, quad "where each" bold(x)_((m))^t in RR^N
$

The measurements need not be binary, but are assumed to be real. The collection of
measurements across all individuals forms a dataset $D$, which is the particular
observed value of the random variable $cal(D)$ representing possible datasets.


While maximum likelihood estimation (MLE) is often used to infer
parameters for similar models @nguyenInverseStatisticalProblems2017
@leeStatisticalMechanicsUS2015, we should be cautious, for two reasons, of applying this method naïvely
in the present study.

Firstly, the model defined in @eqn:model-kbs-dynamics assumes
binary spin states $s in {-1, +1}$. The climate beliefs dataset does not satisfy this
assumption and must be binarised for MLE to be applicable. However, we have no
guarantee that the parameterisation inferred for any specific binarisation is a
reasonable explanation for the non-binarised dataset, nor for any other possible
binarisation in the case where a probabilistic binarisation scheme is used (such as
the one described in @subsec:dataset-binarisation).

// - Formally, can say that any specific binarisation $D_B ~ op("Bin")(D)$ and
//   model $cal(M)$ estimated from $D_B$:
//
// $
//   I(D; cal(M)) <= I(D_B; cal(M))
// $
//
// - And this inequality is strict when $op("Bin")(D)$ is not constant.

Secondly, maximum likelihood estimation is prone to overfitting when the number of
model parameters is similar to the number of observations
@epskampEstimatingPsychologicalNetworks2018. While we consider only a small number of
beliefs in this study ($N in {7,8}$), the number of parameters $p$ grows
rapidly, with $p in O(N^2)$ for both the symmetric and asymmetric model variants. In
combination with sampling error, we expect the number of parameters to negatively
impact the robustness of the inferred parameters---given an alternative dataset of
the same size, we would expect significant variation in parameters.

We mitigate these respective issues in our parameter estimation scheme by
(i) marginalising over the set of possible binarisations of $D$, and (ii) applying
regularisation based on parameter magnitudes. We choose the parameterisation
$bold(theta)^* in RR^p$ which satisfies the optimisation problem:

// TODO: Add dependence on lambda and epsilon

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) f(D; bold(hat(theta))), quad "where" quad
  f(D; bold(hat(theta))) := cal(L)_D (bold(hat(theta))) - lambda sum_(theta in bold(hat(theta))) sqrt(theta^2 + epsilon) quad
$ <eqn:methods-parameter-estimation-optimisation-problem>

The first term in the objective function $f$, $cal(L)_D (bold(hat(theta)))$, denotes the _expected_ log-likelihood
given a parameterisation $bold(hat(theta))$, over possible binarisations of $D$:

$
  cal(L)_D (bold(hat(theta))) = EE[L_(D_B) (bold(hat(theta))) | cal(D) = D] = sum_(D_B) P(op("Bin")(cal(D)) = D_B | cal(D) = D) dot L_(D_B) (bold(hat(theta)))
$ <eqn:methods-parameter-estimation-conditional-expectation>

where $L_(D_B) (bold(hat(theta)))$ is the log-likelihood of a specific binarisation
$D_B$. We will defer explicitly defining $L_(D_B) (bold(hat(theta)))$ for now, but will
return to this point shortly in @eqn:methods-parameter-estimation-log-likelihood.

// *TODO:* Intuition for the effect of using the expectation.
// - When the likelihood given one binary state would be significantly higher than for the
//   other, this is downweighted to account for the probability that the value does not
//   obtain this state.
// - Therefore the expectation prevents overconfident optimisation toward any specific
//   binarisation --- the inferred model is required to explain the binarised dataset
//   _in expectation_.
// Also:
// - What does it mean at the extremes (hard thresholding, fully-random thresholding)?
// - What does it imply for values near zero in soft thresholding?
// - How does it compare to MLE with hard or soft thresholding?



By using the expected likelihood in place of the likelihood, the inferred model reflects
the level of certainty or ambiguity present in the dataset. Consider that when using MLE,
a neutral survey response (with value $0$) must first be binarised to either $+1$ or $-1$.
Supposing (without loss of generality) that the response is
mapped to $+1$, this erases information which may be important, since this observation
is now no longer distinguishable from those which are truly positive. When using the
expected likelihood, however, each observation's contribution to the objective function
is an expectation over the possible binarisations. Values close to zero contribute
comparable weightings from each binary state. Consequently, for values which may be
binarised to $-1$ _and_ $+1$ with non-trivial probability, both cases should be
reasonably explained by the inferred model.


The second term is a smooth variant of L1 regularisation
@tibshiraniRegressionShrinkageSelection1996. This has the effect of penalising
nonzero parameters which do not meaningfully contribute to the expected likelihood.
Parameters instead must reflect relationships which are sufficiently prevalent in the
data, reducing the robustness issues resulting from sampling error and a large
number of parameters. The hyperparameter $lambda in RR^+$ controls regularisation strength,
with higher values resulting in sparser models. As $epsilon -> 0^+$ the second term
converges to the standard formulation of L1 regularisation. Unlike the standard
formulation, when $epsilon > 0$ the first-derivative of this term
exists, so is amenible to gradient-based optimisation. We discuss the choice of
values for $lambda$ and $epsilon$ in
@subsubsec:methods-parameter-estimation-hyperparameters.

Let $D_B ~ op("Bin")(D)$ be a possible binarisation of $D$, and $bold(theta)$ a
parameterisation for the (asymmetric or symmetric) belief system model, which is
decomposable into the model parameters
$bold(theta) = chevron bold(J), bold(h) chevron.r$. The log-likelihood of $D_B$ given
$bold(theta)$ is:

$
  L_(D_B) (bold(theta)) &= log P(D_B | bold(theta)) \
  //&= sum_(m=1)^M sum_(t=1)^(T - 1) sum_(i=1)^N log P(s_(i, (m))^(t+1) | bold(s)_((m))^t, bold(theta)) \
  &= sum_(m=1)^M sum_(t=1)^(T - 1) log s_(i, (m))^(t+1) dot h_i^"eff" (bold(s)_((m))^t) - log(2 cosh h_i^"eff" (bold(s)_((m))^t))
$ <eqn:methods-parameter-estimation-log-likelihood>

The derivation of @eqn:methods-parameter-estimation-log-likelihood is analogous to that
of the non-equilibrium Ising model log-likelihood @nguyenInverseStatisticalProblems2017.
Combining @eqn:methods-parameter-estimation-log-likelihood and
@eqn:methods-parameter-estimation-conditional-expectation, we obtain an explicit
expression for the expected likelihood:

// $
//   cal(L)_D (bold(theta)) &= sum_(m=1)^M sum_(t=1)^(T-1) sum_(bold(s)^t) P(bold(S)_((m))^t = bold(s)_((m))^t | cal(D) = D) sum_(i=1)^N EE[S_(i, (m))^(t+1)] dot h_i^"eff" (bold(s)^t) - log(2 cosh h_i^"eff" (bold(s)^t))
// $

$
  cal(L)_D (bold(theta)) = sum_(bold(s)) lr((sum_(m=1)^M sum_(t=1)^(T-1) P(bold(S)_((m))^t = bold(s) | D) dot EE[bold(S)_((m))^(t+1) | D]^T h^"eff" (bold(s)))) - Z(D; bold(theta))
$ <eqn:methods-parameter-estimation-expected-ll-explicit>

where $EE[bold(S)_((m))^(t+1) | D]$ is the expected binary configuration for the
observation $bold(x)_((m))^(t+1)$, the vector $h^"eff" (bold(s))$ contains the
effective baseline activation for each spin given the previous state $bold(s)$, and $Z$
is the expected log partition function, summed across observations:

$
  Z(D; bold(theta)) = sum_(bold(s)) sum_(m <= M \ t < T) P(bold(S)_((m))^t = bold(s) | D) sum_(i=1)^N log(2 cosh h_i^"eff" (bold(s)))
$ <eqn:methods-parameter-estimation-expected-partition-function>

Per the optimisation problem defined in
@eqn:methods-parameter-estimation-optimisation-problem, we choose the parameterisation
$bold(theta)^*$ which maximises the regularised expected log-likelihood, which occurs
when #box[$(partial f)/(partial theta) = 0$] for every parameter $theta in bold(theta)^*$.
The partial derivative with respect to a given baseline activation parameter $h_i$, for
$i in [1,N]$, is given by:

$
  partial/(partial h_i) f(D; bold(theta)) = &sum_(bold(s)) sum_(m <= M\ t < T) P(bold(S)_((m))^t = bold(s) | D) lr([EE[S_(i, (m))^(t+1) | D] - tanh(h_i^"eff" (bold(s)))]) \ &- (lambda h_i)/sqrt(h_i^2 + epsilon)
$ <eqn:methods-parameter-estimation-derivative-baseline-activation>


Note that the expressions for $cal(L)_D (bold(theta))$ and
$partial/(partial h_i) f(D; bold(theta))$ are applicable to both the asymmetric and
symmetric belief system models. This property does not hold for the partial derivatives
with respect to interaction effects. In the asymmetric model, for $i, j in [1, N]$,
this is derived analogously to
@eqn:methods-parameter-estimation-derivative-baseline-activation as:

$
  partial/(partial J_(j i)) f(D; bold(theta)) = &sum_(bold(s)) sum_(m <= M\ t < T) P(bold(S)_((m))^t = bold(s) | D) s_j lr([EE[S_(i, (m))^(t+1) | D] - tanh(h_i^"eff" (bold(s)))]) \ &- (lambda J_(j i))/sqrt(J_(j i)^2 + epsilon)
$ <eqn:methods-parameter-estimation-derivative-interaction-effect-asym>

In the symmetric belief system model, since we require that $bold(J) = bold(J)^T$, we
estimate a single interaction parameter $J_(j i) = J_(i j) = beta_({i,j})$ for each
pair of spins $S_i, S_j$. Each pair thus contributes twice to the partial derivative,
once for each direction:

$
  partial/(partial beta_({i,j})) f(D; bold(theta)) = &sum_(bold(s)) sum_(m <= M\ t < T) P(bold(S)_((m))^t = bold(s) | D) sum_((i',j') in {i, j}) A_(j' i') s_(j') lr([EE[S_(i', (m))^(t+1) | D] - tanh(h_(i')^"eff" (bold(s)))]) \ &- (lambda beta_({i,j}))/sqrt(beta_({i, j})^2 + epsilon)
$ <eqn:methods-parameter-estimation-derivative-interaction-effect-sym>

=== Hyperparameters <subsubsec:methods-parameter-estimation-hyperparameters>

The optimisation problem in @eqn:methods-parameter-estimation-optimisation-problem
has two hyperparameters which must be specified prior to parameter estimation: the
regularisation strength $lambda in RR^+$, and the smoothing parameter $epsilon in RR^+$.
The values for both are summarised in @tab:methods-hyperparameter-values.

#let regularisation_strengths = json("../results/data/model_fit/optimised_regularisation.json")

#figure(
  table(
    columns: 4,
    stroke: none,
    table.header[Parameter][Model type][Dataset][Value],
    table.hline(stroke: 0.5pt),
    [$lambda$],
    [Symmetric],
    [Full],
    [#num(exponent: "sci")[#calc.round(regularisation_strengths.sym_ising.full, digits: 3)]],
    [], [Asymmetric], [Full], [#num(exponent: "sci")[#calc.round(regularisation_strengths.ising.full, digits: 3)]],
    [],
    [],
    [Conservative],
    [#num(exponent: "sci")[#calc.round(regularisation_strengths.ising.conservative, digits: 3)]],
    [], [], [Liberal], [#num(exponent: "sci")[#calc.round(regularisation_strengths.ising.liberal, digits: 3)]],
    [$epsilon$], [All], [All], [$10^(-8)$],
  ),
  caption: caption(
    short: [Hyperparameter values],
    long: [
      Values for regularisation strength ($lambda$) and smoothing ($epsilon$)
      hyperparameters. Regularisation strength model- and dataset-specific;
      _Conservative_ and _Liberal_ refer to subsets of the climate beliefs dataset
      comprising individuals with the specified ideology (@sec:dataset).
    ],
  ),
  placement: auto,
) <tab:methods-hyperparameter-values>

We consider parameters with magnitude less than $10^(-2)$ as 'effectively zero', and
take #box[$epsilon = 10^(-8)$] such that $sqrt(epsilon)$ is significantly smaller than this
threshold. This choice of $epsilon$ ensures that the smooth regularisation remains a
good approximation to L1 regularisation, i.e.,

$
  sqrt(theta^2 + epsilon) approx |theta|
$ <eqn:methods-parameter-estimation-hyperparameters-L1-approximation>


We use the Extended Bayesian Information Criterion (EBIC)
@chenExtendedBayesianInformation2008 to select $lambda$,
as recommended by #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose"):

// $
//   op("EBIC")(bold(theta)^*) = k dot [ln(M(T-1)) + 2 gamma ln(p)] - 2cal(L)_D (bold(theta)^*)
// $ <eqn:methods-ebic>

$
  op("EBIC")(bold(theta)^*) = overbracket(k ln q - 2 cal(L)_D (bold(theta)^*), op("BIC")(bold(theta)^*)) + 2 k dot gamma ln p
$ <eqn:methods-ebic>

#let ebic-footnote = footnote[
  Note that this is different from the prior used in the BIC, which is uniform over
  the entire space of models. The prior in the EBIC, for $gamma = 1$, is uniform only
  within each class of models containing $k$ parameters.
]

The variable $k$ denotes the number of (effectively) nonzero parameters in the optimised
model. The point of difference between the EBIC and the standard Bayesian Information
Criterion (BIC) is in their assumed priors over the space of possible models. While the
BIC assumes a uniform prior, the EBIC penalises values of $k$ which permit a large number
of models @foygelExtendedBayesianInformation2010 @barberHighdimensionalIsingModel2015.
For instance, the class of models comprising eight spins (i.e., with 72 parameters)
contains considerably fewer models with 10 parameters ($5.4 times 10^11$) than models
with 36 parameters ($4.4 times 10^20$). In this scenario, by assuming a uniform prior,
the BIC implicitly penalises models which are too sparse, or too dense. The parameter
$gamma >= 0$ specifies the degree to which the EBIC penalises such classes of models,
with $gamma = 1$ corresponding to a uniform prior over models with $k$
parameters#ebic-footnote, for each $k in 0...p$.

#cite(<barberHighdimensionalIsingModel2015>, form: "prose") demonstrate that small,
nonzero choices of $gamma$ are sufficient to improve the accuracy of Ising model
structural inference in various contexts. We take $gamma = 0.25$, which is the minimum
value considered in their study. We then select $lambda >= 0$ which minimises the
EBIC for the symmetric and asymmetric models (independently), the results of which
are displayed in @fig:methods-regularisation-ebic.

#figure(
  image(
    "../results/figures/model_fit/regularisation_ebic.pdf",
  ),
  caption: caption(
    short: [Regularisation strength EBIC],
    long: [
      Effect of regularisation strength $lambda$ on Extended Bayesian Information
      Criterion for symmetric and asymmetric belief system models optimised to the
      climate beliefs dataset using
      @eqn:methods-parameter-estimation-optimisation-problem. The vertical axis measures
      the difference in EBIC compared to the no-regularisation case ($lambda = 0$).
    ],
  ),
  placement: auto,
) <fig:methods-regularisation-ebic>



=== Implementation details <subsubsec:methods-parameter-estimation-implementation-details>

We solve the parameter estimation problem using the Scipy 1.17.1 implementation of the
quasi-Newton BFGS optimisation algorithm @virtanenSciPy10Fundamental2020
@nocedal2006numerical[p.~136]. We use the analytic jacobian comprising the partial
derivatives stated above. We take $bold(theta) = bold(0)$ as the initial guess.

To ensure numerical stability irrespective of dataset size, we rescale the expected
log-likelihood contribution to the objective function and partial derivatives, dividing
by the number of observed observations (time intervals) in the dataset. For $M in NN$
individuals and $T in NN$ timesteps this amounts to a scale factor of $1/(M(T-1))$.


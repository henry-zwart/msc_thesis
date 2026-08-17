#import "@local/drifting-cls-thesis:0.1.0": caption
#import "./discussion.typ": internal-link
#import "./dataset.typ": climate-beliefs-variable-table
#import "@preview/zero:0.6.1": num

#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *

#show: show-theorion

// TODO:
// - Parameter estimation: Discussion on why we can't estimate from cross-sectional data,
//   even when excluding self-loops.
//   - If we could, this would simplify dataset. Wouldn't need to rely on repeating
//     participants.

In the previous chapter, we introduced the Kinetic Belief System (KBS) as a model of
belief-system structure and dynamics, that allows for asymmetric influence relations.
While the KBS model is theoretically interesting, its _empirical_ value hinges on
the ability to infer its parameters from observational data.

In this chapter, we provide a method for doing just this, based on maximum likelihood
estimation. This task turns out to be not so straightforward, due to the mismatch between the
binary representation of beliefs assumed by the KBS model and typical approaches for
assessing beliefs in surveys.
// We then use this method to calibrate symmetric and
// asymmetric KBS models to a longitudinal dataset comprising beliefs about climate
// change. These models are used for the experiments in the second half of this study.
We omit derivation details in this chapter; however, the curious reader can find these
in @sec:appendix-derivations.

== The problem with maximum likelihood estimation <sec:parameter-estimation-two-problems>

Given a dataset $D$ and a parameterisable model with $p in NN$ parameters, maximum
likelihood estimation (MLE) seeks the parameterisation $bold(theta)^* in RR^p$ which
maximises the probability of observing $D$ under the model, also known as the likelihood:

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(theta) in RR^p) P(D | bold(theta))
$ <eqn:parameter-estimation-mle>

MLE is often used for parameter estimation in similar modelling situations
@nguyenInverseStatisticalProblems2017 @leeStatisticalMechanicsUS2015. It has a
significant drawback, however, in that it assumes that the observations in the
dataset $D$ are representable within the model. This poses a problem when calibrating
binary belief-system models---such as the KBS model---using survey data, which often
describes belief states with multi-valued (e.g., Likert) scales. To use
MLE in such situations, we must first binarise the observations to the set ${-1, +1}$.

There are several approaches to binarising continuous values; the simplest,
which we will call *sign-thresholding*, is to map values to ${-1, +1}$ according to
their sign. Zero must be handled separately, for instance, using a deterministic
rule (e.g., $0 mapsto +1$) or a Bernoulli random variable. This produces discontinuous
behaviour around the zero point, which may be unrealistic in the present context. If we are
treating zero as an ambivalent or neutral belief state that can be mapped to either $-1$
or $+1$, we should arguably also treat small-magnitude positive or negative values
similarly.

#let scale-choice-footnote = footnote[
  The specific choice of $xi$ is important. As $xi -> 0^+$, the soft thresholding
  function converges to the simple ('hard') thresholding function where zero is mapped
  using a $op("Bernoulli")(0.5)$ random variable. As
  $xi -> infinity$, we approach a function which maps _all_ values randomly in this
  way. Appropriate values are context-dependent, based on the
  range of values which are considered 'near-neutral'.
]

#{
  [
    We can improve the situation by using *soft thresholding*, in which each data value $x in RR$
    is perturbed by an independent noise term $epsilon ~ cal(N)(0, xi)$ prior to this
    mapping. @fig:methods-binarisation illustrates this process for a negative value of $x$
    and a specified $xi in RR_+$.#scale-choice-footnote <scale-choice-footnote>
  ]
}
<sec:parameter-estimation-soft-binarisation>

#figure(
  image(
    "../results/figures/methods/binarisation/distribution.pdf",
    width: 65%,
  ),
  caption: caption(
    short: [Soft thresholding],
    long: [
      Soft thresholding maps $x in RR$ to ${-1, +1}$ by sign-thresholding
      #box[$x' = (x + epsilon)$] where $(x + epsilon) ~ cal(N)(x, xi)$. Negative
      values are mapped to $+1$ with probability
      #box[$P(x' > 0) = "A" = "B" = P(epsilon < x)$], which increases with $xi$ and
      $|x|^(-1)$.
    ],
  ),
  placement: none,
) <fig:methods-binarisation>

#let smooth-thresholding-derivation = footnote[
  See derivation in @sec:appendix-derivations
  (#internal-link(<derivation:smooth-thresholding>)).
]

Observe that $x$ is mapped to $+1$ if, and only if, $epsilon$ is sufficiently large,
such that #box[$x + epsilon > 0$] (region A), or equivalently, when $epsilon < x$ (region B).
The probability that $x$ is mapped to $+1$ is then:#smooth-thresholding-derivation

$
  P(x mapsto +1) = Phi(x/xi)
$ <eqn:methods-dataset-binarisation-probability-map-to-1>

where $Phi$ is the standardised normal cumulative distribution function. This
probability is small when $x$ has a large magnitude or when $xi$ is small.
With soft thresholding, small-magnitude values are mapped to $-1$ and $+1$ with
nontrivial probability, while the binarisation of large values is effectively
deterministic.

#let likert7-footnote = footnote[
  In this case, the 7-point Likert scale has response options: $"strongly oppose" prec "oppose" prec "weakly oppose" prec "neither support nor oppose" prec "weakly support" prec "support" prec "strongly support"$.
]

However, there remains a deeper issue with binarisation, that soft thresholding does not
resolve: _any_ form of binarisation necessarily erases information about
the magnitude of the original data. For instance, consider a survey question that
assesses an individual's attitude toward a particular policy using a 7-point Likert
scale.#likert7-footnote <likert7-footnote-ref>After binarisation, if a value is mapped
to $+1$, we can no longer determine whether the original value corresponded to weak or
strong support, neutrality, or even opposition.

In short, since it uses a single binary value for each observation, MLE cannot capture
ambiguity or neutrality and instead requires that all data be made unambiguous and
non-neutral through binarisation.

// where 'Neutral' (i.e., zero) values may be mapped which
// may be unnatural for values with very small magnitude---should a positive  . with
// small negative values being mapped to $-1$ and nearby small positive values being mapped
// negative values are mapped to $-1$,
//
// However, this approach
// has two main problems. First, it erases all information regarding the magnitude of the
// original data. For instance, in a Likert-7 scale, both 'Weakly support' and 'Strongly
// support' are mapped to $+1$. Hence by using Zero values
// are handled separately, for instance using a deterministic rule or a Bernoulli random
// variable. This approach is
//
// This approach leads to somewhat   to stranand handle zero using
// either a deterministic mapping or via a Bernoulli random variable. However, this
// approach exhibits sharp behaviour around zero
// approach erases all information regarding the magnitude of the original data, and
// behaves sharply around
//
// - Can threshold
//
// - However, it makes sense to assess questions like this. May be important to
//   distinguish between Strong Support and Weak Support.
//
//
//
//
// While maximum likelihood estimation (MLE) is often used to infer
// parameters for similar models @nguyenInverseStatisticalProblems2017
// @leeStatisticalMechanicsUS2015, we should be cautious, for two reasons, of applying this
// method naïvely in the present study.
//
// Firstly, maximum likelihood estimation is prone to overfitting when the number of
// model parameters is similar to the number of observations
// @epskampEstimatingPsychologicalNetworks2018.
// While we consider only a small number of
// beliefs in this study ($N in {7,8}$), the number of parameters $p$ grows
// rapidly, with $p in O(N^2)$ for both the symmetric and asymmetric model variants. In
// combination with sampling error, we expect the number of parameters to negatively
// impact the robustness of the inferred parameters---given an alternative dataset of
// the same size, we would expect significant variation in parameters.
//
// More importantly, however, while the KBS model assumes binary belief states, surveys
// often assess belief states at a more granular level (e.g., using Likert scales, or
// ordinal responses with several options)#footnote[This is the case for the survey dataset
//   used in the present study (@sec:dataset).]. In order to use MLE for model calibration, we
// must first binarise the original data.
// However, we have no
// guarantee that the parameterisation inferred for any specific binarisation is a
// reasonable explanation for the _non-binarised_ dataset, nor for any other possible
// binarisation in the case where a probabilistic binarisation scheme is used (such as
// the one described in @sec:parameter-estimation-soft-binarisation).


// == Soft Binarisation <sec:parameter-estimation-soft-binarisation>
//
// Prior to model fitting, we binarise all variables, mapping data values to the
// domain ${-1, +1}$. Before binarising, we shift each variable such that the _survey
// midpoint_ (e.g., '3' on a 5-point Likert scale) aligns with 0, and rescale each
// variable such that the minimum and maximum possible values map to $-1$ and $+1$
// respectively.
// For variables with no well-defined midpoint, such as those with an even
// number of possible responses, we shift such that the minimal and maximal values are at
// equal distance from 0.
//
// We use a smooth binarisation process to robustly handle data points which are zero, or
// close to zero. This involves perturbing each data value $x in RR$ by an independent
// noise term $epsilon ~ cal(N)(0, sigma)$ before thresholding. @fig:methods-binarisation
// illustrates this process for a negative value of $x$ and given choice of $sigma$.
//
// #figure(
//   image(
//     "../results/figures/methods/binarisation/distribution.pdf",
//   ),
//   caption: caption(
//     short: [Binarisation using gaussian noise with thresholding],
//     long: [
//       $x in RR$ is smoothly binarised to ${-1, +1}$ by
//       thresholding #box[$x' = (x + epsilon)$] where $(x + epsilon) ~ cal(N)(x, sigma)$. Negative values
//       are mapped to $+1$ with probability #box[$P(x' > 0) = "A" = "B" = P(epsilon < x)$], which
//       increases with $sigma$ and $|x|^(-1)$.
//     ],
//   ),
//   placement: auto,
// )// <fig:methods-binarisation>
//
// Observe that $x$ is mapped to $+1$ if, and only if, $epsilon$ is sufficiently large,
// such that $x + epsilon > 0$ (region A), or equivalently when $epsilon < x$ (region B).
// The probability that $x$ is mapped to $+1$ is then
//
// $
//   P(x mapsto +1) = Phi(x/sigma)
// $ //<eqn:methods-dataset-binarisation-probability-map-to-1>
//
// where $Phi$ is the standardised normal cumulative distribution function. This
// probability is small when $x$ has large magnitude, or when $sigma$ is small.

// #let binarisation_sigma = json("../results/data/methods/binarisation_sigma.json").sigma
// For the purposes of our experiments, we choose $sigma = #binarisation_sigma$ such that
// a 'weakly oppose' response to a 7-point Likert scale
// #footnote[
//   The oppose/support 7-point Likert scale has possible responses: strongly oppose,
//   oppose, weakly oppose, neutral, weakly support, support, strongly support.
// ] <fn:likert-7-scale-responses>
// (value $1\/3$) is mapped to $+1$ with probability 0.05.
//
// #figure(
//   image("../results/figures/dataset/likert_7_binarisation_probability.pdf"),
//   placement: auto,
//   caption: caption(
//     short: [Likert-7 binarisation distribution],
//     long: [
//       The probability of binarisation to $+1$ for each possible response to a Likert-7
//       scale survey question@fn:likert-7-scale-responses, given
//       $sigma approx #calc.round(binarisation_sigma, digits: 1)$.
//     ],
//   ),
// )



== Maximising the _expected_ likelihood <subsec:methods-parameter-estimation>


We now introduce a variation on maximum likelihood estimation which resolves the above
issue by avoiding binarisation altogether.

Let $D$ be a dataset with real values, and let $cal(D)_B$ be the random variable
representing possible binarisations of $D$ using a thresholding function,
$b$. In standard MLE, we maximise the likelihood
for a particular realisation, $D_B$, of the random variable $cal(D)_B$. However, when the
probability distribution for $cal(D)_B$ is known, we can avoid explicit binarisation by
instead maximising the _expected_ likelihood, marginalising over the binarisation
function:

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(theta) in RR^p) EE[P(b(D) | bold(theta))]
$ <eqn:parameter-estimation-mele>

If $b$ is the simple thresholding function described above, that maps each value
to its sign (and maps zero deterministically), then @eqn:parameter-estimation-mele is
equivalent to the MLE problem defined in @eqn:parameter-estimation-mle. However, when $b$
is a (non-constant) probabilistic binarisation function, @eqn:parameter-estimation-mele
uses information regarding both binarisation possibilities.

Consider the case where $b := b_xi$ is the soft-thresholding function defined in the
above section, with $xi in RR_+$. If $xi$ is chosen appropriately,@scale-choice-footnote
then data values considered near-neutral or near-ambivalent are mapped to both
$-1$ and $+1$ with nontrivial probability. When using @eqn:parameter-estimation-mele,
the contribution of such values to the objective function is an expectation over
possible binarisations, yielding a parameterised model that explains both
possibilities in accordance with their probabilities. Therefore, by avoiding explicit
binarisation, we can obtain binary models that incorporate the neutrality
and varying degrees of certainty present in non-binarised data.

This is far from the only approach that can be used to account for
neutrality in belief-system models. For instance,
#cite(<vandermaasStatisticalPhysicsPsychological2026>, form: "prose") suggest using
three-valued models, such as the Blume-Capel model (ibid.), that explicitly represent
intermediate states using zero-valued spin states. Such approaches provide extra
representational capacity---our approach cannot _simulate_ neutral states---but raise the
analytical complexity. For the purposes of this study, which has an exploratory nature,
we prefer the relative simplicity of binary models.

== Parameter estimation for the KBS model <sec:parameter-estimation-method>

We now adapt the maximum expected likelihood estimation approach described above to the
KBS model context, explicitly defining the expected likelihood and its derivatives,
which are used for calibration.


Consider a population of $M in NN$ individuals with a shared belief system $cal(M)$
comprising $N in NN$ beliefs.
// for which the parameters (i.e., the baseline activations and interaction effects) are
// unknown.
Suppose that we have measured the belief-system state of each individual, $m in [M]$,
at $T in NN$ uniformly spaced times:
$
  {bold(x)_((m))^t}_(t=1)^T, quad "where each" bold(x)_((m))^t in RR^N
$

The measurements need not be binary, but are assumed to be real and centred at their
'neutral-point'. The collection of
measurements across individuals forms a dataset, $D$, which is the particular
instance of the random variable, $cal(D)$, representing possible datasets.

To calibrate the (symmetric or asymmetric) KBS model, we identify the parameterisation
that maximises the expected likelihood, marginalising over possible binarisations using
a soft thresholding function, $b_xi$, as defined above.
Following #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose"), we also
use regularisation to reduce the risk of overfitting.
// This arises due to the combination
// of a quadratically scaling number of parameters with a small sample size.

#let log-likelihood-equivalence = footnote[
  For numerical stability, we typically maximise the log-likelihood rather than the
  likelihood. Since the logarithm is a strictly increasing function, the two approaches
  yield identical results in principle; however, the multiplication of small
  probabilities when computing the likelihood can lead to numerical overflow.
]
Let
$cal(L)_D (bold(theta))$ denote the expected log-likelihood for a given parameterisation
$bold(theta) in RR^p$, where $p in NN$ is the number of model parameters in the
(symmetric or asymmetric) KBS model:#log-likelihood-equivalence

$
  cal(L)_D (bold(theta)) := EE[log P(b_xi (D)|bold(theta))]
  = sum_(D_B) P(b_xi (D) = D_B) dot log P(D_B|bold(theta))
$ <eqn:parameter-estimation-expected-ll-generic>

We select the parameterisation $bold(theta)^* in RR^p$ which solves the following
optimisation problem:

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(hat(theta)) in RR^p) f(D; bold(hat(theta))), quad "where" quad
  f(D; bold(hat(theta))) := cal(L)_D (bold(hat(theta))) - lambda sum_(theta in bold(hat(theta))) sqrt(theta^2 + epsilon) quad
$ <eqn:parameter-estimation-optimisation-problem>

where the second term is a smooth variant of L1 regularisation
@tibshiraniRegressionShrinkageSelection1996, which penalises nonzero parameters that do
not meaningfully contribute to the expected likelihood. The smoothing hyperparameter,
$epsilon in RR_(>0)$, and regularisation strength, #box[$lambda in RR_(>= 0)$], are determined
beforehand. We will discuss both the regularisation term and methods for selecting these
hyperparameters in @subsec:parameter-estimation-regularisation.


We now give explicit forms for the expected log-likelihood and the partial
derivatives of the objective function with respect to the model parameters for the
(symmetric and asymmetric) KBS model.
The asymmetric and symmetric variants of the KBS model differ only in
the partial derivatives with respect to the interaction parameters.
We omit derivation details here, but these can be found in @sec:appendix-derivations.

Let $p_bold(s) (bold(x))$ denote the probability that an observation $bold(x) in RR^N$
is binarised to the state $bold(s) in {-1, +1}^N$ using the binarisation function
$b_xi$,

$
  p_bold(s) (bold(x)) = P(b_xi (bold(x)) = bold(s))
$

#let log-likelihood-derivation = footnote[
  See expected log-likelihood derivation in @sec:appendix-derivations
  (#internal-link(<derivation:expected-log-likelihood>)).
]
and, for an individual $m in [M]$ and time $t <= T$, let $EE[bold(sigma)_((m))^t]$
denote the expected value of the binarised observation $bold(x)_((m))^t$. The expected
log-likelihood for a KBS model parameterisation,
$bold(theta) = chevron bold(J), bold(h) chevron.r$,
is then derived as:#log-likelihood-derivation

// $
//   cal(L)_D (bold(theta)) = sum_(bold(s)) lr((sum_(m=1)^M sum_(t=1)^(T-1) p_bold(s) (bold(x_((m))^t)) dot EE[bold(sigma)_((m))^(t+1)]^T h^"eff" (bold(s)))) - Z(D; bold(theta))
// $ <eqn:parameter-estimation-expected-ll-explicit>

$
  cal(L)_D (bold(theta)) = lr((sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE[sigma_((m),i)^(t+1) dot h_i^"eff" (bold(sigma)_((m))^t)])) - Z(D; bold(theta))
$ <eqn:parameter-estimation-expected-ll-explicit>

where $h_i^"eff" (bold(s))$ is the effective baseline activation
(@eqn:model-effective-activation) given the previous state $bold(s)$, and
$Z$ is the expected log partition function, summed across observations:

$
  Z(D; bold(theta)) = sum_(m=1)^M sum_(t=1)^(T - 1) sum_(i=1)^N EE[log 2 cosh h_i^"eff" (bold(sigma)_((m))^t)]
$ <eqn:parameter-estimation-expected-partition-function>


#let partial-derivatives-derivation = footnote[
  See the partial derivative derivations in @sec:appendix-derivations
  (#internal-link(<derivation:partial-derivatives>)).
]

For the parameterisation $bold(theta)^*$ which solves
@eqn:parameter-estimation-optimisation-problem, the partial derivatives of the objective
function with respect to each parameter evaluate to zero, i.e.,
#box[$(partial f)/(partial theta) = 0$] for every parameter $theta in bold(theta)^*$.

The partial derivative of $f$ with respect to an arbitrary baseline activation, $h_i$,
for #box[$i in [N]$], is derived for both the symmetric and asymmetric variants
as:#partial-derivatives-derivation

#{
  //show math.equation: set align(left)
  [
    $
      partial/(partial h_i) f(D; bold(theta)) = lr((sum_(m=1)^M sum_(t=1)^(T-1) EE[sigma_((m),i)^(t+1) - tanh h_i^"eff" (bold(sigma)_((m))^t)])) - (lambda h_i)/sqrt(h_i^2 + epsilon)
    $ <eqn:parameter-estimation-derivative-baseline-activation>
  ]
}

For $i,j in [N]$, the partial derivative of $f$ with respect to the directed interaction
parameter $J_(j i)$ in the asymmetric variant (i.e., the influence of $j$ on $i$), is:

#{
  //show math.equation: set align(left)
  [
    $
      partial/(partial J_(j i)) f(D; bold(theta)) = lr((sum_(m=1)^M sum_(t=1)^(T-1) EE[(sigma_((m),i)^(t+1) - tanh h_i^"eff" (bold(sigma)_((m))^t)) dot sigma_((m),j)^t])) &- (lambda J_(j i))/sqrt(J_(j i)^2 + epsilon) quad quad
    $ <eqn:parameter-estimation-derivative-interaction-effect-asym>
  ]
}

In the symmetric model, partial derivatives with respect to self-interaction parameters
are also calculated using @eqn:parameter-estimation-derivative-interaction-effect-asym.
However, for cross-interaction parameters, $J_(i j)$ with #box[$i < j$], we must account
for the contributions to both $S_i$ and $S_j$ in the partial derivative. Let
$alpha_(m,t) (i,j)$ denote the inner summand in
@eqn:parameter-estimation-derivative-interaction-effect-asym:

$
  alpha_(m,t) (i,j) := (sigma_((m),i)^(t+1) - tanh h_i^"eff" (bold(sigma)_((m))^t)) dot sigma_((m),j)^t
$

Then the partial derivative of $f$ with respect to the bidirectional interaction
parameter $J_(i j)$, for $i < j$, in the symmetric variant is:

#{
  //show math.equation: set align(left)
  [
    $
      partial/(partial J_(i j)) f(D; bold(theta)) = lr((sum_(m=1)^M sum_(t=1)^(T-1) EE[alpha_(m,t) (i,j) + alpha_(m,t) (j,i)])) &- (lambda J_(i j))/sqrt(J_(i j)^2 + epsilon)
    $ <eqn:parameter-estimation-derivative-interaction-effect-sym>
  ]
}


=== Smooth L1 regularisation <subsec:parameter-estimation-regularisation>

Since the number of parameters in the KBS model scales quadratically with the
number of modelled beliefs, parameter estimation is prone to overfitting---even
for relatively small sets of beliefs---due to the typically small size
of psychological datasets. Following
#cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose"), we apply a
smooth variant of L1 regularisation (the second term in
@eqn:parameter-estimation-optimisation-problem)
during parameter estimation. This has the effect of penalising nonzero parameters
that do not meaningfully contribute to the expected likelihood, instead requiring
that parameters reflect relationships which are sufficiently prevalent in the
data.



This regularisation term has two hyperparameters: a smoothing constant,
$epsilon in RR_(>0)$, and a regularisation strength parameter, $lambda in RR_(>= 0)$.
For the objective function ($f$ in @eqn:parameter-estimation-optimisation-problem) to
be differentiable, the smoothing constant must be positive. The value of $epsilon$ should
be chosen such that the smooth regularisation term is a reasonable approximation to the
standard formulation of L1 regularisation, i.e., such that

// As $epsilon -> 0^+$ the second term
// converges to the standard formulation of L1 regularisation (i.e., the absolute value).
// Unlike the standard formulation, when $epsilon > 0$ the first-derivative of this term
// exists for all $bold(theta) in RR^p$, so is amenible to gradient-based optimisation.


$
  sqrt(theta^2 + epsilon) approx |theta|
$ <eqn:methods-parameter-estimation-hyperparameters-L1-approximation>

It is not possible to obtain a good approximation for the full range of parameter
values. Rather, one should choose $epsilon$ such that this
approximation holds for parameter values $|theta| > tau$, where
$tau in RR_(>0)$ is the minimum parameter considered 'effectively nonzero'. As a rule
of thumb, we may take $epsilon$ to be at least two orders of magnitude smaller than
$tau^2$.


The hyperparameter $lambda in RR_(>=0)$ controls regularisation strength, with higher values
resulting in sparser models.
#cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose") suggest choosing
$lambda$ which minimises the Extended Bayesian Information Criterion (EBIC)
@chenExtendedBayesianInformation2008:


// $
//   lambda = op("argmin", limits: #true)_(hat(lambda) in RR_(>= 0)) op("EBIC") (bold(theta)^* (hat(lambda)))
// $


// where $bold(theta)^* (hat(lambda))$ is the solution to the optimisation problem defined
// in @eqn:parameter-estimation-optimisation-problem for a given regularisation strength,
// $hat(lambda)$, and the EBIC is defined as:

$
  op("EBIC")(lambda) = overbracket(k ln q - 2 cal(L)_D (bold(theta)^* (lambda)), op("BIC")(lambda)) + 2 k dot gamma ln p
$ <eqn:parameter-estimation-ebic>


where $bold(theta)^* (lambda)$ denotes the solution to the optimisation problem defined
in @eqn:parameter-estimation-optimisation-problem for regularisation strength $lambda$,
$q in NN$ is the number of observations in the dataset, #box[$p in NN$] is the number of model
parameters, and $k$ is the number of (effectively) nonzero parameters with
$|theta| < tau$ in the parameterisation $bold(theta)^* (lambda)$. Notice that $lambda$
is both a parameter in the optimisation problem defined in
@eqn:parameter-estimation-optimisation-problem, and is itself selected using the solution
to this problem.


#let ebic-footnote = footnote[
  Note that this is different from the prior used in the BIC, which is uniform over
  the entire space of models. The prior in the EBIC, for $gamma = 1$, is uniform only
  within each class of models containing $k$ parameters.
]
The point of difference between the EBIC and the standard Bayesian Information
Criterion (BIC) @schwarzEstimatingDimensionModel1978 is in their assumed priors over the space of possible models. While the
BIC assumes a uniform prior, the EBIC penalises values of $k$ which permit a large number
of models @foygelExtendedBayesianInformation2010 @barberHighdimensionalIsingModel2015.
For instance, the class of models comprising eight spins (i.e., with 72 parameters)
contains considerably fewer models with 10 parameters ($5.4 times 10^11$) than models
with 36 parameters ($4.4 times 10^20$). In this scenario, by assuming a uniform prior,
the BIC implicitly penalises models which are too sparse, or too dense.

The parameter
$gamma in RR_(>= 0)$ specifies the degree to which the EBIC penalises such classes of models,
with $gamma = 1$ corresponding to a uniform prior over models with $k$
parameters, for each $k in 0...p$.#ebic-footnote
#cite(<barberHighdimensionalIsingModel2015>, form: "prose") demonstrate that small,
nonzero choices of $gamma$ are sufficient to improve the accuracy of Ising model
structural inference in various contexts.


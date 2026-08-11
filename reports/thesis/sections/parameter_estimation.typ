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

In the previous chapter we introduced the Kinetic Belief System (KBS) as a model of
belief system structure and dynamics which allows for asymmetric influence relations.
While the KBS model is theoretically interesting, its _empirical_ value hinges on
being able to infer the model from observational data.

In this chapter we provide a method for doing just this, based on maximum likelihood
estimation---this turns out to be not-so-straightforward, due to the mismatch between the
binary representation of beliefs assumed by the KBS model and typical approaches for
assessing beliefs in surveys. We then use this method to calibrate symmetric and
asymmetric KBS model to a longitudinal dataset comprising beliefs about climate
change. These models are used for the experiments in the second half of this study.

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
binary belief system models---such as the KBS model---using survey data, which often
assess belief states using multi-valued (e.g., Likert) scales. In order to use
MLE in such situations, we must first binarise observations to the set ${-1, +1}$.

There are several approaches for binarising continuous values, the simplest of which,
which we will call *sign-thresholding*, is to map values to ${-1, +1}$ in accordance
with their sign. Zero must be handled separately, for instance using a deterministic
rule (e.g., $0 mapsto +1$) or a Bernoulli random variable. This produces discontinuous
behaviour around the zero point, which may be unrealistic in this setting. If we are
treating zero as an ambivalent or neutral belief state that can be mapped to either $-1$
or $+1$, one could argue that we should treat small-magnitude positive or negative values
similarly.

#let scale-choice-footnote = footnote[
  The specific choice of $xi$ is important. As $xi -> 0^+$, the soft thresholding
  function converges to the simple ('hard') thresholding function where zero is mapped
  using a $op("Bernoulli")(0.5)$ random variable. As
  $xi -> infinity$, we approach a function which maps _all_ values randomly in this
  way. Appropriate values are context-dependent, based on the
  range of values which are considered 'near-neutral'.
]

We can improve on this using *soft thresholding*, in which each data value $x in RR$
is perturbed by an independent noise term $epsilon ~ cal(N)(0, xi)$ prior to this
mapping. @fig:methods-binarisation illustrates this process for a negative value of $x$
and given choice#scale-choice-footnote <scale-choice-footnote> of $xi in RR_+$.
<sec:parameter-estimation-soft-binarisation>

#figure(
  image(
    "../results/figures/methods/binarisation/distribution.pdf",
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

Observe that $x$ is mapped to $+1$ if, and only if, $epsilon$ is sufficiently large,
such that #box[$x + epsilon > 0$] (region A), or equivalently when $epsilon < x$ (region B).
The probability that $x$ is mapped to $+1$ is then

$
  P(x mapsto +1) = Phi(x/xi)
$ <eqn:methods-dataset-binarisation-probability-map-to-1>

where $Phi$ is the standardised normal cumulative distribution function. This
probability is small when $x$ has large magnitude, or when $xi$ is small.
With soft thresholding, small-magnitude values are mapped to $-1$ and $+1$ with
nontrivial probability, while the binarisation of large values is effectively
deterministic.

#let likert7-footnote = footnote[
  In this case, the Likert-7 scale has response options: $"strongly oppose" prec "oppose" prec "weakly oppose" prec "neither support nor oppose" prec "weakly support" prec "support" prec "strongly support"$.
]

However, there remains a deeper issue with binarisation which is not resolved by soft
thresholding, namely that _any_ form of binarisation necessarily erases information about
the magnitude of the original data. For instance, consider a survey question which
assesses an individual's attitude toward a particular policy using a Likert-7
scale.#likert7-footnote After binarisation, we can no longer distinguish between weak
and strong support for the policy, or neutrality which has been mapped to $+1$.

In short, since it uses a single binary output for each observation, MLE is not capable
of representing ambiguity or neutrality, and instead requires that such cases are made
unambiguous or non-neutral through binarisation.

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

// For the purposes of the experiments in the following sections, we perform parameter
// estimation to calibrate the belief system model described in
// @subsec:theory-nonequilibrium-belief-system-model to the climate beliefs dataset
// (@sec:dataset). We first outline the context of the parameter estimation problem,
// and then present our approach. We omit derivation details in this section;
// however, the curious reader can find these in Appendix A (*TODO*).

We now introduce a variation on maximum likelihood estimation which resolves the above
issue by avoiding binarisation altogether.

Let $D$ be a dataset with real values, and let $cal(D)_B$ be the random variable
representing possible binarisations of $D$ using a thresholding function,
$b$. In standard MLE, we maximise the likelihood
for a particular realisation $D_B$ of the random variable $cal(D)_B$. However, when the
probability distribution for $cal(D)_B$ is known, we can avoid explicit binarisation by
instead maximising the *expected* likelihood, marginalising over the binarisation
process:

$
  bold(theta)^* = op("argmax", limits: #true)_(bold(theta) in RR^p) EE[P(b(D) | bold(theta))]
$ <eqn:parameter-estimation-mele>

If $b$ is the simple thresholding function described above, where we map each value
to its sign (and we map zero deterministically), then @eqn:parameter-estimation-mele is
equivalent to the MLE problem defined in @eqn:parameter-estimation-mle. But when $b$
is a (non-constant) probabilistic binarisation function, @eqn:parameter-estimation-mele
uses information regarding both binarisation possibilities.

Consider the case where $b := b_xi$ is the soft thresholding function, defined in the
above section, for some choice of $xi in RR_+$. If $xi$ is chosen
appropriately@scale-choice-footnote then data values which are considered somewhat
neutral or ambivalent are mapped to both $-1$ and $+1$ with nontrivial probability.
When using @eqn:parameter-estimation-mele, such values contribute an expectation over
these possible binarisations to the objective function. As such, we obtain a
parameterised model which explains both possibilities, in accordance with their
probability. Therefore, by avoiding explicit binarisation, using
@eqn:parameter-estimation-mele we can obtain binary models which incorporate the
neutrality and varying degrees of certainty present in the original data.

== Parameter estimation for the KBS model <sec:parameter-estimation-method>

We now adapt the maximum expected likelihood estimation approach described above to the
context of the KBS model, explicitly defining the expected likelihood and its derivatives
which are used for calibration.


Consider a population of $M in NN$ individuals with a shared belief system $cal(M)$
comprising $N in NN$ beliefs.
// for which the parameters (i.e., the baseline activations and interaction effects) are
// unknown.
Suppose that we have measured the belief system state of each individual, $m in [M]$,
at each of $T in NN$ uniformly spaced timepoints:
$
  {bold(x)_((m))^t}_(t=1)^T, quad "where each" bold(x)_((m))^t in RR^N
$

The measurements need not be binary, but are assumed to be real. The collection of
measurements across all individuals forms a dataset $D$, which is the particular
observed value of the random variable $cal(D)$ representing possible datasets.

To calibrate the (symmetric or asymmetric) KBS model, we identify the parameterisation
which maximises the expected likelihood, marginalising over possible binarisations using
a soft thresholding function, $b_xi$, as defined above.
Following #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose"), we also
use regularisation to reduce the risk of overfitting. This arises due to the combination
of a quadratically scaling number of parameters with a small sample size.

#let log-likelihood-equivalence = footnote[
  For numerical stability we typically maximise the log-likelihood instead of the
  likelihood. Since the logarithm is a strictly increasing function, the two approaches
  yield identical results (theoretically); however, the multiplication of small
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

We select the parameterisation $bold(theta)^*$ which solves the following
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
is binarised to the state $bold(s) in {-1, +1}^N$ under the binarisation function
$b_xi$,

$
  p_bold(s) (bold(x)) = P(b_xi (bold(x)) = bold(s))
$

#let log-likelihood-derivation = footnote[
  See log-likelihood derivation in @sec:appendix-derivations
  (#internal-link(<derivation:log-likelihood>)).
]
and, for an individual $m in [M]$ and timepoint $t <= T$, let $EE[bold(sigma)_((m))^t]$
denote the expected value of the binarised observation $bold(x)_((m))^t$. The expected
log-likelihood is then derived as:#log-likelihood-derivation

// $
//   cal(L)_D (bold(theta)) = sum_(bold(s)) lr((sum_(m=1)^M sum_(t=1)^(T-1) p_bold(s) (bold(x_((m))^t)) dot EE[bold(sigma)_((m))^(t+1)]^T h^"eff" (bold(s)))) - Z(D; bold(theta))
// $ <eqn:parameter-estimation-expected-ll-explicit>

$
  cal(L)_D (bold(theta)) = lr((sum_(m=1)^M sum_(t=1)^(T-1) EE[bold(sigma)_((m))^(t+1)]^T EE[h^"eff" (bold(sigma)_((m))^t)])) - Z(D; bold(theta))
$ <eqn:parameter-estimation-expected-ll-explicit>

where the vector $h^"eff" (bold(s))$ contains the effective baseline activation
(@eqn:model-effective-activation) for each spin given the previous state $bold(s)$, and
$Z$ is the expected log partition function, summed across observations:

$
  Z(D; bold(theta)) = sum_(bold(s)) sum_(m=1)^M sum_(t=1)^(T - 1) p_bold(s) (bold(x)_((m))^t) sum_(i=1)^N log(2 cosh h_i^"eff" (bold(s)))
$ <eqn:parameter-estimation-expected-partition-function>

#let partial-derivatives-derivation = footnote[
  See the partial derivative derivations in @sec:appendix-derivations
  (#internal-link(<derivation:partial-derivatives>)).
]

For the parameterisation $bold(theta)^*$ which solves
@eqn:parameter-estimation-optimisation-problem, the partial derivatives of the objective
function with respect to each parameter evaluate to zero, i.e.,
#box[$(partial f)/(partial theta) = 0$] for every parameter $theta in bold(theta)^*$.

#let tanh-footnote = footnote[
  We abbreviate $tanh$ to $op("th")$.
]
The partial derivative of $f$ with respect to an arbitrary baseline activation, $h_i$,
for #box[$i in [N]$], is derived for both the symmetric and asymmetric variants
as:#partial-derivatives-derivation#tanh-footnote

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
      partial/(partial J_(j i)) f(D; bold(theta)) = lr((sum_(m=1)^M sum_(t=1)^(T-1) EE[sigma_((m),i)^(t+1) - tanh h_i^"eff" (bold(sigma)_((m))^t)]EE[sigma_((m),j)^t])) &- (lambda J_(j i))/sqrt(J_(j i)^2 + epsilon) quad quad
    $ <eqn:parameter-estimation-derivative-interaction-effect-asym>
  ]
}

In the symmetric model, since all interactions are bi-directional, the interaction
parameter, $J_(i j)$, contributes to the behaviour of both $S_i$ and $S_j$, and as such
we must count both contributions to the partial derivative. Let $alpha_(m,t) (i,j)$ denote
the inner summand in @eqn:parameter-estimation-derivative-interaction-effect-asym:

$
  alpha_(m,t) (i,j) := EE[sigma_((m),i)^(t+1) - tanh h_i^"eff" (bold(sigma)_((m))^t)]EE[sigma_((m),j)^t]
$

Then the partial derivative of $f$ with respect to the bi-directional interaction
parameter $J_(i j)$ in the symmetric variant is:

#{
  //show math.equation: set align(left)
  [
    $
      partial/(partial J_(i j)) f(D; bold(theta)) = lr((sum_(m=1)^M sum_(t=1)^(T-1) alpha_(m,t) (i,j) + alpha_(m,t) (j,i))) &- (lambda J_(i j))/sqrt(J_(i j)^2 + epsilon)
    $ <eqn:parameter-estimation-derivative-interaction-effect-sym>
  ]
}

*MUST HANDLE SELF-INTERACTIONS*


=== Smooth L1 regularisation <subsec:parameter-estimation-regularisation>

where the second term is a smooth variant of L1 regularisation
@tibshiraniRegressionShrinkageSelection1996, which penalises nonzero parameters that do
not meaningfully contribute to the expected likelihood.
Parameters instead must reflect relationships which are sufficiently prevalent in the
data, reducing the sample-size robustness issues described above. The hyperparameter
$lambda in RR^+$ controls regularisation strength,
with higher values resulting in sparser models. As $epsilon -> 0^+$ the second term
converges to the standard formulation of L1 regularisation (i.e., the absolute value).
Unlike the standard formulation, when $epsilon > 0$ the first-derivative of this term
exists for all $bold(theta) in RR^p$, so is amenible to gradient-based optimisation.
We discuss the choice of values for $lambda$ and $epsilon$ in
@subsubsec:methods-parameter-estimation-hyperparameters.


#line(length: 100%)
The first term in the objective function $f$, $cal(L)_D (bold(hat(theta)))$, denotes the _expected_ log-likelihood
given a parameterisation $bold(hat(theta))$, over possible binarisations of $D$:

$
  cal(L)_D (bold(hat(theta))) = EE[L_(D_B) (bold(hat(theta))) | cal(D) = D] = sum_(D_B) P(op("Bin")(cal(D)) = D_B | cal(D) = D) dot L_(D_B) (bold(hat(theta)))
$ <eqn:methods-parameter-estimation-conditional-expectation>

where $L_(D_B) (bold(hat(theta)))$ is the log-likelihood of a specific binarisation
$D_B$. We will defer explicitly defining $L_(D_B) (bold(hat(theta)))$ for now, but will
return to this point shortly in @eqn:methods-parameter-estimation-log-likelihood.

*NOTE: * An alternative approach here is to not mention the regularisation yet. Have
this be a short section on the expected MLE. Then have the following section be on the
specific form used in this study.

+ Introduce optimisation problem
+ High-level, what are the two terms
+ Go in-depth into the first one. Explain why it resolves the above problem.
+ Touch on the second one.

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
the one described in *reference soft binarisation*).

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
$// <eqn:methods-parameter-estimation-optimisation-problem>

The first term in the objective function $f$, $cal(L)_D (bold(hat(theta)))$, denotes the _expected_ log-likelihood
given a parameterisation $bold(hat(theta))$, over possible binarisations of $D$:

$
  cal(L)_D (bold(hat(theta))) = EE[L_(D_B) (bold(hat(theta))) | cal(D) = D] = sum_(D_B) P(op("Bin")(cal(D)) = D_B | cal(D) = D) dot L_(D_B) (bold(hat(theta)))
$// <eqn:methods-parameter-estimation-conditional-expectation>

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
the level of certainty or ambivalence present in the dataset. Consider that when using MLE,
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
$ //<eqn:methods-parameter-estimation-expected-ll-explicit>

where $EE[bold(S)_((m))^(t+1) | D]$ is the expected binary configuration for the
observation $bold(x)_((m))^(t+1)$, the vector $h^"eff" (bold(s))$ contains the
effective baseline activation for each spin given the previous state $bold(s)$, and $Z$
is the expected log partition function, summed across observations:

$
  Z(D; bold(theta)) = sum_(bold(s)) sum_(m <= M \ t < T) P(bold(S)_((m))^t = bold(s) | D) sum_(i=1)^N log(2 cosh h_i^"eff" (bold(s)))
$ //<eqn:methods-parameter-estimation-expected-partition-function>

Per the optimisation problem defined in
@eqn:parameter-estimation-optimisation-problem, we choose the parameterisation
$bold(theta)^*$ which maximises the regularised expected log-likelihood, which occurs
when #box[$(partial f)/(partial theta) = 0$] for every parameter $theta in bold(theta)^*$.
The partial derivative with respect to a given baseline activation parameter $h_i$, for
$i in [1,N]$, is given by:

$
  partial/(partial h_i) f(D; bold(theta)) = &sum_(bold(s)) sum_(m <= M\ t < T) P(bold(S)_((m))^t = bold(s) | D) lr([EE[S_(i, (m))^(t+1) | D] - tanh(h_i^"eff" (bold(s)))]) \ &- (lambda h_i)/sqrt(h_i^2 + epsilon)
$ //<eqn:methods-parameter-estimation-derivative-baseline-activation>


Note that the expressions for $cal(L)_D (bold(theta))$ and
$partial/(partial h_i) f(D; bold(theta))$ are applicable to both the asymmetric and
symmetric belief system models. This property does not hold for the partial derivatives
with respect to interaction effects. In the asymmetric model, for $i, j in [1, N]$,
this is derived analogously to
@eqn:parameter-estimation-derivative-baseline-activation as:

$
  partial/(partial J_(j i)) f(D; bold(theta)) = &sum_(bold(s)) sum_(m <= M\ t < T) P(bold(S)_((m))^t = bold(s) | D) s_j lr([EE[S_(i, (m))^(t+1) | D] - tanh(h_i^"eff" (bold(s)))]) \ &- (lambda J_(j i))/sqrt(J_(j i)^2 + epsilon)
$// <eqn:methods-parameter-estimation-derivative-interaction-effect-asym>

In the symmetric belief system model, since we require that $bold(J) = bold(J)^T$, we
estimate a single interaction parameter $J_(j i) = J_(i j) = beta_({i,j})$ for each
pair of spins $S_i, S_j$. Each pair thus contributes twice to the partial derivative,
once for each direction:

$
  partial/(partial beta_({i,j})) f(D; bold(theta)) = &sum_(bold(s)) sum_(m <= M\ t < T) P(bold(S)_((m))^t = bold(s) | D) sum_((i',j') in {i, j}) A_(j' i') s_(j') lr([EE[S_(i', (m))^(t+1) | D] - tanh(h_(i')^"eff" (bold(s)))]) \ &- (lambda beta_({i,j}))/sqrt(beta_({i, j})^2 + epsilon)
$// <eqn:methods-parameter-estimation-derivative-interaction-effect-sym>

=== Hyperparameters <subsubsec:methods-parameter-estimation-hyperparameters>

// TODO: Incorporate
#let binarisation_sigma = json("../results/data/methods/binarisation_sigma.json").sigma
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

The optimisation problem in @eqn:parameter-estimation-optimisation-problem
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
      @eqn:parameter-estimation-optimisation-problem. The vertical axis measures
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

== Calibrating to the climate beliefs dataset <sec:calibration>
The *climate beliefs dataset*, detailed in @sec:dataset, comprises eight beliefs
relating to climate change (@tab:calibration-climate-beliefs-dataset-items),
extracted from the CCCV survey
(cf. #cite(<constantinoPersonalHardshipNarrows2022>, form: "prose"). The dataset
includes responses from 1693 repeating participants, measured during waves 3 and 4 of
the survey. We map the maximum and minimum (allowable) values for each variable to $+1$
and $-1$ respectively, such that these reflect the two spin states in the KBS model.




#figure(
  block(height: 100%, breakable: false)[

    #figure(
      image("../results/figures/dataset/marginal_distributions.pdf"),
      caption: caption(
        short: [Climate beliefs dataset marginal distributions (replicated)],
        long: [
          Marginal distribution for each of the eight variables in the climate beliefs
          dataset (@tab:calibration-climate-beliefs-dataset-items). Note that this figure
          is identical to @fig:dataset-marginal-distributions displayed in @sec:dataset.
        ],
      ),
    ) <fig:calibration-marginal-distributions>
    #figure(
      {
        show table: set text(size: 10pt)
        climate-beliefs-variable-table
      },
      gap: 1em,
      caption: caption(
        short: [Climate beliefs dataset variables (replicated)],
        long: [
          Variables included in the climate beliefs dataset. Index variables are constructed
          by taking the average of their constituent columns, after re-scaling to the
          interval $[-1, 1]$. Note that this table is identical to
          @tab:climate-beliefs-dataset-items displayed in @sec:dataset.
        ],
      ),
    ) <tab:calibration-climate-beliefs-dataset-items>

  ],
)


Using the
parameter estimation method outlined in the previous chapter, we calibrate the
symmetric and asymmetric belief system models to the climate beliefs dataset (see
@sec:dataset). We will evaluate the calibrated models on both structural accuracy
('how accurate are the parameter estimates?') and predictive capacity ('how well do
the models explain the data?').

#let bootstrap-footnote = footnote[
  Each bootstrap sample comprises a set of survey participants, such that each sampled
  dataset either contains all, or none, of the observations from any given individual.
]
#let dataset-size-footnote = footnote[
  In the climate beliefs dataset we have $M = 1693$, $T=2$, and $N=8$
]

As recommended in #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose"),
we evaluate interaction parameter accuracy by examining the bootstrapped confidence
intervals around each parameter estimate.
We use bootstrapping to estimate the uncertainty in our parameter estimates due to
sampling error. Let $bold(D) in RR^(M times T times N)$ be the complete dataset, where
$M$, $T$, and $N$ denote the number of participants, observations, and spins
respectively#dataset-size-footnote. We construct 500 bootstrapped
datasets by sampling rows (participants) with replacement from $bold(D)$,
such that each bootstrapped dataset has the same shape as the complete dataset.

For each bootstrapped dataset $bold(D)_((i))$ we calibrate a model $cal(M)_((i))$
with parameters
$
  chevron bold(J)_((i)), bold(h)_((i)) chevron.r =: bold(theta)^*_((i)) in RR^p
$

where $p in NN$ is the number of model parameters.

// TODO: Consider adding squares/indicators for elements which are zero

#figure(
  image("../results/figures/model_fit/interaction_heatmap.pdf"),
  caption: caption(
    short: [Calibrated model interaction matrix],
    long: [
      (_Top_) Baseline activations, $bold(h)$, and (_Bottom_) interaction effect matrices,
      $bold(J)$, for the symmetric and asymmetric belief
      system model variants, calibrated to the climate beliefs dataset (@sec:dataset)
      using the parameter estimation method in @subsec:methods-parameter-estimation.
      Error bars on the baseline activations display 95% confidence intervals, calculated
      over bootstrapped models ($n=500$) using the percentile method.
    ],
  ),
) <fig:calibration-interaction-matrices>

#let timescale-footnote = footnote[
  The models' timescales are set by the duration between survey responses, in this case
  approximately six months (@sec:dataset).
]
@fig:calibration-interaction-matrices shows the baseline activation parameters, $bold(h)$,
and interaction effect matrix, $bold(J)$,
for each model. Note that we only display the upper triangular elements of the symmetric
model's interaction matrix, since the matrix is symmetric.
The two models exhibit very similar baseline activations. The observed values indicate
that after accounting for interaction effects, (i) belief in the existence and
human-causes of climate change tend to be high, (ii) concern about extreme weather tends
to be low, and (iii) people mostly believe that other individuals are not particularly
worried about climate change. Regularisation has pushed some values (e.g., worry about
climate change) to zero, indicating that the dataset provides limited evidence that these
tend to be either positive or negative.

Both models feature a dominant diagonal, indicating that most variables are slow-moving
with respect to the modelled timescale#timescale-footnote (they are 'sticky'), which
is consistent with prior studies looking at the rate of change for beliefs
@greenPartisanStabilityTurbulent2024 @kileyMeasuringStabilityChange2020.
This is particularly true for `Politics`, and less so for `CC Others Worry` and
`CC Impact`.

Observe that all interaction effects are non-negative. This is by design; we have
re-coded the dataset variables such that this is the case. The fact that such
a re-coding exists implies that it is possible, within this belief system, to hold
a set of beliefs which are internally consistent, i.e., with no cognitive
dissonance. We provide a formal proof of this statement in @sec:appendix-derivations.



// #emph-block[
//   Stability of belief dynamics:
//   - @osborneDoesOpennessExperience2020
//   - @kileyMeasuringStabilityChange2020
//     - Most observed change in beliefs and behaviours is short-term (or measurement error)
//     - This is consistent with the cognitive dissonance theory
// ]


#figure(
  image("../results/figures/model_fit/edge_accuracy.pdf"),
  caption: caption(
    short: [Calibrated model edge accuracy],
    long: [
      Interaction effect parameter accuracy for symmetric and asymmetric models
      calibrated to the climate beliefs dataset (@sec:dataset). Mean parameter values
      are shown in increasing order. 95% confidence intervals are calculated using the
      percentile method over models calibrated to bootstrapped datasets (500 repeats).
    ],
  ),
) <fig:calibration-edge-accuracy>



// @fig:calibration-edge-accuracy shows the
// estimated interaction effects in increasing order for each model. We apply
// non-parametric bootstrapping (500 repeats), calibrating models to bootstrap datasets
// drawn with replacement from the original dataset#bootstrap-footnote. The confidence
// intervals are calculated using the percentile method (*CITE*) across the bootstrapped
// models' parameters.



@fig:calibration-edge-accuracy shows the estimated interaction effects in increasing
order for each model. The confidence intervals are calculated using the percentile
method (*CITE*) across the bootstrapped models' parameters.
Most parameters display small 95% confidence
intervals, indicating an accurate fit for both models. On average, the
symmetric model exhibits smaller confidence intervals than the asymmetric model
($0.065 < 0.085$), which is expected given the larger number of parameters in the
asymmetric model. In both models the self-interaction effect on `Politics` is
significantly larger than all other parameters, as evidenced by the non-overlapping
confidence intervals, supporting our earlier observation regarding
@fig:calibration-interaction-matrices. Moreover, the remaining self-interaction effects
are, in-general, significantly larger than the pairwise effects, with the exception of
`CC Impact` in the symmetric model, and `CC Impact`, `CC Worry Others` in the asymmetric
model.

#figure(
  image("../results/figures/model_fit/selection_probability.pdf"),
  caption: caption(
    short: [Model calibration edge selection probability],
    long: [
      Edge selection probability for models calibrated to bootstrapped datasets sampled
      with replacement from the climate beliefs dataset (500 repeats). Edges are
      'selected' if they survive regularisation with magnitude at least $0.01$.
    ],
  ),
) <fig:calibration-selection-probability>

Due to the use of regularisation in model calibration we must be careful not to draw
conclusions regarding edge _existence_ from this figure
@epskampEstimatingPsychologicalNetworks2018. Instead, we may consider the proportion
of bootstrapped models for which each edge is nonzero, shown in
@fig:calibration-selection-probability. Relations which are selected in all
models are not shown.

All edges excluded from the model calibrated on the full
dataset (@fig:calibration-interaction-matrices) have low selection probability in the
bootstrapped datasets ($< 50%$). The relation
#box[$#raw("CC Real") -> #raw("Politics")$] is excluded from the complete asymmetric
model but included (bidirectionally) in the symmetric model. This is reflected in the
corresponding selection probabilities---this edge is selected in 100% of bootstrapped
symmetric models but only 23% of asymmetric models. Edges which _are_ selected in the
complete models generally have high selection probability. The notable exception in the
asymmetric case, #box[$#raw("CC Human") -> #raw("CC Impact")$], has a relatively small
effect size ($J_(i,j) approx 0.04$).

#let calibration-disclaimer = footnote[
  While we only show results for the asymmetric model here, the corresponding figures
  for the symmetric model are substantially similar, and all conclusions drawn regarding
  the asymmetric model apply also to the symmetric one.
]

We now evaluate the models' predictive capacities#calibration-disclaimer. First, we
examine the reliability of predicted transitions. @fig:calibration-transition-reliability
shows the average binarisation probability for each spin (i.e., the probability that the
corresponding observation in the second wave of the dataset is binarised to $+1$), binned
by transition probability. Bins with no observations are not shown (e.g., extreme values
for `CC Others Worry`).

#figure(
  image("../results/figures/model_fit/transition_reliability.pdf"),
  caption: caption(
    short: [Calibrated model: transition reliability],
    long: [
      Reliability of transitions predicted by the model measured as the agreement
      between conditional probabilities under the model,
      $P(S_i^(t+1) = +1 | bold(S)^t)$, and expected proportion of $+1$ values after
      binarisation, calculated as the average transition probability for survey
      participants in a given conditional probability bin.
    ],
  ),
) <fig:calibration-transition-reliability>

The two measurements are strongly correlated for most variables. The higher variation
for `CC Real` and `CC Human` likely reflects the observed heavy skew in these variables
toward larger values (see @fig:dataset-marginal-distributions in @sec:dataset).
We observe no high/low probabilities for either `CC Others Worry` or `Weather Worry`,
on account of the limited influence of other spins on these variables, as seen in
the corresponding columns of @fig:calibration-interaction-matrices.

Next, we compare the calibrated model against a null model, in which we permit only
baseline activation ($h_i$) and self-influence ($J_(i,i)$) parameters. We measure the
relative entropy of the binarised data from the second wave of the dataset, with respect
to the probability distributions induced by each model. For each participant and spin,
we calculate the relative entropy as

$
  D(P || Q) := H_C (P, Q) - H(P)
$ <def:calibration-relative-entropy>

Where $P := P(op("Bin")(X_(i, (m))^(t+1)))$ is the distribution over binarisations of
the observation in the first timestep, and $Q := P_cal(M) (S_(i, (m))^(t+1))$ is the
distribution over subsequent states according to the model, marginalising over
binarisation of the previous observation,

$
  Q := P_cal(M) (S_(i, (m))^(t+1)) = P_cal(M) (S_(i, (m))^(t+1) | op("Bin")(X_(i, (m))^t)) dot P(op("Bin")(X_(i, (m))^t))
$

The functions $H$ and $H_C$ denote the entropy and cross-entropy, respectively. The
entropy term quantifies the uncertainty in the binarisation process, and the
cross-entropy measures the 'expected surprise' when comparing predictions generated from
the model with the true binarised dataset. Formally, these are defined as follows:

$
  H(P) = - sum_(s in plus.minus 1) P(s) log_2 P(s)
$ <def:calibration-entropy>

$
  H_C (P,Q) = - sum_(s in plus.minus 1) P(s) log_2 Q(s)
$ <def:calibration-cross-entropy>

#let nonneg-rel-entropy = footnote[
  The relative entropy is strictly non-negative (*CITE*), so the binarisation entropy is
  a lower bound on the cross-entropy. This aligns with our intuition---the model cannot
  possibly be highly accurate when the binarisation process is very uncertain.
]
The relative entropy, $D(P || Q)$, is small when either (i) the model
accurately predicts the observed binarised value such that the cross-entropy is
low#nonneg-rel-entropy, or (ii) the binarisation process is very uncertain. It follows
that the relative entropy is high in cases where the model fails to accurately predict
the next state, despite the binarisation process being fairly deterministic.

#figure(
  image("../results/figures/model_fit/mean_relative_entropy.pdf"),
  caption: caption(
    short: [Calibrated model: mean relative entropy],
    long: [
      _(Left)_ Mean absolute relative entropy of the binarised dataset with respect to
      the calibrated model, for the full-connected and null (only self-interactions)
      models, using 10-fold cross-validation. Average calculated across spins and
      survey participants. _(Right)_ Mean difference in relative entropy. Confidence
      intervals display two standard deviations around the mean value.
    ],
  ),
) <fig:calibration-mean-relative-entropy>

To test for the effect of including cross-interactions, we fit the fully-connected model
and null models using 10-fold cross-validation. For each survey participant in the
validation (holdout) split we calculate the mean difference in relative entropy between
the fully-connected and null models. @fig:calibration-mean-relative-entropy shows the
mean relative entropy across individuals and spins on the null and fully-connected
models (left) and the mean _difference_ in relative entropy, averaged across survey
participants (right).


We find, in the right-hand panel, that the fully-connected model leads to significant
reduction in relative entropy averaged over survey participants ($p < 0.05$). While
statistically significant, the reduction is small. Since the measurement is averaged
across survey participants, this finding suggests that the self-interaction model is
sufficient to explain the behaviour for most participants---reflecting the
slow-moving dynamics of the observed belief system---but not all participants. We
anticipate that individuals whose belief states change more between observations are
better explained by the fully-connected model than the null model.

#figure(
  image("../results/figures/model_fit/kl_difference_dist.pdf"),
  caption: caption(
    short: [Null model relative entropy comparison],
    long: [
      Probability density function (left) and empirical cumulative distribution function
      (right) of the mean difference in relative entropy between the fully-connected and
      null (only self-interaction) models across survey participants. Negative values
      indicate lower relative entropy for the fully-connected model.
    ],
  ),
) <fig:relative-entropy-difference-dist>

@fig:relative-entropy-difference-dist explores this hypothesis, displaying the empirical
probability density and cumulative distribution functions for the mean difference in
relative entropy, across individuals. Indeed, we see substantial variation in effects.
The weak right tail and heavy left tail indicate cases which are better-explained by
the null and fully-connected models respectively.

We examine a sample of cases from either tail (top panel: left tail, bottom panel:
right tail) in @fig:relative-entropy-difference-examples. Each panel displays the
change in binarisation probability between the two observed survey waves for a sampled
survey participant. In the first three panels of the top row, we observe scenarios in
which most spins are initially aligned, and a subset of the remaining spins then update
to align with this set, i.e., where the system shifts toward a more consistent state.
Conversely, in the first, second, and fourth panels in the bottom row we see the opposite
scenario play out. That is, the system is initially well-aligned, yet some spins update
to a less consistent state.

The observed behaviour aligns with our expectations, namely
that the model with cross-interactions outperforms the null model in scenarios where
the belief system state updates toward a more consistent state (according to the theory
of cognitive dissonance), and is out-performed when participants' behaviour contradicts
this theory.



#figure(
  image("../results/figures/model_fit/kl_difference_examples.pdf"),
  caption: caption(
    short: [Null model relative entropy comparison examples],
    long: [
      Observed transitions for sample survey participants in the left tail (top row) and
      right tail (bottom row) of @fig:relative-entropy-difference-dist. Circles indicate
      the probability that participants' observations in the first wave are binarised to
      $+1$. Arrows denote the change in the second wave, colour-coded according to
      whether the change is toward the positive (blue) or negative (orange) state.
    ],
  ),
) <fig:relative-entropy-difference-examples>


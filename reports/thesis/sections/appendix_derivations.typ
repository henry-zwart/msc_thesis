#import "@preview/equate:0.3.3": equate

#show: equate.with(breakable: true)//, sub-numbering: true)
#set math.equation(numbering: "(1.1)")

= Derivations <sec:appendix-derivations>


== Model

=== Positive edges implying consistency possible

Part 1:
+ Internal consistency is possible, iff, for a given model, there exists a configuration
  of belief states such that every pair of positively associated beliefs have the same
  state, and every pair of negatively associated beliefs have opposite states.
+ Corrolary: Internal consistency is not possible, iff, for every configuration, there
  exist a pair of beliefs which are in conflict. i.e., where positively associated
  beliefs have opposing states, or negatively associated beliefs have the same state.

+ Fit model to dataset
+ Signs of edges denote whether each pair of beliefs is aligned or misaligned under the
  original variable coding
+ Reversing the scale for a variable has the effect of multiplying its edge signs by
  $-1$.
+ Notice that there is a bijective mapping between possible re-codings of the dataset,
  and possible model configurations. The result follows immediately.
  + Any re-coding which makes all edges positive is an example of internal consistency
    in the original model.
  + If for every re-coding, there exists at least one negative edge, then internal
    consistency is impossible.
+ Therefore, internal consistency is possible, if and only if, it is possible to re-code
  the dataset variables such that there are no negative edges in the resulting model.

== Smooth thresholding probability

Let $b_xi$ be a soft thresholding function for $xi in RR_(> 0)$, and let $x in RR$.
We now prove the statement from @eqn:methods-dataset-binarisation-probability-map-to-1,
which states that $b_xi$ maps $x$ to $+1$ with probability described in terms of
the standard normal cumulative distribution function:

$
  P(x mapsto +1) = Phi(x / xi)
$

Recall the following diagram from @chp:parameter-estimation:

#align(
  center,
  image(
    "../results/figures/methods/binarisation/distribution.pdf",
  ),
)

In this example, $x < 0$, but the following argument holds in general. Notice
that in this diagram, $x$ is mapped to $+1$ if the sampled noise term,
$epsilon ~ cal(N)(0, xi)$, is such that #box[$x + epsilon$] is in region
'A', i.e.,

$
  P(x mapsto +1) = P(x + epsilon > 0)
$

Or equivalently,

$
  P(x mapsto +1) = P(epsilon > -x)
$

Using the symmetry of the Gaussian distribution, this reduces to the
standard normal cumulative distribution, as desired:

$
  P(x mapsto +1) & = P(epsilon > -x) \
                 & = P(epsilon < x) \
                 & = Phi(x / xi)
$


== Parameter estimation


Let $D$ be a dataset comprising $T in NN$ observations for each of $M in NN$ individuals,
where each observation measures the (not necessarily binary) state of $N in NN$ beliefs,
and let $b_xi$ be a soft thresholding function, as defined in
@eqn:methods-dataset-binarisation-probability-map-to-1, for $xi in RR_(> 0)$. We assume
that observations from different individuals are independent.


// === Log-likelihood <derivation:log-likelihood>
// (*reference old equation for the log likelihood*)
//
// Let $D_B ~ op("Bin")(D)$ be a possible binarisation of $D$, and $bold(theta)$ a
// parameterisation for the (asymmetric or symmetric) belief system model, which is
// decomposable into the model parameters
// $bold(theta) = chevron bold(J), bold(h) chevron.r$. The log-likelihood of $D_B$ given
// $bold(theta)$ is:
//
// $
//   L_(D_B) (bold(theta)) &= log P(D_B | bold(theta)) \
//   //&= sum_(m=1)^M sum_(t=1)^(T - 1) sum_(i=1)^N log P(s_(i, (m))^(t+1) | bold(s)_((m))^t, bold(theta)) \
//   &= sum_(m=1)^M sum_(t=1)^(T - 1) log s_(i, (m))^(t+1) dot h_i^"eff" (bold(s)_((m))^t) - log(2 cosh h_i^"eff" (bold(s)_((m))^t)) \
// $
//
// The derivation of (*old equation for the log-likelihood*) is analogous to that
// of the non-equilibrium Ising model log-likelihood @nguyenInverseStatisticalProblems2017.
// Combining (*old equation for the log-likelihood*) and
// @eqn:parameter-estimation-expected-ll-generic, we obtain an explicit
// expression for the expected likelihood:

=== Single-belief transition probability

Here, we show that the transition probability for a belief $S_i$, as defined
in @chp:kinetic-belief-system in terms of the activation probability and the
logistic function (@eqn:model-activation-probability), has the following
equivalent form:

$
  P(sigma_i^(t+1) = s^(t+1) | bold(sigma)^t = bold(s)^t) = exp(s^(t+1) dot h_i^"eff" (bold(s)^t)) / (2 cosh h_i^"eff" (bold(s)^t))
$ <eqn:apdx-derivation-conditional-prob-alt-form>

Recall that the conditional probability that $S_i$ takes on the value $+1$
given the previous state is defined as:

$
  P(sigma_i^(t+1) = +1 | bold(sigma)^t = bold(s)^t) = op("logistic")(2 h_i^"eff" (bold(s)^t))
$ <eqn:apdx-derivation-activation-probability>

where $h_i^"eff" (bold(s))$ is the effective baseline activation as defined in
@eqn:model-effective-activation. To derive the explicit form of
$P(sigma_i^(t+1) | bold(sigma)^t)$, we first rewrite
@eqn:apdx-derivation-activation-probability equivalently as:

$
  P(sigma_i^(t+1) = +1 | bold(sigma)^t = bold(s)^t) &= 1/(1 + exp(-2 h_i^"eff" (bold(s)^t))) \
  &= exp(h_i^"eff" (bold(s)^t))/(exp(h_i^"eff" (bold(s)^t)) + exp(-h_i^"eff" (bold(s)^t)))
$

from which we obtain the complimentary probability as:

$
  P(sigma_i^(t+1) = -1 | bold(sigma)^t = bold(s)^t) = exp(-h_i^"eff" (bold(s)^t))/(exp(h_i^"eff" (bold(s)^t)) + exp(-h_i^"eff" (bold(s)^t)))
$

It follows that the general probability distribution
$P(sigma_i^(t+1) | bold(sigma)^t = bold(s)^t)$ is given by:

$
  P(sigma_i^(t+1) = s^(t+1) | bold(sigma)^t = bold(s)^t) &= exp(s^(t+1) dot h_i^"eff" (bold(s)^t))/(exp(h_i^"eff" (bold(s)^t)) + exp(-h_i^"eff" (bold(s)^t))) \
  &= exp(s^(t+1) dot h_i^"eff" (bold(s)^t)) / (2 cosh h_i^"eff" (bold(s)^t))
$


=== Expected log-likelihood <derivation:expected-log-likelihood>

Here, we derive the explicit form of the expected log-likelihood for a Kinetic Belief
System model (KBS) with respect to an observational dataset.

The expected log-likelihood for a parameterisation, $bold(theta) in RR^p$, of the KBS
model, with respect to $D$, is given by:

$
  cal(L)_D (bold(theta)) : & = EE[log P(b_xi (D) | bold(theta))] \
                           & = sum_(m=1)^M EE[log P(bold(sigma)_((m))^1, ..., bold(sigma)_((m))^T)] \
                           & = sum_(m=1)^M sum_(t=1)^(T-1) EE[log P(bold(sigma)_((m))^(t+1) | bold(sigma)_((m))^t)] \
$ <eqn:apdx-derivation-expected-ll-generic>

where we use our assumptions regarding the independence of individuals in the dataset
$D$ and the KBS model's Markov assumption, as well as the linearity of the expectation.
Substituting the conditional transition probability from @eqn:model-kbs-dynamics, we
may rewrite this in terms of the transition probabilities for individual beliefs, as:

$
  cal(L)_D (bold(theta)) = sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE[log P(sigma_((m),i)^(t+1) | bold(sigma)_((m))^t)]
$ <eqn:apdx-derivation-expected-ll-generic-distributed>

Using the alternative form for the conditional probability in
@eqn:apdx-derivation-conditional-prob-alt-form, we may expand
@eqn:apdx-derivation-expected-ll-generic-distributed as follows:

$
  cal(L)_D (bold(theta)) &= sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE lr([log(exp(sigma_((m),i)^(t+1))/(2cosh h_i^"eff" (bold(sigma)_((m))^t)))])\
  &= sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE[sigma_((m),i)^(t+1) dot h_i^"eff" (bold(sigma)_((m))^t) - log 2 cosh h_i^"eff" (bold(sigma)_((m))^t)] #<eqn:apdx-derivation-combined-expected-ll-explicit>\
  &= sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE[sigma_((m),i)^(t+1) dot h_i^"eff" (bold(sigma)_((m))^t)] - Z(bold(theta); D)\
$

where $Z(bold(theta); D)$ is the expected log partition function:

$
  Z(bold(theta); D) = sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE[log 2 cosh h_i^"eff" (bold(sigma)_((m))^t)]
$


=== Partial derivatives of the objective function <derivation:partial-derivatives>

We now derive the partial derivatives of the objective function
($f$ in @eqn:parameter-estimation-optimisation-problem) with respect to each parameter
in the KBS model. Let $theta$ be an arbitrary parameter in a KBS model parameterisation
$bold(theta) in RR^p$.

Taking the partial derivative of $cal(L)_D (bold(theta))$ with respect to $theta$, using
the form specified in @eqn:apdx-derivation-combined-expected-ll-explicit, we find:

$
  partial/(partial theta) cal(L)_D (bold(theta)) &= sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N partial/(partial theta) EE[sigma_((m),i)^(t+1) dot h_i^"eff" (bold(sigma)_((m))^t) - log 2 cosh h_i^"eff" (bold(sigma)_((m))^t)] \
  &= sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE[sigma_((m),i)^(t+1) dot partial/(partial theta)h_i^"eff" (bold(sigma)_((m))^t) - partial/(partial theta)log 2 cosh h_i^"eff" (bold(sigma)_((m))^t)] \
  &= sum_(m=1)^M sum_(t=1)^(T-1) sum_(i=1)^N EE[(sigma_((m),i)^(t+1) - tanh[h_i^"eff" (bold(sigma)_((m))^t)])dot partial/(partial theta) h_i^"eff" (bold(sigma)_((m))^t)] #<eqn:apdx-derivation-ll-partial-generic>\
$


We now determine the partial derivatives of the effective baseline activation. First,
for a baseline activation parameter $theta = h_i$, we have:
$
  partial/(partial h_i) h_k^"eff" (bold(s)) = cases(1\, quad "if" k = i, 0\, quad "otherwise")
$ <eqn:apdx-derivation-partial-baseline>

Similarly, if the KBS model has asymmetric interaction parameters, then for
$theta = J_(j i)$, the corresponding partial derivative of the effective baseline
activation $h_k^"eff" (bold(s))$ will be zero if $k != i$, and otherwise is given
by $s_j$:

$
  partial/(partial J_(j i)) h_k^"eff" (bold(s)) = cases(s_j\, quad "if" k = i, 0\, quad "otherwise")
$ <eqn:apdx-derivation-partial-interaction-asym>

If the KBS model has symmetric interaction parameters, then each interaction
parameter, $theta = J_(i j)$, contributes to the behaviour of both $S_i$ and $S_j$.
Therefore the partial derivative of the effective baseline activation
$h_k^"eff" (bold(s))$ is nonzero if $k in.not {i,j}$:

$
  partial/(partial J_(i j)) h_k^"eff" (bold(s)) = cases(s_j\, quad "if" k in {i, j}, 0\, quad "otherwise")
$ <eqn:apdx-derivation-partial-interaction-sym>

We must also account for the partial derivative of the regularisation term. For an
arbitrary parameter $theta$ and regularisation hyperparameters
$lambda in RR_(>= 0), epsilon in RR_(>0)$, this is:

$
  partial/(partial theta) lambda sum_(theta' in bold(theta)) sqrt(theta'^2 + epsilon) &= lambda partial/(partial theta) sqrt(theta^2 + epsilon) \
  &= (lambda theta) / sqrt(theta^2 + epsilon)
$

Finally, the complete partial derivative of the objective function $f$, with respect
to a parameter $theta$ is:

$
  partial/(partial theta) f(D; bold(theta)) = partial/(partial theta) cal(L)_D (bold(theta)) - partial/(partial theta) lambda sum_(theta' in bold(theta)) sqrt(theta'^2 + epsilon)
$

Substituting the above results, we obtain the following partial derivatives of $f$ with
respect to each parameter type:

#{
  show math.equation: set align(left)
  [
    $
      partial/(partial h_i) f(D; bold(theta)) &= sum_(m=1)^M sum_(t=1)^(T-1) EE[sigma_((m),i)^(t+1) - tanh[h_i^"eff" (bold(sigma)_((m))^t)]] - (lambda h_i)/sqrt(h_i^2 + epsilon)quad &""\
      partial/(partial J_(j i)) f(D; bold(theta)) &= sum_(m=1)^M sum_(t=1)^(T-1) EE[alpha_(m,t)(i,j)] - (lambda J_(j i))/sqrt(J_(j i)^2 + epsilon)& "(Asymmetric)" \
      partial/(partial J_(i j)) f(D; bold(theta)) &= sum_(m=1)^M sum_(t=1)^(T-1) EE[alpha_(m,t)(i,j) + alpha_(m,t)(j,i)] - (lambda J_(i j))/sqrt(J_(i j)^2 + epsilon) & "(Symmetric)" \
    $
  ]
}

where

$
  alpha_(m,t)(i,j) = (sigma_((m),i)^(t+1) - tanh h_i^"eff" (bold(sigma)_((m))^t)) dot sigma_((m),j)^t
$





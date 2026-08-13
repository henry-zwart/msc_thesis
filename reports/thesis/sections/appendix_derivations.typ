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


== Parameter estimation

=== Log-likelihood <derivation:log-likelihood>
(*reference old equation for the log likelihood*)

Let $D_B ~ op("Bin")(D)$ be a possible binarisation of $D$, and $bold(theta)$ a
parameterisation for the (asymmetric or symmetric) belief system model, which is
decomposable into the model parameters
$bold(theta) = chevron bold(J), bold(h) chevron.r$. The log-likelihood of $D_B$ given
$bold(theta)$ is:

$
  L_(D_B) (bold(theta)) &= log P(D_B | bold(theta)) \
  //&= sum_(m=1)^M sum_(t=1)^(T - 1) sum_(i=1)^N log P(s_(i, (m))^(t+1) | bold(s)_((m))^t, bold(theta)) \
  &= sum_(m=1)^M sum_(t=1)^(T - 1) log s_(i, (m))^(t+1) dot h_i^"eff" (bold(s)_((m))^t) - log(2 cosh h_i^"eff" (bold(s)_((m))^t))
$

The derivation of (*old equation for the log-likelihood*) is analogous to that
of the non-equilibrium Ising model log-likelihood @nguyenInverseStatisticalProblems2017.
Combining (*old equation for the log-likelihood*) and
@eqn:parameter-estimation-expected-ll-generic, we obtain an explicit
expression for the expected likelihood:

=== Expected log-likelihood
@eqn:parameter-estimation-expected-ll-explicit

=== Partial derivatives of expected log-likelihood <derivation:partial-derivatives>


== Dataset

=== Binarisation probability
@eqn:methods-dataset-binarisation-probability-map-to-1



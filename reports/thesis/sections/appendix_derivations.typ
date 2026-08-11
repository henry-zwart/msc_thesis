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
@eqn:methods-parameter-estimation-log-likelihood

=== Expected log-likelihood
@eqn:methods-parameter-estimation-expected-ll-explicit

=== Partial derivatives of expected log-likelihood


== Dataset

=== Binarisation probability
@eqn:methods-dataset-binarisation-probability-map-to-1



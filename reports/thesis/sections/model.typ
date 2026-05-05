Glauber dynamics new spin state probability:

$
  p(s_i (t+1)|bold(s)(t)) = exp(1/T dot s_i (t+1) dot [h_i + sum_(j eq.not i) J_(i,j) dot s_j (t)])/(2 cosh(h_i + sum_(j eq.not i) J_(i,j) dot s_j (t)))
$


Equivalent form in terms of logistic function:
$
  p(s_i (t+1)|bold(s)(t)) = op("logistic")(-2/T dot s_i (t+1) dot [h_i + sum_(j eq.not i) J_(i,j) dot s_j^t])
$

#pagebreak()


// == Modelling individual differences
//
// In the simplest problem formulation, we treat all individuals as replicates of the same
// underlying belief system. This is commonly referred to as a _total-pooling_ approach.
// Total pooling allows us to use a maximal amount of data to fit a minimal number of
// parameters. In the case where the homogeneity assumption holds, total pooling is
// optimal.
//
// // TODO: Define total pooling
//
// However, if the homogeneity assumption does not hold, then some individuals will not be
// well-represented by the inferred belief system. This is particularly critical when
// considering the stability of observed belief system configurations.
//
// Suppose we have belief system measurements from individuals for a system comprising
// three beliefs. After fitting the model using total pooling, we find that $s_1$ tends
// to be `OFF` in absence of interactions. However, suppose that for a subset of
// individuals $s_1$ is more typically `ON`; due to differences in their context, perceived
// norms, or knowledge, their tendencies differ from the general population. For these
// individuals we are likely to observe $s_1$ as being `ON` more often than otherwise
// expected. This is a stable configuration for these individuals; however, assessing
// stability with reference to the total pooling model will tell us that they are unstable,
// and likely to transition to a new configuration in future.
//
// // TODO: Draw the above graph
//
// At the other extreme, termed _no-pooling_, we can fit a separate model for each
// individual. However, it is unlikely that we would have adequate data to achieve a robust
// fit, and since beliefs and attitudes are often quite stable, we would likely not observe
// key interaction effects between certain beliefs, even over extended measurement periods.
//
// We can instead make the intermediate assumption that many belief system aspects are
// shared between individuals, but that there exists some individual variation. For
// instance, we expect certain directed belief interactions to be present for the majority
// of individuals, particularly when these reflect logical conditions, or widespread
// societal understandings.







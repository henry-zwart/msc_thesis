Considering moving this section to later in the thesis.

- Early work on modelling belief systems, triadic consistency
- Approaches:
  - partial correlation networks,
  - Bayesian networks,
  - Causal attitude network, Ising-style models
- Beliefs as edges vs. beliefs as nodes
- Social influence: hierarchical Ising models, network of belief model
- Within-person vs between-person correlations; complications around inferring
  individual belief systems.


// === Symmetric (equillibrium) Ising model
//
// $
//   P(bold(S) = bold(s)) = exp(-1/T H(bold(s)))/(sum_(bold(s)') exp(-1/T H(bold(s)')))
// $ <eq:model-symmetric-ising-boltzmann>
//
// Where the temperature parameter $T in RR_(>0)$ controls the degree of stochasticity. At
// high temperatures $P(bold(S) = bold(s))$ converges to a uniform distribution over
// states (i.e., maximum stochasticity), whereas as $T -> 0^+$ it converges in probability
// (*TODO: double-check this statement*) to a distribution over the restricted set of
// states with minimum energy.
//
// - Introduce maximum likelihood parameter estimation using:
//   - Cross-sectional methods
//   - Time-series methods
//
// === Causal Attitude Networks <subsec:model-causal-attitude-network>
//
// *TODO:* Discuss what they say in original paper about differences in the sets of
// nodes included in different individuals' networks.
//
// The Causal Attitude Network (*CAN*) model @dalegeFormalizedAccountAttitudes2016b is an
// Ising-style theory of endogenous belief system dynamics, which operates under the
// assumption that these dynamics are primarily driven by efforts --- conscious or
// otherwise --- to reduce cognitive dissonance. The model considers a collection of
// evaluative axes for cognitive items, such as attitudes, beliefs, feelings, or
// behaviours, which are arranged as vertices on an undirected, signed, weighted network.
//
// Edges in the network describe causal influences between items, such that a pair of
// cognitive items related via a positive edge are likely to exhibit evaluations of the
// same _valence_ (positive or negative), while items related via a negative edge are
// likely to exhibit evaluations with different valences. The degree to which a pair of
// related items are expected to covary increases with both the absolute magnitude of
// the weight of their relation, and the relative magnitude compared to other relations
// involving either of the items. Observations from a pair of items may have low mutual
// information despite a high absolute magnitude relation, if, for instance, the
// associated cognitive items have much higher-weight relations with other,
// non-overlapping sets of cognitive items.
//
// Each cognitive item has an associated *threshold*, $tau_i in RR$, describing its
// tendency to assume either positive ($tau_i > 0$) or negative ($tau_i < 0$) evaluations
// in the absence of influencing interactions with other items, or in the case that the
// net effect of these interactions is zero.
//
// The CAN model defines the dynamics of a belief system using an equilibrium Ising model
// framework, with the Hamiltonian of a particular configuration of evaluations defined in
// @eq:model-can-hamiltonian, where $omega_(i j) in RR$ is the signed weight of a relation
// between nodes $i$ and $j$ in the network and $N in NN$ is the number of cognitive items
// in the model.
//
//
// $
//   H(bold(s)) = - sum_(i=1)^N tau_i s_i - sum_(chevron i j chevron.r) omega_(i j) s_i s_j
// $ <eq:model-can-hamiltonian>
//
// At equilibrium, the probability is described by the Boltzmann distribution
// (@eq:model-symmetric-ising-boltzmann) with @eq:model-can-hamiltonian as its Hamiltonian.
// Since the CAN model is equivalent to a symmetric network Ising model, all standard
// methods for solving the inverse Ising problem for this class of models also apply here
// to recovering parameter values $tau_i, omega_(i j) in RR$ for a CAN model assumed to
// generate the observations in a binary dataset.

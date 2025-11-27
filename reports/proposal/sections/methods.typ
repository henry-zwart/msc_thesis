#{
  set text(fill: luma(140))
  [
    *Methods:*
    + Motivation for statistical-physics-inspired models of belief

    + Base model (beliefs-as-nodes):
      - Immediately amenable to directional relations between beliefs.
        - A directed relation $A --> B$ is interpreted as "if you believe $A$, then also $B$, but 
          not necessarily the converse".
      - The beliefs-as-edges model does not have a natural interpretation with directed edges. However,
        it does have advantages over the beliefs-as-nodes model. In particular concepts (nodes) can feature
        consistently in several beliefs. Moreover, the beliefs-as-edges model can be translated to a 
        beliefs-as-nodes model (at the expense of additional nodes) by taking the line graph operation and 
        removing edges such that the balance condition holds on node-triads in the resulting graph.
      - Potential dissonance between personal beliefs given by @dalege_networks_2025 
        $ H_"pers" = sum_i tau_i b_i - sum_(i j) omega_(i j) b_i b_j $

    + Causal discovery:

    + Dataset:
      - Description: longitudinal study on climate attitudes in the US, collected between ... and .... 
      - Source
      - Intention
      - Two dimensions: population and time.
        - Time
          - Six waves
          - Each individual is present in a subset of the waves. These can be not noncontiguous.
        - Population: 
          - Unsure about key statistics ($n$, sampling methods)
      - Questions:
        - Demographic/population groups
        - Experiences
        - Beliefs/attitudes
      - No relationship information (as far as I am aware), so we will disregard social connections in 
        model for purposes of model-fitting.
  ]
}



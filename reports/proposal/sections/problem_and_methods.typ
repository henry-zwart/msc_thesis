#{
  set text(fill: luma(140))
  [
    *To-do:* Rework following section to tie in significance (required per 
    the proposal template). 
    Perhaps reframe around two questions: 
    + Ontological --- '_what are_ the dynamics of internal beliefs?' and 
    + Pragmatic --- 'how would _intervening_ on beliefs change the behaviour of individuals or 
      collectives?'
  ]
}



The sensitivity of individuals' behaviour to their underlying preferences,
attitudes, and beliefs is well-acknowledged in cognitive psychology. Moreover, 
work in collective dynamics has shown that the preferences of select individuals 
can also disproportionately influence population-level behaviour in qualitatively 
predictable ways @mittal_anticonformists_2024. These findings underscore the 
risk to realism imposed by neglecting internal belief (preference) dynamics in 
models of collective behaviour.

Recent efforts to model such internal belief dynamics are primarily motivated 
to explain how known phenomena such as polarisation or minority influence may 
arise, often through conflicting social conformity and dissonance reduction 
pressures. To this end they have been largely successful, even under
considerable simplifying assumptions regarding the structure and causal 
directionality of beliefs and their relations.

However, for a particularly salient class of questions concerning the behavioural
implications of _intervening_ on individuals' beliefs, these simplifying 
assumptions are on weaker footing. 

#{
  set text(fill: luma(140))
  [
    - Illustrate why structural and causal assumptions are potentially important for 
      intervention:
      - Star graph -- depending on arc directions may be best/worst to target central
        belief.
    - What do we plan to do?
      - Extend/modify existing internal belief models to support directed relations.
      - Investigate implications of structural and causal assumptions on belief networks
        inferred from climate attitudes data:
        - Undirected Ising model, directed, directed with arcs obtained via causal 
          discovery.
        - Variation across population groups.
        - Implications for intervention (*expand on this*)
  ]
}

*Research context:*
- Internal belief models:
  - Social conformity and cognitive dissonance
  - Beliefs as edges vs beliefs as nodes

*Methods:*
- Starting model
  - Two possible starting points: beliefs as edges (relations between concepts)
    or beliefs as nodes @dalege_networks_2025. 
  - Directed relations don't have a natural interpretation in the former. 
    Belief is typically considered a symmetric relation (if you believe 
    $A "and" B$, then you also believe $B "and" A$). However, this representation 
    does have benefits (concepts can appear in many beliefs), and it can be 
    transformed into the latter representation at the cost of additional nodes. 
  - The latter is more immediately amenible to directed edges. Since beliefs are 
    nodes, a directed relation $A --> B$ is interpreted as "if you believe $A$, 
    then also $B$, but not necessarily the converse".
- Dataset
- Causal discovery 






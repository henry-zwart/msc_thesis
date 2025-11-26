The sensitivity of individuals' behaviour to their underlying preferences,
attitudes, and beliefs is well-entrenched in common knowledge. However, 
recent work in collective dynamics has shown that the internal states of 
select individuals can also disproportionately influence population-level 
behaviour in dramatic, and qualitatively predictable ways 
@mittal_anticonformists_2024. These findings underscore the risk to realism 
imposed by neglecting internal state dynamics in models of collective 
behaviour. 

Recent efforts to model such internal belief dynamics are primarily motivated 
to explain how known phenomena such as polarisation or minority influence may 
arise, often through conflicting social conformity and dissonance reduction 
pressures @rodriguez_collective_2016 @aiyappa_emergence_2024 @dalege_networks_2025. 
To this end they have been largely successful, even under considerable simplifying 
assumptions regarding the structure and causal directionality of beliefs and their 
relations.

A separate, but particularly salient, class of questions concerns the behavioural 
implications of _intervening_ on individuals' beliefs. For instance,

#align(center)[_'Which belief(s)
should one target, and in which individuals, to promote a particular behaviour?'_]

or conversely, 

#align(center)[_'Could targeting certain beliefs, or in certain individuals, result in 
a behavioural rebound?'_]

For this purpose, however, simplifying assumptions regarding the structure
and causal relations between beliefs are on significantly weaker footing. As illustrated 
in @fig:stargraph, if beliefs are causally supported by other beliefs, then the direction 
of this causality and the general structure of the belief network can potentially decide 
the effectiveness of an intervention.

We propose to investigate the extent to which these structural and causal assumptions influence 
the dynamics of internal belief networks, in the context of a longitudinal survey on climate 
attitudes in the US. We will extend and/or modify existing Ising models of internal belief 
to include directed relations. 

#figure(
  grid(
    columns: 2,
    column-gutter: 10em,
    image("../stargraph_out.pdf"),
    image("../stargraph_in.pdf"),
  ),
  caption: [
    Belief network with five beliefs (nodes). *(Left)* Intervening on the central belief 
    changes support for all other beliefs. *(Right)* Intervening on the central belief is more difficult since 
    it is supported by all others, and doing so has no implications for other beliefs.
  ]
) <fig:stargraph>


// #{
//   set text(fill: luma(140))
//   [
//     - What do we plan to do?
//       - Extend/modify existing internal belief models to support directed relations.
//       - Investigate implications of structural and causal assumptions on belief networks
//         inferred from climate attitudes data:
//         - Undirected Ising model, directed, directed with arcs obtained via causal 
//           discovery.
//         - Variation across population groups.
//         - Implications for intervention (*expand on this*)
//   ]
// }

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






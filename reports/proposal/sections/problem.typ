The sensitivity of individuals' behaviour to their underlying preferences,
attitudes, and beliefs is well-entrenched in common knowledge. However, 
recent work in collective dynamics has shown that the internal states of 
select individuals can also influence population-level behaviour in dramatic, 
and qualitatively predictable ways @mittal_anticonformists_2024. These 
findings underscore the risk to model realism imposed by neglecting internal state 
dynamics in models of collective behaviour. 

Recent efforts to model such internal belief dynamics are primarily motivated 
to explain how known phenomena such as polarisation or minority influence may 
arise, often through conflicting social conformity and dissonance reduction 
pressures @rodriguez_collective_2016 @aiyappa_emergence_2024 @dalege_networks_2025. 
To this end they have been largely successful, even under considerable simplifying 
assumptions regarding the structure and causal directionality of beliefs and their 
relations.

A separate, but particularly salient, class of questions concerns the behavioural 
implications of _intervening_ on individuals' beliefs. For instance,

#align(center)[
  _'Which belief(s) should one target, and in which individuals, to promote 
  a particular behaviour?'_
]

or conversely, 

#align(center)[
  _'Could targeting certain beliefs, or in certain individuals, result in a 
  behavioural rebound?'_
]

For this purpose, however, simplifying assumptions regarding the structure
and causal relations between beliefs are on significantly weaker footing. 
As illustrated in @fig:stargraph, if beliefs causally support one another, 
then the direction of this causality can decide the effectiveness of intervention.


#figure(
  grid(
    columns: 2,
    column-gutter: 10em,
    image("../figures/stargraph_out.pdf"),
    image("../figures/stargraph_in.pdf"),
  ),
  placement: none,
  caption: [
    Belief network with five beliefs (nodes). *(Left)* Intervening 
    on the central belief changes support for all other beliefs. 
    *(Right)* Intervening on the central belief is more difficult 
    since it is supported by all others, and doing so has no 
    implications for other beliefs.
  ]
) <fig:stargraph>

#let vacc_intervention_fig = figure(
  image("../figures/vaccination_intervention.pdf"),
  placement: top,
  caption: [
    Intervening on family wellbeing beliefs (F) could either positively 
    or negatively influence preference for vaccination (V), depending on 
    other beliefs about the relative danger of disease and vaccination (D),
    which may vary with individual experience (E). 
  ]
) 

#let vacc_intervention_par = [
  The implications of particular interventions may also vary with
  beliefs or experiences. For instance, appealing to beliefs about 
  family wellbeing may promote vaccination behaviour in some 
  individuals, but discourage it in others, depending on their 
  beliefs regarding the relative dangers of disease and vaccination 
  (@fig:vaccination-intervention). 
]

#grid(
  columns: (1fr, 2.25fr), 
  column-gutter: 2em,
  align: horizon,
  vacc_intervention_par,
  [#vacc_intervention_fig <fig:vaccination-intervention> ],
)

#{
  set text(fill: luma(140))
  [
    *Research intent:*
    - Investigate implications of structural and causal assumptions on belief networks
      inferred from climate attitudes data.
    - Note that fitting the models to empirical data is interesting in itself. Previous 
      papers have mostly used empirical proxies (e.g. correlations) or manually-set 
      parameters.
    - Broader programme of work: controlled experiments testing behaviour change 
      resulting from belief intervention.
  ]
}

#{
  set text(fill: luma(140))
  [
  *Present research questions/intented contributions: *
  - _(Contribution)_: Framework for inferring belief relations from data; studying 
    behavioural effects of intervening on beliefs.
    - The word 'framework' is vague here --- perhaps a combination of:
      + A formal model of causal internal belief dynamics, based on existing 
        undirected models;
      + Model-fitting considerations, assumptions, trade-offs, suggestions, etc.
        (This is a more appropriate place to use 'framework');
      + Methods for analysing the implications of belief-level intervention in 
        undirected, directed, and directed-causal models.
  - _(RQ1)_: How do relations between beliefs about climate change (policy?) vary 
    across population groups, and under different structural assumptions? 
  - _(RQ2)_: How do the implications (outcome, effectiveness) of belief-level interventions
    vary under different structural assumptions. 
  - _(RQ3)_: 'Something about identifying effective interventions, or ones whose outcomes 
    differ from those predicted by undirected models; possibly also considering alignment with
    theories of persuasion (e.g., focusing on shared community values @the_workshop_how_2024)'.

  ]
}

We propose an empirical investigation into the nature of real belief networks in 
the context of a longitudinal survey on climate attitudes in the US.  We intend 
to characterise the extent to which structural and causal assumptions can alter 
the outcome or effectiveness of intervention at the level of individuals' beliefs 
(e.g., as in Figures @fig:stargraph[] and @fig:vaccination-intervention[]). 
More specifically, we will address the following research questions:

#{
  set enum(numbering: "RQ1.", indent: 1em)
  block(width: 97%, [
    +  How do beliefs about climate change, and the relations between beliefs, 
      vary across population groups and under different structural and causal 
      assumptions regarding belief dynamics? <RQ1>

    + To what degree are the implications (outcome, effectiveness) of belief-level 
      interventions influenced by structural and causal assumptions regarding belief 
      dynamics? <RQ2>

    + How do predictions regarding belief-level intervention effectiveness compare 
      with classical theories of belief change? <RQ3>
  ])
}

#let rq1 = link(<RQ1>)[*RQ1*]
#let rq2 = link(<RQ2>)[*RQ2*]
#let rq3 = link(<RQ3>)[*RQ3*]

#{
  set text(fill: luma(140))
  [
    *Research context:*
    - Coupled system, social network and internal beliefs
    - Social conformity and cognitive dissonance
    - Beliefs as edges vs beliefs as nodes
  ]
}

While the present study specifically concerns the dynamics of belief networks,
we consider recent models of coupled _social_ and belief dynamics inspired by 
statistical physics as a foundation for our work, so as to leave the door open 
to future research concerning the implications of belief intervention on collective
behaviour. Nevertheless, we focus here on the belief dynamics aspects of these 
models.

These models tend to describe the evolution of individuals' beliefs as actions to 
reduce cognitive dissonance within a network of internal states, and can be further 
subcategorised according to whether they treat beliefs as edges (*BAE*) or as nodes 
(*BAN*). The former consider beliefs as associations between concepts 
@rodriguez_collective_2016 @aiyappa_emergence_2024, while the latter consider 
(typically undirected, signed, and weighted) edges between nodes as correlations 
between related or conflicting beliefs @dalege_attitudinal_2018 @dalege_networks_2025.

The causal assumptions of interest in #rq1 and #rq2 take the form of implied
beliefs. That is, a directed relation $A -> B$ indicates that belief in $A$ implies 
belief in $B$, or equivalently, belief in $A$ _necessitates_ belief in $B$. This 
is a natural interpretation of BAN models modified to include directed edges; however,
the same natural interpretation does not exist for BAE approaches. If we take $cal(b)_i$ 
as representing individual $i$'s belief in some object or relation, then directed edges 
in BAN approaches correspond to implications _between_ beliefs, 
$cal(b)_i (w) => cal(b)_i (x)$, while in BAE approaches they correspond to beliefs _about_ 
implications, $cal(b)_i (y => z)$.

This difference highlights an additional distinction with particular relevance to 
inferring realised beliefs (#rq1). In BAN models a set of beliefs is judged 
unstable if some $cal(b)_i (w) => cal(b)_i (x)$ is contradicted by $i$'s other beliefs, 
which depends on the realised values of $cal(b)_i (w), cal(b)_i (x)$. On the other hand, 
in BAE models a set of beliefs is unstable if $cal(b)_i (y => z)$ is contradicted by $i$'s 
beliefs regarding a set of other implications. Since $y => z$ is satisfied#footnote[
  Assuming an intelligible interpretation of what it means for a concept to be true or false.
] by #box[$not y or z$], 
a stable belief configuration can, in general, be realised in multiple ways. Hence BAE 
stability is distinct from individuals' concrete beliefs, and rather concerns the logical 
satisfiability of relations between concepts. So, assuming these notions of stability, 
BAN models are better-suited to inferring actual (realised) beliefs.

For these reasons, we consider the beliefs-as-nodes approach a more appropriate foundation
for this study. In particular, we will extend the 'Networks of Belief' model recently 
proposed by #cite(<dalege_networks_2025>, form: "author") to include directed relations.


// Among the diversity of internal belief models that have been proposed in recent 
// years, those inspired by statistical physics theories -- in particular, the Ising 
// model -- have proved adept at capturing the coupled dynamics of beliefs and social 
// interactions. Our proposed research direction concerns belief dynamics, so we 
// focus here on comparing these models along this dimension only. Nevertheless, we 
// are motivated by _behavioural_ implications of intervention, and since collective 
// behaviour is sensitive to individuals' beliefs, by restricting our view to such models
// we leave the door open to future work. 
//
//
// Models in this class typically represent beliefs and their relations as weighted
// networks, and can be categorised according to whether they represent beliefs as 
// _edges_ (*BAE*) @rodriguez_collective_2016 @aiyappa_emergence_2024 or as _nodes_ 
// (*BAN*) @dalege_attitudinal_2018, @dalege_networks_2025. 
//
// In BAE models, beliefs (edges) are signed 'associations' relating pairs of concepts
// #footnote[
//   #cite(<aiyappa_emergence_2024>, form: "prose") adopt an inclusive definition with 
//   nodes representing concepts, entities, and general notions such 'good' or 
//   'dangerous' @aiyappa_emergence_2024[p.~2].
// ] (nodes). Each concept can feature in arbitrarily-many belief relations, and 
// belief updates are interpreted as changes in associations between concepts. On the other 
// hand, in BAN models, signed values describe the strength and direction of beliefs
// #footnote[
//   #cite(<dalege_networks_2025>, form: "prose") adopt a similarly inclusive definition 
//   of _beliefs_, encompassing 'assumptions about the state of the world, views on moral
//   and political issues, evaluations of attitudes, or [individuals'] own preferences.' 
//   @dalege_networks_2025[p.~2] @galesic_integrating_2021.
// ] (nodes), while 
// weighted edges describe correlation beween related or conflicting beliefs. Belief 
// updates are interpreted as changes in the strength an individual ascribes to a particular
// belief. 
//
// Both categories take 'cognitive dissonance reduction' as the core mechanism driving 
// individuals' belief dynamics. Updates to individuals beliefs act (in expectation) to 
// reduce cognitive dissonance --- inconsistencies among beliefs or their relations --- 
// captured by the energy of a belief system. The BAE models considered here measure dissonance
// as proportional to the number of 'unstable triads' in a belief system, while the Networks of 
// Belief BAN model adopts the classical network Ising model energy function, comprising 
// interaction (misalignments between related beliefs) and field (exogenous influences on 
// specific beliefs, e.g., life factors, personal experience) terms.



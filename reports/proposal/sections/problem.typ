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
then the direction of this causality and the general structure of the belief 
network can decide the effectiveness of intervention.


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

We propose an empirical investigation into the nature of real belief networks in 
the context of a longitudinal survey on climate attitudes in the US.  We intend 
to characterise the extent to which structural and causal assumptions can alter 
the outcome or effectiveness of intervention at the level of individuals' beliefs 
(e.g., as in Figures @fig:stargraph[] and @fig:vaccination-intervention[]).

This work will extend the undirected Networks of Belief model introduced by 
#cite(<dalege_networks_2025>, form: "author") to include directed relations. We 
will also consider a restricted class of directed models, where the set of relations 
and their directions are inferred via causal discovery. We refer to the respective 
model variations as *undirected*, *directed*, and *directed-causal*. More loosely,
we refer to these variations as 'structural assumptions'.

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

#{
  set text(fill: luma(140))
  [
    *Research context:*
    - Coupled system, social network and internal beliefs
    - Social conformity and cognitive dissonance
    - Beliefs as edges vs beliefs as nodes
  ]
}


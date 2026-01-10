#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

// // A paragraph or two describing what the authors intention was, their method, findings, and any important notes, limitations, 
// // or implications.
// *Overview:*
//
// // Follow-up tasks for me to do, based on reading of this paper. Excluding additional reading (see tagged notes on Zotero).
// *Tasks:*
//
// // Who are the intended readers of the paper? i.e., whose minds are the authors attempting to change?
// *Audience:* 
//
// // If necessary, what extra info is necessary to understand the problem (below)?
// *Problem context:* 
//
// // What problem, conflict, or gap have the authors identified in the literature?
// *Problem:* 
//
// // What do the authors hope to learn?
// *Intent:* 
//
// // What specific questions are they asking, in order to satisfy the intent? 
// *Research questions:* 
//
// // What conclusions did they draw based on their results? What other contributions were made (e.g., a method for evaluation, or a new model)?
// *Claims and contributions:*
//
// // What were the key (relevant) limitations of the study? Did you identify any potential issues?
// *Limitations:*
//
// // Whose research did they build on? Did they compare to anyone in particular?
// *Connections to other research:*
//
// *Other notes:*


= What is Central to Political Belief System Networks @brandtWhatCentralPolitical2019

*Tasks:*
- Look into partial correlation networks, and contrast with Ising model

*Audience:* Quantitative political science and sociology

*Problem:* Prior attempts to determine central components of political belief systems do not typically consider the global network structure of belief systems, so may falsely identify peripheral relationships between beliefs/attitudes as central.

*Research questions:*
  - Are operational components of belief systems more 'central' in those systems than symbolic components, or vice versa? 
  - To what degree are operational and symbolic components associated with political (voting) behaviours? (Based on the hypothesis that more central $-->$ stronger association.)

*Claims/contributions:*
  - (Contribution 1) Partial correlation network constructed for operational and symbolic components of political belief systems, based on longitudinal survey data from New Zealand.
  - (Contribution 2) A more continuous method than is typical for assessing centrality of belief system components. Authors assert that typical approaches dichotomise components into 'central' and 'peripheral' categories.
  - (Claim 1) Symbolic components are more 'central' than operational components, on all considered measures of centrality (strength, closeness, betweenness).
  - (Claim 2) If symbolic or operational components tend to be more 'central' than the other, then the more central component should be closer in the network to voting behaviour. 
    - _This claim should be examined more closely. While they cite other work as supporting it, the claim is not well-reasoned in the paper, especially given the loose treatment of 'centrality' interpretation in partial correlation networks._
  - (Claim 3) In political belief systems, symbolic attachments to parties and labels are more important than actual policy positions.
    + _Does the strong importance claim follow from the reported centrality results, i.e., is their measure of centrality sufficient to encompass the typical dimensions we may judge the importance of a belief system component?_
    + _How sensitive are the centrality results (and hence importance claim) to the authors' use of a partial correlation network?_

*Other notes:*
  - The study uses longitudinal data primarily to check consistency of results over time. i.e., they construct a partial correlation network for each wave of survey data.
  - The authors acknowledge the limited interpretability of centrality in absence of causation (their edges are directed partial correlations), and that causal structures could theoretically change the support for their claims. In particular they refer to the possibility of a sink-like structure where some belief is only a consequence, and never a cause; however, _they consider this structure unlikely to occur._

*Operational and symbolic components:* Operational components refer to particular positions on issues, while symbolic components refer to 'affective attachments to political groups and labels'. The authors identify survey questions deemed as assessing each of the categories. A question is considered *symbolic* if it asks about support (identification) for (with) political groups or labels. A question is considered *operational* it is concerns support for a particular policy. Overall there were 

*Possible limitations:*
- The term 'centrality' can be used generally in multiple different senses, but has specific technical meanings in network science. The authors have provided some justification for their centrality measures with respect to dynamics on the partial correlation network, though I find this falls short in two ways. Firstly, they do not justify that these measures capture the typical (everyday) uses of the term 'centrality' in this context. Secondly, they provide limited discussion on interpreting partial correlation networks as belief systems. Thus the use and interpretation of these measures have not been well-justified. 

- The authors consider only binary relations between components.

- The belief system components are not beliefs per-se, but rather positions or attitudes implied by underlying beliefs. For instance, consider the survey question regarding '_Reserving places for Māori students to study medicine_'. Participants may not have previously formed any particular belief regarding this issue, yet their response may depend on their established beliefs concerning equitable societies and the importance of medicine as a field of study. Furthermore, it is conceivable that this causation flows in one direction, i.e., that an individual's position on this issue cannot measurably influence their underlying beliefs. If this is true, and measurements have unmeasured common causes, then correlation between responses may not imply any direct relationship between these components.

- Some of the centrality measures require a different interpretation in directed networks. For instance, strength and closeness may vary when considering incoming versus outgoing edges. 

- The measurement interval (2009-2016) does not include a change in government.

- The networks do not attempt to describe belief systems of individuals, but rather variation across the population.


#definition(title: [Strength centrality @brandtWhatCentralPolitical2019])[
  For a node in a belief system, the sum of absolute edge weights connecting directly to the node.
] <def:brandt-strength-centrality>

#definition(title: [Closeness centrality @brandtWhatCentralPolitical2019])[
  For a node in a belief system, the inverse sum of (shortest) distances to each other node.
] <def:brandt-closeness-centrality>

#definition(title: [Betweenness centrality @brandtWhatCentralPolitical2019])[
  For a node in a belief system, the number of shortest paths between other pairs of nodes, which contain
  this node.
] <def:brandt-betweenness-centrality>

= Measuring the belief system of a person @brandtMeasuringBeliefSystem2022


*Tasks*
- Possibly re-run analysis with suggested fix for controls.
- Brandt mentions a measure for 'attitude consistency', which I do not yet understand. See 'Procedures and 
  Methods', page 835.
- Consider risks of excluding data from climate attitudes survey due to missing responses or participants. 
  This is likely not missing-at-random.

*Audience:* Political belief systems/sociology

*Problem:* Typical empirical studies on belief systems consider data aggregated at the population level, 
while theories of belief systems assume these to be individual-level constructs. In other words, such
empirical studies violate a core assumption of their underlying theory.

*Research questions:* To what degree are conceptual similarity reports a reliable and valid approach to 
estimating individual belief system structure in a political belief context?

*Claims and contributions:*
- (Contribution) Conceptual similarity as a method for estimating individual's belief system structures.
- (Claim) Conceptual similarity ratings accurately track true similarity between political attitudes
- (Claim) Conceptual similarity observations are consistent with behaviour predicted by theoretical 
  computational models (Brandt-Sleegers, Goldberg-Stein)
  - *Note:* This is subject to the statistical controls limitation discussed below.

*Limitations*
- Possible issues in statistical controls may invalidate some results from studies 1---3
- Multiple realisability may compromise ability to draw structural conclusions from pairwise
  belief survey questions (cf. Guest)
- Conceptual similarity does not capture causal directionality
- They classify attitude pairs as ideologically consistent or inconsistent. However, this 
  (i) assumes a single dimension for ideological, and (ii) dichotomises each pair, when we could 
  reasonable speak of degrees, and expect differing degrees to affect dynamics.

*Connections to other research*
- Reflecting on two theoretical/computational models of belief systems (Brandt-Sleegers, Goldberg-Stein).

*Possible error in choice of Controls* (Notes, causal DAG on iPad)

= Modeling and leveraging intuitive theories to improve vaccine attitudes @powellModelingLeveragingIntuitive2023

*Overview:* Per the Duhem-Quine underdetermination thesis, when an individual's beliefs on a particular topic
are put to question (e.g., after observing relevant evidence, or following a targeted intervention), the degree 
and direction in which belief revision happens can be sensitive to auxiliary hypotheses or beliefs, which conflict 
or reinforce the target belief. 

The authors propose a method using Bayesian networks to model 
#link("https://henry-zwart.github.io/msc_thesis/glossary/#intuitive-theory")[intuitive theories]. They select
14 beliefs judged as related to a selected target belief (vaccination intention), and undertook a survey to determine 
individual positions on each of these beliefs. Each belief was assessed using several survey questions, with the final
value taken as the normalised average score. The relations between beliefs were inferred using a Beta regression on the 
weights between beliefs (as conditional probabilities), with the added prior restriction that directionality should 
flow from more general to more specific beliefs. This model captures conditional probabilistic relations between beliefs,
at a _population-aggregated_ scale.

Using the fit model, the authors perform several experiments testing its adequacy at explaining the effects of belief
intervention, and observation of evidence, on both the target belief and auxiliary beliefs. This includes replicating
an existing study shown to be effective at shifting vaccination intentions, and a novel study for the same purpose, 
where the authors instead intervened on a belief predicted by the model to be promising for intervention.


*Tasks:*
- Fit directed Ising model to same dataset --- do we get the same graph?
- Review interaction models in Statistical Rethinking textbook
- Investigate differences between Bayesian networks and Ising models. How are they representationally different?
  What are the implications? Perhaps summarise the two model families in a separate document.
- In the 'broader implications' section, the authors suggest questions we might ask to infer belief networks 
  related to climate change. Compare this list against the variables in our data.

*Audience:* Cognitive modelling, applied and theoretical psychology

*Problem:* Intuitive theories, which support much of human thought, can also reinforce misconceptions 
which constitute a major health risk in the context of vaccination. To address these misconceptions, 
it is necessary to understand how they are produced by underlying conceptual/belief systems. Yet our 
understanding here is limited. 

*Research questions:* 
- To what degree is belief-revision (from intervention; from observation of evidence) sensitive to auxiliary 
  beliefs? (cf. Duhem, Quine)
- Can inferred population-aggregate-level Bayesian networks representing intuitive theories be used 
  to non-trivially (i) aid in explaining the success or failure of belief revision outcomes, (ii) reason about 
  the effects of intervention on distant, or indirectly-related beliefs, and (iii) design novel effective 
  interventions for vaccination intention?

*Claims and contributions:*
- (Contribution) A method for generating directional cognitive models of belief (of a population) for 
  a particular domain.
- (Contribution) A plausible population-level cognitive model of beliefs relating to vaccine intention.
- (Claim) Domain-specific Bayesian network models of population-aggregated beliefs can help explain the success 
  or failure of interventions, with respect to auxiliary hypotheses or beliefs.

*Limitations:*
- Model is population-level, so aggregates over individuals rather than representing individual differences.
- "Difference in difference" analyses are difficult to interpret, since they do not incorporate distributional
  skew.

*Connections to other research:*
- Authors note limitations of structure learning algorithms using correlations to identify causal 
  directionality. They suggest future work could ask participants about their perceived causal directionality.
  This is similar to @brandtMeasuringBeliefSystem2022.

*Study intentions:*
+ Develop a cognitive model of 14 beliefs related to vaccine hesitancy in U.S.
+ Replicate success of an existing intervention, and use model from (1) to explain _how_ and _why_
  the intervention works, as well as its effects on related beliefs.
+ Create and validate the success of a novel intervention to address concerns about toxic additives
  in vaccines.
+ Test whether peoples' beliefs changed coherently following relevant real-world events, examining 
  beliefs before and after a serious measles outbreak.

*Other notes:*
- They show that intervening on one part of the belief network can induce changes in other parts. 
  Perhaps this could also inform belief system inference. If we intervene on a particular belief
  and another belief changes, then they are likely closely related in the network. If some other belief
  shows no change, then the two are likely not related, related only weakly, or only via a higher-order
  interaction, e.g., with a third belief.
- They note that auxiliary hypotheses and beliefs can affect belief revision outcomes (per Duhem-Quine thesis).

#figure(
  block(width: 80%,
  table(
    columns: 3,
    align: (right, left, left),
    stroke: none,
    table.header[Category][Belief topic][Further explanation],
    table.hline(stroke: 0.7pt),
    [Vaccines], [Vaccination intentions], [Intention to vaccinate children (or hypothetical children)],
    [], [Vaccine danger], [],
    [], [Toxic additives in vaccines], [],
    [], [Vaccine effectiveness], [Effectiveness at _preventing_ disease],
    table.hline(stroke: 0.7pt),
    [Childhood diseases], [Disease rarity], [],
    [], [Disease severity], [],
    table.hline(stroke: 0.7pt),
    [Infant immune system (IIS)], [IIS: weakness], [],
    [], [IIS: limited capacity], [Limited in capacity and easily overwhelmed],
    [], [IIS: vaccines strain], [Vaccined strain the infant immune system],
    table.hline(stroke: 0.7pt),
    [Parenting and medicine], [Parental protectiveness], [],
    [], [Parental expertise], [i.e., that parents usually know more about their children's health than medical experts],
    [], [Medical skepticism], [Including concerns about pharmaceutical companies and corruption in the medical community],
    table.hline(stroke: 0.7pt),
    [Worldviews], [Naturalism], [Preference for natural over artificial things],
    [], [Holistic balance], [Related to attitudes toward alternative medicine],
  )
  ),
  caption: [Psychometric scales used in a Study 1 of @powellModelingLeveragingIntuitive2023.]
)

= The nature and structure of European belief systems: exploring the varieties of belief systems across 23 European countries @vannoordNatureStructureEuropean2025

*Overview:*

*Tasks:*
- They use correlational class analysis @boutylineImprovingMeasurementShared2017 to identify groups of people 
  whose beliefs are correlated similarly (but who may differ in what those beliefs are). 
  + Could we modify this method to identify such groups in a causal setting? i.e., considering implication rather 
    than correlation?
  + Alternatively, could the correlational analysis results be used to inform a subsequent causal analysis. i.e.,
    what would a positive result in the CCA imply if we permit causal relations for the same data?
- Review the Bayesian phylogenetic tree inference. Could a similar approach be used to identify connections in how
  the belief systems identified by CCA have evolved? Or perhaps a more standard phylogenetic tree inference algorithm? 

*Audience:* 

*Problem context:* 

*Problem:* Belief system research has predominantly focused on single countries, and often the US. We have 
limited insight into whether and how belief systems vary between countries.

*Intent:*
- What do belief systems in European societies have in common?
- What do the people who hold different belief systems in European societies have in common?

*Research questions:* 
- Are political belief system structures similar _across_ Europe?
- Which demographic groups are likely to have similar belief systems _within_ countries?
- How are belief systems related to voting behaviour?

*Claims and contributions:*

*Limitations:*

*Connections to other research:*
- Mark Brandt is a co-author, and authored several other papers we consider here @brandtWhatCentralPolitical2019 
  @brandtMeasuringBeliefSystem2022.
- Cites Converse, like many of the other papers we have considered. 

*Other notes:*

#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

#let glossary(term, body) = link("https://henry-zwart.github.io/msc_thesis/glossary/#" + term, body)

// // A paragraph or two describing what the authors intention was, their method, 
// // findings, and any important notes, limitations, 
// // or implications.
// *Overview:*
//
// // Follow-up tasks for me to do, based on reading of this paper. Excluding 
// // additional reading (see tagged notes on Zotero).
// *Tasks:*
//
// // Who are the intended readers of the paper? i.e., whose minds are the 
// // authors attempting to change?
// *Audience:* 
//
// // If necessary, what extra info is necessary to understand the problem 
// // (below)?
// *Problem context:* 
//
// // What problem, conflict, or gap have the authors identified in the 
// // literature?
// *Problem:* 
//
// // What do the authors hope to learn?
// *Intent:* 
//
// // What specific questions are they asking, in order to satisfy the 
// // intent? 
// *Research questions:* 
//
// // Outline of main methods/analysis
// *Methods:*
//
// // What conclusions did they draw based on their results? What other 
// // contributions were made (e.g., a method for evaluation, or a new model)?
// *Claims and contributions:*
//
// // What were the key (relevant) limitations of the study? Did you 
// // identify any potential issues?
// *Limitations:*
//
// // Whose research did they build on? Did they compare to anyone in 
// // particular?
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

= Modelling and leveraging intuitive theories to improve vaccine attitudes @powellModelingLeveragingIntuitive2023

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
    [], [Medical scepticism], [Including concerns about pharmaceutical companies and corruption in the medical community],
    table.hline(stroke: 0.7pt),
    [Worldviews], [Naturalism], [Preference for natural over artificial things],
    [], [Holistic balance], [Related to attitudes toward alternative medicine],
  )
  ),
  caption: [Psychometric scales used in a Study 1 of @powellModelingLeveragingIntuitive2023.]
)

= The nature and structure of European belief systems: exploring the varieties of belief systems across 23 European countries @vannoordNatureStructureEuropean2025

*Overview:* The authors present a 'bottom-up' method for identifying (population-aggregate) belief systems 
within and between populations, based on shared correlational structures rather than particular belief 
states. They use this method to analyse existence and similarity of belief systems across Europe. 

*Tasks:*
- They use correlational class analysis @boutylineImprovingMeasurementShared2017 to identify groups of people 
  whose beliefs are correlated similarly (but who may differ in what those beliefs are). 
  + Could we modify this method to identify such groups in a causal setting? i.e., considering implication rather 
    than correlation?
  + Alternatively, could the correlational analysis results be used to inform a subsequent causal analysis. i.e.,
    what would a positive result in the CCA imply if we permit causal relations for the same data?
- Review the Bayesian phylogenetic tree inference. Could a similar approach be used to identify connections in how
  the belief systems identified by CCA have evolved? Or perhaps a more standard phylogenetic tree inference algorithm? 
- Their analysis is quite complex. Will need to re-read this paper in detail, and make notes on their methods.
- Review Statistical Rethinking on Latent Factor analysis. Possibly another approach to identifying 
  common threads?

*Audience:* Social psychology, cognitive modelling

*Problem:* Belief system research has predominantly focused on single countries, and often the US. We have 
limited insight into whether and how belief systems vary between countries.

*Intent:*
- What do belief systems in European societies have in common?
- What do the people who hold different belief systems in European societies have in common?

*Research questions:* 
- Are political belief system structures similar _across_ Europe?
- Which demographic groups are likely to have similar belief systems _within_ countries?
- How are belief systems related to voting behaviour?

*Methods:*
- _Identifying belief systems:_ #link("https://henry-zwart.github.io/msc_thesis/glossary/#cca")[Correlational class analysis (CCA)]
  per country to identify *clusters of individuals* based on how their beliefs relate to one another 
  (i.e., they may not hold the same beliefs, but their beliefs are correlated in the same ways). The clusters represent belief systems.
- _Structure of a belief system:_ For each correlational class (cluster of individuals), authors produce
  a correlation matrix relating beliefs to beliefs. This can be viewed as a network, where strong positive
  (negative) edges reflect strong positive (negative) correlations between beliefs.
- _Identifying similar belief systems:_ Authors calculate Pearson correlation between each pair of belief 
  systems, across all countries. The resulting correlation matrix reflects the similarity between each 
  pair of belief systems. Authors cluster the corresponding network to identify groups of similar belief 
  systems.
- _How many dimensions per belief system:_ PCA on each belief system separately. Then factor analysis to 
  determine possible number of "meta-dimensions" that organise the identified principal components.
- _What are the underlying dimensions:_ Finding little support for a 1D belief-system, authors consider 
  the two-factor solution to factor analysis (above), counting how often two beliefs have $> 0.3$ loading 
  on the same dimension (factor).
- _How are the dimensions related to one another:_ *Didn't quite understand, as it relied on 
  understanding the prior analysis classifying the underlying dimensions, and I did not quite 
  get this.*

*Findings:*
- _Number of belief systems:_ 70 across 23 countries, with 2---5 per country. 
- _Groups of systems:_ Two clusters of belief systems.
- _Similarity between belief systems:_ Across all countries, between-belief system correlation is 
  in $[-0.053, 0.792]$ with a mean of $0.326$. So some similar belief systems, but lots of variation.
- _Within-cluster similarity:_ Group 1 more similar than Group 2.
- _Constraint (structuredness):_ Similar mean #glossary("density")[density] between the groups. 
  Within each group there exists more variation in density. Key finding: main difference between groups 
  is not their structuredness.
- _How many dimensions per belief system:_ 
  - PCA: Between 6 and 9 per belief system with eigenvalues $> 1$.
  - Factor analysis: Almost all belief systems in Europe multidimensional.
- _What are the underlying dimensions:_ Belief-pairs with high loading ($> 0.3$) on a given factor 
  typically both economic or both cultural. Suggests factors describe economic or cultural dimensions 
  rather than a mix.
  - *Struggled to understand this section --- to review*
- _How do dimensions relate to each other:_ In Group 1 right-wing cultural beliefs tend to go with 
  right-wing economic beliefs, while in Group 2 right-wing cultural beliefs tend to go with left-wing 
  economic beliefs. However, the correlations are small. Likely due to many factors not classified as 
  cultural or economic --- if these follow a different logic then their correlations are unlikely to be 
  in-line with cultural or economic factors.

*Claims and contributions:* 
- (Contribution) A 'bottom-up' method for analysing the belief systems held _within_ a population 
  and _between_ populations.
- (Contribution) Qualitative analysis of the variation in, and types of belief systems present across 
  Europe.
- (Claim) Belief systems in Europe can be broadly categorised into two groups, one of which exhibits 
  positive correlation between cultural and economic dimensions (i.e., right-wing goes with right-wing), 
  and one of which exhibits negative correlation. These types were also associated with various 
  demographic features (in particular *education*), and geographic location in Europe.

*Limitations:*
- Only considers bidirectional correlations
- Some potential statistical methodological issues in analysis (treating demographic variables as 
  independent; excluding data with 'zeroes' rather than modelling it)

*Connections to other research:*
- Mark Brandt is a co-author, and authored several other papers we consider here @brandtWhatCentralPolitical2019 
  @brandtMeasuringBeliefSystem2022.
- Cites Converse, like many of the other papers we have considered. 

*Other notes:*
- Survey questions selected from the 2016 European Social Survey, comprising question to test both 
  #glossary("operational-component")[operational] and #glossary("symbolic-component")[symbolic] components
  of belief systems.

= Variations in climate change belief systems across 110 geographic areas @leeVariationsClimateChange2025

// A paragraph or two describing what the authors intention was, their method, 
// findings, and any important notes, limitations, or implications.
*Overview:* The authors infer population-aggregate climate change belief systems for countries around 
the globe, modelled as regularised partial correlation networks. They analyse differences in belief 
system stability (#glossary("density-of-belief-system")[density]) and 
#glossary("inconsistency-of-belief-system")[inconsistency], to illuminate possible areas for belief 
intervention. They find geographic variation in density (higher in the global north), and inconsistencies
particularly relating to fossil fuel usage. Density is positively correlated with education and GDP, while 
inconsistency correlates positively with #glossary("carbon-resource-rent")[carbon resource rent] and 
negatively with education.

// Follow-up tasks for me to do, based on reading of this paper. Excluding 
// additional reading (see tagged notes on Zotero).
*Tasks:*
- Read about problems with inferring individual-level insights from population-level 
  belief models @brandtBetweenpersonMethodsProvide2022.
- Consider differences between causal belief relations and implication relations.
- Review Statistical rethinking chapter on social networks, or network inference work from 
  McElreath. May be applicable to inferring networks of belief.
- Consider different intentions for intervention. Could attempt to change beliefs (node values), 
  or to change belief system (edge values).
- Authors hypothesise that lack of association between education and density may be due to 
  population aggregation. We should consider this in our work.

// Who are the intended readers of the paper? i.e., whose minds are the 
// authors attempting to change?
*Audience:* Cognitive modelling, social psychology

// What problem, conflict, or gap have the authors identified in the 
// literature?
*Problem:* Population-level climate action requires individual belief systems to be aligned with 
this. Conflicting beliefs or doubt about climate change can hinder this. Furthermore, the structure
and resilience of belief systems can affect the effectiveness and outcome of interventions. However, 
there is limited research on these properties, and even less considering possible geographical variation.
This limits our ability to understand the effects of intervention, and how these may vary in different 
contexts or locations.

// What do the authors hope to learn?
*Intent:* Identify cross-societal differences in the stability and coherence of climate change 
belief systems around the globe.

// What specific questions are they asking, in order to satisfy the 
// intent? 
*Research questions:* 
- How does density (reflecting stability) of belief systems vary by country, global north/south 
  divide, and other societal factors (below)
- How does inconsistency (reflecting belief-pair conflicts) of belief systems vary by country, global north/south 
  divide, and other societal factors (below)
Additional factors: education level, exposure to climate change information, GDP, 
#glossary("carbon-resource-rent")[carbon resource rent].

*Methods:*
- A belief system for each area was estimated using eight key climate-related 
  beliefs and attitudes commonly assessed in public surveys.
- Network edges were determined through 
  #glossary("partial-correlation-network")[partial correlations] among these 
  elements.
- Uses proportional measures of belief system #glossary("density-of-belief-system")[density]
  and #glossary("inconsistency-of-belief-system")[inconsistency].
- Data from survey of Facebook users (n=99,074)

// What conclusions did they draw based on their results? What other 
// contributions were made (e.g., a method for evaluation, or a new model)?
*Claims and contributions:*
- Countries in the global north exhibit more interconnected belief systems (more large edges) 
  than those in other regions.
- Density varies significantly by region; typically higher in global north, reflecting more stable 
  belief systems.
- Level of interconnection correlates negatively with pro-climate beliefs and attitudes. i.e., 
  - More stable (population-level) belief systems are typically more anti-climate, typically in the 
    global north.
  - Low density, pro-climate is more typical in the global south, reflecting supportive but less 
    stable systems.
- Inconsistencies centre around fossil fuel use, and:
  - Renewable energy support (Nigeria, Zambia, the Philippines, and Jordan), suggesting support for 
    renewable energy use, but not for reducing fossil fuel usage.
  - Support for governmental climate priority (Laos, Kuwait, Vietnam, Jordan), suggesting support for 
    the government making climate change a priority, but not for reducing fossil fuel usage.
- Belief system stability (density) is positively correlated with information exposure relating to 
  climate change, and GDP. It is not correlated with education or carbon resource rent.
- Belief system inconsistency is correlated _negatively_ with information exposure relating to climate 
  change, and _positively_ with carbon resource rent. Suggests higher economic dependence on carbon 
  resources begets more inconsistency.

// What were the key (relevant) limitations of the study? Did you identify 
// any potential issues?
*Limitations:*
- Population-level aggregate belief-systems.
- No causal model in analysis of factors, though some could reasonably be hypothesised to be causally 
  related (e.g., education and information exposure).
- Their 'inconsistency' measure is taken as the absolute proportion of negative correlations. This 
  assumes all beliefs are coded such that high or low values all correspond to the same situation (pro- 
  or anti-climate). Hence this measure only measures inconsistency with respect to the variable of 
  interest, and is not applicable when beliefs may conflict on other dimensions (e.g., cost, social 
  impact, ideology).

// Whose research did they build on? Did they compare to anyone in 
// particular?
*Connections to other research:*
- Cross-regional variation in belief systems also considered for European nations in 
  @vannoordNatureStructureEuropean2025, though they were more concerned with meta-level similarity and 
  relationships between belief systems, and qualitative 'dimensions', than structural properties.


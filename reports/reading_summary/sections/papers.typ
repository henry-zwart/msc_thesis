#import "@preview/theorion:0.4.1": *
#import cosmos.fancy: *
// #import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

- Audience
- Problem
- Research questions
- Claims and contributions
- Limitations
- Other notes
- Connections to other research
- Problem context (where necessary)


== What is Central to Political Belief System Networks @brandtWhatCentralPolitical2019

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


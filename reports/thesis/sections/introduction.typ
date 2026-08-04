#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion


// *TODO:*
// - Address the specific variables we look at in the outbound/inbound experiments.
//   Are the variables interesting independently of the asymmetry results/theoretically
//   motivated?
// - Mention our hypotheses, where they exist.
//   - RQ3: That interventions can only be effective when the target and the
//     point-of-intervention are both low.

//_Belief systems as interrelated beliefs_

Our subjective interpretations of the world, natural phenomena, and
those around us are dependent on a collection of beliefs about how things are,
and how they work. These beliefs and attitudes are highly interdependent,
related by logical and psychological associations in what are often referred to as
belief systems. Beliefs and attitudes are also subject to social dynamics, as
evidenced by observed geographic segregation of political attitudes in the United
States. Moreover, beliefs and attitudes held by an individual have external consequences
for behavioural decisions and are in turn influenced by these decisions, often in the
form of reinforcing feedback loops. Put plainly, the beliefs and attitudes which allow us
to make internal sense of the world inevitably shape our collective impact on it.

//_Beliefs behave differently. May be more or less stable or influential._

Distinct beliefs and attitudes behave differently within a belief system. Some
attitudes, such as political ideology (e.g., conservativism or liberalism) are highly
stable over time @greenPartisanStabilityTurbulent2024. Others appear to be more
malleable (e.g., attitudes toward particular political candidates). In addition, some
beliefs and attitudes appear to be more influential than others. For instance, one
might intuitively expect political alignment to be dependent on individuals' policy
preferences. However, #cite(<unsworthItsPoliticalHow2014>, form: "prose") demonstrate
that causal influence may actually flow primarily in the opposite direction. When shown
identical policies with different partisan framings, individuals' support for those
policies shifts in line with their own political alignment, suggesting that partisan
identity may shape policy preferences more so than in the other direction.

//*(Empirical knowledge): Measurement approaches*

// TODO: Mention other places this approach has been used
//
// - Measurement via belief network analysis. Nodes are beliefs or attitudes, and
//   edges are correlations or partial correlations:
//   - Individual attitudes:
//     - @dalegeFormalizedAccountAttitudes2016
//     - @dalegeNetworkAnalysisAttitudes2017
//   - Political psychology:
//     - First use @boutylineBeliefNetworkAnalysis2017
//     - Symbolic vs operational ideology centrality @brandtWhatCentralPolitical2019
//     - Comparing political belief systems across countries @vannoordNatureStructureEuropean2025 @keskinturkOrganizationPoliticalBelief2022
//   - Other psychological traits:
//     - @epskampGaussianGraphicalModel2018
//     - @epskampEstimatingPsychologicalNetworks2018
//     - @borsboomNetworkAnalysisMultivariate2021
//     - Psychometrics:
//       - @epskampQgraphNetworkVisualizations2012
//   - Pychopathology:
//     - @bringmannNetworkApproachPsychopathology2013
//     - @epskampPersonalizedNetworkModeling2018
//   - Comparing cross-national climate change belief systems:
//     - @leeVariationsClimateChange2025
//   - Climate belief systems across political ideologies:
//     - @lindComparingAttitudinalStructures2024
//     - @leeClimateChangeBelief2024

// Given belief systems' interdependent nature, understanding the behaviour of any single
// belief (or attitude) requires consideration not only of how it interacts with
// other beliefs, but also how _those beliefs_ interact with the broader belief system.
// Network science methods have proven valuable in this regard, enabling quantitative analysis
// beyond the level of individual beliefs. The typical analytical approach treats
// belief systems as undirected networks describing the pairwise correlational structure
// (edges) between distinct beliefs and attitudes (nodes)
// @epskampQgraphNetworkVisualizations2012 @dalegeFormalizedAccountAttitudes2016
// @dalegeNetworkAnalysisAttitudes2017. Once estimated, a 'belief system network' is
// amenible to analysis under the broad scope of network science methods. Caution is
// required, however, as quantities based on network distance are not straightforwardly
// applicable or interpretable in correlational networks
// @borsboomNetworkAnalysisMultivariate2021.


Given belief systems' interdependent nature, understanding the behaviour of any single
belief (or attitude) requires consideration not only of how it interacts with
other beliefs, but also how _those beliefs_ interact with the broader belief system.
This has motivated empirical approaches to studying belief system structure based on
network science, which treat belief systems as undirected networks describing the
pairwise correlational structure (edges) between distinct beliefs and attitudes (nodes).

Analysis of _belief system networks_ using network science methods has proven
valuable for understanding belief system structure and the roles of specific beliefs and
attitudes in topic-specific belief systems. Using cross-national surveys, several studies
have examined geographic variation in belief system structure on topics including
politics @keskinturkOrganizationPoliticalBelief2022 @vannoordNatureStructureEuropean2025
and climate change @leeVariationsClimateChange2025, comparing both specific relations and
whole-network features such as density (the proportion of realised connections), and
inconsistency (the number of negative correlations). Similarly,
#cite(<chambonHowComplianceBehavioural2023>, form: "prose") examines how beliefs and
attitudes relating to COVID-19 changed over time in the Netherlands during the start of
the global pandemic. Node centrality---despite ongoing debate about its usefulness and
applicability to belief system networks
(cf. #cite(<bringmannWhatCentralityMeasures2019>, form: "prose"))---node
centrality is frequently used to assess belief position within a belief system
@brandtWhatCentralPolitical2019 @borsboomNetworkAnalysisMultivariate2021, relative influence
@robinaughIdentifyingHighlyInfluential2016, or structural importance
@dalegeNetworkAnalysisAttitudes2017 @fonseca2018analisis @heveyNetworkAnalysisBrief2018.
In addition, #cite(<chambonTailoredInterventionsBroad2022>, form: "prose") demonstrate
that node centrality may also contribute to the propagation of belief-level
interventions, in the context of a belief system on COVID-19.





// - Across countries:
//   - @vannoordNatureStructureEuropean2025:
//     - Diverse political belief systems in European countries.
//     - No difference in strength of association.
//   - @keskinturkOrganizationPoliticalBelief2022:
//     - Tests differences across countries w.r.t. political institutionalisation.
//     - Structural/density differences.
//   - @leeVariationsClimateChange2025:
//     - Climate change beliefs across countries
//     - Differences in density. High-density and tight correlations vs. low-density.
//     - Differences in inconsistency explained by conflict between fossil fuel reduction
//       and support for renewable energy/climate policy prioritisation.
//     - Information exposure correlated with density (+) and inconsistency (-).
//     - GDP correlated with density (+).
//     - Carbon resource dependence correlated with inconsistency (-).
// - Across ideologies:
//   - @lindComparingAttitudinalStructures2024:
//     - Denmark.
//     - Similarities in connectivity and node strength.
//     - Differences in the most central nodes.
//   - @leeClimateChangeBelief2024:
//     - Worry is most central
//       - Supports prior studies
//     - Changes in belief systems over time: connections strengthened, increased consistency.
//     - Democrats and republicans structure beliefs similarly

// Belief system network analysis has been used broadly to test theories about belief
// system structure as well as the properties and roles of particular beliefs and attitudes.
// Belief system network analysis has been used broadly to test theories about belief
// system structure as well as the properties and roles of particular beliefs and attitudes.
// Several studies have examined belief system networks inferred from cross-national surveys
// to understand geographic variation in belief systems on topics such as politics
// @keskinturkOrganizationPoliticalBelief2022 @vannoordNatureStructureEuropean2025 and
// climate change @leeVariationsClimateChange2025. Such studies typically compare networks
// with respect to both specific network associations and whole-network measures such as
// density (proportion and strength of realised connections). For instance,
// #cite(<leeVariationsClimateChange2025>, form: "prose") finds that exposure to information
// on climate change correlates positively with network density and negatively with
// inconsistency between climate change beliefs and attitudes, indicating that information
// exposure leads to more complex, consistent views on climate change.
//
// #let centrality-footnote = footnote[
//   We set questions of the latter two indices' suitability for measuring belief
//   importance here. For extended discussion on this matter, see
//   #cite(<bringmannWhatCentralityMeasures2019>, form: "prose").
// ]

// - Not all centrality measures applicable
// - Strength and betweenness
// - In undirected networks, interpreted best as direct influence and structural importance
//   @brandtWhatCentralPolitical2019
// - What kinds beliefs are most fundamental? (what do people build belief systems around?)
// - Where best to intervene?
// - Node centrality can be used to answer questions about
//
// - Influence (more strength centrality @brandtWhatCentralPolitical2019) @robinaughIdentifyingHighlyInfluential2016
// - Structural importance (more betweenness @brandtWhatCentralPolitical2019) @dalegeNetworkAnalysisAttitudes2017
//
// Other refs:
// - @borsboomNetworkAnalysisMultivariate2021
//
// Not without problems @bringmannWhatCentralityMeasures2019 @forbes2017evidence @borsboomFalseAlarmComprehensive2017

// Choosing effective interventions: @castroCentralityMeasuresPsychological2024
// Node centrality is often considered a measurement of a
// given belief's position @borsboomNetworkAnalysisMultivariate2021 @brandtWhatCentralPolitical2019,
// influence @robinaughIdentifyingHighlyInfluential2016, or structural importance
// @dalegeNetworkAnalysisAttitudes2017 @fonseca2018analisis @heveyNetworkAnalysisBrief2018
// within a belief system. The
// most prominent variants in belief systems literature are _strength centrality_ (the
// absolute sum of adjacent edges), _closeness centrality_ (the inverse sum of shortest
// path lengths to other nodes), and _betweenness centrality_ (the number of shortest paths
// in the network which the given node is incident to)#centrality-footnote.
//
// Although most often used to assess the relative importance of beliefs or identify the
// 'most central' beliefs on a given topic *CITE*, node centrality can also be used to
// test hypotheses about how different categories of beliefs are positioned within a
// belief system. For instance, #cite(<brandtWhatCentralPolitical2019>, form: "prose")
// demonstrates, for a political belief system, that symbolic attachments (i.e.,
// identity-based, such as partisan alignment) tend to be more central than operational
// attitudes (e.g., positions on specific issues or policies). Furthermore,
// for a belief system on attitudes surrounding COVID-19,
// #cite(<chambonTailoredInterventionsBroad2022>, form: "prose") demonstrate that node
// centrality may contribute to the propagation of belief-level interventions to other
// beliefs and attitudes.
//

// NOTE:
// *(Mechanistic knowledge): Hypothesised causal mechanisms, conceptual frameworks*
// - Correlational approach provides valuable insight into belief system structure, but
//   does not make claims of causality.
// - The use of the term _system_ implies an abstraction away from individual beliefs and
//   attitudes, refocusing on belief states and dynamics as characterised by the
//   interactions of the entire set of beliefs.
//   This perspective on the nature of beliefs
//   and attitudes lends itself naturally to formalisation of belief systems under the complex
//   systems framework.
// - Two main families of models under the complex systems/statistical physics framework.
//   These draw on separate theories of internal consistency.
//   + Festinger's theory of cognitive dissonance $-->$ connectionist model
//     - Cognitive dissonance: when two beliefs are in conflict, tend to adjust one of them
//       to resolve this.
//   + Heider's balance theory $-->$ SKS model (maybe cf.)
// - Causal models assume symmetric influences. Two beliefs related via a positive edge
//   reinforce one another with equal strength. Negative edge: oppose one another with
//   equal strength. In particular, holding all other beliefs constant, the influence of
//   one belief on the other is the same as vice versa.

// While correlational networks identify statistical associations between beliefs and
// attitudes, they do not purport to explain the mechanisms by which beliefs and attitudes
// are related, nor the dynamic implications of belief system structure. Several
// influential theories of belief dynamics rest on the notion of internal
// consistency---that individuals strive to hold largely compatible beliefs and
// attitudes. In his theory of cognitive dissonance,
// #cite(<festingerCognitiveDissonance1962>, form: "prose") argues that when an individual
// holds two beliefs which they consider conflicting, they will tend to change one of them
// to achieve a more consistent internal state.
// #cite(<heiderAttitudesCognitiveOrganization1946>, form: "author")'s
// #cite(<heiderAttitudesCognitiveOrganization1946>, form: "year") balance theory, which
// conceptualises attitudes as signed associative relations between concepts, makes a
// similar argument for attitude change as an effort to eliminate inconsistencies in the
// form of unstable triads, defined as concepts related in a triangle structure with an odd
// number of negative associations.

// TODO: 'Both of these aspects are important to understanding how beliefs and attitudes
// change, affect one another and behaviour, and spread between individuals'.
Although belief system networks characterise the statistical associations between
beliefs and attitudes in a belief system, they make no claims regarding the nature of
these associations, how they arise, nor their implications for belief dynamics.
Several explanatory models have been proposed to address these shortcomings, most often
considering endogenous belief system dynamics as driven by individuals' efforts to
achieve consistent sets of beliefs and attitudes; that is, which are perceived as
mutually compatible. This perspective is particularly amenible to formalisation under
the framework of complex systems, treating belief system dynamics as arising from
micro-level attempts to resolve perceived inconsistencies between beliefs and attitudes.

Current theories (and models) of belief system dynamics have been especially influenced
by two classical theories of belief and attitude consistency:
#cite(<heiderAttitudesCognitiveOrganization1946>, form: "author")'s
_balance theory_
(#cite(<heiderAttitudesCognitiveOrganization1946>, form: "year")) and
#cite(<festingerCognitiveDissonance1962>, form: "author")'s
_theory of cognitive dissonance_
(#cite(<festingerCognitiveDissonance1962>, form: "year")).
Heider's balance theory interprets attitudes as signed, affective associations between
concepts. Inconsistency arises when three concepts are related in a triangle for which
the product of edge weights is negative. Festinger's theory of cognitive dissonance,
on the other hand, takes the view that beliefs (and by extension, attitudes) can be
more or less compatible with one another. The difference is best clarified with an
example. For instance, consider a person who cares deeply about animal wellbeing but who
also eats meat. We illustrate the two interpretations below. Heider (_left_) considers
the cognitive inconsistency as arising from the negative association between animals and
meat consumption (interpreted as 'harm'). To resolve this, the individual could adjust
their attitudes toward animal wellbeing, change their dietary habits, or limiting the
perceived association between animals and meat consumption. Festinger (_right_) instead
relates the individual's attitudes directly, rather than via their conceptual referrents,
but comes to the same conclusion, namely that the person will tend to change one of the
two attitudes, or reduce their perceived negative association.

#grid(
  columns: (1fr, 1fr),
  align: (center, center),
  row-gutter: 0.8em,
  [*(Balance theory)*], [*(Cognitive dissonance)*],
  image("../diagrams/cog_inconsistency/balance_theory.svg", height: 8em),
  image("../diagrams/cog_inconsistency/cognitive_dissonance.svg", height: 8em),
)

// TODO: Doesn't use their version of 'attitude'
// TODO: Maybe reference HIOM and networks of belief?
Balance theory and the theory of cognitive dissonance have given way to two families
of belief system models basd on the statistical physics notion of energy minimisation
(*CITE*). The present study primarily considers models inspired by Festinger's theory of
cognitive dissonance, which is more so concerned with relations _between_ beliefs and
attitudes than attitudes as relating concepts. For models based on Heider's balance
theory, we refer the reader to
#cite(<greenwaldUnifiedTheoryImplicit2002>, form: "prose"),
#cite(<rodriguezCollectiveDynamicsBelief2016>, form: "prose"), and
#cite(<aiyappaEmergenceSimpleComplex2024>, form: "prose").

// TODO: We don't use the precise notion of attitude that they use
// TODO: Mention the HIOM, Networks of Belief as social extensions.
//  - More generally, mention the usefulness of these models.
The _Causal Attitude Network_ (CAN) model @dalegeFormalizedAccountAttitudes2016
formalises Festinger's theory of cognitive dissonance in an Ising-style model, also
drawing on the more recently-proposed connectionist perspective on attitude change
@monroeGeneralConnectionistModel2008. It can be viewed as a dynamic formulation of
the belief network approach described above. While the Ising model was originally
presented as a model of ferromagnetic behaviour, it has since been variously applied to
describe diverse systems of interacting variables which attract or repel one another
@nguyenInverseStatisticalProblems2017.
In the CAN model, beliefs and attituds are
represented as spins which take on values in the set ${-1, +1}$, representing two
opposing states (e.g., 'climate change is happening' versus 'climate change is _not_
happening' or 'support' versus 'oppose'). These are related by reinforcing ($+$) or
opposing ($-$) interaction effects, based on the notion of cognitive dissonance.
Model dynamics are described in terms energy (read 'inconsistency') minimisation.
That is, individuals tend to reduce cognitive dissonance, such that positively
associated beliefs generally agree, and negatively associated beliefs generally disagree.
// The tendency for each
// belief to be positive or negative, holding all interaction effects constant, is captured
// by their respective _baseline activations_.

*TODO:* Diagram of the CAN model.

*TODO:* Discuss model usefulness; extensions to model social influences.




// *NOTE:* Add a bit more here on the SKS approach, to show that we have considered it.
// We don't use it because we're operating under the CAN model framework. Also because
// this is closely aligned with the empirical belief networks.
// - SKS models are concerned with belief system consistency, taking attitudes as relating
//   concepts.
// - Connectionist models are more similar to the belief network empirical approach, and
//   are concerned with how beliefs themselves are related.

// These theories have given way to two families of belief system models based on the
// statistical physics notion of energy minimisation. The first class, building
// directly on Heider's balance theory, defines belief system dynamics as efforts to
// reduce internal inconsistencies in the form of unstable triads
// @greenwaldUnifiedTheoryImplicit2002 @rodriguezCollectiveDynamicsBelief2016
// @aiyappaEmergenceSimpleComplex2024. For the purposes of this study, however, we focus
// primarily on the second class of models. The Causal Attitude Network
// (CAN) model formalises Festinger's theory of cognitive dissonance in an Ising-style
// model @dalegeFormalizedAccountAttitudes2016. Beliefs and attitudes are represented as
// spins which take on values in ${-1, +1}$, representing two opposing states, and are
// related by reinforcing ($+$) or opposing ($-$) interaction effects. The tendency for each
// belief to be positive or negative, holding all interaction effects constant, is captured
// by their respective _baseline activations_. The CAN model defines belief system dynamics
// as efforts to reduce cognitive dissonance, such that positively related beliefs generally
// agree and negatively related beliefs generally disagree.

Critically, the CAN model defines interaction relations as symmetric, such that related
beliefs exert equal reinforcing or opposing influence on one another. This is
mathematically convenient. In particular, with symmetric relations, the underlying
Ising model satisfies detailed balance, and can be analysed as an equibrium system.

dynamics to be the assumption of detailed balance, and
consequentially as it enables belief systems to be analysed under the
assumption of equilibrium
assumption  for the assumption that enabling analysis of belief system dynamics under the
assumption
- Most authors agree than influence relations are not necessarily bi-directional.
- There is evidence that they are not.
- Asymmetric relations (can) affect measures of node centrality.
- Asymmetric relations (can conceivably) affect belief system dynamics.
- Therefore, asymmetric relations (can conceivably) affect how beliefs and attitudes
  translate to individual behaviour.
- Therefore also, others' beliefs and attitudes.
- Therefore also, collective behaviour.
- Therefore, asymmetric relations (can conceivably) affect intervention dynamics.


// class of models, inspired by The second---which we focus
// (SKS) model @greenwaldUnifiedTheoryImplicit2002 builds directly on Heider's balance
// theory
// The Causal Attitude Network (CAN)
// model @dalegeFormalizedAccountAttitudes2016 formalises Festinger's theory of cognitive
// dissonance in an Ising-style model. Beliefs and attitudes are represented as spins which
// take on values $s in {-1, +1}$, representing two opposing states (e.g., 'climate change
// is real' vs. 'climate change is fake', or 'likes dogs' vs. 'dislikes dogs'), and are
// related via signed, weighted interaction effects which determine the extent to which a
// pair of beliefs reinforce ($+$) or oppose ($-$) one another. Each belief also has an
// associated _baseline activation_, reflecting its tendency to be positive or negative,
// holding all interaction influences constant. Interaction relations are symmetric, such
// that each pair of beliefs exert equal reinforcing or opposing influence on one another.
// The model implements belief system dynamics as driven by efforts to reduce cognitive
// dissonance (i.e., such that positively related beliefs generally have the same valence,
// and negatively related beliefs generally have opposite valence). The second class
// of models, inspired by Heider's balance theory, defines belief system dynamics in
// terms of efforts to increase internal consistency as measured by absence of unstable
// triangles @greenwaldUnifiedTheoryImplicit2002 @rodriguezCollectiveDynamicsBelief2016
// @aiyappaEmergenceSimpleComplex2024.

// - Distinction between static (predicting position on A given B) and dynamic constraint
//   (how much does $B$ change when $A$ changes).
// - Lends naturally to formalisation under

Gives meaning to centrality:
- More/stronger connections --> more constrained. More stable.

Centrality indices can be different in directed networks.
- Commonly used in analysis, but directed networks plausible in reality?
- @brandtWhatCentralPolitical2019[p.~2] "Causal potency does not necessarily say
  anything about centrality, as the causally potent variable may be on the periphery
  of the belief system."

Examples:
- Belief system networks to represent dynamics of political belief systems. Capture
  several phenomena @brandtEvaluatingBeliefSystem2021

Choosing effective interventions with simulation studies: @castroCentralityMeasuresPsychological2024


*The puzzle*

- Interpretation of node importance/influence in the CAN model. More constrained. Changes
  affect many other beliefs.
-


+ Target phenomenon: Some beliefs are more influential than others. Peripheral nodes
  can be good intervention targets.
+ Failure mode of current understanding:
  - Most authors agree/acknowledge directed influence relations as plausible
  - Evidence of asymmetric relations between beliefs and attitudes from temporal networks
  - To the best of our knowledge, there are no current theoretical models of belief
    dynamics which capture asymmetric influences.
+ Consequence:
  - Conceivably matters for interventions. (Diagrams)

Examples:
- Asymmetry? @arceneauxCriticalEvaluationResearch2025
- @brandtWhatCentralPolitical2019[p.~2] "Causal potency does not necessarily say
  anything about centrality, as the causally potent variable may be on the periphery
  of the belief system."

*Our study ...*



// - Some beliefs/attitudes more central to belief systems:
//   - Operational vs. symbolic ideology @brandtWhatCentralPolitical2019 @fishmanChangeWeCan2022
// - Some beliefs appear more 'fundamental' or 'influential' than others.
// - Some are very stable.
// - Some appear to have limited influence over attitudes which we would expect to
//   be related.
//   - e.g., Policy on political attitudes
//   - e.g., Central beliefs on others @fishmanChangeWeCan2022 @brandtInterattitudeCentralityDoes2023
// - When internal conflict arises, some beliefs/attitudes are more likely to change
//   than others.
//   - Various accounts suggesting that 'core' beliefs are more likely to be retained than
//     'peripheral' beliefs which are not as well connected @zotero-item-17041
//   - Differences in causal potency provide an alternative explanation (which is not
//     mutually exclusive). That some beliefs or attitudes, by way of their nature,
//     exert greater influence than they receive.

Importantly, beliefs and attitudes do not appear
Beliefs and attitudes within a belief system vary in stability and apparent influence
on other beliefs and attitudes.


Within a belief system, different beliefs and attitudes exhibit different properties.
In particular, some beliefs and attitudes appear to be more influential or resistant
to change than others. From the Philosophy of Science, Quine
(#cite(<zotero-item-17041>, form: "year"), #cite(<vanormanquineTwoDogmasEmpiricism1976>, form: "year"))
adopts the notion of a belief system in the context of human knowledge and its relation
to empirical evidence. He argues that, when faced with contradictory evidence to some
theory, one can adjust either the theory itself or any number of auxiliary hypotheses
such that the theory still stands. Moreover, he asserts that theories which are
more central---supported by a plethora of auxiliary hypotheses---are relatively more
stable than those closer to empirical reality, since to adjust a central theory would
require vast changes in other beliefs.

and those that are that   In the _Two Dogmas of Empiricism_
(@vanormanquineTwoDogmasEmpiricism1976) and later _The Web of Belief_ @zotero-item-17041
text, _The Web of Belief_, Quine
#cite(<zotero-item-17041>, form: "year") argues that every facet of human knowledge is
predicated on auxiliary hypotheses about the world. When faced with evidence that
contradicts some belief, one can either update the belief in question, or the hypotheses
that support it. He asserts that core beliefs---those which are further from empirical
reality, and supported by a large number of auxiliary hypotheses---are more stable,
since adjustments here would require vast changes in other areas of the web.

of the
evidence, these hypotheses can be updated
Some attitudes, such as political ideology (e.g., conservativism or liberalism),
are relatively stable over time, while others, such as views regarding particular
political candidates, vary more readily. Likewise, some beliefs and attitudes appear
to exert high degrees of influence on others; however, influence may not always flow in
the expected direction. For instance, Influence does not, however, always
flow in the

Some are relatively stable over time (e.g., political ideology), while others vary more
readily (e.g., support for particular policies or political candidates). Some appear
to exert significant influence over other beliefs and attitudes (e.g., religiosity),
while in other cases attitudes we would expect



- Some beliefs are more stable or influential
- Some which we would expect to be influential in fact have limited influence.
- Quine; psychology


_Complex systems approaches, and what we know. Current theories about centrality etc._
These
, which give way to notions of
internal consistency---sets of beliefs and attitudes that are mutually compatible.

The use of the term _system_ implies an abstraction away from individual beliefs and
attitudes, refocusing on belief states and dynamics as characterised by the
interactions of the entire set of beliefs.
This perspective on the nature of beliefs
and attitudes lends itself naturally to formalisation of belief systems under the complex
systems framework.

- Internal dynamics---internal consistency:
  - Stable triads (based on Heider's balance theory)
  - Connectionist view (based on Festinger's theory of cognitive dissonance)
- Recent work including social influences:
  - Misalignments between own beliefs and others' beliefs @rodriguezCollectiveDynamicsBelief2016
    @vandermaasPolarizationIndividualsHierarchical2020 @aiyappaEmergenceSimpleComplex2024
  - Misalignment between own beliefs and _perceptions_ of others' beliefs
    @dalegeNetworksBeliefsIntegrative2025
- We focus here on the connectionist view, and internal dynamics. However, our work is
  orthogonal to the Networks of Belief approach to modelling social belief dynamics
  proposed by #cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose").

_Problems with centrality when it comes to dynamic constraint._
- Centrality doesn't always predict ease of change. Sometimes peripheral is better

_Another perspective: asymmetry in causal influences_
- Most authors agree it is plausible, yet model only symmetric relations
- Empirical evidence to suggest it @chambonHowComplianceBehavioural2023
- Three situations where it may/may not make a difference

_Our study_




This conceptualisation abstracts away from individual beliefs and attitudes, allowing
for higher-level examination of belief dynamics as arising from the interactions of the
system as a whole.
- Belief systems view belief and attitude dynamics, not at the level of individual cognitive
  states, but as the result
Complex systems approaches lend themselves naturally to the study of belief
systems, enabling  itto studying  Considering beliefs and attitudes in this    Often, within a belief system, certain beliefs or attitudes appear to be
more stable, influential, or

- Some beliefs/attitudes more central to belief systems:
  - Operational vs. symbolic ideology @brandtWhatCentralPolitical2019 @fishmanChangeWeCan2022
- Some beliefs appear more 'fundamental' or 'influential' than others.
- Some are very stable.
- Some appear to have limited influence over attitudes which we would expect to
  be related.
  - e.g., Policy on political attitudes
  - e.g., Central beliefs on others @fishmanChangeWeCan2022 @brandtInterattitudeCentralityDoes2023
- When internal conflict arises, some beliefs/attitudes are more likely to change
  than others.
  - Various accounts suggesting that 'core' beliefs are more likely to be retained than
    'peripheral' beliefs which are not as well connected @zotero-item-17041
  - Differences in causal potency provide an alternative explanation (which is not
    mutually exclusive). That some beliefs or attitudes, by way of their nature,
    exert greater influence than they receive.





are highly interdependent. Logical and psychological associations between beliefs
and attitudes give way to the notion of internal consistency. Beliefs and attitudes also
influence, and influenced by behavioural decisions. Moreover, they are subject to social
dynamics,

mutually influence and are _influenced by_ behavioural
decisions, and oftne . Logical and psychological associations between certain beliefs
and attitudes give way to the notion of internal consistency among beliefs.

are highly interdependent. They affect one another, whether by way of logical relationships
(e.g., *...*) or psychological associations (e.g., *...*). Attitudes and preferences
are also generally considered key determinants of behaviour, and are often also
themselves reinforced by behavioural choices. Moreover,

Our individual interpretations of the world are predicated on a collection of beliefs, attitudes As individuals, our beliefs, attitudes, and dispositins

At any point in time, our understanding of the world, ourselves, our

== Plan

High-level structure:
- *A:*
  - (Phenomenon) Beliefs and attitudes are interrelated. Some appear to be more
    influential, or central, than others.
  - (Empirical knowledge) Evidenced, for example, by stability of political attitudes
    over the past decade, alongside broad shifts in public attitudes toward climate
    change.
  - (Why it matters) Understanding the mechanisms for belief change is important to
    ...
  - (Mechanistic knowledge) Internal consistency (cognitive dissonance), social cohesion.
    We focus on the former.
  - (Modelling knowledge)
    - Beliefs as nodes. Edges are signed, weighted, and typically bi-directional edges
      @dalegeFormalizedAccountAttitudes2016 @dalegeNetworksBeliefsIntegrative2025: based
      on the connectionist model of attitudes @monroeGeneralConnectionistModel2008.
    - Beliefs/attitudes often assessed in terms of network centrality (measured using
      degree or strength(*?*))
- *B:*
  - Another possible explanation for differences is that some beliefs and
    attitudes exert greater causal influence on others than vice versa.
  - For instance, show example.
  - While most authors acknowledge the plausibility of asymmetric influence relations,
    most studies assume symmetric relations.
  - Little empirical evidence







=== Establish the territory

*The phenomenon, and why it matters*
- Beliefs and attitudes influence one another.
- Some appear to be highly influential or stable, while others appear to be highly
  influentiable and subject to change.

*What we currently know, and how we know it*
Empirical knowledge:
- Clustering across individuals/geographic areas
- Stability of political beliefs
- Changes in beliefs/attitudes about climate change
- Measurement approaches: surveys, correlational networks showing associations between
  beliefs/attitudes.
- ...?

Mechanistic knowledge:
- Theory:
  - Individuals tend to minimise inconsistencies among their beliefs and attitudes
    (cognitive dissonance). Tend to change beliefs when two are inconsistent with
    one another. Consistent beliefs tend to hold each other in check.
  - Individuals tend to align their beliefs and attitudes with those around them
    (social coherence). Evidenced by geographic clustering, studies showing that
    policy support is sensitive to partisan framing.

Modelling knowledge:
- Families of models:
  - #cite(<rodriguezCollectiveDynamicsBelief2016>, form: "prose") and
    #cite(<aiyappaEmergenceSimpleComplex2024>, form: "prose") consider belief systems
    based on the Social Knowledge Structure (SKS) model @greenwaldUnifiedTheoryImplicit2002.
    Nodes are concepts. Edges are beliefs about the association between a pair of concepts.
    Internal inconsistency is measured with respect to unstable triads, building on Heider's
    balance theory @heiderAttitudesCognitiveOrganization1946.
    - *What does it buy you?*
  - Bayesian networks have been used to capture conditional probability structures among
    beliefs and attitudes @powellModelingLeveragingIntuitive2023
    @cookRationalIrrationalityModeling2016. Models belief systems as directed acyclic
    graph, where nodes represent beliefs, and a directed edges encode probabilistic
    dependencies.
    - *Benefit:* Flexible conditional distribution for each belief with respect to its
      parents, such that state distribution can be a complex function of interacting
      parent states. Observing 'upstream' beliefs (or priors) fixes the probability
      distribution for downstream beliefs, making analysis of potential interventions
      straightforward.
    - *Downsides:* Since belief systems are inherently psychological constructs, there
      is no reason to expect strict hierarchy of beliefs. Cannot capture mutual
      reinforcement feedback loops.
  - Connectionist models of belief: Nodes represent beliefs, which can take on different
    states. Signed, weighted edges represent consistency between two beliefs. Examples
    include the Causal Attitude Network (CAN) model @dalegeFormalizedAccountAttitudes2016
    and the related Hierarchical Ising Opinion model
    @vandermaasPolarizationIndividualsHierarchical2020. Based on theory of cognitive
    dissonance @festingerCognitiveDissonance1962.
    - *Benefits:* Theoretically motivated. ...
- What does modelling enable in this domain:
  - Theory/mechanism testing: Belief change and propagation is difficult to reason about
    due to many connections. Models based on statistical physics are theories themselves.
    Abstract away from individual beliefs and theorise about general mechanisms which
    drive the _entire_ system.
    - We see this particularly for CAN, Networks of Belief models. They are used to make
      predictions about behaviour.
  - Structural inference: Understanding how beliefs and attitudes relate.
  - Simulation experiments: Understanding how changes in a belief system are likely to
    propagate; testing interventions; investigating how phenomena arise
    (e.g., polarisation).


- Computational modelling approaches have been used to explain various observed phenomenon
- Also help us to reason about how beliefs and attitudes in a given state are likely to
  evolve.
  - Can be used to test intervention effects _in silico_
  - This requires that the model is an accurate reflection of the true dynamics.
- CAN model:
  - Based on Ising model: maximum entropy model that matches spin means and pair averages.
  - Fits the data, reproduces key statistics.
  - Assumes equilibrium belief state.
  - But what if these are not sufficient? What if belief systems are non-equilibrium?

Important motivators:
- Understanding how collective behaviours arise.
  - Beliefs and attitudes are determinants for individual behaviour.
  - Beliefs and attitudes influence both individual and collective behaviour. Understanding
  the causal structures that constitute a belief system is important to understanding how
  behaviours spread.
-


*A:*
- Beliefs and attitudes influence one another.



*A:*
- Beliefs and attitudes are interrelated. Internal consistency and social cohesion.
- Some beliefs appear to be highly influential, while being relatively stable themselves.
- Understanding how changes in certain beliefs and attitudes can lead to changes in
  others is important, e.g., for climate mitigation. Driving behaviour change.
- Models used to describe dependencies and explain dynamics.
*B:*
-

#emph-block[
  Two territories:
  + System: What is the real-world system? What patterns, behaviours, outcomes are
    important?
  + Model: How have models been used here? What kinds exist? What can they do well?
    What is standard practice? What can they _not_ do well?

  *Goal:* Reader thinks that this is a real, interesting scientific problem, and modelling
  is a legitimate way to address it.
]

*Short short short*

The phenomenon, and why it matters:
- *A:*
  - Beliefs, attitudes aren't random. Internally consistent, and often socially clustered.
  - They influence behaviour.
  - Current issues such as climate change, which require widespread changes in behaviour,
    also require widespread changes in attitudes, which may spread socially.
  - General attitudes toward climate action/policy often polarised, subject
    to pluralistic ignorance. Presents a situation which feels like there is a lack of
    consensus; prevents effective progress.
  - Furthermore, some attitudes appear more influential or resistant to change than others.
    - Increasingly polarised policy stances from Republicans and Democrats.
    - Yet while there has been significant change in individuals' beliefs/attitudes toward
      climate change over the past decade, political views have remained highly stable.
    - Suggests that ...
- *B:*
  - In part due to the complex nature by which beliefs and attitudes appear to be related.
    Any one belief or attitude is constrained by a multitude of others.
  - Relatively little is known about how changes in attitudes spread to
    other attitudes (known as dynamic constraint).
- *T:*
  - Complex systems approach

What we currently know, and how we know it:
- *A*



=== Establish the niche

#emph-block[
  Typically two problems:
  - Knowledge: something the field cannot yet explain, predict, estimate, or decide.
  - Method: Limitation in how existing models represent mechanisms, scale,
    heterogeneity, etc.

  *Goal:* Narrowing from broad topic to specific puzzle.
]

*Target phenomenon:*

*Failure mode of current understanding:*

*Consequence of the problem:*

*What is in scope:*

*What is not in scope:*

*What assumptions will matter later:*


=== Occupy the niche

#emph-block[
  Stating what we will do, how we will do it, and why this is a credible response to the
  problems above.

  Comprises four steps:
  + Precise RQ or RQs
  + High-level modelling approach, without technical details
  + How success is evaluated
  + Contributions, with forward references to chapters
]

Recent empirical evidence of asymmetric relations in fast-changing context using
temporal network @chambonHowComplianceBehavioural2023:
- Frame as:
  - Evidence of asymmetric relations
  - Helpful for explaining changes in compliance.
  - Focuses on bi-directional reinforcing relations (we argue unidirectional cases also important,
    as are cases where they are different)
  - Post-hoc analysis (we argue this means also useful for simulation studies)
  - 'Temporal networks have been used to analyse temporal associations between attitudes
    and compliance during COVID-19'. i.e., focus is on 'analysis'. Can then say
    *mechanistic* models of belief system dynamics are mostly concerned with
    static constraint (symmetric relations). Is Bayesian network a mechanistic model?

Intervention effects have been analysed in terms of network features
@chambonTailoredInterventionsBroad2022. Though not using simulation approach.

-
i.e., post-hoc explanation. Our argument is: (1)

While most authors in the belief system modelling literature acknowledge the plausibility
of asymmetric influences between beliefs and attitudes, currently predominant modelling
practices assume symmetric relations. Two notable exceptions are Bayesian networks
@pearl1988probabilistic and temporal networks @kriekeEcologicalMomentaryAssessments2015.
Bayesian networks model conditional probabilistic relationships between random variables
in a directed, acyclic structure, and have been applied to the study of belief dynamics
@cookRationalIrrationalityModeling2016 @powellModelingLeveragingIntuitive2023. However,
the strict acyclicity assumption prohibits modelling (even asymmetric)
reciprocal influences between beliefs. Temporal (psychological) networks, on the other
hand, are obtained by regressing instantaneous belief and attitude states on previous
observations using a linear model.
...

// NOTE: Maybe talk about why symmetric relations prevalent. Easy (can use
// cross-sectional data); historically-prevalent.

// Empirical evidence for both the prevalence of asymmetric influences and their potential
// impacts on belief system dynamics remain limited.

*Diagram showing three possibilities: mostly symmetric, random directions, sinks and
sources:*
- First: not likely to differ much from symmetric
- Second: different
- Third: ...?

This study explores the prevalence of asymmetric influence among beliefs and attitudes
about climate change in the US, as well as the dynamic implications of symmetric and
asymmetric modelling assumptions for belief-level interventions. The data used for this
investigation is sourced from a longitudinal representative survey collected between
2020 and 2023. Specifically, we will address the following research questions:

#let RQ1 = [
  To what extent are causal influences _symmetric_ or _asymmetric_, in models
  of climate change belief systems inferred from the climate beliefs dataset?
]

#let RQ2 = [
  How do asymmetric and symmetric beliefs systems differ with regards to
  intervention strategy and effectiveness, in models inferred from the climate
  beliefs dataset?
]

#let RQ3 = [
  How do intervention outcome and effectiveness vary between individuals with
  different initial conditions in asymmetric belief systems inferred from the
  climate beliefs dataset?
]

#let RQ4 = [
  How do asymmetric belief systems inferred from the climate beliefs dataset
  vary between conservative and liberal individuals?
]

#{
  set enum(numbering: "RQ1.", indent: 1em)
  block(width: 97%, [
    + #RQ1 <RQ1>

    + #RQ2 <RQ2>

    + #RQ3 <RQ3>

    + #RQ4 <RQ4>
  ])
}

To assess intervention dynamics we require a mechanistic asymmetric belief system
model, whose behaviour can be assessed via simulation. We extend the CAN model to
a kinetic Ising model form, allowing directed interaction effects between each pair of
beliefs to differ, and redefining model dynamics as explicitly dependent on the
previous states of all beliefs and attitudes.

Our contributions are as follows: *Workshop this---check academic phrasebank.*




#line(length: 100%)


== Plan

- Motivate the problem
- Contributions
- Research questions (thinking these are perhaps better left to later, in favour of
  contributions here)

#emph-block[
  The probable existence of directed causal relations between beliefs and attitudes, as
  well as their potential implications for endogenous dynamics, is widely acknowledged
  in recent studies on belief system modelling. In spite of this, empirical evidence for
  the existence and impacts of such directed relations remains scarce, likely due,
  in-part, to a historical focus on bidirectional (i.e., symmetric) models in theories of
  belief dynamics (*CITE*), as well as the additional data requirements associated with
  inferring directional relations @nguyenInverseStatisticalProblems2017[p.~35] (*CITE*).

  These unknowns, _existence_ and _impact_, are the primary subjects of this
  thesis, and of our first two research questions, introduced back in
  @sec:introduction:

  *RQ1:* To what extent are causal relations _symmetric_ or _asymmetric_, in models
  of climate change belief systems inferred from the climate beliefs dataset?

  *RQ2:* How do asymmetric and symmetric beliefs systems differ with regards to
  intervention strategy and effectiveness, in models inferred from the climate
  beliefs dataset?

  The _climate beliefs dataset_, here, refers to the reduced longitudinal dataset
  whose construction we describe in @subsec:dataset-dataset-construction. These research
  questions are concerned with population-level belief systems and intervention effects.
  However, while some aspects of belief system structure are likely shared within a
  population, the notion of a belief system is inherently individual. We also expect
  differences in individuals' responses to interventions. Our final research questions
  address these two topics, specifically for asymmetric belief systems:

  *RQ3:* How do intervention outcome and effectiveness vary between individuals with
  different initial conditions in asymmetric belief systems inferred from the
  climate beliefs dataset?

  *RQ4:* How do asymmetric belief systems inferred from the climate beliefs dataset
  vary between conservative and liberal individuals?
]

== Motivation

Causality in psychological networks @kossakowskiSearchCausalityComparison2021

Practical considerations for designing empirical studies for psychological networks.
Discusses limitations of cross-sectional studies for teasing apart within-person and
between-person effects @chambonNetworkPsychometricsPractice2026.

Dynamics vs. static constraint. @converseNatureBeliefSystems2006

Intervention studies with belief system models:
- Looks at dynamics constraint. Uses symmetric network, doesn't fit individual models.
  Applies persuasive experimental condition and predicts how attitudes will change.
  Finds that attitudes generally change most when close to the point-of-intervention
  @turner-zwinkelsBeliefSystemNetworks2022
- Finds that (counter to their hypothesis) peripheral attitudes changed less than
  central ones (no 'straightforward association between inter-attitude centrality and
  persuasion'). Also uses symmetric model. 'such a process is often assumed to be
  bi-directional'. @brandtInterattitudeCentralityDoes2023
  - Possible explanation for their findings: attitudes found to be peripheral may not
    actually be peripheral. They may be asymmetric, with different
    influence/influentiability.
- Looks at temporal network of behavioural compliance in COVID-19
  @chambonHowComplianceBehavioural2023. Says they measure within-person effects, but
  not clear that this is true (they use temporal and contemporaneous networks).
  - Their context is expected to have non-stable beliefs and attitudes. Early stages
    of pandemic.
  - They find cases of asymmetry, but these are typically in the other direction.
    Variables which are mostly influenced by others. We find variables which mostly
    influence others.
  - Their focus is primarily on bi-directional reinforcing effects. They also don't
    compare with symmetric model.
- @chambonTailoredInterventionsBroad2022

Issue support on climate policies in US driven by political identification and climate
beliefs @bumannWhatAreDeterminants2021 @shaoApprovalPoliticalLeaders2020
@zieglerPoliticalOrientationEnvironmental2017 @roser-renoufGenesisClimateChange2014
@unsworthItsPoliticalHow2014.

But political identification is often not consistent with policy attitudes
@iyengarAffectNotIdeology2012 @huddyExpressivePartisanshipCampaign2015. More often
identity-driven (symbolic) than issue-driven (operational)
@masonIdeologuesIssuesPolarizing2018. Also @eganIdentityDependentVariable2020.

Suggestions of asymmetric/causal directionality in belief systems:
- So far reviewed in Zotero: Belief Networks, Papers from Sara
- @brandtWhatCentralPolitical2019[p.~2,9,10]
- @brandtMeasuringBeliefSystem2022[p.~3,22]
- @keskinturkOrganizationPoliticalBelief2022[p.~10]
- @vannoordNatureStructureEuropean2025[p.~4]
- @brandtEvaluatingBeliefSystem2021[p.~2]: Belief system _dynamics_ require causal connections.
  - Constraint, causality, exogenous factors all necessary for any theory of BS dynamics.
  - Though still interprets edges as undirected/bi-directional
- @brandtEvaluatingBeliefSystem2021[p.~22]: "In some cases ... assume that causal influence
  for some elements (e.g., partisan identification) is primarily in one direction".
- @converseNatureBeliefSystems2006[p.~208] (mentioned in @brandtEvaluatingBeliefSystem2021[p.~2])
- @coppockBeliefSystemsExhibit2022: Referenced in @brandtEvaluatingBeliefSystem2021

Self-interaction effects:
- @brandtEvaluatingBeliefSystem2021[p.~22]: "we made the simplifying assumption that a node
  does not affect itself".


Variation in belief systems between individuals:
- @brandtEvaluatingBeliefSystem2021[p.~4,20] "connections will likely vary between people,
  time, and political contexts", "Although ... belief systems are at the individuals level,
  this does not mean that structure is not shared"


Stability of belief dynamics:
- @osborneDoesOpennessExperience2020
- @kileyMeasuringStabilityChange2020
  - Most observed change in beliefs and behaviours is short-term (or measurement error)
  - This is consistent with the cognitive dissonance theory

Individual belief dynamics are important to understanding behavioural influences
between individuals: @rodriguezCollectiveDynamicsBelief2016
@aiyappaEmergenceSimpleComplex2024
- "Models of internal belief networks generally disregard external social networks, although a number of classic social-cognitive theories recognise the importance of social environments in changing individual beliefs and behaviours (Ajzen, 1991; Cialdini & Trost, 1998; Festinger, 1954; Fishbein & Ajzen, 1975; Petty & Cacioppo, 1986)" @dalegeNetworksBeliefsIntegrative2025

Richness of _perceptions_ of others beliefs:
- Discussed in @dalegeNetworksBeliefsIntegrative2025
- References @galesicHumanSocialSensing2021

Approaches to modelling belief systems/dynamics:
- Regularised partial correlation networks, e.g., @brandtWhatCentralPolitical2019
- Bayesian networks @powellModelingLeveragingIntuitive2023
- Social Knowledge Structure @greenwaldUnifiedTheoryImplicit2002
- Causal Attitude Network @dalegeFormalizedAccountAttitudes2016
  - Attitudinal Entropy @dalegeAttitudinalEntropyAE2018
- Hierarchical Ising Opinion model.
- SEM?

Our approach as an intermediate between undirected models and directed models with
prespecified structure or acyclicity constraints.

Understanding exogenous influences on belief systems and attitudes
@coppockBeliefSystemsExhibit2022

Modularity clustering for correlation networks @masudaIntroductionCorrelationNetworks2025

== Asymmetry example

Suppose thin arrows have weight 1, thick arrows have weight 2, and a belief/attitude
adopts the dominant state in its neighbourhood, weighted by the incoming edge weights.
If your support for non-climate-related policies and your social circle are
Republican-aligned, you adopt that political ideology. Suppose that you believe in
human-caused climate change, then that reinforces your support for climate action;
however, the net support is $-1$, so you flip, taking the support for Republican
politics to $+4$. If you then become concerned about extreme weather, and believe
that the impacts of climate change are high, your support for climate action flips
to positive with a net support of $+1$. However, this is not sufficient to shift
your Republican alignment, which stays at $-1$. In the extreme case, where there is
no feedback to Politics, your change in attitude has no bearing on your political
alignment.

Asymmetry is then best thought of as the weight imposed on one belief/attitude by
another being different from the opposite direction. To overcome Republican alignment,
we need at least two pro-Democrat attitudes. To overcome negative `CC Action`,
we require at least three other pro-climate attitudes.



#figure(
  image("../diagrams/draft/asymmetry_example.png"),
  placement: none,
)

== Research questions

*Theoretical contributions:*
- *RF1.1:* Extending the causal attitude network model of belief systems to: (i)
  support asymmetric causal effects between beliefs and attitudes, and (ii) model
  intervention dynamics.

*Inferring belief systems:*
- *RQ2.1:* To what extent are causal relations _symmetric_ or _asymmetric_ in models
  of climate change belief systems inferred from observational data?

- *RQ2.2:* How do (symmetric or asymmetric) belief systems relating to climate change
  vary between conservative and liberal individuals?

*Intervention dynamics:*
- *RQ3.1:* How do asymmetric and symmetric beliefs systems inferred from the climate
  attitudes dataset differ with regards to intervention strategy and effectiveness?

- *RQ3.2:* How do intervention outcome and effectiveness vary between individuals with
  different initial conditions, or between conservative and liberal individuals?


== Contributions
+ We present a mathematical model for belief system dynamics that does not assume
  equilibrium and does not assume symmetric influence between cognitive aspects
  (@sec:asymmetric-belief-systems)
+ We describe a novel parameter estimation method for fitting binary Ising models to
  continuous data (@sec:methods).
+ We calibrate said model to data from a recent longitudinal survey including items on
  beliefs and attitudes regarding climate change
  (@sec:results-asymmetry-in-belief-systems).
+ We demonstrate, by way of the calibrated model, the existence of asymmetric influence
  relations between beliefs and attitudes. Furthermore we show that influence relations
  are not _necessarily_ asymmetric, may vary in the degree of asymmetry, and can be
  unidirectional (@sec:results-asymmetry-in-belief-systems).
+ We demonstrate that the decision to represent asymmetric relations in belief system
  models can change intervention dynamics, and therefore conclusions one draws
  regarding intervention effect and effectiveness
  (@sec:results-asymmetry-in-belief-systems).
+ We then show that belief systems may vary significantly between individuals, by
  fitting the proposed model to subsets of the climate attitudes dataset comprising
  conservative and liberal individuals
  (@sec:heterogeneity-in-belief-systems-and-intervention-effects).
+ Finally, we show that reasoning about the effects of interventions on _individuals_
  is, in general, non-trivial. How an individual responds to an intervention typically
  depends on their prior belief system state, including beliefs and attitudes other
  than the target and goal of intervention
  (@sec:heterogeneity-in-belief-systems-and-intervention-effects).


// == Proposed thesis structure
//
// - *Terminology and notation*
//
// - *Introduction:*
//   - Motivate the problem,
//   - Outline contributions (research questions)
//
// - *Asymmetric belief system:*
//   - Define and illustrate the model
//   - Model simulation with Glauber dynamics
//   - How do we model interventions?
//
// - *Methods:*
//   - Counterfactual intervention experiments --- comparing against the no-intervention
//     scenario, measuring differences in effects.
//   - Parameter estimation:
//     - Maximum likelihood estimation
//       - Conditional on a specific binarisation
//       - Marginalising over binarisation process
//     - Regularisation
//
// - *Existence and impacts of asymmetry in belief systems*
//   - Results for:
//     - *RF1:* Show asymmetric model fit
//     - *RQ2.1:* Existence of asymmetric relations. Some, but not all, are significant.
//       Categorising relations into types: symmetric, asymmetric (both directions exist,
//       with different effect sizes), and unidirectional (only one direction exists).
//     - *RQ3.1:* Differences between symmetric and asymmetric models, with regards to
//       intervention strategy (which intervention to do) and effectiveness (magnitude of
//       change compared to the no-intervention case).
//
// - *Individual heterogeneity in belief systems and intervention dynamics*
//   - Second results section
//   - *RQ2.2:* Fit models to conservative and liberal subsets of the data; compare and
//     contrast. Compare with the model from the previous section, i.e., fit on the entire
//     dataset.
//   - *RQ3.2:*
//     - Distribution of intervention effectiveness by individual.
//     - How does intervention ranking vary across individuals?
//     - Characterising how different initial states affect intervention success.
//     - Looking at how other theory-driven features affect success, e.g.:
//       - How receptive is the individual to the intervention?
//
//         The effective baseline ($h_i + sum_j J_(j i) s_j$) determines the probability
//         that $S_i^(t+1) = s$ for a state $s in plus.minus 1$. Evaluating this after
//         intervening provides a measurement for the success of the intervention on the
//         intervention spin itself.
//
//         We could look at how this changes with different intervention strengths (it
//         follows a logistic curve).
//
//       - How consistent is the individual's belief state, as measured by the total system
//         energy?
//
//       - How 'entrenched' is the target attitude?
//
//         Measure $h_k s_k + sum_(j) J_(j k) s_j s_k$, where $k$ is the target attitude.
//
// - *General discussion*
//   - Draw out the key findings from the above two results sections
//   - Make clear the implications for our theory of belief system dynamics
//   - Sensitivity of parameter estimation to unmeasured factors or incorrect structural
//     assumptions. i.e., what happens when we cannot include an influential belief, or
//     when we falsely assume that a relation does or does not exist?
//   - Representational limitations of our model:
//     - Pairwise relations limit what can be modelled. Demonstrate using vaccination
//       example --- we can't capture relations between pairs of attitudes, whose effect
//       sign or magnitude depends on a third belief/attitude.
//     - Polar ($-1, +1$) spin state assumption; some beliefs may be better treated as
//       'on/off', where the 'off' state has _no_ effect on other spins, rather than a
//       negative effect.
//     - More generally, effect sizes may vary depending on specific spin states.
//
// - *Dataset*
//   - Introduce the (insert name here) dataset, give context, survey details
//   - Validation, cleaning, transformations
//   - Question selection, indexes
//   - Binarisation
//
// - *Literature review/related work*
//
// - *Conclusions and future work*

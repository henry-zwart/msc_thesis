#import "../lib.typ": glossary

#show figure.where(kind: table): it => {
  set text(size: 8pt)
  it
}

== Correlational data-driven belief models

During our meeting on #link("https://henry-zwart.github.io/msc_thesis/log/#wednesday_1")[December 17], Sara 
shared several papers related to data-driven models of internal belief systems @brandtWhatCentralPolitical2019 
@brandtMeasuringBeliefSystem2022 @powellModelingLeveragingIntuitive2023 @vannoordNatureStructureEuropean2025 
@leeVariationsClimateChange2025. 

The studies describe attempts to infer #glossary("belief-system")[belief systems] from survey 
data, for the purposes of either proposing such a method or as a means to study properties of these belief 
systems. @tab:data-driven-belief-models-overview outlines the key features of these studies. Most of the 
examined papers consider population-aggregate belief systems, and treat belief systems as correlational 
networks. The surveys cover a variety of belief system contexts, spanning general political attitudes and 
ideologies, climate change policies, as well as beliefs and intentions concerning childhood vaccination.

Only one of the studies, #cite(<powellModelingLeveragingIntuitive2023>, form: "prose"), considers directional
belief relations, in the form of a #glossary("bayesian-network")[Bayesian Network]. While the authors of this 
study employ structure learning to identify edge existence and weight, they restrict the search space by 
forbidding edges flowing from more specific to more general concepts#footnote[
  #cite(<powellModelingLeveragingIntuitive2023>, form: "author") remark that the relations should not _all_ 
  be interpreted causally, but rather as 'probabilistic dependencies or "influence" relations'. They evidence 
  this point with respect to the inferred edge #raw("Vaccine Danger") $-->$ #raw("Vaccines Toxicity")\; 
  intuitively, people do not consider vaccines toxic _because_ they consider them dangerous. Instead, the 
  authors argue that this relation is more appropriately interpreted as set membership.
]. 
All other studies model belief systems as either 
#glossary("partial-correlation-network")[regularised partial correlation networks]
@brandtWhatCentralPolitical2019 @leeVariationsClimateChange2025 or a related correlational measure of belief 
association @brandtMeasuringBeliefSystem2022 @vannoordNatureStructureEuropean2025.

Most of the studies consider population-aggregated belief systems#footnote[
  These are also referred to as 'between-person' belief systems.
], for which edges are inferred from population-level associations observed in the survey data. These have 
limited interpretability at the individual level @brandtBetweenpersonMethodsProvide2022, e.g., for inferring 
structural variation across individuals' belief systems, or reasoning about interventions. The only examined 
study to explicitly consider individual belief systems is 
#cite(<brandtMeasuringBeliefSystem2022>, form: "prose"), which investigates differences in belief system 
structure using individual conceptual similarity ratings#footnote[
  The survey for this study asks participants to judge the conceptual association between pairs of beliefs or 
  attitudes. For instance: 'Someone who believes in _X_ is likely to also believe in _Y_.'
]. In all other studies the relations between beliefs should be considered general trends or statistical 
associations.

None of the studies consider higher-order belief relations comprising three or more beliefs. This is a 
potential limiting factor on claims for model accuracy, in particular due to the multiple realisability of 
the survey data observations when higher-order interactions are permitted. That is to say that claims for the 
accuracy of the inferred models are subject to the assumption that all meaningful belief relations are 
pairwise.

#figure(
  table(
    columns: 5,
    align: (right, right, center, left, left),
    stroke: none,
    table.header[Text][Model][Aggregation][Context][Research intent],
    table.hline(stroke: 0.7pt),
    [@brandtWhatCentralPolitical2019], [R-PCN], [Population], [General political], [What _types_ of beliefs are most central in belief networks: #glossary("operational-component")[operational] or #glossary("symbolic-component")[symbolic]?],
    [@brandtMeasuringBeliefSystem2022], [CSN], [Individual], [General political], [Method to infer (undirected) individual belief systems.],
    [@powellModelingLeveragingIntuitive2023], [BN], [Population], [Vaccination], [Role of auxiliary hypotheses/beliefs in intervention outcome and effect on belief revision.],
    [@vannoordNatureStructureEuropean2025], [R-PCN *(?)*], [Cluster], [General political], [Method to identify and compare belief systems within/between populations.],
    [@leeVariationsClimateChange2025], [R-PCN], [Country], [Climate change], [Analyse stability and inconsistency of climate belief systems across globe.]
  ),
  placement: none,
  caption: [Model, context, and intentions of (considered) papers on data-driven belief models. Models: #strong[R]egularised #strong[p]artial #strong[c]orrelation #strong[n]etwork (*R-PCN*), #strong[C]onceptual #strong[S]imilarity #strong[N]etwork (*CSN*), #strong[B]ayesian #strong[N]etwork (*BN*). Belief systems aggregated at varying levels --- non-individual aggregations to be thought of as general trends/statistical associations.],
) <tab:data-driven-belief-models-overview>

== Brandt (2022) statistical control issues
We identified potential methodological issues in the choice of control variables for the statistical analysis 
in #cite(<brandtMeasuringBeliefSystem2022>, form: "prose"). In this study the authors regress survey 
participants' conceptual association ratings for belief pairs on a number of individual difference factors 
(political identity, political engagement, political knowledge, liberal/conservative attitudes) to investigate
their impact on belief system structure. While the authors do not descrbie their assumed causal model for these analyses, at least one plausible model indicates problems in their choice of control variables, which could 
bias their results. We note that the authors appear to recognise the interdependencies of these variables, 
as they separate their statistical analysis into sets of control variables rather than performing a single 
linear regression (which would imply an independence assumption).

Let $i$ refer to some survey participant, and $p$ a pair of beliefs. The response variable is the individual's conceptual 
similarity rating for the belief pair ($R_(i,p)$). Individuals are characterised by:
- $I_i$: #strong[I]deological identification (liberal $<-->$ conservative), 
- $X^I_i$: #strong[I]deological e#strong[X]tremity,
- $P_i$: #strong[P]arty identification (democrat $<-->$ republican),
- $X^P_i$: #strong[P]artisan e#strong[X]tremity,
- $E_i$: Political #strong[E]ngagement level, and
- $K_i$: Political #strong[K]nowledge.
Ideological and partisan extremity factors are constructed from the corresponding identification factors by 
'"folding over" the measure' @brandtMeasuringBeliefSystem2022[p.~838]. Participants are assigned randomly to 
one of two experimental #strong[C]onditions#footnote[
  The experimental condition determined whether survey participants are asked to rate conceptual similarity 
  of beliefs for themselves (e.g., "Imagine you hold belief _X_. How likely are you to believe _Y_?"), 
  or for other people (e.g., "Suppose that someone holds belief _X_. How likely are they to believe _Y_?").
]: $C_i$. Pairs of beliefs are tagged with a #strong[T]ype: $T_p$, according to whether the beliefs are 
ideologically consistent or inconsistent.

To construct a causal graph for conceptual similarity ratings from the described variables#footnote[
  We acknowledge that there may exist other factors which should be considered in this model, but do not 
  consider these here since our intention is to illustrate a problem with the use of existing variables.
], we assume that: 
+ Each of the stated factors could have a direct #text(fill: rgb("#CC0000"))[*causal effect*] on an individual's conceptual rating for 
  a given belief pair. 
+ Ideological identification is a #text(fill: rgb("#B266FF"))[*causal factor*] for party identification (e.g., people who 
  view themselves as conservative are more likely to vote Republican on account of its general recognition as 
  the conservative party).
+ Ideological identification is a #text(fill: rgb("#009900"))[*causal factor*] for political engagement.
+ Political engagement is a #text(fill: rgb("#0000FF"))[*causal factor*] for political knowledge.
+ Ideological extremity is a #text(fill: rgb("#990099"))[*causal factor*] for partisan extremity (i.e., individuals who are firmly 
  liberal/conservative are likely to be also firmly partisan).
Furthermore, since the extremity factors are constructed, these are 
#text(fill: rgb("#00CCCC"))[*causally dependent*] on the corresponding identification factors by definition. 
The resulting causal DAG is shown in @fig:brandt-2022-dag.

#figure(
  image("../figures/brandt_2022_dag.pdf", width: 60%),
  placement: none,
  caption: [
    Causal DAG for conceptual similarity ratings ($R_(i,p)$) in 
    #cite(<brandtMeasuringBeliefSystem2022>, form: "prose"), where $i$ represents a participant in the survey,
    and $p$ is a belief pair. Edge colours correspond to causal assumptions outlined in main text.
    Factors are: ideological identification ($I_i$), partisan identification ($P_i$), 
    ideological extremity ($X^I_i$), partisan extremity ($X^P_i$), political engagement ($E_i$), political 
    knowledge $K_i$, pair type ($T_p$; ideologically consistent or inconsistent), and experimental condition 
    ($C_i$; questions about _own_ beliefs or _others'_ beliefs). ]
) <fig:brandt-2022-dag>

#cite(<brandtMeasuringBeliefSystem2022>, form: "author") performs four statistical analyses on this set of 
variables. We will summarise the estimands, choice of controls, and correct controls for each one. In each case
they separate the the analysis according to belief-pair ideological consistency ($T_p$) and experimental 
condition ($C_i$), controlling for both factors. 



=== $E_i --> R_(i,p)$
The authors first investigate the effect of political engagement 
on rating. They control for $E_i$, but leave open a backdoor path through $I_i$ (according to our assumed model 
in @fig:brandt-2022-dag). If political engagement varies with ideological identification then the measured 
effect will be biased. The correct control set to estimate the _total_ effect is ${E_i, I_i}$. If the authors 
intend to measure the _direct_ effect (i.e., excluding the portion of the effect due to influence of political 
engagement on political knowledge), they should also control for $K_i$.

=== $K_i --> R_(i,p)$
They then estimate the effect of political _knowledge_ on rating, controlling for $K_i$, leaving open a 
backdoor path through $E_i$. The correct control set is ${K_i, E_i, I_i}$. They observe a similar effect 
here as in the first study; however, since this includes the effect of political engagement this is not 
measuring the effect of interest. 

=== $I_i --> R_(i,p)$ and $X^I_i --> R_(i,p)$
Thirdly, they investigate two estimands with the same model, i.e., the effects of ideological 
identification and partisan identification, controlling for $I_i$ and $X^I_i$. These controls are correct 
for estimating the effect of $X^I_i$, but not for $I_i$. 

It is unclear from the text whether the authors intend to measure the direct effect of ideological 
identification, or the total effect (i.e., including the intermediary causal paths through party identification,
political engagement, etc.). If they intend to measure the _direct_ effect, then the correct control set is 
${I_i, P_i, E_i, X^I_i}$. If they intend to measure the _total_ effect, then the correct control set 
${I_i}$ excludes $X^I_i$.

=== $P_i --> R_(i,p)$ and $X^P_i --> R_(i,p)$
As above, they investigate two estimands with a single model, controlling for $P_i$ and $X^P_i$. We treat 
these two estimands separately.

For partisan identification, the correct control set is ${I_i, P_i}$ for the _total_ effect or 
${I_i, P_i, X^I_i, X^P_i}$ for the _direct_ effect. For partisan extremity the direct and total effects are 
equivalent, and are correctly estimated using the control set ${P_i, X^I_i, X^P_i}$.



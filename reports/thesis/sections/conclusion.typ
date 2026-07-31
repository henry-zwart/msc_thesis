//*0. (Maybe) Little reminder of the gap(?)*

While studies on belief system dynamics often acknowledge that certain beliefs and
attitudes may be more causally influential than others, current research focuses
predominantly on symmetric influence relations. Theoretical belief system models which
capture asymmetric relations remain scarce, as do empirical studies on the existence of
asymmetric belief relations or their potential impacts on belief system dynamics.

//*1. Remind reader of the research questions*

This study set out to explore the presence of asymmetric relations in beliefs and
attitudes relating to climate change in the US (*RQ1*), and their potential consequences
for collective interventions on belief systems (*RQ2*). The secondary aims
of this study were to investigate how intervention effectiveness varies among individuals
in asymmetric belief systems (*RQ3*), and how asymmetric belief systems may differ
structurally between subpopulations with different political ideologies (*RQ4*).
// In this work we address each of these items in turn. After introducing an asymmetric
// belief system model based on the Causal Attitude Network theory
// @dalegeFormalizedAccountAttitudes2016, we investigate the extent to which asymmetric
// relations feature in longitudinal data on climate-related beliefs and attitudes in the
// US (*RQ1*), and their consequences for collective (*RQ2*) and individual (*RQ3*) belief
// system dynamics during interventions. We additionally investigate differences in
// asymmetric belief system structure between subpopulations with different political
// ideologies (*RQ4*).
//*2. Describe the general approach we took (mathematical model based on cognitive dissonance, calibrated to longitudinal survey data on climate change; intervention studies using common random numbers)*
To address these research questions, we first introduced an asymmetric non-equilibrium
model of belief system dynamics based on the Causal Attitude Network theory
@dalegeFormalizedAccountAttitudes2016, which we then calibrated to longitudinal survey
data on climate-related beliefs and attitudes collected in the US between 2020 and 2023.
We assessed the existence of asymmetric
relations and structural differences between ideological belief systems via direct
analysis of the calibrated models, and investigated the consequences of asymmetry for
intervention dynamics by comparing simulated outcomes with those of an analogous
symmetric model using common random numbers.
// We then proceaassessed the existence of asymmetric
// relations as well as structural differences in ideological belief systems via direct
// analysis of the calibrated models. We investigated the implications of asymmetry for
// intervention dynamics

// To address these research questions we introduced a non-equilibrium model of belief
// system dynamics which captures asymmetric influences, based on the Causal Attitude
// Network theory @dalegeFormalizedAccountAttitudes2016, which we then calibrated to
// longitudinal survey data collected in the US between 2020 and 2023.
// We assessed
// the existence of asymmetric relations using model bootstrapping, and investigate
// the consequences for belief system dynamics under intervention via model simulation,
// and comparison to an analogous symmetric model using common random numbers.

//*3. Answer the RQs. At most 3-4 sentences on each.*

Our investigation identified several significant instances of asymmetry in the calibrated
model. In particular, all such cases featured either 'political ideology/alignment' or
'climate-related worry' as the dominant influencing factor. All other (non-null)
relations were found to be inconclusively asymmetric or likely symmetric. This suggests
that (i) asymmetry is likely the exception as opposed to the norm, and (ii) asymmetry
may be more accurately characterised in terms of differences between a given belief's
influence and influentiability, rather than at the level of
individual relations. In the subsequent simulation experiments on collective interventions
we found significant differences in expected outcomes between symmetric and asymmetric
models, particularly when targeting or intervening on the aforementioned attitudes. We
argue that these differences arise primarily due to conflation of influence and
influentiability by the symmetric model, which amounts to model misspecification when
true relations are asymmetric.

Expected intervention effectiveness was found to depend predictably on an individual's
belief system state prior to intervention. Most effective interventions required that
the point-of-intervention and target both be different from their desired
post-intervention states. While this was expected behaviour, we additionally found
that all highly effective interventions required that prior climate-related worry be
low. We attribute this finding to the variable's high levels of both influence and
influentiability, which make it an effective indirect pathway for various interventions
to propagate.
// In addition, we find that low climate-related worry is necessary for all effective
// interventions targeting attitudes toward climate action.

In spite of relatively smaller sample sizes, our findings suggest that belief systems
for the conservative and liberal subsets of the dataset may differ in sparsity (the
proportion of missing edges) and specific belief relations, while also displaying broad
structural similarities. These similarities suggest that while, in line with
the typical assumption, belief systems likely vary between individuals, they also likely
display common structural features (e.g., based on shared experiences or world-views).
On the other hand, the observed differences in pairwise relations when stratifying by
political ideology suggest the presence of higher-order relations between beliefs. This
is to say that the existence, strength, or direction of a given relation between two
beliefs may depend on the specific state of a third (in this case, political ideology).



*4. Particularity of the research (also sometimes called limitations)*


Since the data used for model calibration comprised only two waves, it was not possible
to model individual baseline activations; therefore, the extent to which the observed
asymmetric relations reflect within-person or between-person associations is unknown.

- Within-person and between-person effects
- Individual belief systems
- Modelling social influences, exogenous effects
- Higher-order interactions (as suggested by the ideology experiment). Limits
  representational capacity. We expect that such effects may qualitatively change
  belief (and intervention) dynamics.
-


*5. Contributions to the literature*

- Empirical evidence of asymmetry in belief system interactions
- Simulation-based analysis of the effects of intervening in (symmetric or asymmetric)
  belief systems

*6. Implications for the field*

- Symmetric models as misspecification:
  - Asymmetry characterised at the belief level (mostly influential vs. mostly influenced)
  - Can lead to underestimating 'importance' in symmetric models on most (all?) centrality
    measures.







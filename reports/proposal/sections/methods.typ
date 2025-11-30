#import "../lib.typ": plan

#let rq1 = link(<RQ1>)[*RQ1*]
#let rq2 = link(<RQ2>)[*RQ2*]
#let rq3 = link(<RQ3>)[*RQ3*]

#plan[
  *Methods:*
  1. Base model (beliefs-as-nodes):
    - Motivation
    - Potential dissonance between personal beliefs given by @dalegeNetworksBeliefsIntegrative2025 
      $ H_"pers" = sum_i tau_i b_i - sum_(i j) omega_(i j) b_i b_j $
]

We consider the BAN approach an appropriate foundation for this study, on account of its natural 
extension to directed relations and amenability to inferring beliefs from data (discussed above). 
In particular, we will extend the 'Networks of Belief' (*NB*) model recently proposed by 
#cite(<dalegeNetworksBeliefsIntegrative2025>, form: "author"). The NB model measures the cognitive dissonance of 
a collection of beliefs using the standard network Ising model energy function (ibid.):

$ 
   H(bold(b)) := sum_i tau_i b_i - sum_(i j) omega_(i j) b_i b_j 
$ <eq:nb-internal-dissonance>

where $b_i$ is the belief associated with node $i$, $tau_i$ is a 'field' term (reflecting 
exogenous influence), and $omega_(i j)$ is the signed interaction strength between beliefs 
related beliefs. Individuals update their beliefs to decrease cognitive 
dissonance, as modelled by iterative samples from a Boltzmann distribution parameterised
by $H$ and a temperature parameter. In the NB model each $omega_(i j)$ is symmetric, 
thus we can support directed relations by allowing each $omega_(i j)$ and $omega_(j i)$ pair 
to vary separately.

#plan[
  2. Causal discovery:

  3. Dataset:
    - Description: longitudinal study on climate attitudes in the US, collected between ... and .... 
    - Source
    - Intention
    - Two dimensions: population and time.
      - Time
        - Six waves
        - Each individual is present in a subset of the waves. These can be not noncontiguous.
      - Population: 
        - Unsure about key statistics ($n$, sampling methods)
    - Questions:
      - Demographic/population groups
      - Experiences
      - Beliefs/attitudes
    - No relationship information (as far as I am aware), so we will disregard social connections in 
      model for purposes of model-fitting.
]

To answer #rq1 we intend to fit the NB model (and its directed variants) to empirical 
data from a longitudinal survey on climate attitudes in the US. The survey comprises 
six waves of responses collected over recent years (roughly 2023--2024), with questions covering
demographic information, experience and beliefs related to extreme weather, attitudes 
about climate change and related policy, among other categories. Each participant has 
responded to a (possibly noncontiguous, possibly singular) subset of waves. 

Given the considerable extent of available data and computational limitations associated 
with fitting large spin models (see #cite(<nguyenInverseStatisticalProblems2017>, form: "prose")), 
an initial analysis stage is necessary to identify the factors and questions most relevant to 
the present study. 

Inferring belief relations consists in the inverse problem of determining the values of $tau_i$ 
and $omega_(i j)$, for each pair of beliefs $i,j$, such that the resulting network reproduces 
the observed empirical distribution. This problem is underdetermined in-general; however, it is 
common practice to further constrain the solution to have maximum entropy among candidate 
parameterisations, i.e., that which imposes minimal structural assumptions beyond reproducing the 
data @leeStatisticalMechanicsUS2015 @nguyenInverseStatisticalProblems2017.


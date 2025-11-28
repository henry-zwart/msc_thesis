#import "../lib.typ": plan

#let rq1 = link(<RQ1>)[*RQ1*]
#let rq2 = link(<RQ2>)[*RQ2*]
#let rq3 = link(<RQ3>)[*RQ3*]

#plan[
  *Methods:*
  1. Base model (beliefs-as-nodes):
    - Motivation
    - Potential dissonance between personal beliefs given by @dalege_networks_2025 
      $ H_"pers" = sum_i tau_i b_i - sum_(i j) omega_(i j) b_i b_j $
]

For these reasons, we consider the beliefs-as-nodes approach a more appropriate foundation
for this study. In particular, we will extend the 'Networks of Belief' (*NB*) model recently 
proposed by #cite(<dalege_networks_2025>, form: "author") to include directed relations.
The NB model measures the cognitive dissonance of a collection of beliefs using the standard
network Ising model energy function (ibid.):

$ 
   H(bold(b)) := sum_i tau_i b_i - sum_(i j) omega_(i j) b_i b_j 
$ <eq:nb-internal-dissonance>

where $b_i$ is the belief associated with node $i$, $tau_i$ is a 'field' term (reflecting 
exogenous influence), and $omega_(i j)$ is the signed interaction strength between beliefs 
which are connected by an edge. Individuals update their beliefs to minimise cognitive 
dissonance. This is modelled by repeated samples from a Boltzmann distribution parameterised
by $H$ and a temperature parameter. In the original model $omega_(i j)$ is symmetric, 
reflecting undirected associations between beliefs, thus we can extend the model to support 
directed relations by allowing each $omega_(i j)$ and $omega_(j i)$ to vary.

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

In #rq1 we plan to fit the NB model and its directed variants to empirical data, to 
investigate the relational structure of beliefs in real individuals, and how this varies
across population groups or different experiences. For this purpose we have access to a 
longitudinal survey on climate attitudes in the US. The survey comprises six waves of 
responses collected between *DATE 1* and *DATE 2*. Each participant has responded to a 
subset of the waves, which may not be contiguous (e.g., a person may have responded in 
waves 1 and 3, but not 2). Questions cover demographic information about participants,
their past experience with extreme weather events, beliefs regarding the causes of 
severe weather, attitudes about climate change and related policy, among other categories.

Inferring belief networks from this data will require an initial analysis stage to 
identify factors and questions that are relevant to the present study.

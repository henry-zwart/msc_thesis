Kyuri recommends starting with @epskampEstimatingPsychologicalNetworks2018 and possibly @epskampGaussianGraphicalModel2018.

Papers which use partial correlation in belief/internal cognitive state context:
- @brandtWhatCentralPolitical2019
- @fishmanChangeWeCan2022
- @leeVariationsClimateChange2025
- @brandtEvaluatingBeliefSystem2021
- @dalegeNetworksBeliefsIntegrative2025
- @dalegeUsingCognitiveNetwork2022

Other papers which discuss partial correlations:
- @parkDiscoveringCyclicCausal2024
- @epskampEstimatingPsychologicalNetworks2018
- @epskampGaussianGraphicalModel2018
- @borsboomNetworkAnalysisMultivariate2021
- @yinSPARSECONDITIONALGAUSSIAN2011

Criticism:
- @brandtBetweenpersonMethodsProvide2022


== The Gaussian Graphical Model in Cross-Sectional and Time-Series Data @epskampGaussianGraphicalModel2018

Let $Sigma$ be a variance-covariance matrix with rank $n$, then the precision matrix is defined 
as the inverse, $K = Sigma^(-1)$, if it exists. Standardising $K$ gives the partial correlation 
matrix:

$
R = op("Cor")(Y_i, Y_j | bold(y)_(-(i,j))) := - kappa_(i j)/(sqrt(kappa_(i i) . kappa_(j j)))
$

Note that the diagonal elements equal 1 by definition, rather than by this formula, and 
should not be negated.

=== Causal interpretation of edges

An edge $A - B$ appears in a GGM only if there is a causal link $A -> B$ or $B -> A$, or a 
collider $A -> C <- B$ which we condition on. The authors do not consider the possibility of an 
unobserved fork, likely because they assume that "a causal model between _observed_ variables 
generated the data".

So non-zero partial correlations/edges in a GGM can be considered indicators of potential 
causal relations involving the variables of interest. However, causal directionality, and the 
presence of forks or colliders is underdetermined. In the case of forks, unobserved 
common causes are indistinguishable from direct relations ($A <-> B$), while observed forks 
are conditioned on and thus reduce the observed relation between $A$ and $B$. With regards to 
colliders, the implications are reversed. Unobserved colliders do not affect the partial 
correlation matrix since they are not conditioned on, and thus may not be detected. Observed 
colliders bias the relation between the causes, and thus feature as a modified direct relation.

*Question:* Why do we observe a non-zero partial correlation between $A$ and $C$ in the fork 
$A <- C -> B$? To calculate this, we control for $B$. However, since $A$ and $B$ are only caused
by $C$, I would expect the partial correlation then to be zero, since we remove the comparable 
relation between $C$ and $B$. 


== Estimating Psychological Networks and their Accuracy: A Tutorial Paper @epskampEstimatingPsychologicalNetworks2018

*Problem:* Use of psychological networks linking psychological behaviour to underlying 
psychological factors is popular, but evaluation measures have not been well-explored.

*Contributions:*
- Introduction to SOTA psychological network estimation
- Discussion on importance of investigating their accuracy
- Provide a methodology for evaluating accuracy, stability (of centrality indices),
  and comparing variables in psychological networks.
- Introduce novel statistical methods:
  - Correlation stability coefficient
  - Bootstrapped difference test
- Produce R package (`bootnet`) for estimating and evaluating psychological networks
  using proposed measures.
- Case study using `bootnet`.

The supplementary material includes description of how to interpret psychological networks, and 
overview of network measures.

@vanborkuloNewMethodConstructing2014

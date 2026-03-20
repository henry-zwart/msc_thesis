## March 16 - March 22

### Thursday
- Meeting with Vítor
- Converting questions groups into indices
- Sent data + EDA report to Kyuri

#### Meeting with Vítor
Past two weeks:

- Pruned low-association variables as discussed with Sara
- Reproduced 'willingness-to-pay' analysis: comparable measure of costed policy 
  support for solving CC/compensating affected communities
- Included `cc2` (beliefs regarding causes of climate change) in question set;
  remapped such that human-causes are high, natural-causes only/CC not happening 
  are low
- Constructed 5-point `pol_affiliation` scale from political party alignment and party
  leaning variables
- Implemented regularised partial correlation (using GLASSO) and VAR (using LASSO 
  regression)
- Added 'distance correlation' measure to EDA, to identify possible hidden non-linear
  associations
- Identified sets of variables which consistently cluster together under different 
  measures of association. Roughly 7--8 such groups. Some variables not included 
  in any group, or appear in different groups for different metrics, but have high 
  betweenness centrality.
- Started planning + writing thesis section on dataset (context, validation, cleaning,
  imputation)

Next week:

- Create indices:
    - Transform each identified variable group according to its first principle
      component.
    - Evaluate index consistency using cronbach's alpha; set pre-defined quality 
      threshold based on established standards.
    - For indices which do not meet criteria, investigate alternatives (e.g., first 
      two PCA components; leave variables split) 
- Understand the reduced dataset:
    - Marginal distributions for variables + indices
    - What do the indices represent? (Check PCA vectors -- any oddities?)
    - Plot correlation/association figures, clustering, networks
    - Is binarisation reasonable?
- Create baseline models:
    - Ising (may require binarisation): undirected, directed
    - Partial correlation networks
- Continue writing:
    - Finish draft of dataset section
    - Plan index construction section; theory (models, metrics, etc.)

Discussion points:

- ENLENS: Dataset info and citations; what to call the dataset; possibly publish 
  validated/cleaned dataset (may need to extend set of validated variables).
- Vítor meeting: 
    - Touch base with examiner (Johan); 
    - Timeline: defence date

## March 9 - March 15
Goals for the week:

- Figure out how to include expected relevant, yet problematic variables (e.g., `cc2`, binary vars).
- Reduce set of variables by pruning out low relevance ones, with justification when these were 
  expected to be important.
- Re-do analysis within the beliefs, attitudes categories. Identify broad trends/factors.
- Start planning thesis writing, likely for methods section.

### Tuesday
- Cleaned up repo a bit
- Worked on constructed variables:
    - Supplement `pol_party` with `pol_lean` responses to create a 5-point scale
    - Include `cc2` (CC causes) and re-code such that human-causes are high.

### Monday
- Met with Kyuri and Katinka to go back over main points from Thursday ENLENS meeting.
- Implemented 'cut' hierarchical clustering (a.k.a. feature clustering).

#### Feature clustering
Hierarchical clustering algorithms typically take as input a set of $M$ observations 
in $N$ dimensions, then iteratively merge these observations based on (i) a given 
distance measure, and (ii) a merge rule (e.g., 'single' or 'ward'). The algorithm
terminates either when the observations have been reduced to a pre-specified number 
of clusters, or when all observations have been recursively merged under a unifying 
root.

For the purpose of identifying non-linear relationships between survey variables, we 
need a slight variation on this algorithm. In particular, we want to treat each variable
(aka column; aka dimension) as a leaf comprising all observed values, then cluster these 
leaves such that similar variables are grouped together. Critically, we must be careful
to remember that observations from different variables are still grouped at the level of 
individual survey participants, as well as survey waves.

To achieve this, we instead pass pre-computed distance matrix (with shape $N \times N$)
to the clustering algorithm. The values of this matrix are calculated according to the 
merge rule used for the clustering algorithm. In the case of the 'single' merge rule, 
we use the minimal (euclidean) distance between any pair of observations from the same 
survey response (same participant and wave). For the 'complete' rule, we take the 
maximum such distance, and for 'average' we take the mean. I'm not sure yet how to 
implement this for the Ward merge rule.




## March 2 - March 8
A short week for me, as I am at the NTDS Friday through Sunday. Met with Kyuri 
to discuss variable indexes EDA, then with Sara and team on Thursday.

#### Meeting with Kyuri
- Revert from split variables to singular scales 
- Use EFA to qualitatively identify groups of variables; compare findings with 
  other methods (PCA, ICA, hierarchical clustering).
- Try to prune out questions which don't appear to load strongly with any other 
  factors.
- Consider the differences between methods; what do contrasting results imply?
- Once we have removed unuseful variables, we may see more structure appear for 
  the found clusters.

## Feb 23 - March 1 2026
### Plan for week
- Regular meeting with Vítor on Monday at 1pm, shifted due to Kobe workshop on 
  Thursday.
- Kobe workshop on Thursday.

### Monday
- Weekly catch-up with Vítor
- Exploring missing wave imputation for survey data

#### Weekly catch-up
- Discussed imputing missing responses.
- Planning for future ENLENS meetings.
- Moved regular meeting to 12.30 on Thursdays to make it easier for Kyuri to attend.
- Project goals for next few weeks.

In future, we would like the ENLENS meetings to be clearer in purpose, and in the 
questions we have for Sara and her team. To achieve this we discussed setting a 
meeting agenda on Tuesday (CEST) to send to Sara by Wednesday. This will help 
direct my work in the days running up to each meeting, and give us the chance to
either change course prior to meeting, move questions to email, or cancel in a 
given week.

On Thursdays Kyuri typically attends a meeting at the DIEP from 11am. We decided 
to shift our regular meeting to 12.30pm so that it is possible for Kyuri to attend.
We can revert this at a later date if we don't find it necessary. 

We spent the final fifteen minutes discussing the broader project plan + goals for 
the coming weeks. While I have been attempting to find a focal area of the survey 
for our study (e.g., belief systems relating to local effects of climate change), we
discussed the merits of a more general analysis of 'beliefs, attitudes, experiences,
behaviours related to climate change'. Given the limitations associated with trying 
to retro-fit the climate attitudes survey data to a specific question, this approach 
is far from ideal. 

On the other hand, the more general approach allows us to focus on identifying a 
proof-of-concept scenario in which a directed belief system differs meaningfully from
the equivalent undirected systems inferred using standard methods. If we can show that
interventions may differ in this proof-of-concept scenario, this is a more general 
finding and would have greater relevance to future, more directed studies.

Thus over the next few weeks, my goal will be to:

1. Construct indices for variables in the data, so as to reduce redundancy. 
    - Note: this may require imputation or other variable transformations.
2. Explore the make-up of these indices, to discuss with Sara at the next ENLENS
    meeting. Ideally the indices should make sense qualitatively (e.g., 'these 
    variables reflect concern about social impacts of CC'), such that we can 
    meaningfully discuss interventions. 
3. Re-examine the relationships between these indices using the analytical tools 
    already used for the raw data variables (VAR, partial correlation, etc.)
4. Undirected models: Fit standard models to the indices.
5. Directed models: Fit directed Ising models; run causal discovery.

#### Missing wave imputation
Vítor and I discussed using imputation methods to estimate survey responses for 
missing waves. I have been exploring methods using latent continuous states which 
translate to ordinal responses, and using sampled transition matrices to impute the 
responses directly. This makes most sense when we have recorded responses at 
$t \in \{i, i+2\}$ but no data for $t = i + 1$, as the missing response is constrained 
by the prior and following data points. 

We decided that in the first instance, a simpler method is to replace missing values 
by either the previous value, the next value, or a random sample from the two.  


## Feb 16 - Feb 22 2026

### Friday
- Emailed Sara regarding data validation issues
- Reconsidering question presence for more complex cases, combinations of related 
  questions.


#### Email to Sara
Follow-up from Yesterday's ENLENS meeting. I checked out the data to see: (i) how many 
null-ID participants there are per wave, and (ii) whether there are clear temporal 
switchpoints in the data where the survey provider has updated/fixed survey logic to 
resolve the identified null/non-null response issues.

#### Question presence
Until now I have considered questions in isolation for purposes of identifying 
relevant/repeated questions. However, in some cases we may find it useful to consider
questions which are only asked once, or combinations of related questions. 

For instance, `ew4` asks how well public officials handled the extreme weather event
that affected participants most in the prior 10 years. We expect this to be relatively
stable across waves, while also potentially influencing other variables as a 
conditional factor. This is to say that `ew4` may not itself induce change in a 
variable $Y$, but may instead moderate the causal relation $X \to Y$.

Alternatively, questions regarding beliefs such as `cc9_globstab` (regarding the 
threat of CC to global social and political stability), which are only asked in a 
single wave, may be extrapolated to later waves by considering their relation to 
other questions which are asked in multiple waves.

In the second case, `ew1` asks participants about their experiences with extreme 
weather events in the prior 10 years. This is only asked to new participants (except in 
Wave 5); however, a separate question is presented to repeating participants, asking 
instead about the change in their response since (presumably) the previous wave. Thus
while no question in this group is asked more than once, we can combine them to extract 
a repeated measure (recent extreme weather experience; total extreme weather experience).

On a related note, perhaps the erroneous survey responses (e.g., where repeating participants
answer questions intended for new participants) could be used to help impute these values 
more generally. For instance, `cc2` asks about the causes of climate change. This question is 
not asked to repeating participants in Wave 2, limiting its usage for multi-wave analyses. 
However, due to the aforementioned survey error, we actually have responses from 380 repeating 
participants. 

### Thursday
- Meeting with Vítor
- ENLENS meeting

#### Weekly catch-up
To-do:
- Understand what is happening with the VAR calculation; inverse of covariance of 
  residuals.
- Add $B$ matrix visualisation. (Done)
- Standardise variables for correlation calculations (Done); think about how they'd differ
  otherwise.
- Show networks for partial correlations, VAR. (Done)
- Significance tests for partial correlations.

### Tuesday
- Cleaning up GH repository; Python package
- Uploaded built data assets to OneDrive
- Brief catch-up with Kyuri, who has recommended some papers on partial correlation


### Monday

#### Weekly standup
##### Last week:
- _(Data validation; [#67](https://github.com/henry-zwart/msc_thesis/issues/67))_ 
  Emailed Sara about data validation issues in climate attitudes dataset.
- _(Presentation; [#72](https://github.com/henry-zwart/msc_thesis/issues/72))_
  Created presentations for Thursday ECHO talk:
    - Teaching practice (collider bias)
    - Project update (validation; initial EDA)
- Started looking at variables outside those considered in Lee et al. (2025)
- Discussed project with colleagues at Dragonfly
- _(EDA; [#76](https://github.com/henry-zwart/msc_thesis/issues/76))_ Implemented 
  partial correlation calculation for Polars DataFrames.

##### This week:
- _(Meetings)_ ENLENS on Thursday afternoon.
- _(Meetings)_ Perhaps catch up with Kyuri (Tuesday?) to discuss preparations 
  for Thursday meeting.
- _(Literature; [#77](https://github.com/henry-zwart/msc_thesis/issues/77))_
  Read up on partial correlation.
- _(EDA, literature [#78](https://github.com/henry-zwart/msc_thesis/issues/78))_ 
  Look at ways to reduce data dimensionality, both in the number of questions and 
  number of response options.

##### Other tasks:
- _(EDA; [#79](https://github.com/henry-zwart/msc_thesis/issues/79))_ Fit diffusion 
  models to individual question response Markov processes. 
- _(Analysis; [#80](https://github.com/henry-zwart/msc_thesis/issues/80))_ Check 
  whether the matrix inversion method for computing partial correlations is generally
  appropriate for our data.
- _(Analysis; [#81](https://github.com/henry-zwart/msc_thesis/issues/81) 
  [#82](https://github.com/henry-zwart/msc_thesis/issues/82))_ Redo Vítor's 
  'willingness-to-pay' analysis to extract between-person comparable factors  
  from `ccSolve`, `ccComp` variables. Consider whether a similar approach 
  could be applied to other variable-treatment questions.
- _(Analysis; [#83](https://github.com/henry-zwart/msc_thesis/issues/83))_ Estimate
  distance-from-equilibrium for survey questions as Markov processes.
- _(Research direction; [#84](https://github.com/henry-zwart/msc_thesis/issues/84))_
  Identify a couple of specific contexts for my research questions.

## Feb 9 - Feb 15 2026

### Summary
This week was a bit slow, as I was still recovering from my cold. I met with Vítor
twice (on Monday and Thursday), and presented at the ECHO meeting on Thursday. 
Much of the week was dedicated to preparing my presentations. I also began 
some EDA.

Key items are as follows:

- I emailed Sara regarding the dataset validation issues I have identified.
- We decided to extend our field-of-view beyond Lee et al (2025). Only four of their 
  cognitive items are well-assessed by the climate attitudes dataset; conversely, we 
  have variables of interest which Lee et al did not consider, such as priced policies
  and recorded experience. Rather, we can treat this paper as a moral basis for our 
  question selection, particularly in their categorisation of cognitive items into 
  different types.
- EDA: 
    - Pairwise correlation (for Lee et al variables, and extended set).
    - Implemented partial correlation as well. 
    - Visualising changes in individuals' responses to particular questions as a 
      Markov process, on a directed transition network.
- Created slides for Thursday ECHO talk:
    - Teaching practice (collider bias).
    - Project status.


### Friday

- Implementing partial correlations
- Brief catchup with Vítor

#### Partial correlations
I implemented these using [matrix inversion](https://en.wikipedia.org/wiki/Partial_correlation#Using_matrix_inversion).
We calculate the inverse pairwise covariance matrix for the dataset, and normalise the 
elements by the root product of the corresponding row/column diagonals.

This approach requires that the covariance matrix be positive definite. While the 
method does not fail for any of the examined columns, I need to check why this is 
apparently satisfied for our data. Perhaps due to the heavy diagonal.

#### Catchup with Vítor
I caught up with Vítor for 5min or so to discuss my plans for the following week.
Key takeaways are:

- Read up on partial correlations: use in related literature, interpretation, 
  limitations, connections to the Ising model.
- Don't focus too much on interpreting results for the time being (e.g., from 
  the partial correlations). Two reasons: (i) we have not yet settled on a 
  context, and (ii) we should resolve the data issues first.
- Think (generally) about how to reduce the data dimensionality, both in terms 
  of the number of questions and number of response options, based on the 
  partial correlations (and/or other metrics). e.g., Clustering, binarisation.

### Thursday

- Weekly catchup with Vítor
- ECHO presentation

#### Weekly catch-up
We talked about the initial EDA I have started since Monday: (i) plotting pairwise
correlations for Lee representative survey questions, and (ii) visualising changes in 
individuals' responses to particular questions as a Markov process, plotting the 
transition probabilities on a directed network.

Vítor also showed me an analysis he had done on the costed policies questions. By 
modelling responses as a function of policy cost as well as individual factors 
(e.g., financial capacity, age, etc.), and solving the resulting equation for the 
price at which individuals are neutral, he derived a "willingness-to-pay" factor 
for each participant. This illustrates one way that we can extract variable-treatment
responses into variables which are comparable across individuals from different 
treatment groups. I should consider redoing this analysis, perhaps also for other 
treatment questions.

**Pairwise correlations:** These don't show much at the moment. Most variables are 
positively correlated, since they are all generally associated with pro/anti-climate
stances. Vítor suggested also plotting the partial correlations, which assess the 
correlation between a pair of variables while controlling for all others. 

**Response changes as Markov process:** All of the survey questions I have examined 
are ordinal, and most of these display stronger connections between consecutive 
response options. This is indicative of a continuous underlying internal state. We 
can also look at the responses as measurements of a diffusion process, allowing us 
to see how the 'velocity' varies along the scale. While this visualisation is limited
to individual survey questions, directed belief systems can be considered a 
generalisation of this to higher dimensions (more questions). This analysis may also 
justify binarising some questions, for instance, when changing response from one value 
to another almost always requires passing through an intermediary ordinal state.

On the same plot, I have coloured the nodes (response values) according to the 
stationary distribution of the Markov process. Vítor has suggested also investigating
the difference between this stationary distribution and the actual distribution as 
observed in the data. This gives an indication of how far the system is from 
equilibrium (at a global population level) for each survey question.

**Question selection:** Finally, we discussed selecting/narrowing down the set of 
survey questions we are considering. The narrowing-down is best done with respect 
to a particular context frame (e.g., select a behaviour of interest, then select 
the beliefs/attitudes/experiences/positions which are relevant to that behaviour).
If we do this carefully, we may be able to identify a couple of contexts, spanning 
multiple waves, with relatively few and non-overlapping relevant items.  


### Wednesday

- Creating slides for Thursday ECHO presentation.
    - Teaching practice: Collider bias.
    - Project status: data validation, initial EDA.

### Monday

- Weekly catch-up with Vítor, as rescheduled from last Thursday.
- Sent email to Sara, describing dataset issues.
- Visualisation of Lee 2025 representative variables: Plotting transition diagrams for 
  responses across waves 1 & 2, treating as a MC.

#### Weekly catch-up
We discussed the general state of the survey questions I have selected as representative of the 
dimensions examined in Lee et al (2025), as well as a number of problems with this selection. 
From the initial question tagging, I have selected for each dimension the questions which are likely 
the most directly indicative internal state, such that both positive and negative responses are 
meaningful. This yields approximately 1--2 questions per dimension, once we have filtered to those 
questions which appear in both waves 1 and 2, and are asked of the same participants.

Some of the dimensions (support for fossil fuel reduction/renewable energy increases, expectations 
of personal harm from climate change) are represented only by `cc13` (or `cc13_apr`), which asks 
about specific actions taken due to climate change. Responses to this question can be extracted to 
specialised measures regarding fossil fuel reduction, risk perceptions, etc. However, this measure 
has limited usefulness for our purposes, since (i) perceived attribution of past actions may be subject
to error, and (ii) historical actions do not necessarily represent current states of affairs.

Vítor agreed with my concern that retrofitting the climate attitudes survey data to the purpose of
this study may be a bold ask. 

We instead considered that the questions posed by Lee et al could form the (moral) basis of our study.
In their paper, they categorise the presented survey questions into three categories: Belief, Risk 
perception, and Policy support. We could instead operate from this more abstract base to identify 
a line of inquiry that is more readily supported by the available data. This also allows us to make 
use of richer aspects of the climate attitudes dataset which are not considered by Lee et al, such 
as policy support with varying costs.

Finally, we briefly discussed the necessity of having all questions be contiguous across waves. 
Waves 5 and 6 of the survey contain several behavioural questions which are not present in earlier 
waves, yet exclude many of the policy support/climate belief questions. I suggested that this may
provide a natural and possible divide; we may use earlier waves to fit a model of internal states,
yielding a theory of belief change which allows us to extrapolate to those later waves, where 
the internal states are considered inputs to a behavioural model for these other questions. 

**Tasks:**

- Prepare an email for Sara, describing the issues identified with the climate attitudes dataset.
- Continue with EDA for the unproblematic subset of representative questions.
- Prepare a presentation for Thursday. 

#### Question categorisation
Lee et al group their survey questions into three categories: beliefs, risk perception, and policy 
support. This offers an alternative method for us to compare with their work, namely by taking their
abstract categories as the base for our own variable selection.

I propose the following set of categories:

- Belief: Assesses participant's epistemic position on some issue. 
- Attitude: Assesses attitudinal positions (i.e., not necessarily true or false, but rather 
  character alignments or feelings).
- Policy support
- Experience: Past events which participants have experienced.
- Demographic: Individual-level information about participants.




## Feb 2 - Feb 8 2026
This week was a write-off due to a bad cold. I've mostly recovered now, so will continue next 
week with the tasks planned for this week.


## Jan 26 - Feb 1  2026

### Tuesday
- Finished implementing validation code for response data (waves 1 --- 5).
- Identified columns, from the subset related to Lee et al. 2025 variables, which have schema problems. 
- Sent list of Lee et al. 2025 variables and related survey items to Kyuri.

#### Schema problems
A number of columns have unexpected null/non-null values. Likely most of these are due to errors in the 
codebook, which should be straightforward to resolve. It is possible that some are related to the null-PID
individuals, as we observe a small number of cases where questions intended only for repeat participants 
are answered by seemingly new participants. 


## Jan 19 - Jan 25 2026

### Thursday
#### Meeting with Vítor
Tasks:

- Classify survey questions according to category (e.g., experience, belief, attitude, behaviour)
    - Look for an existing classification framework, ideally with established causal relation directions
- Lee et al. use P-CRNs which are frequency-dependent(?). 

Could look again at a model of the question responses in terms of latent beliefs:

- Belief that CC happening depends on belief that it is a scam (or maybe on trust in science, belief that climate change 
  could cause worse extreme weather, and exposure to extreme weather; belief that it is a scam could be an alternative 
  belief which is inconsistent with the belief that CC happening) and belief that human actions can cause climate change.
- Beliefs may be clustered by individual (across waves), as well as age, gender, ...
- Question is how to justify directed relations between beliefs, since this is something we wish to infer. 


### Monday
#### Categorising CA items
I have been categorising the CA survey items to reflect their similarity/comparability
with the beliefs assessed in Lee et al (2025)[@leeVariationsClimateChange2025].

- Many items reflect more than one cognitive item assessed by Lee et al. To handle this I 
  have included a boolean indicator for each cognitive item, per row in the item table, 
  specifying relation.
- Some of the concepts assessed by Lee et al could reasonably be considered consequents of others. 
  For instance, the degree to which an individual thinks government should prioritise climate change 
  depends on their beliefs regarding the existence of climate change, its causes, and their perceived 
  risk. If an individual believes in climate change, but also believes individuals can avoid its affects
  through their own actions, they may not support government policy prioritising climate change. This 
  affects my labelling somewhat, as some beliefs marked as "true" for a survey item are considered causes
  of the participant's response, while others may be considered consequents. 


#### Weekly standup
##### Last week: 
- _(Meetings)_ Caught up with Kyuri on Wednesday to discuss reading 
  ([#26](https://github.com/henry-zwart/msc_thesis/issues/26)) and priorities for 
  EDA prior to meeting on Thursday (this week).
- _(Lit review; [#26](https://github.com/henry-zwart/msc_thesis/issues/26), 
  [#33](https://github.com/henry-zwart/msc_thesis/issues/33))_ Finished reading papers
  from Sara, summarised in [report](https://github.com/henry-zwart/msc_thesis/blob/main/outputs/reports/reading_summary.pdf).
- _(Lit review; [#32](https://github.com/henry-zwart/msc_thesis/issues/32))_ Assessed (above) 
  papers for factors similar to those assessed in the climate attitudes survey. Only 
  one study is directly comparable. Others examine different context (but may be useful 
  for comparison at abstract level), or ask different kinds of questions (e.g., conceptual similarity
  ratings).
- _(EDA; [#50](https://github.com/henry-zwart/msc_thesis/issues/50))_ Loaded climate attitudes dataset
  into a database; started on some enrichment, categorising survey items according to topic (e.g., climate change, 
  demographics), mode (e.g., beliefs, experiences, risk perception), or similarity with papers from 
  [#26](https://github.com/henry-zwart/msc_thesis/issues/26).
- _(EDA; [#27](https://github.com/henry-zwart/msc_thesis/issues/27))_ Started high-level EDA, looking at
  participation patterns across survey waves, response distributions, etc.

##### This week:
- _(Data enrichment; [#52](https://github.com/henry-zwart/msc_thesis/issues/52))_ Categorise survey 
  items' relevance to Lee et al. (2025)[@leeVariationsClimateChange2025] belief topics.
- _(EDA; [#54](https://github.com/henry-zwart/msc_thesis/issues/54))_ Investigate responses to items from [#52](https://github.com/henry-zwart/msc_thesis/issues/52).
    - Compare within-person variability and between-person variability.
    - Consistency in responses to related questions.
    - ...
- _(Lit review; [#53](https://github.com/henry-zwart/msc_thesis/issues/53))_ Methods for estimating within-person belief relations.
    - Population-aggregate data can indicate pairwise belief correlations which don't exist/are different
      at individual level. This would be a problem for reasoning about intervention.
    - Brandt et al (2022) propose using conceptual similarity ratings to estimate individuals' belief 
      structures, as an alternative to longitudinal studies. However, I haven't read any studies using 
      longitudinal studies for this purpose.
- _(Lit review; [#31](https://github.com/henry-zwart/msc_thesis/issues/31))_ Reviewing model families used to model belief systems (Ising model, regularised 
  partial correlation networks (is this the same/related?), Bayesian networks, ...?)
- _(Meetings)_ Meeting with Vítor and Sara on Thursday (17:00--18:00).


## Jan 12 - Jan 18 2026
### Summary
- ([#26](https://github.com/henry-zwart/msc_thesis/issues/26)) Finished reading papers 
  (suggested by Sara) on data-driven models of belief. 
- ([#33](https://github.com/henry-zwart/msc_thesis/issues/33)) Outlined relevant 
  takeaways from [#26](https://github.com/henry-zwart/msc_thesis/issues/26) in 
  'reading summaries' report.
- ([#32](https://github.com/henry-zwart/msc_thesis/issues/32)) Assessed papers from 
  [#26](https://github.com/henry-zwart/msc_thesis/issues/26) for variables similar to 
  those in climate attitudes dataset.
      - Lee et al (2025) is sufficiently similar.
      - The rest are either different in context (political beliefs; vaccination),
        or in survey question type (e.g., conceptual similarity ratings). 
      - Studies with different context may still be useful at an abstract level.
- ([#50](https://github.com/henry-zwart/msc_thesis/issues/50)) Loaded climate attitudes 
  dataset into a database to simplify querying data by participation, examining changes
  in question text across waves, subsetting items by category, etc.
- ([#27](https://github.com/henry-zwart/msc_thesis/issues/27)) Started basic high-level 
  EDA. Looking at participation patterns across waves, response distributions, etc.

### Friday
- ([#32](https://github.com/henry-zwart/msc_thesis/issues/32)) Assessing papers for similar variables to those in climate attitudes dataset
    - Only Lee et al (2025) is sufficiently similar. Rest are either non-CC-related, or ask different/specialised 
      questions (e.g., conceptual similarity ratings).
- ([#27](https://github.com/henry-zwart/msc_thesis/issues/27)) Started EDA on climate attitudes dataset. So far just looking at overview, e.g., participance across waves.

### Thursday
- ([#50](https://github.com/henry-zwart/msc_thesis/issues/50)) Loaded climate attitudes dataset into a database with tables for: 
    - Waves, 
    - Survey items: concepts assessed by the survey, 
    - Survey questions: questions for a single 'item' may vary between waves or with experimental conditions; 
      this table holds the question text and response format, and describes the conditions/waves for which it 
      is shown,
    - Participants: describes which waves they respond to, and when they joined the survey
    - Responses: for each participant, groups their answers to a single wave of the survey
    - Question-responses: Participants' answers to individual survey questions.
- The database is available as both a sqlite database and a collection of parquets. 


### Wednesday
- ([#33](https://github.com/henry-zwart/msc_thesis/issues/33)) Finished general overview of papers from 
  Sara, sent to Vítor. Still need to write about survey questions in light of climate attitudes dataset.
- Catch-up with Kyuri.

### Tuesday
- ([#33](https://github.com/henry-zwart/msc_thesis/issues/33)) Overview writeup of the papers from Sara, 
  including the possible methodological issue in Brandt (2022)[@brandtMeasuringBeliefSystem2022].

### Monday
- Finished reading papers from Sara ([#26](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=145733292&issue=henry-zwart%7Cmsc_thesis%7C26)).
- Assessing for similar variables in climate attitudes dataset ([#32](https://github.com/henry-zwart/msc_thesis/issues/32)).

#### Weekly standup
Completed last week:

- Reading papers from Sara; ongoing, completed $4.5/5$ ([#26](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=145733292&issue=henry-zwart%7Cmsc_thesis%7C26))
- Started 'reading summaries' document for critical reflection and notes on papers

This week:

- Finish reading papers from Sara ([#26](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=145733292&issue=henry-zwart%7Cmsc_thesis%7C26))
- Assess climate attitudes data for similar vars/beliefs as in above papers ([#27](https://github.com/henry-zwart/msc_thesis/issues/27))
- Review, summarise model families for belief modelling ([#31](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=148672585&issue=henry-zwart%7Cmsc_thesis%7C31))
- Continue broader literature review reading ([#28](https://github.com/henry-zwart/msc_thesis/issues/28))

## Jan 5 - Jan 11 2026
### Summary
#### Week overview
- A somewhat slow week, on account of a snowy Amsterdam, and easing back into study.
- Mostly working through the papers Sara shared prior to the holiday ([#26](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=145733292&issue=henry-zwart%7Cmsc_thesis%7C26)):
    - Progress: $3.5/5$ read, with plan to finish the remaining ones before Monday.
    - I noticed some potential methodological issues in Brandt 
      2022[@brandtMeasuringBeliefSystem2022]. To discuss with Vítor?
- Some minor workflow updates:
    - Started writing short summaries for each paper, including some critical reflection, with 
      the intention that these feed into my writing later down the track (to view: 
      `make outputs/reports/reading_summary.pdf`).
    - Switched to using the ['mkdocs-bibtex'](https://github.com/shyamd/mkdocs-bibtex) plugin to 
      handle references in the project site (e.g., in the 
      [glossary](https://henry-zwart.github.io/msc_thesis/glossary/)), where I had previously been 
      using footnotes. This has a caveat that the plugin is no longer maintained. Given that there 
      exist no other plugins for this purpose, if I run into issues I may consider writing my own plugin,
      or potentially taking over maintenance of this one.

#### Next week
- Reviewing the nature of the beliefs/attitudes studied in the papers Sara has shared, and assessing
  the climate attitudes dataset for similar variables.
- Review model families used for modelling belief systems (e.g., Ising model, Bayesian network, partial 
  correlation network). Describe each and compare/contrast. Write up a short summary. 

### Sunday
- Finished van Noord et al. (2025)
- Wrote standup paragraph for upcoming week

### Friday
- Caught up with Shania over coffee
- Finished reading Powell et al. (2023), made summary
- Started reading van Noord et al. (2025)
- Read through document from Vítor regarding thesis introduction
- Thinking about writing plan going forward

#### Thoughts on writing plan
My project proposal had a tentative due date for my literature review of Feb 2. However, since both
the literature review and introduction should be targeted and overwhelmingly relevant to my thesis 
research, it doesn't make much sense to start properly drafting these until I have made progress on
my own work. 

Instead I should focus on the reading summaries I have started on this week, with the intention that
these should eventually feed into my writing. It is also safe to begin writing contained descriptions
of relevant background models (e.g., the Ising model, Bayesian networks, etc.) with the same intent.

To help ensure my summaries will be sufficient to inform my later writing it may also be worth reviewing
some texts on literature reviews and thesis writing.

### Thursday
- Reading Powell et al. (2023)
- Tried (unsuccessfully) to fix Typst autoformatting in neovim

### Wednesday
- Started on EDA/extraction of climate attitudes dataset
- Finished reading Brandt 2022
    - Found some possible issues in their statistical analysis due to choice of controls. Will
      detail in reading summaries report.

### Tuesday
- Mostly reading, summarising notes on Brandt et al. 2019
- Started on Brandt 2022
- Set up a new report for literature review reading summaries (`make outputs/reading_summary.pdf`)

### Monday
- Slow start, as I took the morning off to explore snowy Amsterdam.
- Started working through the papers Sara shared before the break. Today I've read Brandt et al. (2019).
- Katinka sent me Gabriela's thesis, and I've added this to my reading list in Zotero.

#### Weekly standup
Completed over holiday:

- R&R!
- Started planning literature review scope.

This week:

- Follow-up work from meeting with Sara:
    - Reading papers shared during meeting [#26](https://github.com/henry-zwart/msc_thesis/issues/26).
    - EDA on climate attitudes dataset (load data, understand content; assess for similar variables as used in papers 
      mentioned above) [#27](https://github.com/henry-zwart/msc_thesis/issues/27).
- Continue broader literature review reading [#28](https://github.com/henry-zwart/msc_thesis/issues/28).
- Add Gabriela Torres' thesis to reading list [#29](https://github.com/henry-zwart/msc_thesis/issues/29).


## Dec 15 - Dec 21 2025
### Wednesday
- Information theory exam - now finished with courses!
- Meeting with Vítor, Katinka, Kyuri, and Sara.

Meeting:

- Discussing this project and broader context of work for internal belief models/interventions.
- Fortnightly meetings planned with Vítor, Sara. Thursdays, 5-6pm, starting 22 January.

To-do:

- Identifying relevant variables in climate attitudes dataset, for comparison with existing belief state 
  models [#26](https://github.com/henry-zwart/msc_thesis/issues/26).
    - Read papers Sara sent regarding internal belief models of climate policy; identify other relevant literature.
    - Assess whether the climate attitudes dataset contains similar variables/factors to those used in this work. 
- EDA on climate attitudes dataset [#27](https://github.com/henry-zwart/msc_thesis/issues/27).
- Given variables identified above, which (causal/directed) structures make sense theoretically (e.g., star graphs as 
  'attractor' vs 'repeller').

Other notes:

- One of Vítor's previous students (Gabriela Torres) looked at causal relations in the climate 
  attitudes dataset, relating beliefs regarding (i) COVID-19 and (ii) climate policy, with trust in
  institutions(?) as a shared influence. Will be good to read her thesis.


## Dec 8 - Dec 14 2025
### Summary
#### Week overview:
- Prepared and presented a (not-so-)short presentation on project plan
- Reading up on cog. psychological and philosophical theories of belief
- Set up a few additional workflows in repo (glossary, presentations)
- Thinking about representing causal implications in Ising model 

#### Next week:
- Mostly exam prep Monday + Tuesday, then done with courses from Wednesday!
- After that, continue reading for literature review 
- Ask about example literature reviews, e.g., from past students, or in general.

### Sunday
#### Representing causal implication in an Ising model
To model causal relations in an Ising model it is not sufficient to allow directional interaction terms
to vary independently. Suppose for beliefs $p$ and $q$ that we wish for the model to capture the relation

$$p \implies q$$

The interaction energy with weight $\omega_{p \to q}$ is typically modelled as

$$h_{p\to q} = \omega_{p\to q} \cdot p\cdot q$$

We also consider the following alternative formulation, derived according to de Morgan's law to explicitly 
preserve the relationship $(p \implies q) \Leftrightarrow (\neg p \vee q)$:

$$h_{p\to q}' = \omega_{p\to q} \cdot [1 - p(1-q)]$$

Suppose that belief states are $1$ (believes) and $0$ (doesn't believe), then these relations are defined by 
the following truth table

<div class="center-table" markdown>

| $p$   | $q$   | $p \implies q$   | $h_{p\to q}$ | $h_{p\to q}'$ |
| :---: | :---: | :--------------: | :---:        | :---:         |
| $1$   | $1$   | $1$              | $1$          | $1$           |
| $1$   | $0$   | $0$              | $0$          | $0$           |
| $0$   | $1$   | $1$              | $0$          | $1$           |
| $0$   | $0$   | $1$              | $0$          | $1$           |

</div>

Thus $h_{p\to q}$ fails to capture the semantics of implication, while $h_{p\to q}'$ does capture these 
for belief states of $\{0, 1\}$. 

#### Distinction between not-believing and no-belief
While the meaning of "$X$ believes in $p$" is unambiguous, its converse is not. Suppose $p$ is the belief:

  _"Cats are the ideal pet."_

To say that $X$ does not believe in $p$ could either mean that they believe in $\neg p$:

  _"Cats are terrible pets."_

or that they have no strong beliefs, either way, concerning cats as pets.

This raises the question of whether we can simply collapse these two interpretations for modelling purposes. However, this seems 
unlikely. For instance, an individual can "hold a belief without subscribing to all of its consequents" (need to find where this 
quote was from --- Alan Musgrave?). In other words, we can adopt a belief in $p$ before accepting the beliefs that $p$ implies. 

On the other hand, it is intuitively different to adopt a belief which implies a consequent $q$, when one a priori believes $\neg q$.
In the first case, $p$ can be adopted or not adopted with no resulting change in the belief system energy. In the second, adopting $p$
causes a decrease (increase) in the system energy. 

This suggests that what we instead want is a way to represent ambivalent beliefs such that their interaction energy with positive 
and negative antecedents is identical, and equal to the interaction energy of a consistent belief relation. 


### Friday
- Finished presentation
- Presented project plan
- Reading: cognitive science + philosophical theories of belief

### Tuesday
- Began working on a short presentation for Friday.

### Monday
- Looking at cognitive theories of belief and belief change
    - Appears to be support for the notion that in order to change a belief, it 
      is not always necessary to intervene directly on that belief (i.e., causal 
      relations are important). Furthermore that intervening on a belief directly 
      can cause a blow-back effect, since this 'reactivates' the prior belief.
- Have started a [glossary](glossary.md) to keep track of relevant terminology.

## Dec 1 - Dec 7 2025 
### Summary
#### Week overview:
- Confirmed that I have access to the climate attitudes data already.
- Set up research log to track progress and issues, and static site to collate information 
  on the project.
- Started thinking about literature review; read paper[^1] on the topic. 

#### Next week:
- Identify areas to explore in literature review; questions to answer.
- Continue reading.

### Sunday
- Read paper on how to write literature reviews[^1].

[^1]: J. W. Knopf, “Doing a Literature Review,” APSC, vol. 39, no. 1, pp. 127–132, Jan. 2006, doi: 10.1017/S1049096506060264 

### Tuesday
- Confirmed that I already have access to the climate attitudes data (on OneDrive).
- Created project log to track progress, identify issues.
- Created (this) static site to collate information & reports related to 
  the project.

## Nov 24 - Nov 30 2025
### Summary
#### Week overview:
- Submitted thesis proposal, and had it accepted
- Confirmed examiner (Johan Bollen) and assessor (Sara Constantino)

#### Next week:
- Access plan for climate attitudes data, incl. privacy/governance/usage conditions.
- Literature review planning

#### Notes for Monday stand-up:
- Joined remotely due to appointment
- Working part-time on project while I finish my final course. I expect to 
    be full-time on research from January.

### Sunday
- Submitted project proposal
- Project proposal accepted

### Saturday
- Confirm examiner (Johan Bollen) and assessor (Sara Constantino)
- Final draft of project proposal

# References

\bibliography


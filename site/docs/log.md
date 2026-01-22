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
- Many of the items reflect more than one belief. For instance, when we ask whether a 
  participant takes action "X" in order to help address climate change, how they respond 
  reflects both whether they believe climate change is happening, and whether it is human-caused.
  At the moment I am labelling items with the belief(s) they are most directly associated with,
  but may need to go back through and create boolean columns for each belief, to ensure comprehensivity.
    - _Scratch that:_ I've switched to the boolean method
- Some of the concepts assessed by Lee et al could reasonably be considered consequents of others. 
  For instance, the degree to which an individual thinks government should prioritise climate change 
  depends on their beliefs regarding the existence of climate change, its causes, and their perceived 
  risk. If an individual believes in climate change, but also believes individuals can avoid its affects
  through their own actions, they may not support government policy prioritising climate change. This 
  affects my labelling somewhat, as some beliefs marked as "true" for a survey item are considered causes
  of the participant's response, while others may be considered consequents. 
- In my labelling, I write "T" to indicate a measurable relation, "T!" to indicate a relation whose 
  direction can't be accurately determined (e.g., "have impacts of climate change influenced you to 
  change your vote", doesn't say _how_ they changed their vote).


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
- _(EDA; [#27](https://github.com/henry-zwart/msc_thesis/issues/27)) Started high-level EDA, looking at
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


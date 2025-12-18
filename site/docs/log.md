## Dec 15 - Dec 21 2025
### Wednesday
- Information theory exam - now finished with courses!
- Meeting with Vitor, Katinka, Kyuri, and Sara.

Meeting:

- Discussing this project and broader context of work for internal belief models/interventions.
- Fortnightly meetings planned with Vitor, Sara. Thursdays, 5-6pm, starting 22 January.

To-do:

- Identifying relevant variables in climate attitudes dataset, for comparison with existing belief state 
  models [#26](https://github.com/henry-zwart/msc_thesis/issues/26).
    - Read papers Sara sent regarding internal belief models of climate policy; identify other relevant literature.
    - Assess whether the climate attitudes dataset contains similar variables/factors to those used in this work. 
- EDA on climate attitudes dataset [#27](https://github.com/henry-zwart/msc_thesis/issues/27).
- Given variables identified above, which (causal/directed) structures make sense theoretically (e.g., star graphs as 
  'attractor' vs 'repeller').

Other notes:

- One of Vitor's previous students (Gabriela Torres) looked at causal relations in the climate 
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

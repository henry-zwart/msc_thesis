#import "@local/drifting-cls-thesis:0.1.0": caption
#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion


#let full-dataset-name = [*placeholder dataset*]
#let dataset-name = [climate beliefs dataset]

*TODO:*
- Create table describing climate beliefs dataset variables
- Discuss how we create the index variables

// == Plan
//
// + Introduce and motivate:
//   - Longitudinal dataset which captures various climate-related beliefs, attitudes,
//     behaviours in the US over recent years.
//   - Significance of longitudinal aspect --- captures how _individuals'_ cognitive states
//     change over time
//   - Yet several complexities:
//     - Variable survey participation
//     - Inconsistent survey items --- some only present in certain waves, or only for
//       new/repeating participants (so don't have repeated responses); some cases where
//       survey question text or response schema changes between waves
//     - Survey errors
//     - Heterogeneous response schemas; generally not binary
//     - Variable inter-response times, i.e., interval between consecutive responses for
//       a given individual
//     - Current events may confound the dynamics for any given interval
//   - Meta-level figures, summary statistics
//
// + $checkmark$ Validation and cleaning
//
// + $checkmark$ Dataset construction:
//   - Identify a small collection of climate-related beliefs and attitudes which
//     - Are theoretically expected to be related,
//     - Include certain key items which are often recognised as drivers of belief/attitude
//       change (cc6?),
//     - Span at least two waves,
//     - Maximise number of observations (requiring no null observations).
//   - Describe the complete set of identified variables, prior to EDA.
//   - Outline EDA process:
//     - Given the full set of variables, how can we reduce this to a core set. Using
//       index variables to reduce redundancy.
//     - Pairwise correlation, partial correlation:
//       - Which variables are irrelevant, i.e., consistently low correlation with others
//       - Which pairs of variables exhibit similar correlation patterns? i.e.,
//         redundant/alternatives
//     - Likewise for VAR --- measures for temporal relationships.
//     - Hierarchical clustering: which groups of variables tend to exhibit similar
//       behaviour?
//     - PCA/EFA: Identify groups of variables which are well-explained by a shared latent
//       factor.
//     - Variable selection and index variable construction
//   - Figures for final dataset:
//     - Marginal distributions
//     - Partial correlations (maybe also as network)
//
// + $checkmark$ Binarisation (may go in methods)
//
// #line(length: 100%)

#let dataset_metadata = json("../results/data/dataset_metadata.json")

#let parse-date(datestr) = {
  let date_parts = datestr.split("-").map(int)
  let year = date_parts.at(0)
  let month = date_parts.at(1)
  let day = date_parts.at(2)
  datetime(year: year, month: month, day: day)
}
#let survey_start_date = parse-date(dataset_metadata.first_response_date)
#let survey_end_date = parse-date(dataset_metadata.last_response_date)

In this chapter we outline the context and construction of the dataset used for
model calibration in @sec:methods. We will
first describe the broader context and complexities of the dataset underlying this study,
before outlining our data validation and cleaning methods in @sec:dataset-preprocessing.
Finally, in @subsec:dataset-dataset-construction we detail the construction of the
targeted dataset used for model calibration (@sec:methods).

While many empirical studies on belief systems rely on cross-sectional data
@leeVariationsClimateChange2025 @vannoordNatureStructureEuropean2025
@powellModelingLeveragingIntuitive2023, longitudinal data is necessary to capture
changes in individuals' internal cognitive states over time. In fact, repeated
per-individual observations are essential to our adopted method for model calibration.
We are fortunate, in this study, to have had access to a longitudinal dataset on
climate beliefs and attitudes in USA as our primary data resource.

The longitudinal study (*CITE*) comprises six waves of responses from individuals
residing in the United States, collected between
#survey_start_date.display("[month repr:long] [year]") and
#survey_end_date.display("[month repr:long] [year]"). The assessed dimensions include
general demographic information (e.g., age, gender, education, and financial status),
beliefs, attitudes, and experiences relating to concurrently-salient topics such as
COVID-19, climate change, or the 2020 US presidential election, and support for
hypothetical policies. In addition to a wide-form table of survey response data, the
dataset includes a codebook which specifies, for each survey item, the question text,
occurrence in survey waves, and conditional display logic where applicable. At present,
the codebook is limited to Waves 1---5, i.e., excluding the sixth (final) wave.

However, the dataset is not without complexities. Survey participation varies, with
each participant responding to a (possibly non-contiguous) subset of waves.
@fig:dataset-survey-participation shows the number of participants who have responded
to each combination of survey waves, with a minimum count of 1500. While each individual
wave has a relatively high response rate (roughly 4000--5000), this rapidly drops off
when other waves are considered. For instance, only \~2500 individuals responded to
Waves 1 and 2, and only \~1900 of these individuals also responded to Wave 3.

#figure(
  image("../results/figures/dataset/participation.pdf"),
  caption: caption(
    short: [Survey participation counts],
    long: [
      Number of repeat participants for different wave combinations. Combinations with
      total responses below 1500 have been removed.
    ],
  ),
) <fig:dataset-survey-participation>

Survey content also varies between waves and participants, both with regards to
_which_ questions are included, and _how_ they are presented. Certain questions are
displayed only in particular waves, or only to either repeating or new participants.
Some questions are shown conditionally based on an individual's responses to prior
questions (within the same wave). Others vary according to survey treatment conditions,
such that individuals in different treatment groups are presented different variants of
a question. This survey logic is not always executed correctly; in some cases
participants are shown survey questions incorrectly (e.g., 'new' participants shown
questions intended only for 'repeating' participants). We discuss this issue further
in @sec:dataset-validation.

Question format, text, and response schemas also occasionally change between survey
waves. Changes in response schema are less common, however, and typically affect items
with categorical responses. With a view to constructing the calibration dataset for our
experiments, we note that most response schemas are not binary and therefore require
binarisation (see @subsec:dataset-binarisation).

Casting our attention to the survey timing, we examine the survey response dates for
each wave (@fig:dataset-longitudinal-response-eventplot) and the distribution of
interval durations between consecutive-wave responses across individuals
(@fig:dataset-longitudinal-interresponse-times), i.e., the 'inter-response time'.

In @fig:dataset-longitudinal-response-eventplot we observe that the survey waves occur
with irregular spacing and duration. Some consecutive pairs of waves are much
closer than others. For instance, notice that:

#{
  set enum(numbering: "(i)")
  [
    + The duration from the start of Wave 1 until the end of Wave 3 is shorter than the
      duration _between_ Waves 5 and 6, and

    + The duration spanned by Wave 4 alone exceeds that of the interval spanned by both Waves
      1 and 2.
  ]
}
This poses a potential problem for model calibration, since the non-equilibrium
belief model (defined in @sec:asymmetric-belief-systems) operates on the assumption that
samples are equispaced.

#figure(
  image("../results/figures/dataset/response_eventplot.pdf"),
  caption: caption(
    short: [Longitudinal survey response dates per-wave],
    long: [*TODO*],
  ),
) <fig:dataset-longitudinal-response-eventplot>

We see the irregular spacing reflected also in the inter-response time distributions.
For each pair of consecutive waves, we observe substantial variation in the time between
responses for different participants.

#figure(
  image("../results/figures/dataset/interresponse_times.pdf"),
  caption: [Between-response time distribution],
) <fig:dataset-longitudinal-interresponse-times>


Finally, we note that the time interval spanned by the longitudinal dataset includes
several notable events which could reasonably be expected to influence --- and
confound --- the dynamics of beliefs and attitudes in myriad contexts. These
include the COVID-19 pandemic, which arrived in the US only three months prior to the
first survey wave @holshueFirstCase20192020, the 2020 US Presidential Election which
occurred during Wave 3, the January 6 United States Capitol Attack, which occurred
between Waves 3 and 4, ...

== Data Validation <sec:dataset-validation>

The complexity of the climate attitudes survey, as outlined above, necessitates a
rigorous approach to data validation, both to identify errors in the expected schema
and to ensure that the data matches our expectations.

We have implemented a general validation pipeline comprising three stages:

+ *Type-level validation:* The set of columns is exactly as expected, and all columns
  have the correct data type.

+ *Response-value validation:* All _non-null_ responses are valid according to the
  schema specified in the codebook.

+ *Null-value validation:* Responses are null if, and only if, we expect them to be
  null.


=== Type-level validation <subsec:dataset-validation-type-level>
Type-level validation ensures that the _observed_ data schema
matches the _prescribed_ schema. Since response data types vary between questions
(see @tab:dataset-types), the type-checking must be
flexible and capable of handling complex data types.

For instance, categorical multiple-choice responses are represented using a
```python list[Enum]```, where ```python Enum``` is a question-specific enum-type
#footnote[An enum is a type defined by a finite set of allowable values. In our case
  the values are human-readable strings. For instance, the `dem_urban` survey question,
  which asks 'What kind of area do you live in?' has responses with data type described
  by the enum ${"Urban", "Suburban", "Rural"}$.
]. Type validation for a multiple-choice question thus requires checking: (i) that the
response column comprises ```python list```'s, and (ii) that all list elements belong to
the set of values defined by the ```python Enum```.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (center, center, center),
    [Response schema], [Raw type], [Coerced type],
    [Text], [```python str```], [```python str```],
    [Single response (ordinal)], [```python int```], [```python int```],
    [Single response (categorical)], [```python int```], [```python Enum```],
    [Multiple response], [```python str```], [```python list[Enum]```],
    [Numeric], [```python float```], [```python float | int```],
  ),
  placement: auto,
  caption: caption(
    short: [Dataset type coercion mapping],
    long: [*TODO*],
  ),
) <tab:dataset-types>

=== Response-value validation <subsec:dataset-validation-response-value>
Response-value validation then ensures that all non-null response values are valid according
to the survey codebook. For most variables this is straightforward. Numeric and
single-response ordinal variables typically have a defined range (e.g.,
#box[$18 <= "age" <= 99$], or $1 <= x <= 5$ for a 5-point Likert scale
variable). Text-entry responses are always considered valid.

Single-response categorical questions have ```python Enum``` type, so type-level
validation is sufficient to ensure that the responses do not contain any values outside
the set defined by the ```python Enum```. However, the allowable values occasionally
change between survey waves. Hence response-value validation is also required for
categorical single-response and multiple-response variables, and in general must
handle schema variation between waves.


=== Null-value validation <subsec:dataset-validation-null-value>

Finally, null-value validation ensures that responses are null if, and only if, they
are expected to be null. For a question $Q$, the response of a participant $P$ in wave
$W$ is permitted to be null, iff, at least one of the following four conditions is true:

#{
  set enum(numbering: "N1.", indent: 1em)
  block(width: 97%, [
    + $Q$ is not asked in wave $W$,

    + In wave $W$, $Q$ is only shown to _new_ participants, but $P$ is a _repeating_
      participant (or vice versa),

    + In wave $W$, $Q$ is only shown to a treatment group of which $P$ is not a member, or

    + In wave $W$, $Q$ is conditionally shown to participants based on their response to a
      distinct question $Q'$, and $P$'s response to $Q'$ does not satisfy the condition.
  ])
}

Formally we can write the condition for $P$'s response $R$ being null as:

#let nullop = $op("null")$
$
  nullop(R) arrow.l.r.double.long ("N1" or "N2" or "N3" or "N4")
$ <eqn:dataset-validation-null-value>

Null-value validation then consists in identifying the set of responses $bold(R)$ such
that for $R in bold(R)$, exactly one of $nullop(R)$ and $("N1" or "N2" or "N3" or "N4")$
is true. Validation succeeds if $bold(R)$ is empty. Otherwise the members of
$bold(R)$ are counterexamples to the above conditions.

=== Implementation <subsec:dataset-validation-implementation>

We implement type-level and simple response-value validation using the
#link("https://pandera.readthedocs.io/en/latest/index.html")[Pandera] Python
library for DataFrame validation @bantilanUnionaiossPanderaBeta2022. We implement
manual validation checks for more complex response-value cases, such as questions whose
response schema varies between waves.

The null-value validation logic, i.e., the process of testing for contradictions
@eqn:dataset-validation-null-value, is also manually implemented. Conditions N1 and N2
are derived automatically from the survey codebook. Conditions N3 and N4 must be
manually specified, as the codebook currently does not have a standardised method for
describing conditional display logic.

=== Validation results <subsec:dataset-validation-results>

// - $checkmark$ Which questions are validated?
//   - Type-level and response-level: Roughly X% of the full survey question set. Includes
//     all survey items considered for reduced dataset used for model calibration.
// - $checkmark$ Type-level and response-value varlidation are good
// - $checkmark$ Various issues with Null responses:
//   - Some due to survey logic errors
//   - Some not explained
// - Miscellaneous inconsistencies which aren't currently validated.
//   - Born in US in some waves, not in others
//   - Changing responses to extreme weather experience in last 10 years
// - Extending validation scope is straightforward, but time-consuming. Requires
//   manually checking question specifications in the codebook. Null-value validation is
//   relatively easier. The occurrence of survey questions in certain waves, or for
//   new/repeating participants is derived automatically from the codebook. Treatment
//   groups and conditional items require manually specifying survey logic; however,
//   these items are rare.

At the time of writing, approximately 25% of the complete survey question set for Waves
1--5 has been validated, including all survey questions which were considered for the
targeted calibration dataset (@subsec:dataset-dataset-construction). Since Wave 6 is
currently undocumented in the survey codebook we can reasonably validate neither the
data schema, nor the presence of null-values. We have therefore not yet validated any
of the data from Wave 6, and exclude this wave from the present study.

All type-level and response-value validation checks succeed, providing a strong
guarantee that the data schema matches our expectations per the codebook. We do,
however, encounter several problems during null-value validation.

#emph-block[
  Acknowledge Sara and team for help diagnosing the errors, per the declaration
  of authorship.
]

In some cases, these were due to errors in the codebook itself. These errors are
relatively straightforward to identify from the null-value validation results, since
they often affect all individuals in a particular wave. For instance, if the codebook
specified that a question is not presented in Wave 1, yet all responses are non-null,
then this most likely indicates an error in the codebook. While some cases are more
subtle, such as where a treatment class is misspecified, when arising due to a
codebook error we still expect the contradictions to affect a well-defined subset of
the population (in this case, the individuals in a particular treatment class).

// TODO: Do we want to talk about the case where the error only starts _after_ the
// survey is updated? (see email to Sara)
// Possible that this is actually a codebook error or something.
In other cases we identify contradictions which are due to errors in the survey
process, which caused certain survey questions to be displayed to some individuals
in conditions which did not satisfy the specified survey logic. Some such cases
were systematic, affecting all individuals until the survey process was updated;
however, in other cases we have not been able to identify the source of the error.

#figure(
  image("../results/figures/dataset/validation_switchpoints.pdf"),
  caption: caption(
    short: [Null-value validation],
    long: [*TODO*],
  ),
) <fig:dataset-validation-null-value-switchpoints>

We exclude all responses which fail the null-value validation from further analysis in
the data cleaning stage (@subsec:dataset-preprocessing-cleaning).

The described validation process is primarily concerned with ensuring that the data
schema --- comprising types and values --- aligns with our expectations as per the
survey codebook. While comprehensive in this regard, the process does not account for
_all_ possible forms of errors or inconsistencies. One category which is currently
unaccounted for, but is worth mentioning, comprises inconsistencies in the responses
from a given individual over multiple waves. For instance, the dataset includes several
cases in which individuals presented the question:


#align(center)[
  #quote[Were you born in the United States?]
]

respond with 'Yes' in one wave, but 'No' in another. Validating data for inconsistencies
such as this requires careful consideration on a question-by-question basis to assess
response types for conflicts. We consider this category beyond the scope of this study,
describing it here only to illustrate the bounds of the above validation process.


//
//We split this up into:
//If not in wave, then $R$ is null.
//$
//  ("N1" or "N2") arrow.double.long nullop(R)
//$
//
//If conditions not met, then $R$ is null.
//$
//  ("N3" or "N4") arrow.long.double nullop(R)
//$
//
//For unconditional columns, if shown, then not null:
//$
//  not ("N1" or "N2") arrow.long.double not nullop(R)
//$
//
//For conditional columns, if shown, then not null:
//$
//  not ("N1" or "N2" or "N3" or "N4") arrow.long.double not nullop(R)
//$
//
//For a conditional $A arrow.double.long B$, let $bold(R)$ be the subset of responses
//for which the contradiction $not (A arrow.double.long B) equiv (A and not B)$ is true.
//Then $A arrow.double.long B$ is satisfied if, and only if, $bold(R)$ is empty *check this --- is it iff, if, or only if?*. If
//$bold(R)$ is non-empty, then the contained responses are counter-examples to the
//conditional.
//
//
//- Single-response ordinal:

== Normalisation, cleaning, and transformations <sec:dataset-preprocessing>

We apply pre-processing steps to make the dataset amenible to downstream
analysis, which are divided into three categories:

- *Normalisation:* Ensuring the data schema (variable names, types, and values) conform to
  consistent standards.

- *Cleaning:* Filtering erroneous or otherwise-problematic data.

- *Transformation:* Structural dataset enrichments, including constructed data variables
  and improved organisation of information.

=== Normalisation <subsec:dataset-preprocessing-normalisation>

Variable names in the original dataset are subject to some inconsistency, featuring
a mixture of `snake_case`, `CamelCase`, `dot.case`, and `kebab-case`. We therefore
first convert the names of all variables specified in the codebook to a standard
format, making all names lowercase, and replacing hyphens and periods with underscores.

The dataset also contains several columns which are not described in the codebook, often
containing survey metadata, the functions of which are typically indicated
using a variable name prefix. For instance, the `Group_` prefix indicates that a
column describes treatment group membership. We do not normalise these variable names
here, so as to maintain identiability for later transformations
(@subsec:dataset-preprocessing-transformations).

Secondly, we coerce all variable data types to a standard set. In most cases this
is straightforward. Dates and times represented as strings are coerced to timezone-free
`datetime` types. Non-floating-point numeric values (which constitute most survey
response types) are coerced to 64-bit integers.

Categorical variable responses are originally represented as integeres, which presents
three issues. Firstly, it imposes an ordinal structure which does not, in general, make
sense for categorical variables. For instance, consider the first four response options
to a survey question asking participants about their recent experience with different
forms of extreme weather:

#{
  set math.equation(numbering: none)
  set text(size: 10pt)
  $
    1. "Severe winter storm", #h(2em) 2. "Hurricane", #h(2em) 3. "Tornado", #h(2em) 4. "Heat wave"
  $
}


One may devise any number of reasonable ordinal interpretations over this set (e.g.,
'highest average risk of property damage', or 'annual emergency response cost'), yet
such interpretations are context-dependent and not inherent to the categories
themselves. Recording categorical responses using numeric types therefore risks spurious
interpretations. Second, integer values provide no information about the categories to
consumers of the dataset, requiring that they cross-reference manually with the
codebook. Thirdly, in some cases the mapping from categories to integers for a given
question varies between survey waves. We account for all three of these issues by
coercing categorical variables to `Enum` types, which preserve information about the
underlying categories, and do not assume an ordinal structure.

Multiple-selection survey items are more complex still. These are represented as
strings comprising comma-separated integers, whose values typically refer to non-ordinal
categories. We coerce these to `list[Enum]` types, which have all the benefits of the
categorical enums discussed above, and enable simpler programmatic analysis (e.g.,
testing for set membership, determining differences in response sets between waves).

Finally, we perform a series of value updates to ensure consistency between responses
to different questions. This consists in replacing all empty string responses with
`null` values#footnote[Note that this particular value mapping must happen _after_
  null-value validation (@sec:dataset-validation).], and re-mapping integer columns
(both numeric and ordinal) such that the minimum value is zero.

=== Cleaning <subsec:dataset-preprocessing-cleaning>

Following schema normalisation, we then perform a cleaning stage, which primarily
includes filtering out invalid or problematic data. We only filter out entire
survey responses, rather than answers to specific survey items. Survey responses may
be removed for any one of three reasons.

Firstly, we remove responses where the `participant_id` column is `null`, such that the
individuals cannot be traced across survey waves. Secondly, we remove any responses
from participants who fail the survey validity check in _any_ of their participation
waves. Thirdly, we remove any responses which fail either of the response-value or
null-value validation checks described in the previous section
(@sec:dataset-validation). We recognise that these issues are not necessarily
problematic in every research context (e.g., cross-sectional studies are unconcerned
with tracing an individual's responses across waves), and thus have made each condition
optional in the dataset construction code.

=== Transformation <subsec:dataset-preprocessing-transformations>

Finally, we apply several transformation steps with the goal of simplifying manipulation
and analysis of the existing dataset, or enriching it with additional information.

The original dataset includes two survey items querying participants' alignment with the
two largest US political parties (i.e., the Republicans and the Democrats). The first
item asks whether the participant whether they consider themselves as _Republican_,
_Democrat_, or _Independent_. Those who respond _Independent_ are then presented a
follow-up question asking whether they _lean_ toward either (or neither) party.
We replace these two survey items with a single variable combining the responses, with
possible values:

#{
  set math.equation(numbering: none)
  set text(size: 10pt)
  $
    "Democrat" prec "Leaning Democrat" prec "Independent" prec "Leaning Republican" prec "Republican"
  $
}

While this supplements the first item with additional information, we note two potential
limitations of this transformation. Firstly, some participants who respond _Republican_
or _Democrat_ to the first question may more accurately describe themselves as only
leaning in a given direction, if they had been aware of the (conditional) second question.
Therefore the 'Leaning' responses are perhaps better interpreted as 'Independent with
Republican/Democrat tendencies'.

Secondly, our implicit assumption that _Independent_ is a midpoint between
_Republican_ and _Democrat_ would misrepresent individuals who consider themselves
'right-of-Republican' or 'left-of-Democrat'. However, the available data does not allow
us to distinguish such cases. Furthermore, this issue is also present in the original
first question.

Our second transformation concerns survey questions with different variants, which are
conditionally displayed based on treatment group membership. The original dataset
includes, for each treatment group associated with a given question, a separate
response column, as well as a binary indicator column describing group membership.
Since group membership is always mutually exclusive in the dataset, we coalesce these
various columns, replacing them with singular response and group membership columns.
The group membership column contains integer indexes as opposed to the original binary
indicators. In some cases, different treatment groups have an associated numerical
value. For instance, the `ccSolveX` items query support policies compensating
communities affected by climate change, with the treatment group specifying the cost
($X$) of such a policy to the participant. In these cases we supplement the dataset
with an additional column containing the associated numerical value, simplifying
downstream analyses.

Finally, we improve the dataset organisation by constructing a database comprising
tables for survey item and question metadata and responses, as well as participants
themselves (@fig:dataset-preprocessing-transformations-database-diagram). The
requirement for such as database arose during the construction of the climate beliefs
dataset used for model calibration (@subsec:dataset-dataset-construction). The original
data, comprising a codebook (a spreadsheet) and an RData file containing rows of
participant responses, is not immediately amenible to our task, which requires
reasoning about both survey logic and participation in tandem.
The constructed database primarily serves to link survey metadata (extracted from the
codebook) with survey response data.

#figure(
  image("../diagrams/survey_database/database.svg"),
  caption: caption(
    short: [Constructed survey database diagram],
    long: [
      The survey database comprises tables for survey items (underlying
      concepts assessed in the survey), survey questions (the particular mode in which
      an item is assessed in a given wave or treatment condition), survey responses,
      and participants.
    ],
  ),
) <fig:dataset-preprocessing-transformations-database-diagram>

Recognising the hierarchical structure of the
longitudinal dataset, in which a single survey item may vary in question text or
response schema between waves or treatment conditions, we separate the concepts of
_survey items_ (the underlying concept being assessed) and _survey questions_ (the
particular mode of assessment). Survey questions are associated with particular waves,
participant types (i.e., new or repeating), and treatment conditions, but may be related
under a common survey item. _Survey responses_ are associated with a particular
question as well as a _survey participant_. We include a separate table for participants
which records wave participation as well as the initial wave in which a participant has
responded.

The database is stored on disk as a collection of parquet files @Parquet, which
preserve complex data type information and are supported in both R (e.g., using
#link("https://arrow.apache.org/docs/r/reference/read_parquet.html")[Arrow]) and Python
(e.g., using
#link("https://pandas.pydata.org/docs/reference/api/pandas.read_parquet.html")[Pandas]
or #link("https://docs.pola.rs/user-guide/io/parquet/")[Polars]).



// == Missing-wave imputation
// - Survey responses as Markov processes
// - Viterbi imputation:
//   - Maximum likelihood estimation based on transition matrix
//   - Independence assumption (assumes variables are independent in missing waves), can only reduce measured dependence between variables.
//     - Maybe I can give an info theory proof of this?
//   - Allows us to consider questions which are not always asked in same waves.
// - Evaluation:
//   - Look at imputation impacts on manually degraded dataset, perhaps from COVID questions (which I'm not using, but which are analogous to
//     some of our key questions).
//   - How is the direct performance on individual variables? How does it degrade with the number of imputed waves, or with the locations of the
//     non-null waves?
//   - How does dependence/correlation between related variables degrade as we increase the number of imputation waves?


== Climate beliefs dataset <subsec:dataset-dataset-construction>

// *TODO:*
// - We exclude sixth wave due to no codebook


#emph-block[
  *Note:* Take the content of this subsection with a grain of salt. I drafted this
  a while back, and need to tidy it up. The variable selection description is
  also incomplete, and we currently don't describe how the index variables are
  constructed (we take their mean).
]

#set text(fill: luma(120))

In light of the complexities and breadth of content of the #full-dataset-name, we
construct a smaller, targeted dataset of beliefs and attitudes relating to climate
change, which we expect -- on theoretical grounds -- to exhibit interdependent
behaviour. We will refer to this targeted dataset as the #strong[#dataset-name]. The
primary motivator for constructing this dataset is the calibration of the
non-equilibrium belief system model (@subsec:methods-parameter-estimation).

We aim for 7--10 variables in the final set, so as to keep both the number of model
parameters and parameter uncertainty sufficiently small. We first filter the survey
items to consider only those which assess cognitive states (e.g., beliefs, attitudes,
opinions, stances). We further restrict our attention to items which either relate
directly to climate change, or which are expected to influence climate-related
cognitive states (e.g., political alignment).

Within this restricted set of survey items our intention is to select a collection
of variables which: (i) exhibit related behaviour, (ii) maximise the number of
observations, and (iii) satisfy the requirements of the parameter estimation method
used for model calibration. We will discuss the latter two requirements now, and return
to the first shortly. We require at least two waves of responses from each participant,
as the model is defined by a time-dependent Markov process, and thus parameter
estimation involves fitting a conditional probability distribution where each
belief state depends on the previous one. Moreover, each participant's responses should
be equispaced, with spacing being consistent across individuals, and the dataset must
contain no missing values. In addition to these requirements, we prioritise including
several variables of interest:

+ *CC Worry*: Concern about current and future climate change
+ *CC Others Worry*: Belief regarding _others'_ level of worry about
  climate change
+ *CC Human*: Belief that climate change is caused by human activities

The first is generally considered influential in shifting related attitudes, while
the second is expected to be influential on the first, as a perceived descriptive norm.
Finally, while most inividuals in the USA believe in the _existence_ of climate change,
there is relatively greater variation in beliefs about it's _causes_. Hence the third
item is an interesting target for intervention studies. (*TODO*)
// TODO: Citations

Given the above requirements and the objective to maximise the number of observations,
we identify Waves 3 & 4 as suitable candidates. These waves include 1693 repeat
observations (excluding survey errors as described in the previous subsection). After
removing items with no substantial correlations, and small groups of items which exhibit
only internal correlations, we identify 17 relevant survey items, comprising both
beliefs (epistemic positions, @tab:dataset-dataset-beliefs) and attitudes (qualitative
evaluations, @tab:dataset-dataset-attitudes).

//#{
//  set par(spacing: 1em)
//  block(fill: luma(230), inset: 1em, width: 100%)[
//    *CC Real:* Do you think that climate change is happening?
//
//    *Category:* Belief
//
//    *Response schema:* $"No" prec "Don't know" prec "Yes"$
//
//    #h(1em)
//
//    *CC Human:* Do you think rising temperatures are a result of human activities, natural causes, or both?
//
//    *Category:* Belief
//
//    *Response schema:* All yes/no combinations of _natural causes_ and _human activities_.
//
//    *Note:* We map responses to binary -- includes/does not include _human activities_.
//
//
//
//
//  ]
//}

// Item name | Category | Question | Response schema | Notes
#set table(stroke: (x, y) => (y: if y == 1 { 0.5pt } else { 0pt }))
//#show table.cell.where(y: 0): set text(weight: "bold")
#figure(
  {
    set text(size: 9pt)
    table(
      columns: 3,
      align: (right, left, left),
      table.header[Item][Question text][Response schema],
      [CC Real], [Do you think that climate change is happening?], [#list[Yes][No][Don't know]],

      [CC Human (\*)],
      [Do you think rising temperatures are a result of human activities, natural causes, or both?],
      [#list[Not happening][Natural causes][Human activities][Both]],

      [CC Impact (world)],
      [How much do you think climate change is currently harming the world in general?],
      [#list[Not at all][Only a little][A moderate amount][A great deal]],

      [CC Impact (wealthy)],
      [How much do you think climate change is currently harming wealthy communities within the United States?],
      [#list[Not at all][Only a little][A moderate amount][A great deal]],

      [CC Impact (poor)],
      [How much do you think climate change is currently harming poor communities within the United States?],
      [#list[Not at all][Only a little][A moderate amount][A great deal]],

      [CC Impact (comm)],
      [How much do you think climate change is currently harming your local community?],
      [#list[Not at all][Only a little][A moderate amount][A great deal]],

      [CC Others Worry],
      [How worried do you think most Americans are about global warming/climate change these days?],
      [#list[Not at all worried][Not very worried][Somewhat worried][Very worried]],
    )
  },
  caption: caption(
    short: [],
    long: [
      \* Re-mapped to: includes/does not include human activities
    ],
  ),
) <tab:dataset-dataset-beliefs>

#figure(
  {
    set text(size: 9pt)
    table(
      columns: 3,
      align: (right, left, left),
      table.header[Item][Question text][Response schema],
      [CC Worry],
      [How worried are you about current and future global warming/climate change?],
      [#list[Not at all worried][Not very worried][Somewhat worried][Very worried]],

      [Weather Worry],
      [How worried are you about an extreme weather event or natural disaster happening to you personally in the next year?],
      [#list[Not at all][Only a little][A moderate amount][A great deal]],

      [CC Responsibility],
      [It is important that individuals take action on issues of climate change.],
      [5-point Likert agreement scale],

      [CC Scientists],
      [Scientists with appropriate expertise should guide how we respond to climate change],
      [5-point Likert agreement scale],

      [Policy: ICA (\*)],
      [Do you favour an international agreement committing the USA and other countries to reduce their carbon emissions?],
      [#list[Yes and legally binding)][Yes but _not_ legally binding)][No]],

      [Policy: Tax fuel],
      [How much do you support/oppose a tax on the production/distribution of carbon-based fuelds?],
      [5-point Likert support scale],

      [Policy: Auto],
      [How much do you support/oppose stronger carbon emissions standard for car manufacturers?],
      [5-point Likert support scale],

      [Policy: Env. Reg.],
      [Which statement comes closer to your views?],
      [#list[Stricter environmental regulations cost too many jobs and hurt the economy][Stricter environmental regulations are worth the cost]],

      [Political affiliation (\*\*)],
      [In politics today, do you consider yourself a:],
      [#list[Republican][Leaning Republican][Independent][Leaning Democrat][Democrat]],

      [Political ideology],
      [What is your political ideology?],
      [#list[Very conservative][Conservative][Moderate][Liberal][Very liberal]],
    )
  },
  caption: caption(
    short: [],
    long: [
      \* Re-mapped to: Yes/No

      \*\* Constructed from separate items for identification and leaning
    ],
  ),
) <tab:dataset-dataset-attitudes>

//Decisions regarding dataset size, variable selection, and
//transformation are non-trivial on account of the scope of the #full-dataset-name,
//and are further complicated by the variability in both survey content and participation
//across waves, as discussed above. Our design decisions are motivated by three factors:
//(i) our specific empirical research focus (@sec:introduction), (ii) the theoretical
//non-equilibrium model defined in @sec:asymmetric-belief-systems, whose calibration
//serves as our primary motivator in constructing the targeted dataset, and (iii) the
//specific requirements and limitations of the parameter estimation method employed for
//calibration (@subsec:methods-parameter-estimation).
//
//Our empirical research focus --- dependent systems of beliefs and attitudes pertaining
//to climate change --- allows us to narrow set of considered survey items to only those
//representing cognitive aspects (e.g., beliefs, attitudes, emotions, opinions, stances).
//Furthermore, we only consider variables which either relate directly to climate change
//or are otherwise expected to influence climate-related variables. For instance,
//variables in the former category may include beliefs regarding the causes of climate
//change and specific climate-related policy positions, while those in the latter may
//include general extreme weather concerns or political alignment. We prioritise including
//three variables-of-interest from the former category:
//
//+ *CC Worry*: Concern about current and future climate change
//+ *CC Others Worry*: Belief regarding _others'_ level of worry about
//  climate change
//+ *CC Human*: Belief that climate change is caused by human activities
//
//Climate worry is generally considered influential in shifting other climate-related
//attitudes. Perceived descriptive norms, such as the second item, are also influential
//for individual's beliefs and attitudes. Finally, while most individual in the USA
//believe in the existence of climate change, there is greater variation in beliefs
//regarding its causes. Hence the third item is an interesting target for intervention
//studies. (*TODO: Add citations*)


//Beliefs and attitudes in the non-equilibrium belief system model, defined in
//@sec:asymmetric-belief-systems, take on values from the set ${-1, +1}$. This contrasts
//binary variations of the Ising model which allows spins to assume values in the set
//${0, 1}$. In the binary Ising model, a spin with state $0$ exerts no influence on
//related spins, while in our model, a belief or attitude with state $-1$ exerts
//negative influence. It follows that the variables in the #dataset-name must have a
//reasonable interpretation in our model. This is particularly important in the context
//of _beliefs_, which are epistemic positions regarding states of affairs. Consider a
//particular state of affairs $p$ (e.g., 'It will rain today'). There are two
//reasonable states which we may consider 'opposite' to belief in $p$: belief that $p$
//is false (i.e., that it will not rain today), and _lack of belief_ that $p$ is true.
//Our model expects the state of a belief spin to reflect the state of affairs believed
//to be true, i.e., the first case. However, whether a given survey item should be
//interpreted under the first or second cases depends on the specific phrasing of the
//question.
//
//
//Finally, the calibration process itself imposes several constraints. Firstly, that the
//number of variables is relatively small, such that the number of model parameters
//remains tractable, and parameter uncertainty is sufficiently low. We set a goal of 7--10
//variables. Secondly, the calibration method assumes that there is no missing data.
//Thirdly, estimating the temporal conditional probability distributions which define the
//model requires that the dataset contain at least two waves of data for each survey
//participant. Moreover, consecutive responses should be roughly equispaced for each
//participant, and this spacing should be identical across participants. Finally, to
//ensure minimal uncertainty in parameter estimates, we maximise the number of
//observations.
//

To reduce the set of candidate variables to the target range of 7--10, we proceed to
identify groups of similar or redundant variables which may be removed or combined into
interpretable index variables. We use two primary measures to investigate similarity:
pairwise partial correlation, and vector autoregression
@epskampPersonalizedNetworkModeling2018   @epskampGaussianGraphicalModel2018.

Partial correlation measures the correlation between a pair of variables $X$ and $Y$
after conditioning on all remaining variables $Z$:

$
  rho(X, Y) = op("Corr")(X,Y | Z)
$ <eqn:dataset-partial-correlation>

In particular, $|rho(X, Y)|$ is non-zero if $X$ and $Y$ exhibit _linear_
correlation which is not shared with the remaining variables in $Z$. For instance,
consider the fork structure $X <- A -> Y$ where $X$ and $Y$ are probabilistic linear
functions of $A$. If the value of $A$ is unknown, then $X$ and $Y$ are dependent.
However, once $A$ is known, the dependency structure is broken. Thus $op("Corr")(X,Y)$
is nonzero, while $rho(X, Y) = 0$.

@fig:dataset-full-subset-partial-correlations displays the pairwise partial correlation
between each pair of variables in the filtered set. Note that we have coded all
variables such that the partial correlation matrix entries are predominantly positive.
Cells with magnitude below $0.05$ have been masked for visual clarity. Rows and columns
are ordered using hierarchical clustering.

#figure(
  image("../results/figures/dataset/full_subset_partial_corr.pdf"),
  caption: caption(
    short: [Pairwise partial correlation: full subset],
    long: [
      Pairwise partial correlation for the filtered candidate set
      (@tab:dataset-dataset-beliefs, @tab:dataset-dataset-attitudes). Cells with
      $|rho(X, Y)| < 0.05$ are masked for visual clarity. Rows and columns are
      ordered using hierarchical clustering over the distance
      matrix: $d_rho (X,Y) = 1 - |rho(X, Y)|$.
    ],
  ),
  placement: auto,
) <fig:dataset-full-subset-partial-correlations>

Partial correlations are limited, however, in that they capture only instantaneous
(or 'contemporaneous') relations between variables, while the non-equilibrium belief
system model is concerned with temporal relationships. Therefore we also examine the
temporal and contemporaneous networks obtained using vector autoregression (VAR)
with a #box[$delta t = 1$] time lag @brandtMultipleTimeSeries2007. These networks are derived
from the solution to the following regression problem, described in
#cite(<epskampGaussianGraphicalModel2018>, form: "prose"):

$
  bold(y)^t & = bold(B)bold(y)^(t-1) + epsilon^(t) \
  epsilon^t & ~ cal(N)(bold(0), bold(Theta))
$ <eqn:dataset-var-regression-problem>

Where $bold(y)^t$ is the vector of observed variable values for each individual at time
$t$. The _temporal network_ matrix $bold(B)$ comprises linear next-state predictors, while
the _contemporaneous network_ matrix $bold(K) = Theta^(-1)$ describes the pairwise
conditional correlations which remain after accounting for temporal effects. The
entries of $bold(K)$ are analogous to partial correlations, constituting the conditional
correlation between $X$ and $Y$ given the remaining variables.

@fig:dataset-full-subset-var shows the contemporaneous and temporal network matrices
for the filtered set of candidate variables. The contemporaneous matrix is symmetric,
thus the upper triangle is not shown.

#figure(
  image("../results/figures/dataset/full_subset_var.pdf"),
  caption: caption(
    short: [Pairwise vector autoregression: full subset],
    long: [
      Contemporaneous (left) and temporal (right) network matrices for the filtered
      candidate set (@tab:dataset-dataset-beliefs
      @tab:dataset-dataset-attitudes). Entries in row $i$ of the temporal matrix are
      the regression predictors for the subsequent value of variable $X_i$. Rows and
      columns are ordered using hierarchical clustering on the distance matrix:
      $d_bold(K) (X,Y) = 1 - abs(bold(K))$.
    ],
  ),
  placement: auto,
) <fig:dataset-full-subset-var>

We observe some apparent commonalities between the partial correlation and VAR
networks. First, the _CC Impact_ variables exhibit relatively strong
internal relations. External relations with variables outside this set are
typically weaker, with the exception of _CC Impact (world)_, which has several
non-trivial partial correlations with other variables, including other climate-related
beliefs. All variables in this group, except _CC Impact (wealthy)_, also have
non-trivial partial correlations with _CC Worry_ --- one of our
variables-of-interest. Second, the policy variables, as well as _CC Responsibility_
and _CC Scientists_, also exhibit substantial connectivity in the partial correlation
network. This is diminished in the contemporaneous VAR network, but visible in the
clustering of the temporal network. The similarities among these variables in the
rows and columns of the temporal matrix indicate that they fill similar roles as
predictors, and are also predicted similarly. Thirdly, _Political affiliation_ and
_Political ideology_ are highly related in the partial correlation matrix, and
also exhibit similar behaviour in the temporal network.

// *TODO:* PCA/EFA plot.

Based on these observations, we construct three index variables: (i) _CC Impact_,
comprising the four climate impact beliefs, (ii) _Politics_, comprising the measures
of political affiliation and ideology, and (iii) _CC Action_, comprising the four
policy variables, as well as _CC Responsibility_ and _CC Scientists_.


// #figure(
//   image("../results/figures/dataset/reduced_subset_partial_corr.pdf"),
//   caption: caption(
//     short: [Pairwise partial correlation: reduced dataset],
//     long: [*TODO*],
//   ),
//   placement: auto,
// )
#figure(
  image("../results/figures/dataset/reduced_subset_temporal.pdf"),
  caption: caption(
    short: [Temporal network: reduced dataset],
    long: [Temporal],
  ),
  placement: auto,
)

#figure(
  image("../results/figures/dataset/reduced_subset_contemporaneous.pdf"),
  caption: caption(
    short: [Contemporaneous network: reduced dataset],
    long: [Contemporaneous],
  ),
  placement: auto,
)


#figure(
  image("../results/figures/dataset/marginal_distributions.pdf"),
  caption: caption(
    short: [Marginal distributions: reduced dataset],
    long: [*TODO*],
  ),
  placement: auto,
) <fig:dataset-marginal-distributions>

#set text(fill: black)



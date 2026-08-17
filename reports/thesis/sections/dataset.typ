#import "@local/drifting-cls-thesis:0.1.0": caption
#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion



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

In this chapter, we outline the context and construction of the dataset used for
model calibration in @sec:methods. We will
first describe the broader context and complexities of the dataset underlying this study,
and then outline our data validation and cleaning methods in @sec:dataset-preprocessing.
Finally, in @subsec:dataset-dataset-construction, we detail the construction of the
targeted dataset used for model calibration (@sec:methods).

While many empirical studies on belief systems rely on cross-sectional data
@leeVariationsClimateChange2025 @vannoordNatureStructureEuropean2025
@powellModelingLeveragingIntuitive2023, longitudinal data are necessary to capture
changes in individuals' internal cognitive states over time. In this study, we are
fortunate to have had access to data from the *Longitudinal Panel of Perceptions About
Climate Change and Covid* (*CCCV*), a representative longitudinal survey comprising six
waves of responses from individuals residing in the United States, collected between
#survey_start_date.display("[month repr:long] [year]") and
#survey_end_date.display("[month repr:long] [year]")
@constantinoPersonalHardshipNarrows2022. The assessed
dimensions include general demographic information (e.g., age, gender, education, and
financial status), beliefs, attitudes, and experiences related to concurrently salient
topics such as COVID-19, climate change, or the 2020 US presidential election, as well
as support for hypothetical policies. In addition to a wide-form table of survey response
data, the dataset includes a codebook that specifies, for each survey item, the
question text, its occurrence in survey waves, and conditional display logic (where
applicable). At present, the codebook is limited to Waves 1---5, i.e., excluding the
sixth (final) wave.

However, the dataset is not without complexities. Survey participation varies, with
each participant responding to a (possibly non-contiguous) subset of waves.
@fig:dataset-survey-participation shows the number of participants who have responded
to each combination of survey waves, with a minimum count of 1500. While individual waves
have a relatively high response rate (roughly 4000--5000), this rapidly drops off
when other waves are considered. For instance, only \~2500 individuals responded to
Waves 1 and 2, and only \~1900 of these individuals also responded to Wave 3.

#figure(
  image("../results/figures/dataset/participation.pdf"),
  caption: caption(
    short: [CCCV survey participation],
    long: [
      Number of repeat participants for different wave combinations in the Longitudinal
      Panel of Perceptions About Climate Change and Covid dataset, prior to dataset
      cleaning. Excludes combinations with fewer than 1500 responses.
    ],
  ),
) <fig:dataset-survey-participation>

Survey content also varies between waves and participants, with regard to both
_which_ questions are included and _how_ they are presented. Certain questions are
displayed only in particular waves or only to either repeat participants or new
participants. Some questions are shown conditionally based on an individual's responses
to prior questions (within the same wave). Others vary according to survey treatment
conditions, such that individuals in different treatment groups are presented with
different question variants. This survey logic is not always executed correctly; in
some cases, participants are shown survey questions incorrectly (e.g., 'new' participants
are shown questions intended only for 'repeating' participants). We discuss this issue
further in @sec:dataset-validation.

Question format, text, and response schemas also occasionally change between survey
waves. Changes in response schema are less common, however, and typically affect items
with categorical responses. With a view to constructing the calibration dataset for our
experiments, we note that most response schemas are not binary.

Casting our attention to the survey timing, we examine the survey response dates for
each wave (@fig:dataset-longitudinal-response-eventplot) and the distribution of
interval durations between consecutive-wave responses across individuals
(@fig:dataset-longitudinal-interresponse-times), i.e., the 'inter-response time'.
In @fig:dataset-longitudinal-response-eventplot, we observe that the survey waves occur
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
This poses a potential problem for model calibration, since the Kinetic Belief System
model (defined in @chp:kinetic-belief-system) assumes that samples are equispaced.

#figure(
  image("../results/figures/dataset/response_eventplot.pdf"),
  caption: caption(
    short: [CCCV survey response dates],
    long: [
      Per-wave survey response dates for the Longitudinal Panel of Perceptions About
      Climate Change and Covid dataset (prior to dataset cleaning). Annotations
      illustrate differences in intervals spanned by/between survey waves.
    ],
  ),
) <fig:dataset-longitudinal-response-eventplot>

We also see the irregular spacing reflected in the inter-response time distributions.
For each pair of consecutive waves, we observe substantial variation in the time between
responses for different participants.

#figure(
  image("../results/figures/dataset/interresponse_times.pdf"),
  caption: caption(
    short: [CCCV survey inter-response time distribution],
    long: [
      Inter-response time distribution between each pair of consecutive waves in the
      Longitudinal Panel of Perceptions About Climate Change and Covid dataset (prior to
      dataset cleaning). The inter-response time between two waves is calculated,
      for individuals present in both waves, as the number of days between their responses.
    ],
  ),
) <fig:dataset-longitudinal-interresponse-times>


Finally, we note that the time interval spanned by the longitudinal dataset includes
several notable events that could reasonably be expected to influence---and confound---the
dynamics of beliefs in myriad contexts. These
include the COVID-19 pandemic, which arrived in the US only three months prior to the
first survey wave @holshueFirstCase20192020, the 2020 US Presidential Election which
occurred during Wave 3, and the January 6 United States Capitol Attack, which occurred
between Waves 3 and 4.

== Data Validation <sec:dataset-validation>

The complexity of the CCCV survey, as outlined above, necessitates a
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
matches the _prescribed_ schema. Since response data types vary across questions
(see @tab:dataset-types), the type checking must be
flexible and capable of handling complex data types.

#let enum-footnote = footnote[
  An enum is a type defined by a finite set of allowable values. In our case,
  the values are human-readable strings. For instance, the `dem_urban` survey question,
  which asks 'What kind of area do you live in?' has responses with data type described
  by the enum ${"Urban", "Suburban", "Rural"}$.
]

For instance, categorical multiple-choice responses are represented using a
```python list[Enum]```, where ```python Enum``` is a question-specific
enum type.#enum-footnote Type validation for a multiple-choice question thus requires
checking: (i) that the response column comprises ```python list```s, and (ii) that all
list elements belong to the set of values defined by the ```python Enum```.

//#set table(stroke: (x, y) => (y: if y in (0,1) { 0.5pt } else { 0pt }))
// #set table(
//   inset: (x: 6pt, y: 4pt),
// )
#show table: set text(size: 10pt)
#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    stroke: none,
    table.header[Response format][Raw type][Coerced type],
    table.hline(stroke: 0.5pt),
    [Text], [```python str```], [```python str```],
    [Single response (ordinal)], [```python int```], [```python int```],
    [Single response (categorical)], [```python int```], [```python Enum```],
    [Multiple response], [```python str```], [```python list[Enum]```],
    [Numeric], [```python float```], [```python float | int```],
  ),
  placement: auto,
  caption: caption(
    short: [CCCV survey type coercion mapping],
    long: [
      Data type coercion mapping for different question types in the Longitudinal Panel
      of Perceptions About Climate Change and Covid survey.
    ],
  ),
) <tab:dataset-types>

=== Response-value validation <subsec:dataset-validation-response-value>
Response-value validation then ensures that all non-null response values are valid according
to the survey codebook. For most variables, this is straightforward. Numeric and
single-response ordinal variables typically have a defined range (e.g.,
#box[$18 <= "age" <= 99$], or $1 <= x <= 5$ for a 5-point Likert scale
variable). Text-entry responses are always considered valid.

Single-response categorical questions have an ```python Enum``` type, so type-level
validation is sufficient to ensure that responses do not contain values outside
the ```python Enum```'s defined set. However, the allowable values occasionally
change between survey waves. Hence, response-value validation is also required for
categorical single-response and multiple-response variables and, in general, must
handle schema variation between waves.


=== Null-value validation <subsec:dataset-validation-null-value>

Finally, null-value validation ensures that responses are null if, and only if, they
are expected to be null. For a question $Q$, the response of a participant $P$ in wave
$W$ is permitted to be null if, and only if, at least one of the following four conditions is true:

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
response schema varies across waves.

The null-value validation logic, i.e., the process of testing for contradictions in
@eqn:dataset-validation-null-value, is also manually implemented. Conditions N1 and N2
are derived automatically from the survey codebook. Conditions N3 and N4 must be
specified manually, as the codebook currently does not have a standardised method for
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

At the time of writing, approximately 25% of the complete set of survey questions for
Waves 1--5 has been validated, including all questions which considered for the
targeted calibration dataset (@subsec:dataset-dataset-construction). Since Wave 6 is
currently undocumented in the survey codebook, we cannot reasonably validate either the
data schema or the presence of null-values. We have therefore not yet validated any
of the data from Wave 6, and exclude this wave from the present study.

All type-level and response-value validation checks succeed, providing a strong
guarantee that the data schema matches our expectations as defined by the codebook. We do,
however, encounter several problems during null-value validation.

In some cases, these were due to errors in the codebook itself. These errors are
relatively straightforward to identify from the null-value validation results, since
they often affect all individuals in a particular wave. For instance, if the codebook
specified that a question is not presented in Wave 1, yet all responses are non-null,
then this most likely indicates an error in the codebook. While some cases are more
subtle, such as where a treatment class is misspecified, when these arise due to a
codebook error, we still expect the contradictions to affect a well-defined subset of
the population (in this case, the individuals in a particular treatment class).

// TODO: Do we want to talk about the case where the error only starts _after_ the
// survey is updated? (see email to Sara)
// Possible that this is actually a codebook error or something.
In other cases, we identify contradictions due to errors in the survey
process that caused certain survey questions to be displayed to some individuals
under conditions that did not satisfy the specified survey logic.
@fig:dataset-validation-null-value-switchpoints shows examples observed in Waves
2 and 3. Some cases were systematic, affecting all individuals until the survey process
was updated (_left_); however, in other cases, we have not been able to identify the
source of the error (_right_).
We exclude all responses which fail the null-value validation from further analysis in
the data cleaning stage (@subsec:dataset-preprocessing-cleaning).

#figure(
  image("../results/figures/dataset/validation_switchpoints.pdf"),
  caption: caption(
    short: [CCCV survey null-value validation errors],
    long: [
      Systematic (_left_) and unresolved (_right_) null-value validation errors
      identified in Waves 2 and 3 of the Longitudinal Panel of Perceptions About
      Climate Change and Covid survey.
    ],
  ),
) <fig:dataset-validation-null-value-switchpoints>


The described validation process primarily ensures that the data
schema---comprising types and values---aligns with our expectations defined in the
survey codebook. While comprehensive in this regard, the process does not account for
_all_ possible forms of errors or inconsistencies. One category that is currently
unaccounted for but worth mentioning comprises inconsistencies in the responses
from a given individual across waves. For instance, the dataset includes several
cases in which individuals presented with the question:


#align(center)[
  #quote[Were you born in the United States?]
]

responded with 'Yes' in one wave but 'No' in another. Validating data for inconsistencies
such as this requires careful, question-by-question consideration to assess
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

We apply pre-processing steps to make the dataset amenable to downstream
analysis, which are divided into three categories:

- *Normalisation:* Ensuring the data schema (variable names, types, and values) conforms
  to consistent standards.

- *Cleaning:* Filtering erroneous or otherwise problematic data.

- *Transformation:* Structural dataset enrichments, including constructed data variables
  and improved information organisation.

=== Normalisation <subsec:dataset-preprocessing-normalisation>

Variable name formats in the original dataset are inconsistent, featuring
a mixture of `snake_case`, `CamelCase`, `dot.case`, and `kebab-case`. We therefore
first convert the names of all variables specified in the codebook to a standard
format, making all names lowercase, and replacing hyphens and periods with underscores.

The dataset also contains several columns that are not described in the codebook, often
containing survey metadata, whose functions are typically indicated
by a variable-name prefix. For instance, the `Group_` prefix indicates that a
column describes treatment group membership. We do not normalise these variable names
here to maintain identifiability for later transformations
(@subsec:dataset-preprocessing-transformations).

Secondly, we coerce all variable data types to a standard set. In most cases, this
is straightforward. Dates and times represented as strings are coerced to timezone-free
`datetime` types. Non-floating-point numeric values (which constitute most survey
response types) are coerced to 64-bit integers.

Categorical variable responses in the original dataset are represented as integers, which
presents three issues. Firstly, it imposes an ordinal structure which does not, in
general, make sense for categorical variables. For instance, consider the first four
response options to a survey question asking participants about their recent experience
with different forms of extreme weather:

#{
  set math.equation(numbering: none)
  set text(size: 10pt)
  $
    1. "Severe winter storm", #h(2em) 2. "Hurricane", #h(2em) 3. "Tornado", #h(2em) 4. "Heat wave"
  $
}


One may devise any number of reasonable ordinal interpretations over this set (e.g.,
'highest average risk of property damage', or 'annual emergency response cost'); however,
such interpretations are context-dependent and not inherent to the categories
themselves. Recording categorical responses using numeric types therefore risks spurious
interpretations. Second, integer values provide no information about the categories for
dataset users, requiring them to manually cross-reference columns with the codebook.
Thirdly, in some cases, the mapping from categories to integers for a given
question varies between survey waves. We account for all three of these issues by
coercing categorical variables to `Enum` types, which preserve information about the
underlying categories and do not assume an ordinal structure.

Multiple-choice survey items are even more complex. These are represented as
strings comprising comma-separated integers, whose values typically refer to non-ordinal
categories. We coerce these into `list[Enum]` types, which have all the benefits of the
categorical enums discussed above and enable simpler programmatic analysis (for example,
testing for set membership and identifying differences in response sets between waves).

#let empty-string-fixing-footnote = footnote[
  Note that this particular value mapping must happen _after_ null-value validation
  (described in @sec:dataset-validation), otherwise empty strings will be considered
  errors.
]
Finally, we perform a series of value updates to ensure consistency between responses
to different questions. This involves replacing all empty-string responses with
`null` values,#empty-string-fixing-footnote and remapping integer columns
(both numeric and ordinal) so that the minimum value is zero.

=== Cleaning <subsec:dataset-preprocessing-cleaning>

Following schema normalisation, we perform a cleaning step to filter out invalid or
problematic data. We filter entire survey responses, rather than individual survey items,
to avoid creating null response values. Survey responses may be removed for any one of
three reasons.

Firstly, we remove responses where the `participant_id` column is `null`, such that the
individuals cannot be traced across survey waves. Secondly, we remove responses
from participants who fail the survey validity check in _any_ of their participation
waves. Thirdly, we remove any responses which fail either of the response-value or
null-value validation checks described in the previous section
(@sec:dataset-validation). We recognise that these issues are not necessarily
problematic in every research context (for example, cross-sectional studies are not
concerned with tracing an individual's responses across waves) and thus have made each
condition optional in the dataset-construction code.

=== Transformation <subsec:dataset-preprocessing-transformations>

Finally, we apply several transformation steps to simplify the manipulation
and analysis of the existing dataset and to enrich it with additional information.

The original dataset includes two survey items that ask participants about their
identification with the two largest US political parties (i.e., the Republicans and the
Democrats). The first item asks whether a participant considers themselves
a _Republican_, _Democrat_, or _Independent_. Those who respond _Independent_ are then
presented with a follow-up question asking whether they lean toward either party (or
neither). We replace these two survey items with a single variable that combines the
responses and has the following ordered response values:

#{
  set math.equation(numbering: none)
  set text(size: 10pt)
  $
    "Democrat" prec "Leaning Democrat" prec "Independent" prec "Leaning Republican" prec "Republican"
  $
}

While this supplements the first item with additional information, we note two potential
limitations of this transformation. Firstly, some participants who responded _Republican_
or _Democrat_ to the first question may have more accurately described themselves as only
leaning in a given direction if they had been aware of the conditional second question.
Therefore, the 'Leaning' responses are perhaps better interpreted as 'Independent with
Republican/Democrat tendencies'.

Secondly, our implicit assumption that _Independent_ is a midpoint between
_Republican_ and _Democrat_ would misrepresent individuals who consider themselves
'right-of-Republican' or 'left-of-Democrat'. However, the available data does not allow
us to distinguish such cases. Furthermore, this issue is also present in the original
first question.

Our second transformation concerns survey questions with different variants, which are
conditionally displayed based on treatment group membership. The original dataset
includes, for each treatment group associated with a given question, a separate
response column and a binary-valued column indicating group membership.
Since group membership is always mutually exclusive in the dataset, we coalesce these
columns, replacing them with one column describing responses and one column describing
group membership. The group membership column contains integer indices rather than the
original binary indicators. In some cases, treatment groups are associated with a
numerical value. For instance, the `ccSolveX` items ask about support for policies
compensating communities affected by climate change, with the treatment group specifying
the cost ($X$) of such a policy to the participant. In these cases, we supplement the
dataset with an additional column containing the associated numerical value, simplifying
downstream analyses.

Finally, we improve the dataset organisation by constructing a database comprising
tables for survey items' and questions' metadata, responses, and participants
(illustrated in @fig:dataset-preprocessing-transformations-database-diagram). The
need for such a database arose during the construction of the climate beliefs
dataset used for model calibration (@subsec:dataset-dataset-construction). The original
data, comprising a codebook (a spreadsheet) and an RData file containing rows of
participant responses, is not immediately amenable to our task, which requires reasoning
about survey logic and participation simultaneously. The constructed database primarily
serves to link survey metadata (extracted from the codebook) with survey response data.

#figure(
  image("../diagrams/survey_database/database.svg"),
  caption: caption(
    short: [Constructed survey database diagram],
    long: [
      The constructed survey database comprises tables for survey items (the underlying
      concepts assessed in the survey), survey questions (the specific mode used to assess
      an item for a given wave or treatment condition), survey responses,
      and participants. Arrows denote data hierarchy, e.g., each response belongs to
      a participant and is associated with a particular survey question.
    ],
  ),
) <fig:dataset-preprocessing-transformations-database-diagram>

Recognising the hierarchical structure of the
longitudinal dataset, in which a single survey item may vary in question text or
response schema between waves or treatment conditions, we separate the concepts of
_survey items_ (the underlying concept being assessed) and _survey questions_ (the
particular mode of assessment). Survey questions are associated with particular waves,
participant types (i.e., new or repeating), and treatment conditions, but may be related
under a common survey item. _Survey responses_ are associated with both a particular
question and a _survey participant_. We include a separate table for participants
that records overall wave participation and the first wave in which a participant
responded.

The database is stored on disk as a collection of parquet files, which
preserve information about complex data types, including those in @tab:dataset-types, and
are supported in both R (e.g., using
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

In light of the complexities and breadth of content in the CCCV survey, we
construct a smaller, targeted dataset of beliefs related to climate
change, which we expect---on theoretical grounds---to exhibit interdependent
behaviour. This serves as the calibration dataset for the experiments described
in this study. We will refer to this targeted dataset as the *climate beliefs dataset*.

We aim for 7--10 variables in the final set, to keep both the number of model
parameters and parameter uncertainty acceptably small. We first filter the survey
items to consider only those which assess beliefs (in the inclusive sense described by
#cite(<galesicIntegratingSocialCognitive2021>, form: "prose"), which includes both
epistemic positions about states of affairs, as well as views, opinions, and preferences),
and which either relate directly to climate change or are expected to influence
climate-related beliefs (e.g., political alignment). The parameter
estimation method used to calibrate the Kinetic Belief System model (outlined in
@chp:parameter-estimation)
imposes several additional requirements on the
constructed dataset, in particular, the dataset should comprise at least two waves,
with approximately equispaced observations per individual, and with no null values.
We additionally constrain the dataset to include three specific variables of interest:

#let cc-human-footnote = footnote[
  In the CCCV survey, the item `CC Human` has four possible (categorical)
  responses, reflecting all combinations of 'human activities' and 'natural causes' as
  the causes of climate change. We remap these values to 'human-caused' and
  'not human-caused', such that the variable is binary, and thus both amenable
  to the analysis described below and interpretable within the kinetic belief system
  model in @sec:calibration.
]

+ *CC Worry*: Level of worry regarding current and future climate change.

+ *CC Others Worry*: Belief about how worried _others_ are about climate change.

+ *CC Human*: Belief that climate change is caused by human activities.#cc-human-footnote

Climate-related worry is generally considered an influential factor for other
beliefs relating to climate change, including support for climate policy
@meadInformationSeekingGlobal2012 @whitmarshClimateAnxietyWhat2022a
@goldbergIdentifyingMostImportant2021 @boumanWhenWorryClimate2020
@bumannWhatAreDeterminants2021, and is expected to be
influenced by beliefs about others' level of worry, as a descriptive norm
@gavriletsModellingSocialNorms2024. The third variable provides a more complex
view of individuals' beliefs about the nature of climate change. While most
Americans believe climate change exists, there is greater variation in
beliefs about its causes @hamiltonTrackingPublicBeliefs2015.

To satisfy these requirements while maximising the number of observations (for model
calibration purposes), we limit the climate beliefs dataset to waves 3 and 4, which
contain 1693 repeat observations, excluding survey errors. After removing items
with no substantial correlations and small groups with no substantial external
correlations, we identify 17 relevant survey items (see @apdx:dataset for the full set
of items).

However, this set of items still exceeds our target range of 7--10. We therefore also
identify groups of similar or redundant variables that may be removed or combined
into interpretable index variables. Note that cross-sectional methods should not be used
for this analysis, as they fail to capture temporal relationships, which are fundamental
to the kinetic belief system model (defined in @chp:kinetic-belief-system). Instead,
we examine the temporal and contemporaneous networks obtained using lag-1 vector
autoregression (VAR).
These networks are derived
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

#let re-coded-footnote = footnote[
  We have re-coded the survey items such that the matrix values are predominantly
  positive.
]
@fig:dataset-full-subset-var displays the contemporaneous and temporal networks for the
filtered set of 17 candidate variables, with rows and columns ordered using hierarchical
clustering on the temporal matrix to highlight groups of related items.#re-coded-footnote
Values with magnitude less than 0.05 are excluded, as is the (symmetric) upper triangle
of the contemporaneous network. The values in each row of the temporal matrix are the
regression predictors for that row's variable. Therefore, we interpret row $i$ as
describing the variables which _influence_ item $i$, and column $i$ as describing the
variables which are influenced _by_ item $i$.

#figure(
  image("../results/figures/dataset/full_subset_var.pdf"),
  caption: caption(
    short: [Pairwise vector autoregression: full subset],
    long: [
      Contemporaneous (left) and temporal (right) network matrices for the filtered
      candidate set. Entries in row $i$ of the temporal matrix are
      the regression predictors for the subsequent value of variable $X_i$. Rows and
      columns are ordered using hierarchical clustering on the temporal matrix:
      $d_bold(K) (X,Y) = 1 - abs(bold(K))$.
    ],
  ),
  placement: auto,
) <fig:dataset-full-subset-var>

We note three apparent clusters of variables: (i) political views, (ii) beliefs about
climate change impacts, and (iii) positions on climate policy, and other beliefs
relating to climate action. In the first case, political affiliation (partisan identity)
and ideology (conservative $<-->$ liberal) cluster together in both networks, yet
appear to have minimal external associations. We retain this group on theoretical
grounds, since political beliefs are often key determinants for climate-related
beliefs and policy positions @palmWhatCausesPeople2017 @bumannWhatAreDeterminants2021.
Secondly, beliefs regarding the impact of climate change on different population groups
(`CC Impact X`) exhibit strong internal contemporaneous associations but relatively
weak internal temporal associations. Here, we choose to combine these into an index
variable. However, an alternative strategy would be to retain only `CC Impact (World)`
and/or `CC Impact (Wealthy)`, noting that these variables each have several (and
distinct) temporal associations. Finally, the right-most six variables form clear
clusters in both networks. Four of these relate directly to climate policy, while the
remaining two assess participants' views on the importance of individual action in
managing climate change and the role of scientists in guiding the climate change
response. We combine these into a third cluster, which we interpret as reflecting an
individual's general attitude toward climate action.

#figure(
  image("../results/figures/dataset/marginal_distributions.pdf"),
  caption: caption(
    short: [Climate beliefs dataset marginal distributions],
    long: [
      Marginal distribution for each of the eight variables in the climate beliefs
      dataset (@tab:climate-beliefs-dataset-items).
    ],
  ),
  placement: auto,
) <fig:dataset-marginal-distributions>

We construct the index variables by first rescaling each constituent item to the
interval $[-1, 1]$ and then averaging them. All other variables are also rescaled
in the same way. The final dataset comprises eight variables, described in
@tab:climate-beliefs-dataset-items. Figures @fig:dataset-marginal-distributions[] and
@fig:dataset-reduced-var[] show the marginal distributions and the contemporaneous and
temporal networks, respectively, for the climate beliefs dataset.

#figure(
  image("../results/figures/dataset/reduced_subset_var.pdf"),
  caption: caption(
    short: [Temporal network: reduced dataset],
    long: [
      Contemporaneous and temporal network matrices for the climate beliefs dataset.
      Entries in row $i$ of the temporal matrix are
      the regression predictors for the subsequent value of variable $X_i$. Rows and
      columns are ordered using hierarchical clustering on the temporal matrix:
      $d_bold(K) (X,Y) = 1 - abs(bold(K))$.
    ],
  ),
  placement: auto,
) <fig:dataset-reduced-var>

#let climate-beliefs-variable-table = {
  show table: set text(size: 9.25pt)
  table(
    columns: 3,
    stroke: none,
    align: (left, center, left),
    table.header[Item][Index][Interpretation],
    table.hline(stroke: 0.5pt),
    [CC Real], [No], [Belief that climate change is/is not real.],

    [CC Human],
    [No],
    [Belief that climate is/is not caused (at least partly) by human activities.],

    [CC Worry],
    [No],
    [Level of worry about current and future climate change.],

    [CC Others Worry],
    [No],
    [Belief regarding _others'_ level of worry about current/future climate change.],

    [Weather Worry],
    [No],
    [Level of worry about near-term extreme weather events/natural disasters.],

    [Politics],
    [Yes],
    [Political views, a combination of political alignment and ideology.],

    [CC Impact],
    [Yes],
    [Belief about current climate change impacts' severity, in general.],

    [CC Action],
    [Yes],
    [General attitude toward action on climate change.],
  )
}

#figure(
  climate-beliefs-variable-table,
  gap: 1em,
  caption: caption(
    short: [Climate beliefs dataset variables],
    long: [
      Variables included in the climate beliefs dataset. Index variables are constructed
      by taking rescaling each constituent column to the interval $[-1, 1]$ and then
      averaging them.
    ],
  ),
) <tab:climate-beliefs-dataset-items>












// In light of the complexities and breadth of content of the CCCV, we
// construct a smaller, targeted dataset of beliefs and attitudes relating to climate
// change, which we expect -- on theoretical grounds -- to exhibit interdependent
// behaviour. We will refer to this targeted dataset as the *climate beliefs dataset*.
// The primary motivator for constructing this dataset is the calibration of the
// non-equilibrium belief system model (@subsec:methods-parameter-estimation).
//
// We aim for 7--10 variables in the final set, so as to keep both the number of model
// parameters and parameter uncertainty sufficiently small. We first filter the survey
// items to consider only those which assess cognitive states (e.g., beliefs, attitudes,
// opinions, stances). We further restrict our attention to items which either relate
// directly to climate change, or which are expected to influence climate-related
// cognitive states (e.g., political alignment).
//
// Within this restricted set of survey items our intention is to select a collection
// of variables which: (i) exhibit related behaviour, (ii) maximise the number of
// observations, and (iii) satisfy the requirements of the parameter estimation method
// used for model calibration. We will discuss the latter two requirements now, and return
// to the first shortly. We require at least two waves of responses from each participant,
// as the model is defined by a time-dependent Markov process, and thus parameter
// estimation involves fitting a conditional probability distribution where each
// belief state depends on the previous one. Moreover, each participant's responses should
// be equispaced, with spacing being consistent across individuals, and the dataset must
// contain no missing values. In addition to these requirements, we prioritise including
// several variables of interest:
//
// + *CC Worry*: Concern about current and future climate change
// + *CC Others Worry*: Belief regarding _others'_ level of worry about
//   climate change
// + *CC Human*: Belief that climate change is caused by human activities
//
// The first is generally considered influential in shifting related attitudes, while
// the second is expected to be influential on the first, as a perceived descriptive norm.
// Finally, while most inividuals in the USA believe in the _existence_ of climate change,
// there is relatively greater variation in beliefs about it's _causes_. Hence the third
// item is an interesting target for intervention studies. (*TODO*)

// Given the above requirements and the objective to maximise the number of observations,
// we identify Waves 3 & 4 as suitable candidates. These waves include 1693 repeat
// observations (excluding survey errors as described in the previous subsection). After
// removing items with no substantial correlations, and small groups of items which exhibit
// only internal correlations, we identify 17 relevant survey items, comprising both
// beliefs (epistemic positions, @tab:dataset-dataset-beliefs) and attitudes (qualitative
// evaluations, @tab:dataset-dataset-attitudes).

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


//#show table.cell.where(y: 0): set text(weight: "bold")
// #figure(
//   {
//     set text(size: 9pt)
//     table(
//       columns: 3,
//       align: (right, left, left),
//       table.header[Item][Question text][Response schema],
//       [CC Real], [Do you think that climate change is happening?], [#list[Yes][No][Don't know]],
//
//       [CC Human (\*)],
//       [Do you think rising temperatures are a result of human activities, natural causes, or both?],
//       [#list[Not happening][Natural causes][Human activities][Both]],
//
//       [CC Impact (world)],
//       [How much do you think climate change is currently harming the world in general?],
//       [#list[Not at all][Only a little][A moderate amount][A great deal]],
//
//       [CC Impact (wealthy)],
//       [How much do you think climate change is currently harming wealthy communities within the United States?],
//       [#list[Not at all][Only a little][A moderate amount][A great deal]],
//
//       [CC Impact (poor)],
//       [How much do you think climate change is currently harming poor communities within the United States?],
//       [#list[Not at all][Only a little][A moderate amount][A great deal]],
//
//       [CC Impact (comm)],
//       [How much do you think climate change is currently harming your local community?],
//       [#list[Not at all][Only a little][A moderate amount][A great deal]],
//
//       [CC Others Worry],
//       [How worried do you think most Americans are about global warming/climate change these days?],
//       [#list[Not at all worried][Not very worried][Somewhat worried][Very worried]],
//     )
//   },
//   caption: caption(
//     short: [],
//     long: [
//       \* Re-mapped to: includes/does not include human activities
//     ],
//   ),
// ) <tab:dataset-dataset-beliefs>
//
// #figure(
//   {
//     set text(size: 9pt)
//     table(
//       columns: 3,
//       align: (right, left, left),
//       table.header[Item][Question text][Response schema],
//       [CC Worry],
//       [How worried are you about current and future global warming/climate change?],
//       [#list[Not at all worried][Not very worried][Somewhat worried][Very worried]],
//
//       [Weather Worry],
//       [How worried are you about an extreme weather event or natural disaster happening to you personally in the next year?],
//       [#list[Not at all][Only a little][A moderate amount][A great deal]],
//
//       [CC Responsibility],
//       [It is important that individuals take action on issues of climate change.],
//       [5-point Likert agreement scale],
//
//       [CC Scientists],
//       [Scientists with appropriate expertise should guide how we respond to climate change],
//       [5-point Likert agreement scale],
//
//       [Policy: ICA (\*)],
//       [Do you favour an international agreement committing the USA and other countries to reduce their carbon emissions?],
//       [#list[Yes and legally binding)][Yes but _not_ legally binding)][No]],
//
//       [Policy: Tax fuel],
//       [How much do you support/oppose a tax on the production/distribution of carbon-based fuelds?],
//       [5-point Likert support scale],
//
//       [Policy: Auto],
//       [How much do you support/oppose stronger carbon emissions standard for car manufacturers?],
//       [5-point Likert support scale],
//
//       [Policy: Env. Reg.],
//       [Which statement comes closer to your views?],
//       [#list[Stricter environmental regulations cost too many jobs and hurt the economy][Stricter environmental regulations are worth the cost]],
//
//       [Political affiliation (\*\*)],
//       [In politics today, do you consider yourself a:],
//       [#list[Republican][Leaning Republican][Independent][Leaning Democrat][Democrat]],
//
//       [Political ideology],
//       [What is your political ideology?],
//       [#list[Very conservative][Conservative][Moderate][Liberal][Very liberal]],
//     )
//   },
//   caption: caption(
//     short: [],
//     long: [
//       \* Re-mapped to: Yes/No
//
//       \*\* Constructed from separate items for identification and leaning
//     ],
//   ),
// ) <tab:dataset-dataset-attitudes>

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

// To reduce the set of candidate variables to the target range of 7--10, we proceed to
// identify groups of similar or redundant variables which may be removed or combined into
// interpretable index variables. We use two primary measures to investigate similarity:
// pairwise partial correlation, and vector autoregression
// @epskampPersonalizedNetworkModeling2018   @epskampGaussianGraphicalModel2018.
//
// Partial correlation measures the correlation between a pair of variables $X$ and $Y$
// after conditioning on all remaining variables $Z$:
//
// $
//   rho(X, Y) = op("Corr")(X,Y | Z)
// $ <eqn:dataset-partial-correlation>
//
// In particular, $|rho(X, Y)|$ is non-zero if $X$ and $Y$ exhibit _linear_
// correlation which is not shared with the remaining variables in $Z$. For instance,
// consider the fork structure $X <- A -> Y$ where $X$ and $Y$ are probabilistic linear
// functions of $A$. If the value of $A$ is unknown, then $X$ and $Y$ are dependent.
// However, once $A$ is known, the dependency structure is broken. Thus $op("Corr")(X,Y)$
// is nonzero, while $rho(X, Y) = 0$.
//
// @fig:dataset-full-subset-partial-correlations displays the pairwise partial correlation
// between each pair of variables in the filtered set. Note that we have coded all
// variables such that the partial correlation matrix entries are predominantly positive.
// Cells with magnitude below $0.05$ have been masked for visual clarity. Rows and columns
// are ordered using hierarchical clustering.
//
// #figure(
//   image("../results/figures/dataset/full_subset_partial_corr.pdf"),
//   caption: caption(
//     short: [Pairwise partial correlation: full subset],
//     long: [
//       Pairwise partial correlation for the filtered candidate set
//       . Cells with
//       $|rho(X, Y)| < 0.05$ are masked for visual clarity. Rows and columns are
//       ordered using hierarchical clustering over the distance
//       matrix: $d_rho (X,Y) = 1 - |rho(X, Y)|$.
//     ],
//   ),
//   placement: auto,
// ) <fig:dataset-full-subset-partial-correlations>
//
// Partial correlations are limited, however, in that they capture only instantaneous
// (or 'contemporaneous') relations between variables, while the non-equilibrium belief
// system model is concerned with temporal relationships. Therefore we also examine the
// temporal and contemporaneous networks obtained using vector autoregression (VAR)
// with a #box[$delta t = 1$] time lag @brandtMultipleTimeSeries2007. These networks are derived
// from the solution to the following regression problem, described in
// #cite(<epskampGaussianGraphicalModel2018>, form: "prose"):
//
// $
//   bold(y)^t & = bold(B)bold(y)^(t-1) + epsilon^(t) \
//   epsilon^t & ~ cal(N)(bold(0), bold(Theta))
// $ //<eqn:dataset-var-regression-problem>
//
// Where $bold(y)^t$ is the vector of observed variable values for each individual at time
// $t$. The _temporal network_ matrix $bold(B)$ comprises linear next-state predictors, while
// the _contemporaneous network_ matrix $bold(K) = Theta^(-1)$ describes the pairwise
// conditional correlations which remain after accounting for temporal effects. The
// entries of $bold(K)$ are analogous to partial correlations, constituting the conditional
// correlation between $X$ and $Y$ given the remaining variables.
//
// @fig:dataset-full-subset-var shows the contemporaneous and temporal network matrices
// for the filtered set of candidate variables. The contemporaneous matrix is symmetric,
// thus the upper triangle is not shown.
//
// #figure(
//   image("../results/figures/dataset/full_subset_var.pdf"),
//   caption: caption(
//     short: [Pairwise vector autoregression: full subset],
//     long: [
//       Contemporaneous (left) and temporal (right) network matrices for the filtered
//       candidate set. Entries in row $i$ of the temporal matrix are
//       the regression predictors for the subsequent value of variable $X_i$. Rows and
//       columns are ordered using hierarchical clustering on the distance matrix:
//       $d_bold(K) (X,Y) = 1 - abs(bold(K))$.
//     ],
//   ),
//   placement: auto,
// ) //<fig:dataset-full-subset-var>

// We observe some apparent commonalities between the partial correlation and VAR
// networks. First, the _CC Impact_ variables exhibit relatively strong
// internal relations. External relations with variables outside this set are
// typically weaker, with the exception of _CC Impact (world)_, which has several
// non-trivial partial correlations with other variables, including other climate-related
// beliefs. All variables in this group, except _CC Impact (wealthy)_, also have
// non-trivial partial correlations with _CC Worry_ --- one of our
// variables-of-interest. Second, the policy variables, as well as _CC Responsibility_
// and _CC Scientists_, also exhibit substantial connectivity in the partial correlation
// network. This is diminished in the contemporaneous VAR network, but visible in the
// clustering of the temporal network. The similarities among these variables in the
// rows and columns of the temporal matrix indicate that they fill similar roles as
// predictors, and are also predicted similarly. Thirdly, _Political affiliation_ and
// _Political ideology_ are highly related in the partial correlation matrix, and
// also exhibit similar behaviour in the temporal network.

// *TODO:* PCA/EFA plot.

// Based on these observations, we construct three index variables: (i) _CC Impact_,
// comprising the four climate impact beliefs, (ii) _Politics_, comprising the measures
// of political affiliation and ideology, and (iii) _CC Action_, comprising the four
// policy variables, as well as _CC Responsibility_ and _CC Scientists_.


// #figure(
//   image("../results/figures/dataset/reduced_subset_partial_corr.pdf"),
//   caption: caption(
//     short: [Pairwise partial correlation: reduced dataset],
//     long: [*TODO*],
//   ),
//   placement: auto,
// )




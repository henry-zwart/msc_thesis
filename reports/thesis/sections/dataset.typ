
- Longitudinal survey overview
- Question selection
- Cleaning and transformation
- Validation
- Imputation

== Longitudinal climate attitudes survey

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

*Introduce the survey:*
- Motivate it: This is the main resource used to construct our dataset.
- Description:
  - Content: What sorts of questions? (Examples)
  - Waves: how many, when were they run? (Participation event plot)
  - Participation: counts, variability. (Statistics: how many people answered all waves? How many singletons?)
  - Question variability. (...?)
- Overlap with notable events:
  - COVID-19 outbreaks
  - US electoral cycle
  - Major weather events

The longitudinal study (*CITE*) comprises six waves of responses from individuals
residing in the United States, collected between
#survey_start_date.display("[month repr:long] [year]") and
#survey_end_date.display("[month repr:long] [year]"). The assessed dimensions include
general demographic information (e.g., age, gender, education, and financial status),
beliefs, attitudes, and experiences relating to concurrently-salient topics such as
COVID-19, climate change, or the 2020 US presidential election, and support for
hypothetical policies.

- Significance of longitudinal data --- most studies use cross-sectional data which
  has limited interpretability at individual level.

*Survey content; nature of the questions asked*
- Context
- Category (belief, attitude, demographic, etc.)
- Response formats
The survey content varies between waves, and between participants.

*Participation*

*Waves*
The survey waves occur with irregular spacing and duration, as illustrated in
@fig:dataset-longitudinal-response-eventplot. Some consecutive pairs of waves are much
closer than others. For instance, the joined interval spanned by the first three
waves has a longer duration than the interval between Waves 5 and 6, and the duration
spanned by Wave 4 exceeds that of the joined interval comprising Waves 1 and 2.

The 2020 US Presidential Election date occurred during Wave 3. This wave was modified
for responses started after the election date; future-focused survey questions regarding
individuals' voting intentions, beliefs, and attitudes concerning the election were
removed.

#figure(
  image("../results/figures/dataset/response_eventplot.pdf"),
  placement: top,
  caption: [Longitudinal survey response dates per-wave.],
) <fig:dataset-longitudinal-response-eventplot>

#figure(
  image("../results/figures/dataset/interresponse_times.pdf"),
  placement: top,
  caption: [Distribution of inter-response times across individuals.],
) <fig:dataset-longitudinal-interresponse-times>



- Context of the survey:
  - Time-span
  - Wave timing/duration
  - Overlap with COVID-19 outbreaks and US electoral cycle, major weather events
- Codebook covers first five waves
- Nature of the questions asked:
- Variability in questions (between waves, participants)

== Question selection
- Motivation (identify measures of distinct beliefs and attitudes regarding climate change -- impacts, risks, policies, etc.)
- Criteria for selecting questions
- Exclude sixth wave due to no codebook

== Validation
- Only validate selected questions
- Validation components:
  - Schema (Pandera)
  - Null responses iff null expected
  - Valid survey responses
  - Miscellaneous inconsistencies
    - Born in US in some waves, not in others
    - Changing responses to extreme weather experience in last 10 years
- Results:
  - Schema good
  - Various issues with Null responses:
    - Some due to survey logic errors
    - Some not explained

== Normalisation, cleaning, and transformations

- Variable names (replace '.' with double underscore)
- Filter out participants with:
  - Null `participant_id`
  - Survey errors (from validation above)
  - Failed survey validation checks (if any check is failed, participant is removed entirely)
- Response type/value conversions
  - Non-float numeric variables to Int64
  - Re-map $1..=k$ variables to ($0..=k-1$)
  - Replace empty string entries with `Null`
  - Multiple choice questions: comma-separated string of integers to list of integers/enums
  - Replace categorical variable integer responses with enums (for human-readability and to ensure value consistency across waves)
  - `cc2`: Re-order such that human-causes are 'high values' and natural-causes/no climate change are 'low values'
- Coalescing treatment columns:
  - Responses stored in one column
  - Separate index column specifies treatment group membership
  - Optional third column for treatment-specific numeric parameters (e.g., policy cost)
- Constructed columns:
  - Merge `pol_party` and `pol_lean` to create five-point `pol_affiliation` scale. Note that this does not capture individuals who 'lean _right_ toward Democrat' for example.


== Missing-wave imputation
- Survey responses as Markov processes
- Viterbi imputation:
  - Maximum likelihood estimation based on transition matrix
  - Independence assumption (assumes variables are independent in missing waves), can only reduce measured dependence between variables.
    - Maybe I can give an info theory proof of this?
  - Allows us to consider questions which are not always asked in same waves.
- Evaluation:
  - Look at imputation impacts on manually degraded dataset, perhaps from COVID questions (which I'm not using, but which are analogous to
    some of our key questions).
  - How is the direct performance on individual variables? How does it degrade with the number of imputed waves, or with the locations of the
    non-null waves?
  - How does dependence/correlation between related variables degrade as we increase the number of imputation waves?

== Data Validation
The complexity of the climate attitudes survey (*reference section discussing this*)
necessitates a rigorous approach to data validation, both to identify errors in the
expected schema and to ensure that the data matches our expectations.

We have implemented a general validation pipeline comprising three stages:

+ *Type-level validation:* The set of columns is exactly as expected, and all columns
  have the correct data type.

+ *Response-value validation:* All _non-null_ responses are valid according to the
  schema specified in the codebook.

+ *Null-value validation:* Responses are null if, and only if, we expect them to be
  null.


In the first instance, type-level validation ensures that the _observed_ data schema
matches the _prescribed_ schema. Since response data types vary between questions
according to the question type (see @tab:dataset-types), the type-checking must be
flexible and capable of handling complex data types.

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
  placement: bottom,
  caption: [*TODO*],
) <tab:dataset-types>


For instance, categorical multiple-choice responses are represented using a
```python list[Enum]```, where ```python Enum``` is a question-specific enum-type
#footnote[An enum is a type defined by a finite set of allowable values. In our case
  the values are human-readable strings. For instance, the `dem_urban` survey question,
  which asks 'What kind of area do you live in?' has responses with data type described
  by the enum ${"Urban", "Suburban", "Rural"}$.
]. Type validation for a multiple-choice question thus requires checking that the
response column comprises ```python list```'s whose elements are all from the
set of values defined by the ```python Enum```.

Response-value validation then ensures that all non-null responses are valid according
to the set of allowable values described in the survey codebook. For most variables
this is straightforward. Numeric and single-response ordinal variables typically have
a defined range (e.g., $18 <= "age" <= 99$, or $1 <= x <= 5$ for a 5-point Likert scale
variable). Text-entry responses are always considered valid.

Single-response categorical questions have ```python Enum``` type, so type-level
validation is sufficient to ensure that the responses do not contain any values outside
the set defined by the ```python Enum```. However, the allowable values occasionally
change between survey waves. Hence response-value validation is also required for
categorical single-response and multiple-response variables, and in general must
handle with schema variation between waves.

We implement both type-level and response-value validation using the
#link("https://pandera.readthedocs.io/en/latest/index.html")[Pandera] Python
library for DataFrame validation @bantilanUnionaiossPanderaBeta2022. The Pandera
API allows for straightforward schema specification using Python type annotations
(for type-level validation) in combination with value constraints (for response-level
validation). We implement a separate validation check for questions whose response
schema varies between survey waves, using a Pandera 'dataframe check' to stratify
validation by wave.

Null-value validation ensures that responses are null if, and only if, they are expected
to be null. For a question $Q$, the response of a participant $P$ in wave $W$ can be
null for one of four reasons:

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
$

We split this up into:
If not in wave, then $R$ is null.
$
  ("N1" or "N2") arrow.double.long nullop(R)
$

If conditions not met, then $R$ is null.
$
  ("N3" or "N4") arrow.long.double nullop(R)
$

For unconditional columns, if shown, then not null:
$
  not ("N1" or "N2") arrow.long.double not nullop(R)
$

For conditional columns, if shown, then not null:
$
  not ("N1" or "N2" or "N3" or "N4") arrow.long.double not nullop(R)
$

For a conditional $A arrow.double.long B$, let $bold(R)$ be the subset of responses
for which the contradiction $not (A arrow.double.long B) equiv (A and not B)$ is true.
Then $A arrow.double.long B$ is satisfied if, and only if, $bold(R)$ is empty *check this --- is it iff, if, or only if?*. If
$bold(R)$ is non-empty, then the contained responses are counter-examples to the
conditional.


- Single-response ordinal:
In the first case, type-level validation ensures that the data schema matches
expectations, independently of the response values.
In the first case, type-level validation ensures that the schema observed in the dataset
matches the schema
Type-level validation
Our validation pipeline comprises three stages:


The first two stages are handled by Pandera, and the third is manually implemented.

- What does type-level validation consist in?
  - Simple types
  - Enums
  - Lists of enums
- What does response value validation consist in?
  - Checking that observed (non-null) values are within the set of allowable values
- What does null-value validation consist in?
  - ...

The data schema defines everything that is necessary. Maybe we can discuss this
separately as an implementation step.

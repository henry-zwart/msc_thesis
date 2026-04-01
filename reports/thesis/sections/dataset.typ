
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
  caption: [Longitudinal survey response dates per-wave.]
) <fig:dataset-longitudinal-response-eventplot>

#figure(
  image("../results/figures/dataset/interresponse_times.pdf"), 
  placement: top,
  caption: [Distribution of inter-response times across individuals.]
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


import polars as pl

WAVES = [1, 2, 3, 4, 5]

US_STATES = [
    ("Alabama", "AL"),
    ("Alaska", "AK"),
    ("Arizona", "AZ"),
    ("Arkansas", "AR"),
    ("American Samoa", "AS"),
    ("California", "CA"),
    ("Colorado", "CO"),
    ("Connecticut", "CT"),
    ("Delaware", "DE"),
    ("District of Columbia", "DC"),
    ("Florida", "FL"),
    ("Georgia", "GA"),
    ("Guam", "GU"),
    ("Hawaii", "HI"),
    ("Idaho", "ID"),
    ("Illinois", "IL"),
    ("Indiana", "IN"),
    ("Iowa", "IA"),
    ("Kansas", "KS"),
    ("Kentucky", "KY"),
    ("Louisiana", "LA"),
    ("Maine", "ME"),
    ("Maryland", "MD"),
    ("Massachusetts", "MA"),
    ("Michigan", "MI"),
    ("Minnesota", "MN"),
    ("Mississippi", "MS"),
    ("Missouri", "MO"),
    ("Montana", "MT"),
    ("Nebraska", "NE"),
    ("Nevada", "NV"),
    ("New Hampshire", "NH"),
    ("New Jersey", "NJ"),
    ("New Mexico", "NM"),
    ("New York", "NY"),
    ("North Carolina", "NC"),
    ("North Dakota", "ND"),
    ("Northern Mariana Islands", "MP"),
    ("Ohio", "OH"),
    ("Oklahoma", "OK"),
    ("Oregon", "OR"),
    ("Pennsylvania", "PA"),
    ("Puerto Rico", "PR"),
    ("Rhode Island", "RI"),
    ("South Carolina", "SC"),
    ("South Dakota", "SD"),
    ("Tennessee", "TN"),
    ("Texas", "TX"),
    ("Trust Territories", "TT"),
    ("Utah", "UT"),
    ("Vermont", "VT"),
    ("Virginia", "VA"),
    ("Virgin Islands", "VI"),
    ("Washington", "WA"),
    ("West Virginia", "WV"),
    ("Wisconsin", "WI"),
    ("Wyoming", "WY"),
]

ItemCategory = pl.Enum(
    [
        "demographic",
        "belief",
        "knowledge",
        "attitude",
        "experience",
        "behaviour",
        "intention",
        "behavioural-cause",
        "policy-support",
        "valid",
    ]
)

StateAbbrev = pl.Enum([abbrev for _, abbrev in US_STATES])

StateName = pl.Enum([name for name, _ in US_STATES])

Education = pl.Enum(
    [
        "Less than or up to 12th grade but no diploma",
        "High school diploma or the equivalent",
        "Some college but no degree",
        "Associate degree (2-year)",
        "Bachelor's degree (4-year)",
        "Advanced degree (Master's, Professional School, Doctorate)",
    ]
)

Gender = pl.Enum(
    [
        "Female",
        "Male",
        "Prefer to self describe",
    ]
)

ResponseType = pl.Enum(
    [
        "Single response",
        "Multiple response",
        "Dropdown",
        "Text",
        "Slider",
        "Numeric",
        "Drag and drop (in order)",
    ]
)

ParticipantType = pl.Enum(["new", "repeating"])

UrbanArea = pl.Enum(["Urban", "Surburban", "Rural"])

GroupCCGlobalResponse = pl.Enum(["ccIO", "ccGovt", "ccIOinterest", "ccGovtinterest"])

GroupCleanAir = pl.Enum(
    [
        "Climate change (control)",
        "Climate change (Democrat)",
        "Climate change (Republican)",
        "Health (control)",
        "Health (Democrat)",
        "Health (Republican)",
    ]
)

GroupPolVoteSupport = pl.Enum(
    [
        "COVID (Democrat)",
        "Climate (Democrat)",
        "COVID (Republican)",
        "Climate (Republican)",
    ]
)

NaturalDisaster = pl.Enum(
    [
        "None of the above",
        "Severe winter storm",
        "Hurricane",
        "Tornado",
        "Heat wave",
        "Flood",
        "Wildfires",
        "Drought",
        "Earthquake",
        "Other unusual weather or natural disaster (text entry)",
        "Wind storm or derecho",
    ]
)

# attr_storm
StormAttribution = pl.Enum(
    [
        "Human-caused global warming or climate change",
        "Natural variation in weather patterns",
        "God or divine intervention",
        "I don’t know the cause",
        "I don’t know about this event",
        "Other (text entry)",
    ]
)

# attr_outage
OutageAttribution = pl.Enum(
    [
        "Failures at coal and natural gas plants",
        "Failures at wind turbines",
        "Deregulation of the energy sector",
        "Bad oversight by the governor",
        "Too much involvement by federal government",
        "Bad management by ERCOT, the state energy regulator",
        "God or divine intervention",
        "Human-caused global warming or climate change",
        "Natural variation in weather patterns ",
        "I don’t know the cause ",
        "I don’t know about this event ",
        "Other (text entry)",
    ]
)

# cc2
ClimateChangeCause = pl.Enum(
    [
        "Not happening",
        "Natural causes",
        "Human activities",
        "Both",
    ]
)

# cc13
ClimateChangeInducedAction = pl.Enum(
    [
        "None of the above",
        "Move to a different area",
        "Buy an energy generator (diesel or gas)",
        "Buy or lease an electric vehicle",
        "Buy rooftop solar panels and/or battery storage",
        "Invest in renewable energy through community solar or energy utility",
        "Use public transportation more",
        "Eat less or no meat",
        "Fly less",
        "Help others with deliveries, gifts of food, or other acts during/after disasters",
        "Send messages to members of your religious or social organization (including social media) about global warming/climate change",
        "Send messages to public officials or sign online petitions about global warming/climate change",
        "Give money to charitable/environmental organizations",
        "Reduce your energy use",
        "Support a political candidate or politician (e.g. donate, make calls, etc.)",
    ]
)

# cc_policybenefit
ClimatePolicyBenefit = pl.Enum(
    [
        "None will benefit me or my loved ones",
        "Subsidies for the renewable energy sector (solar, wind, hydro power)",
        "Funding for public transportation infrastructure",
        "Funding for restoration of existing ecosystems",
        "Subsidies for carbon sequestration (carbon capture & storage) development and implementation",
        "Funding for people to fortify property/belongings against extreme weather events",
        "Funding for people to relocate away from areas that experience extreme weather events",
        "Funding to assist people purchasing electric vehicles or electrifying their homes",
        "Tax or fee on the production or distribution of fossil fuels",
        "Stronger emissions standards for power plants, vehicles, and other industries",
        "Stronger extreme weather risk disclosure standards for properties",
        "Limitations on development in areas that experience repeated extreme weather events",
        "Strict regulation of political donations and lobbying",
    ]
)

# cvcc8a__opp
ReasonOpposeGreenInfra = pl.Enum(
    [
        "This is not the role of government",
        "It will cost too much money",
        "It is not an effective tool to fight the current economic problems",
        "It doesn't go far enough in addressing existing social issues",
        "Addressing environmental issues should not be the focus of a stimulus plan right now",
        "Other (text entry)",
    ]
)

# cvcc8a__supp
ReasonSupportGreenInfra = pl.Enum(
    [
        "The scale of the economic crisis demands bold government action",
        "The scale of the environmental crisis demands bold government action",
        "The costs of a large-scale program will be outweighed by the long-term economic benefits",
        "The focus of government efforts should be on creating new green jobs, not bailing out large polluters such as airlines and oil companies",
        "This crisis has revealed unequal access to resources such as high-speed internet in rural and low-income communities that the government should address",
        "The government should help marginalized communities that are also most vulnerable to the effects of climate change",
        "This is a once-in-a-lifetime opportunity to put the country on the path to a carbon neutral future",
        "Other (text entry)",
    ]
)

# cvcc8b__opp
ReasonOpposeInfra = pl.Enum(
    [
        "This is not the role of government",
        "It will cost too much money",
        "It is not an effective tool to fight the current economic problems",
        "It doesn't go far enough in addressing social issues",
        "It doesn't go far enough in addressing environmental issues",
        "Other (text entry)",
    ]
)

# cvcc8b__supp
ReasonSupportInfra = pl.Enum(
    [
        "The scale of the economic crisis demands bold government action",
        "The costs of a large-scale program will be outweighed by the long-term economic benefits",
        "The focus of government efforts should be on creating new jobs, not bailing out large companies",
        "This crisis has revealed unequal access to resources such as high-speed internet in rural and low-income communities that the government should address",
        "This is a once-in-a-lifetime opportunity to transform the nation's infrastructure",
        "Other (text entry)",
    ]
)

# cv__priority, cv__priority2
CovidPolicyFlowonPriority = pl.Enum(
    [
        "None",
        "Global warming/Climate change",
        "Racial discrimination",
        "Poverty and inequality",
        "Immigration",
        "Federal deficit",
        "Policy should focus on coronavirus, now is not the time to think about other issues",
        "Other policy (text entry)",
        "Healthcare",
        "Economy and employment",
    ]
)

# pol_party
PoliticalParty = pl.Enum(["Republican", "Democrat", "Independent"])

# pol_lean
PoliticalLeaning = pl.Enum(["Leaning Republican", "Leaning Democrat", "Neither"])

# Constructed variable (using `PoliticalParty` and `PoliticalLeaning`)
PoliticalAffiliation = pl.Enum(
    ["Republican", "Leaning Republican", "Independent", "Leaning Democrat", "Democrat"]
)

# pol_ideology
PoliticalIdeology = pl.Enum(
    ["Very conservative", "Conservative", "Moderate", "Liberal", "Very liberal"]
)

President = pl.Enum(["Trump", "Biden"])

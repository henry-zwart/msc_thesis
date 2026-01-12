library(data.table)

# Load data
ca_dir <- "/data/climate-attitudes"
# ca_dir <- paste(Sys.getenv("ASSETS_DIR"), "climate-attitudes", sep="/")
load(paste(ca_dir, "w1w2w3w4w5_indices_weights_jul12_2022.Rdata", sep="/"))
load(paste(ca_dir, "w6_cleaned_weights_june12_2023.Rdata", sep="/"))

# Data from waves 1 -- 5 loads as 'df'
w1_to_w5 <- df

# Convert to data.table
setDF(w1_to_w5)
setDF(w6)

head(w6)

library(data.table)
library(arrow)

args <- commandArgs(trailingOnly = TRUE)

print(args)

# Load data
var_name <- load(args[1])

# Save as parquet
write_parquet(get(var_name), args[2])


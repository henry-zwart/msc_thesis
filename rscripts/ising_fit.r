library(arrow)
library(IsingFit)
library(data.table)

df = read_parquet("/data/climate-attitudes/reduced_no_imputation/indices.parquet")
setDT(df)

df[]

IsingFit(df)



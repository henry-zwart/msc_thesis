FROM rocker/r2u:24.04

RUN Rscript -e "Sys.setenv(ARROW_WITH_ZSTD = 'ON'); install.packages(c('dotenv', 'IsingFit', 'arrow'))"

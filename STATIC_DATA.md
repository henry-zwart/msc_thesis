# Constructed datasets

Manually constructed enrichments for climate attitudes data:

- `lee_2025_items.parquet`: Items from the climate attitudes survey which assess similar variables to 
    those studied in [Lee et al (2025)](https://www.nature.com/articles/s41558-025-02410-1). Contains 
    an `item_name` column which corresponds to the `Variable name` column in the codebook, and a separate
    boolean column for each of the eight concepts considered by Lee et al. A 'True' value indicates that 
    the survey item assesses the given concept. Items may be considered as assessing multiple concepts. 
    We exclude any rows with no 'True' values. Items were manually classified.

- `ideology_type.parquet`: Classifies climate attitude survey items related to political support as 
    'operationally' or 'symbolically' ideological, as per 
    [Brandt et al. (2019)](https://journals.sagepub.com/doi/10.1177/0146167218824354). Contains an 
    `item_name` column corresponding to `Variable name` in the codebook, and two boolean columns for 
    operational and symbolic components. Excludes any rows classified as neither. Items were manually 
    classified.

- `error_items.parquet`: Contains a single column, `item_name`, corresponding to `Variable name` in the 
    codebook. Listed items were subject to error of some kind during the survey. For details, refer to 
    the codebook.


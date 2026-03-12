# Include environment variables from .env if exists 
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Expand prerequisites twice, so that we capture the '%' in wildcards
.SECONDEXPANSION:

# Each recipe runs in a single shell.
.ONESHELL:

RUN_R := docker run -it --rm  -v $$(pwd):/code -v ${CA_RAW_ASSETS}:/raw-data -w /code msc-thesis-r:latest

REPORT_TYPES := proposal reading_summary climate-attitudes-eda
PRESENTATION_TYPES := project_plan  # collider-bias feb-echo-talk
REPORTS = \
		$(patsubst %,outputs/reports/%.pdf, $(REPORT_TYPES)) \
		$(patsubst %,outputs/slides/%.html, $(PRESENTATION_TYPES)) \
		$(patsubst %,outputs/slides/%.pdf, $(PRESENTATION_TYPES))

SITE_REPORT_TYPES := proposal thesis
SITE_PRESENTATION_TYPES := project_plan
SITE_REPORTS = \
		$(patsubst %,outputs/reports/%.pdf, $(SITE_REPORT_TYPES)) \
		$(patsubst %,outputs/slides/%.html, $(SITE_PRESENTATION_TYPES)) \
		$(patsubst %,outputs/slides/%.pdf, $(SITE_PRESENTATION_TYPES))


SITE_SOURCES = $(MKDOCS_CONFIG) $(wildcard site/**/*.md) $(wildcard site/*.md) \
          $(wildcard site/**/*.css) $(wildcard site/**/*.js)


QUARTO_REPORTS := \
		outputs/reports/index_eda_ds1_5/index_eda.html \
		outputs/reports/index_eda_ds1/index_eda.html \
		outputs/reports/index_eda_beliefs/index_eda.html \
		outputs/reports/index_eda_attitudes/index_eda.html

DATASETS := \
	    ${CA_BUILT_ASSETS}/base/metadata.json \
	    ${CA_BUILT_ASSETS}/ds1/metadata.json \
	    ${CA_BUILT_ASSETS}/ds1_5/metadata.json \
	    ${CA_BUILT_ASSETS}/beliefs/metadata.json \
	    ${CA_BUILT_ASSETS}/attitudes/metadata.json

.PHONY: clean serve data-assets quarto-reports all-reports

all: site/site/index.html all-reports quarto-reports

all-reports: $(REPORTS)

quarto-reports: $(QUARTO_REPORTS)

data-assets: $(DATASETS)

# Serve site locally
serve:
	uv run --only-group docs mkdocs serve -f site/mkdocs.yml

# Build site
site/site/index.html: $(SITE_REPORTS) $(SITE_SOURCES)
	@printf "Site    → Copying sources...\n"
	@for d in site/docs/reports site/docs/slides; do \
	  if [ -e "$d" ]; then \
	    printf "Site    → Error: $d already exists" >&2; \
	    exit 1; \
	  fi; \
	done
	@cp -r outputs/* site/docs
	@printf "Site    → Building site...\n"
	@uv run --only-group docs mkdocs build -f site/mkdocs.yml --quiet
	@printf "Site    → Done.\n"


# Compile project reports
outputs/reports/%.pdf: reports/%/main.typ \
			$$(wildcard reports/%/sections/*.typ) \
			| outputs/reports
	@printf "Compile → Report '$*'.\n"
	@$(MAKE) -C reports/$* && cp reports/$*/main.pdf $@

# Compile project presentations to PDF
outputs/slides/%.pdf: | outputs/slides
	@printf "Compile → Presentation '$*' to PDF.\n"
	@$(MAKE) -C presentations/$* main.pdf && cp presentations/$*/main.pdf $@

# Compile project presentations to HTML (for presenting)
outputs/slides/%.html: | outputs/slides
	@printf "Compile → Presentation '$*' to HTML.\n"
	@$(MAKE) -C presentations/$* main.html && cp presentations/$*/main.html $@


# == Create results and output directories
outputs/slides: | outputs
	@mkdir -p outputs/slides

outputs/reports: | outputs
	@mkdir -p outputs/reports

outputs:
	@mkdir -p outputs


outputs/reports/index_eda_%/index_eda.html: \
			reports/index-eda/index_eda.qmd \
			${CA_BUILT_ASSETS}/%/metadata.json \
			| outputs/reports
	@printf "Quarto  → Build 'index_eda_$*.html'...\n"
	@uv run quarto render $< \
			--execute-daemon-restart \
			--output-dir index_eda_$* \
			-P ds_name:$* && \
		printf "Quarto  → Removing old 'index_eda_$*.html'...\n"
		rm -rf $(@D) && \
		printf "Quarto  → Moving new 'index_eda_$*.html' to destination...\n"
		mv reports/index-eda/index_eda_$* $(@D)
		


# === Dataset construction ===
${CA_BUILT_ASSETS}/beliefs/metadata.json: \
			${CA_BUILT_ASSETS}/base/metadata.json \
			src/climate_attitudes/datasets/beliefs.py
	@printf "Dataset → Build beliefs dataset...\n"
	@uv run cadata create imputed-dataset --name beliefs --force

${CA_BUILT_ASSETS}/attitudes/metadata.json: \
			${CA_BUILT_ASSETS}/base/metadata.json \
			src/climate_attitudes/datasets/attitudes.py
	@printf "Dataset → Build attitudes dataset...\n"
	@uv run cadata create imputed-dataset --name attitudes --force

${CA_BUILT_ASSETS}/ds1_5/metadata.json: \
			${CA_BUILT_ASSETS}/base/metadata.json \
			src/climate_attitudes/datasets/imputed_reduced.py
	@printf "Dataset → Build reduced imputed dataset...\n"
	@uv run cadata create imputed-dataset --name ds1_5 --force


${CA_BUILT_ASSETS}/ds1/metadata.json: \
			${CA_BUILT_ASSETS}/base/metadata.json \
			src/climate_attitudes/datasets/imputed.py
	@printf "Dataset → Build imputed dataset...\n"
	@uv run cadata create imputed-dataset --name ds1 --force


${CA_BUILT_ASSETS}/base/metadata.json: \
			src/climate_attitudes/dataset.py \
			src/climate_attitudes/data_extract.py \
			src/climate_attitudes/schema/dataset.py \
			src/climate_attitudes/schema/extract.py \
			${CA_RAW_ASSETS}/w1w2w3w4w5_indices_weights_jul12_2022.parquet \
			${CA_RAW_ASSETS}/Codebook_220528.xlsx \
			${CA_STATIC_ASSETS}/item_columns.json \
			${CA_STATIC_ASSETS}/item_groups.csv \
			${CA_STATIC_ASSETS}/categories.csv \
			${CA_STATIC_ASSETS}/error_items.csv \
			${CA_STATIC_ASSETS}/variable_names.csv \
			${CA_STATIC_ASSETS}/ideology_type.csv \
			${CA_STATIC_ASSETS}/lee_2025_items.csv
	@printf "Dataset → Build base dataset...\n"
	@uv run cadata create base-dataset --prune-error-participants --filter-valid


# == Convert Rdata response files to parquet.
# WARNING: Takes ~12 minutes
#
# ${CA_RAW_ASSETS}/%.parquet: \
# 			rscripts/convert_rdata_to_parquet.r \
# 			${CA_RAW_ASSETS}/%.Rdata \
# 			.docker-r
# 	$(RUN_R) bash -c "Rscript $< /raw-data/$*.rdata /raw-data/$*.parquet"
#
# .docker-r: rscripts/Dockerfile
# 	docker build -t msc-thesis-r rscripts && touch $@

# Remove all generated files 
clean: 
	@rm -rf outputs
	@rm -rf site/site
	@$(MAKE) clean -C reports/proposal
	@$(MAKE) clean -C reports/reading_summary
	@$(MAKE) clean -C reports/climate-attitudes-eda
	@$(MAKE) clean -C presentations/project_plan


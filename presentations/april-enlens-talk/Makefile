APRIL_ENLENS_DIR := presentations/april-enlens-talk
APRIL_ENLENS_FIGURES := $(APRIL_ENLENS_DIR)/figures/partial-correlation-network.pdf 
APRIL_ENLENS_REPORT_FILES := $(APRIL_ENLENS_DIR)/main.typ $(APRIL_ENLENS_FIGURES)

#all: $(APRIL_ENLENS_DIR)/main.html $(APRIL_ENLENS_DIR)/main.pdf

# ==== Report
$(APRIL_ENLENS_DIR)/main.pdf: $(APRIL_ENLENS_REPORT_FILES)
	@printf "Compile → Presentation 'April ENLENS talk' to PDF.\n"
	@uvx touying compile $< \
		--format pdf \
		--silent 1 \
		--sys-inputs '{"handout":"true"}'		# Collapse slide animations for PDF

$(APRIL_ENLENS_DIR)/main.html: $(APRIL_ENLENS_REPORT_FILES)
	@printf "Compile → Presentation 'April ENLENS talk' to HTML.\n"
	@uvx touying compile $< --format html --silent 1

$(APRIL_ENLENS_DIR)/figures/partial-correlation-network.pdf: \
			$(APRIL_ENLENS_DIR)/scripts/correlation_network.py \
			${CA_BUILT_ASSETS}/reduced_no_imputation/metadata.json
	@printf "Generate figures → April ENLENS talk: Partial correlation network.\n"
	@uv run $<


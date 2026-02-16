COMPILE_ARGS ?= --root "$$(pwd)" 

.PHONY: clean preview

REPORT_FILES = main.typ figures/lee_correlations.pdf figures/lee_transitions.pdf figures/all_corr.pdf

all: main.html main.pdf

# ==== Report
main.pdf: $(REPORT_FILES)
	@uvx touying compile $< \
		--format pdf \
		--silent 1 \
		--sys-inputs '{"handout":"true"}'		# Collapse slide animations for PDF

main.html: $(REPORT_FILES)
	@uvx touying compile $< --format html --silent 1

figures/lee_correlations.pdf: scripts/lee_correlations.py
	@uv run $<


figures/lee_transitions.pdf: scripts/lee_response_transitions.py
	@uv run $<


figures/all_corr.pdf: scripts/all_corr.py
	@uv run $<


clean:
	rm main.html main.pdf


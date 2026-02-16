COMPILE_ARGS ?= --root "$$(pwd)" 

.PHONY: clean preview

REPORT_FILES = main.typ figures/salsa_collider.pdf figures/cc_collider_biased.pdf

all: main.html main.pdf

# ==== Report
main.pdf: $(REPORT_FILES)
	@uvx touying compile $< \
		--format pdf \
		--silent 1 \
		--sys-inputs '{"handout":"true"}'		# Collapse slide animations for PDF

main.html: $(REPORT_FILES)
	@uvx touying compile $< --format html --silent 1

figures/salsa_collider.pdf: scripts/salsa_collider.py
	@uv run $<

figures/cc_collider_biased.pdf: scripts/cc_collider.py
	@uv run $<

clean:
	rm main.html main.pdf


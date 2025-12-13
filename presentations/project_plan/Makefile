COMPILE_ARGS ?= --root "$$(pwd)" 

.PHONY: clean preview

REPORT_FILES = main.typ

all: main.html main.pdf

# ==== Report
main.pdf: $(REPORT_FILES)
	@uvx touying compile $< \
		--format pdf \
		--silent 1 \
		--sys-inputs '{"handout":"true"}'		# Collapse slide animations for PDF

main.html: $(REPORT_FILES)
	@uvx touying compile $< --format html --silent 1

clean:
	rm main.html main.pdf


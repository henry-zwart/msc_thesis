COMPILE_ARGS ?= --root "$$(pwd)" 

.PHONY: clean preview

REPORT_FILES = main.typ

all: main.html main.pdf

# ==== Report
main.%: $(REPORT_FILES)
	uvx touying compile $< --format $*

clean:
	rm main.html main.pdf


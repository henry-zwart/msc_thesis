COMPILE_ARGS ?= --root "$$(pwd)" 

.PHONY: clean preview

REPORT_FILES = main.typ lib.typ

all: main.pdf 

# ==== Report
main.pdf: $(REPORT_FILES)
	@typst compile $<

preview:
	typst compile main.typ $(COMPILE_ARGS) && \
	zathura main.pdf & \
	typst watch main.typ $(COMPILE_ARGS)

clean:
	rm main.pdf 


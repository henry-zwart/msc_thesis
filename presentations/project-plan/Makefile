COMPILE_ARGS ?= --root "$$(pwd)" 

.PHONY: clean preview

REPORT_FILES = main.typ

all: main.html 

# ==== Report
main.html: $(REPORT_FILES)
	uvx touying compile $<

clean:
	rm main.html 


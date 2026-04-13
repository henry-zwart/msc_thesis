PROJECT_PLAN_DIR := presentations/project_plan
PROJECT_PLAN_REPORT_FILES := $(PROJECT_PLAN_DIR)/main.typ

#all: $(PROJECT_PLAN_DIR)/main.html $(PROJECT_PLAN_DIR)/main.pdf

# ==== Report
$(PROJECT_PLAN_DIR)/main.pdf: $(PROJECT_PLAN_REPORT_FILES)
	@uvx touying compile $< \
		--format pdf \
		--silent 1 \
		--sys-inputs '{"handout":"true"}'		# Collapse slide animations for PDF

$(PROJECT_PLAN_DIR)/main.html: $(PROJECT_PLAN_REPORT_FILES)
	@uvx touying compile $< --format html --silent 1

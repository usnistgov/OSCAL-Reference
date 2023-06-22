SHELL:=/usr/bin/env bash

.PHONY: help
# Run "make" or "make help" to get a list of user targets
# Adapted from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | awk 'BEGIN { \
	 FS = ":.*?## "; \
	 printf "\033[1m%-30s\033[0m %s\n", "TARGET", "DESCRIPTION" \
	} \
	{ printf "\033[32m%-30s\033[0m %s\n", $$1, $$2 }'

REFERENCE_DIR:=site/content/releases
REVISIONS_DIRS:=$(wildcard revisions/*/)
REVISIONS_MODELDOC_DIRS:=$(patsubst revisions/%/,$(REFERENCE_DIR)/%/,$(REVISIONS_DIRS))

.PHONY: modeldoc
modeldoc: $(REVISIONS_MODELDOC_DIRS) ## Generate model documentation

$(REFERENCE_DIR)/%/:
	./support/generate_modeldoc.sh $*

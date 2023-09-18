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

.PHONY: clean
clean: clean-modeldoc clean-site clean-release-assets ## Clean all

#
# Website generation / hugo
#

REVISIONS:=develop $(shell ./support/list_revisions.sh)
MODELDOC_CONTENT_DIR:=site/content/models
MODELDOC_REVISION_CONTENT_DIR:=$(patsubst %,$(MODELDOC_CONTENT_DIR)/%/,$(REVISIONS))
MODELDOC_DATA_DIR:=site/data/models
MODELDOC_REVISION_DATA_DIR:=$(patsubst %,$(MODELDOC_DATA_DIR)/%/,$(REVISIONS))
SITE_OUTPUT:=site/public

.PHONY: serve
serve: modeldoc release-assets ## Spin up a static web server for local dev
	cd site; hugo serve

.PHONY: site
site: $(SITE_OUTPUT) ## Build the site

$(SITE_OUTPUT): modeldoc release-assets
	cd site; hugo --minify

.PHONY: clean-site
clean-site: ## Clean the site
	rm -fr $(SITE_OUTPUT)

#
# Model documentation
#

.PHONY: modeldoc
modeldoc: $(MODELDOC_REVISION_CONTENT_DIR) ## Generate model documentation

# TODO specify archetypes/ as a dependency
$(MODELDOC_CONTENT_DIR)/%/:
	./support/generate_modeldoc.sh $*

.PHONY: clean-modeldoc
clean-modeldoc: ## Clean model documentation
	rm -fr $(MODELDOC_REVISION_CONTENT_DIR)
	rm -fr $(MODELDOC_REVISION_DATA_DIR)

#
# Release assets link
#

RELEASE_ASSET_REDIRECTS_DIR:=site/content/release-assets/latest/

.PHONY: release-assets
release-assets: $(RELEASE_ASSET_REDIRECTS_DIR) ## Generate redirects to latest release's assets

$(RELEASE_ASSET_REDIRECTS_DIR):
	./support/generate_release_assets_redirect.sh

.PHONY: clean-release-assets
clean-release-assets: ## Clean release redirects
	rm -fr site/content/release-assets/latest/

#
# Checks
#

LYCHEE_IGNORE_FILE:=./support/lychee_ignore.txt
LYCHEE_CONFIG_FILE:=./support/lychee.toml
# Flags that currently cannot be configured via the configuration file
LYCHEE_FLAGS:=--verbose --format markdown
# Extra flags for the user to override (used to set github token in GHA workflow)
LYCHEE_EXTRA_FLAGS:=

.PHONY: linkcheck
linkcheck: site
	lychee \
		--exclude-file '$(LYCHEE_IGNORE_FILE)' \
		--config '$(LYCHEE_CONFIG_FILE)' \
		$(LYCHEE_FLAGS) $(LYCHEE_EXTRA_FLAGS) \
		'$(SITE_OUTPUT)/**/*.html'

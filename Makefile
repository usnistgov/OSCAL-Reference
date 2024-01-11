SHELL:=/usr/bin/env bash

.PHONY: help
# Run "make" or "make help" to get a list of user targets
# Adapted from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | awk 'BEGIN { \
	 FS = ":.*?## "; \
	 printf "\033[1m%-30s %s\033[0m\n", "TARGET", "DESCRIPTION" \
	} \
	{ printf "\033[32m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: clean
clean: clean-modeldoc clean-site clean-release-assets clean-linkcheck ## Clean all

#
# Website generation / hugo
#

PROTOTYPE_BRANCHES_REMOTE:=origin
PROTOTYPE_BRANCHES_PREFIX:=prototype
# `REVISIONS` contains a list of Git refs (specifically branches and tags) of the OSCAL repository that documentation will be built for.
# By default, `REVISIONS` includes:
# 1. The `develop` branch, showcasing changes staged for the next release.
# 2. Tagged releases matching a semver pattern (e.g. `v.1.0.0`).
# 3. Prototype branches matching the specified `PROTOTYPE_BRANCHES_REMOTE` and `PROTOTYPE_BRANCHES_PREFIX`.
# For local development, `REVISIONS` can be overridden to build a subset of the site
#   (e.g. `make site REVISIONS='v1.1.0 my-special-branch'`)
REVISIONS:=develop $(shell ./support/list_revisions.sh) $(shell ./support/list_branches.sh ${PROTOTYPE_BRANCHES_REMOTE} ${PROTOTYPE_BRANCHES_PREFIX})
# Release assets link
RELEASE_ASSET_REDIRECTS_DIR:=site/content/release-assets/latest/
MODELDOC_CONTENT_DIR:=site/content/models
MODELDOC_REVISION_CONTENT_DIR:=$(patsubst %,$(MODELDOC_CONTENT_DIR)/%/,$(REVISIONS))
MODELDOC_DATA_DIR:=site/data/models
MODELDOC_REVISION_DATA_DIR:=$(patsubst %,$(MODELDOC_DATA_DIR)/%/,$(REVISIONS))
SITE_OUTPUT_DIR:=site/public

.PHONY: environment
environment:
	$(info    REVISIONS = $(REVISIONS))
	$(info    MODELDOC_CONTENT_DIR = $(MODELDOC_CONTENT_DIR))
	$(info    MODELDOC_REVISION_CONTENT_DIR = $(MODELDOC_REVISION_CONTENT_DIR))
	$(info    MODELDOC_REVISION_DATA_DIR = $(MODELDOC_REVISION_DATA_DIR))
	$(info    RELEASE_ASSET_REDIRECTS_DIR = $(RELEASE_ASSET_REDIRECTS_DIR))
	$(info    SITE_OUTPUT_DIR = $(SITE_OUTPUT_DIR))
	$(info    Content in site: $(shell find ./site/content/models))
	$(info    Models in site: $(shell find ./site/data/models))

.PHONY: serve
serve: modeldoc release-assets ## Spin up a static web server for local dev
	cd site
	hugo serve

.PHONY: site
site: $(SITE_OUTPUT_DIR) ## Build the site

$(SITE_OUTPUT_DIR): $(MODELDOC_REVISION_CONTENT_DIR) $(RELEASE_ASSET_REDIRECTS_DIR)
	cd site; hugo --minify

.PHONY: clean-site
clean-site: ## Clean the site
	rm -fr $(SITE_OUTPUT_DIR)

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

.PHONY: release-assets
release-assets: $(RELEASE_ASSET_REDIRECTS_DIR) ## Generate redirects to latest release's assets

$(RELEASE_ASSET_REDIRECTS_DIR):
	./support/generate_release_assets_redirect.sh

.PHONY: clean-release-assets
clean-release-assets: ## Clean release redirects
	rm -fr $(RELEASE_ASSET_REDIRECTS_DIR)

#
# Checks
#

LYCHEE_OUTPUT_FILE:=lychee_report.md
LYCHEE_CONFIG_FILE:=./support/lychee.toml
# Flags that currently cannot be configured via the configuration file
LYCHEE_FLAGS:=--verbose --format markdown
# Extra flags for the user to override (used to set github token in GHA workflow)
LYCHEE_EXTRA_FLAGS:=

.PHONY: linkcheck
linkcheck: $(LYCHEE_OUTPUT_FILE) ## Generate a report of all site links

$(LYCHEE_OUTPUT_FILE): $(SITE_OUTPUT_DIR)
	lychee \
		--config '$(LYCHEE_CONFIG_FILE)' \
		--output $(LYCHEE_OUTPUT_FILE) \
		$(LYCHEE_FLAGS) $(LYCHEE_EXTRA_FLAGS) \
		'$(SITE_OUTPUT_DIR)/**/*.html'

clean-linkcheck: ## Clean the linkcheck report
	rm -f $(LYCHEE_OUTPUT_FILE)

.PHONY: list-tags
list-tags: ## List OSCAL tagged releases
	./support/list_revisions.sh

.PHONY: list-prototype-branches
list-prototype-branches:  ## List OSCAL prototype branches for publication
	./support/list_branches.sh $(PROTOTYPE_BRANCHES_REMOTE) $(PROTOTYPE_BRANCHES_PREFIX)
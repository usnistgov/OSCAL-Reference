#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The root of the OSCAL-Reference repository
ROOT_DIR="${SCRIPT_DIR}/.."
SITE_DIR="${ROOT_DIR}/site"
# Where generated content will be placed
RELEASES_DIR="${SITE_DIR}/content/releases"
# Where OSCAL submodules are located
REVISIONS_DIR="${ROOT_DIR}/revisions"
METASCHEMA_DIR="${ROOT_DIR}/support/metaschema-xslt"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") <REVISION>
Generates model documentation for a specific revision.
The revision will be pulled from the corresponding ${REVISIONS_DIR} folder of this
OSCAL-Reference repository and placed into ${RELEASES_DIR}
EOF
}

if ! [ -x "$(command -v mvn)" ]; then
  echo 'Error: Maven (mvn) is not in the PATH, is it installed?' >&2
  exit 1
fi

if ! [ -x "$(command -v hugo)" ]; then
  echo 'Error: Hugo (hugo) is not in the PATH, is it installed?' >&2
  exit 1
fi

if ! [ -x "$(command -v git)" ]; then
  echo 'Error: Git (git) is not in the PATH, is it installed?' >&2
  exit 1
fi

[[ -z "${1-}" ]] && { echo "Error: REVISION not specified" >&2; usage; exit 1; }
REVISION=$1
# The path to write generated content to
DOC_PATH="${RELEASES_DIR}/${REVISION}"
# The path to the target OSCAL submodule
REVISION_PATH="${REVISIONS_DIR}/${REVISION}"

#
# Set up env vars for hugo generation
#

REF="$(cd "${REVISION_PATH}";git symbolic-ref -q --short HEAD || git describe --tags --exact-match)"
if [[ "$REF" =~ ^v.* ]]; then
  VERSION="${REF/#"v"}"
  TYPE="tag"
  OUTPUT_DIR="${VERSION}"
elif [ "$REF" = "main" ]; then
  VERSION="$(cd "${REVISION_PATH}";git describe --abbrev=0)"
  VERSION="${VERSION/#"v"}"
  TYPE="branch"
  OUTPUT_DIR="latest"
elif [ "$REF" = "develop" ]; then
  VERSION="develop"
  TYPE="branch"
  OUTPUT_DIR="develop"
else
  echo "Unrecognized ref: ${REF}, defaulting to develop" >&2
  VERSION="develop"
  TYPE="branch"
  OUTPUT_DIR="develop"
fi

export HUGO_REF_VERSION="${VERSION}"
export HUGO_REF_BRANCH="${REF}"
export HUGO_REF_TYPE="${TYPE}"
export SITE_OUTPUT_DIR="${RELEASES_DIR}/${OUTPUT_DIR}"
# TODO parse remote (line 172 of original script)
export HUGO_REF_REMOTE="usnistgov/OSCAL"

# Generate index page

{
  cd "${SITE_DIR}"
  hugo new --kind reference-index "${DOC_PATH}/_index.md"
}

# # Setup temporary/scratch directory

# SCRATCH_DIR="${SCRATCH_DIR-$(mktemp -d)}"
# if [ ! -d "${SCRATCH_DIR}" ]; then
#   mkdir -p "${SCRATCH_DIR}"
# fi
# # TODO delete the scratch dir if needed

# Generate per-model documentation

{

}

#!/usr/bin/env bash

set -Eeuo pipefail

if ! [ -x "$(command -v mvn)" ]; then
  echo 'Error: Maven (mvn) is not in the PATH, is it installed?' >&2
  exit 1
fi

if ! [ -x "$(command -v hugo)" ]; then
  echo 'Error: Hugo (hugo) is not in the PATH, is it installed?' >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
SITE_DIR="${ROOT_DIR}/site"
METASCHEMA_DIR="${ROOT_DIR}/support/metaschema-xslt"

# # Setup temporary/scratch directory
# SCRATCH_DIR="${SCRATCH_DIR-$(mktemp -d)}"
# if [ ! -d "${SCRATCH_DIR}" ]; then
#   mkdir -p "${SCRATCH_DIR}"
# fi

# TODO delete the scratch dir if needed

REVISION="1.0.4"

DOC_PATH="content/${REVISION}"

{
  cd "${SITE_DIR}"
  # TODO add env vars here
  hugo new --kind reference-index "${DOC_PATH}/_index.md"
}

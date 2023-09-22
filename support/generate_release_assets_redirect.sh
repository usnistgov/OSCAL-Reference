#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The root of the OSCAL-Reference repository
ROOT_DIR="${SCRIPT_DIR}/.."
SITE_DIR="${ROOT_DIR}/site"
OSCAL_DIR="${ROOT_DIR}/support/OSCAL"

if ! [ -x "$(command -v hugo)" ]; then
  echo 'Error: Hugo (hugo) is not in the PATH, is it installed?' >&2
  exit 1
fi

if ! [ -x "$(command -v git)" ]; then
  echo 'Error: Git (git) is not in the PATH, is it installed?' >&2
  exit 1
fi

# The latest release tag
REVISION=$("$SCRIPT_DIR"/list_revisions.sh | tail -n 1)

#
# Git Submodule operations
#

SCRATCH_DIR="$(mktemp -d)"

{
  echo "Creating temporary worktree at ${REVISION} in ${SCRATCH_DIR}" >&2
  cd "${OSCAL_DIR}"
  git worktree add --quiet --force "${SCRATCH_DIR}" "${REVISION}"
}

function cleanup() {
  echo "Removing temporary worktree ${SCRATCH_DIR}" >&2
  cd "${OSCAL_DIR}"
  git worktree remove "${SCRATCH_DIR}"
  rm -fr "${SCRATCH_DIR}"
}
trap cleanup EXIT

# Populate ROOT_METASCHEMAS with all metaschema basenames (oscal_catalog ... etc.)
# The find block:
# 1. Finds all files in the scratch directory's src/metaschema directory that match *_metaschema.xml
# 2. Exclude non-root metaschemas ("common" and "metadata" metaschemas)
# 3. Strip the path, leaving just the filename
# 4. Strip the "_metaschema.xml" suffix, leaving just "oscal_$name"
ROOT_METASCHEMAS=()
while IFS='' read -r metaschema; do
    ROOT_METASCHEMAS+=("$metaschema")
done < <(find "${SCRATCH_DIR}/src/metaschema" \
    -name '*_metaschema.xml' \
        -a ! -name '*common*' \
        -a ! -name '*metadata*' \
    -exec basename {} _metaschema.xml ';')

ARTIFACTS=()
while IFS='' read -r asset; do
  ARTIFACTS+=("$asset")
done < <(make -C "${SCRATCH_DIR}/build" list-release-artifacts)

OUTPUT_PATH=release-assets/latest
GH_RELEASES_URL=https://github.com/usnistgov/OSCAL/releases

{
    cd "${SITE_DIR}"

    rm -fr "content/${OUTPUT_PATH}/"

    # For each asset, generate a new hugo page using the alias archetype
    for asset in "${ASSETS[@]}"; do
        HUGO_TO_LINK="${GH_RELEASES_URL}/download/${REVISION}/${asset}" hugo new --kind alias "content/${OUTPUT_PATH}/${asset}/index.html"
    done
}

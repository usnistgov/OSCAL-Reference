#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The root of the OSCAL-Reference repository
ROOT_DIR="${SCRIPT_DIR}/.."

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") <REVISION>
Adds an OSCAL revision submodule to the ${REVISIONS_DIR} folder.

Should be called with version numbers (e.g. 1.0.4)
EOF
}

[[ -z "${1-}" ]] && { echo "Error: REVISION not specified" >&2; usage; exit 1; }
REVISION=$1

{
  REVISIONS_DIR="revisions"
  REVISION_DIR="${REVISIONS_DIR}/${REVISION}"

  cd "${ROOT_DIR}"
  # Create the submodule
  git submodule add \
    https://github.com/usnistgov/OSCAL.git \
    "${REVISION_DIR}"
  # Configure the submodule to be shallow
  git config \
    -f .gitmodules \
    "submodule.${REVISION_DIR}.shallow" true
  # Configure the submodule to clone without submodules
  git config \
    -f .gitmodules \
    "submodule.${REVISION_DIR}.fetchRecurseSubmodules" false
  # Change the checked out revision
  cd "${REVISION_DIR}"
  git checkout "v${REVISION}"
}

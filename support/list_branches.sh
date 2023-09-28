#!/usr/bin/env bash
# List all branches that generated documentation should target (oldest to newest)

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The root of the OSCAL-Reference repository
ROOT_DIR="${SCRIPT_DIR}/.."
OSCAL_DIR="${ROOT_DIR}/support/OSCAL"

# retrieve prefix for branches of prototypes to be listed and published and if
# it is empty, it can be ignored.
PROTOTYPE_BRANCHES_REMOTE=${PROTOTYPE_BRANCHES_REMOTE:-""}
PROTOTYPE_BRANCHES_PREFIX=${PROTOTYPE_BRANCHES_PREFIX:-""}

[[ -z "${PROTOTYPE_BRANCHES_REMOTE}" ]] && { echo "Error: Necessary PROTOTYPE_BRANCHES_REMOTE variable is not set"; exit 1; }
[[ -z "${PROTOTYPE_BRANCHES_PREFIX}" ]] && { echo "Error: Necessary PROTOTYPE_BRANCHES_PREFIX variable is not set"; exit 1; }

# the output of ls-remote is the best for this but doesn't have ready-made
# format or pretty-print options. We need to use sed to filter the output
# output is the following format:
# sha1-hash        refs/heads/branch-name
# 012345abcd012345abcd012345abcd012345abcd        refs/heads/branch-name
PROTOTYPE_BRANCHES=$(cd "${OSCAL_DIR}"; git ls-remote "${PROTOTYPE_BRANCHES_REMOTE}" "${PROTOTYPE_BRANCHES_PREFIX}*" | sed -n -e "s|^.*\(refs/heads/\)\(${PROTOTYPE_BRANCHES_PREFIX}\)|\2|p")
echo "${PROTOTYPE_BRANCHES}"

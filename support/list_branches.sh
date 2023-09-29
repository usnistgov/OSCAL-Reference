#!/usr/bin/env bash
# List all branches that generated documentation should target

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The root of the OSCAL-Reference repository
ROOT_DIR="${SCRIPT_DIR}/.."
OSCAL_DIR="${ROOT_DIR}/support/OSCAL"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") GIT_REMOTE GIT_BRANCH_PREFIX

GIT_REMOTE: the git remote to use for branches, origin or a custom value. This argument is required.
GIT_BRANCH_PREFIX: the branch prefix used used with a wildcard. This argument is required.
EOF
}

[[ -z "${1-}" ]] && { echo "Error: Necessary git remote not set"; usage; exit 1; }
[[ -z "${2-}" ]] && { echo "Error: Necessary git branch prefix not set"; usage; exit 1; }

# the output of ls-remote is the best for this but doesn't have ready-made
# format or pretty-print options. We need to use sed to filter the output
# output is the following format:
# sha1-hash        refs/heads/branch-name
# 012345abcd012345abcd012345abcd012345abcd        refs/heads/branch-name
PROTOTYPE_BRANCHES=$(cd "${OSCAL_DIR}"; git ls-remote "${1}" "${2}"'*' | sed -n -e "s|^.*\(refs/heads/\)\(${2}\)|\2|p")
echo "${PROTOTYPE_BRANCHES}" | tr '\n' ' '

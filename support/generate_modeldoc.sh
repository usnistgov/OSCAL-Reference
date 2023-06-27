#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The root of the OSCAL-Reference repository
ROOT_DIR="${SCRIPT_DIR}/.."
SITE_DIR="${ROOT_DIR}/site"
# Where generated content will be placed
RELEASES_DIR="${SITE_DIR}/content/releases"
OSCAL_DIR="${ROOT_DIR}/support/OSCAL"
METASCHEMA_DIR="${ROOT_DIR}/support/metaschema-xslt"

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") <REVISION>
Generates model documentation for a specific revision.
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

#
# Git Submodule operations
#

SCRATCH_DIR="$(mktemp -d)"

{
  cd "${OSCAL_DIR}"
  git worktree add -f "${SCRATCH_DIR}" "${REVISION}"
}

function cleanup() {
  cd "${OSCAL_DIR}"
  git worktree remove "${SCRATCH_DIR}"
  rm -fr "${SCRATCH_DIR}"
}
trap cleanup EXIT

#
# Set up env vars for hugo generation
#

REF="$(cd "${SCRATCH_DIR}";git symbolic-ref -q --short HEAD || git describe --tags --exact-match)"
if [[ "$REF" =~ ^v.* ]]; then
  VERSION="${REF/#"v"}"
  TYPE="tag"
  OUTPUT_DIR="${VERSION}"
elif [ "$REF" = "main" ]; then
  VERSION="$(cd "${SCRATCH_DIR}";git describe --abbrev=0)"
  VERSION="${VERSION/#"v"}"
  TYPE="branch"
  OUTPUT_DIR="latest"
else
  VERSION="${REF}"
  TYPE="branch"
  OUTPUT_DIR="${REF}"
fi

export HUGO_REF_VERSION="${VERSION}"
export HUGO_REF_BRANCH="${REF}"
export HUGO_REF_TYPE="${TYPE}"
export SITE_OUTPUT_DIR="${RELEASES_DIR}/${OUTPUT_DIR}"
# TODO parse remote (line 172 of original script)
export HUGO_REF_REMOTE="usnistgov/OSCAL"

#
# Generate index page
#

{
  cd "${SITE_DIR}"
  hugo new --kind reference-index "${DOC_PATH}/_index.md"
}

#
# Generate per-model documentation
#

# MODEL_CONFIG.<rawName> = HUGO_MODEL_ID|HUGO_MODEL_NAME|HUGO_LAYER_ID|HUGO_SCHEMA_ID
MODEL_CONFIG=(
  "catalog=catalog|Catalog|control|catalog"
  "profile=profile|Profile|control|profile"
  "ssp=system-security-plan|System Security Plan|implementation|ssp"
  "component=component-definition|Component Definition|implementation|component-definition"
  "assessment-plan=assessment-plan|Assessment Plan|assessment|assessment-plan"
  "assessment-results=assessment-results|Assessment Results|assessment|assessment-results"
  "poam=plan-of-action-and-milestones|Plan of Action and Milestones|assessment|poam"
  "mapping=mapping|Control Mapping|control|mapping"  
)

function configGet() { 
  local index=$1
  for i in "${MODEL_CONFIG[@]}"; do
    KEY="${i%%=*}"
    VALUE="${i##*=}"
    if [[ "$KEY" == "$index" ]]; then
      printf '%s' "$VALUE"
      return
    fi
  done
}

# For all metaschema files in the revision directory
while IFS= read -r -d '' model_path
do {
  model_basename=$(basename "$model_path")
  if [[ "$model_basename" =~ "common" || "$model_basename" =~ "metadata" ]]; then
    # skip generation for common and metadata metaschemas
    continue
  fi

  model_rawname=${model_basename#oscal_}
  model_rawname=${model_rawname%_metaschema.xml}

  export HUGO_MODEL_DATA_DIR="data/releases/${REVISION}/${model_rawname}"
  model_data="${SITE_DIR}/$HUGO_MODEL_DATA_DIR"

  mvn \
    --quiet \
    -f "${METASCHEMA_DIR}/pom.xml" exec:java \
    -Dexec.mainClass="com.xmlcalabash.drivers.Main" \
    -Dexec.args="-i source=$model_path output-path=file://$model_data/ ${METASCHEMA_DIR}/src/write-hugo-metaschema-docs.xpl"

  archetype=""
  model_doc_path=""

  if [[ "$model_rawname" == "complete" ]]; then
    archetype="complete-reference"
    model_doc_path="${DOC_PATH}/complete"
  else
    archetype="model-reference"
    IFS="|" read -r HUGO_MODEL_ID HUGO_MODEL_NAME HUGO_LAYER_ID HUGO_SCHEMA_ID <<< "$(configGet "${model_rawname}")"
    model_doc_path="${DOC_PATH}/${HUGO_MODEL_ID}"
    export HUGO_MODEL_ID HUGO_MODEL_NAME HUGO_LAYER_ID HUGO_SCHEMA_ID
  fi

  {
    cd "${SITE_DIR}"
    hugo new --kind "${archetype}" "${model_doc_path}"
  }
} done <   <(find "${SCRATCH_DIR}/src/metaschema" -type f -name "oscal_*_metaschema.xml" -print0)

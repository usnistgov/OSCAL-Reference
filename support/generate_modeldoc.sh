#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The root of the OSCAL-Reference repository
ROOT_DIR="${SCRIPT_DIR}/.."
SITE_DIR="${ROOT_DIR}/site"
# Where generated content will be placed
SITE_MODELDOC_DIR="${SITE_DIR}/content/models"
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
DOC_PATH="${SITE_MODELDOC_DIR}/${REVISION}"

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

#
# Set up env vars for hugo generation
#

REF="$(cd "${SCRATCH_DIR}";git symbolic-ref -q --short HEAD || git describe --tags --exact-match)"
if [[ "$REF" =~ ^v.* ]]; then
  VERSION="${REF/#"v"}"
  TYPE="tag"
else
  VERSION="${REF}"
  TYPE="branch"
fi

LATEST=$("${ROOT_DIR}"/support/list_revisions.sh | tail -n 1)
if [[ "$VERSION" == "${LATEST/#"v"}" ]]; then
  export HUGO_REF_LATEST="true"
fi

# branch name or version with a stripped "v" (e.g. v1.0.0 -> 1.0.0)
export HUGO_REF_VERSION="${VERSION}"
# branch name or intact version tag
export HUGO_REF_BRANCH="${REF}"
# "tag" or "branch"
export HUGO_REF_TYPE="${TYPE}"
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

  # The path to the model relative to the hugo data dir, output dir, and site root
  model_output_path="models/${REVISION}/${model_rawname}"

  # The directory Hugo will read the models from relative to the site directory
  export HUGO_MODEL_DATA_DIR="data/$model_output_path"

  # The root of the OSCAL Reference site
  page_base_path="OSCAL-Reference/$model_output_path/"

  mvn \
    --quiet \
    -f "${METASCHEMA_DIR}/support/pom.xml" exec:java \
    -Dexec.mainClass="com.xmlcalabash.drivers.Main" \
    -Dexec.args="-i source=$model_path page-base-path=$page_base_path output-path=file://${SITE_DIR}/$HUGO_MODEL_DATA_DIR/ ${METASCHEMA_DIR}/src/document/write-hugo-metaschema-docs.xpl"

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

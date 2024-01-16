---
title: "OSCAL {{ getenv "HUGO_MODEL_NAME" }} Model 
{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
  Development Snapshot
{{ else }}
  {{ getenv "HUGO_REF_BRANCH" }}
{{ end }} JSON Format Index"
heading: "{{ getenv "HUGO_MODEL_NAME" }} Model 
{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
  Development Snapshot
{{ else }}
  {{ getenv "HUGO_REF_BRANCH" }}
{{ end }} JSON Format Index"
weight: 30
generateanchors: false
sidenav:
  title: JSON Index
toc:
  enabled: true
  headingselectors: "h1.toc1"
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/{{ getenv "HUGO_MODEL_ID" }}/json-index/
{{ end }}
---

The following is an index of each JSON property used in the JSON format for this [model](https://pages.nist.gov/OSCAL/concepts/layer/{{ getenv "HUGO_LAYER_ID" }}/{{ getenv "HUGO_SCHEMA_ID" }}/),
whose schema can be {{ if eq (getenv "HUGO_REF_TYPE") "tag" }}found [here](https://github.com/usnistgov/OSCAL/releases/download/{{ getenv "HUGO_REF_BRANCH" }}/oscal_{{ getenv "HUGO_MODEL_RAWNAME" }}_schema.json){{ else }}built using [the following instructions](https://github.com/usnistgov/OSCAL/blob/{{ getenv "HUGO_REF_BRANCH" }}/build/README.md#artifact-generation){{ end }}.
Each entry in the index lists all uses of the given property in the format, which is linked to the corresponding entry in the [JSON Format Reference](../json-reference/).
Each entry also lists the formal name for the definition which is linked to the corresponding JSON definition in the [JSON Format Metaschema Reference](../json-definitions/).

{{< rawhtml >}}
{{ os.ReadFile (printf "%s/%s" (getenv "HUGO_MODEL_DATA_DIR") "json-index.html") }}
{{< /rawhtml >}}
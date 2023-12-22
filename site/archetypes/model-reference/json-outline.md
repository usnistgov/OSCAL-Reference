---
title: "OSCAL {{ getenv "HUGO_MODEL_NAME" }} Model 
{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
  Development Snapshot
{{ else }}
  {{ getenv "HUGO_ORIGINAL_VERSION" }}
{{ end }} JSON Format Outline"
heading: "{{ getenv "HUGO_MODEL_NAME" }} Model 
{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
  Development Snapshot
{{ else }}
  {{ getenv "HUGO_ORIGINAL_VERSION" }}
{{ end }} JSON Format Outline"
custom_js:
  - "/js/oscal-metaschema-map-expander.js"
weight: 10
generateanchors: false
sidenav:
  title: JSON Outline
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/{{ getenv "HUGO_MODEL_ID" }}/json-outline/
{{ end }}
---

The following outline is a representation of the JSON format for this [model](https://pages.nist.gov/OSCAL/concepts/layer/{{ getenv "HUGO_LAYER_ID" }}/{{ getenv "HUGO_SCHEMA_ID" }}/),
whose schema can be {{ if eq (getenv "HUGO_REF_TYPE") "tag" }}found [here](https://github.com/usnistgov/OSCAL/releases/download/{{ getenv "HUGO_REF_BRANCH" }}/oscal_{{ getenv "HUGO_SCHEMA_ID" }}_schema.json){{ else }}built using [the following instructions](https://github.com/usnistgov/OSCAL/blob/{{ getenv "HUGO_REF_BRANCH" }}/build/README.md#artifact-generation){{ end }}.
For each property, the name links to the corresponding entry in the [JSON Format Reference](../json-reference/).
The cardinality and data type are also provided for each property where appropriate.

{{< rawhtml >}}
{{ os.ReadFile (printf "%s/%s" (getenv "HUGO_MODEL_DATA_DIR") "json-outline.html") }}
{{< /rawhtml >}}
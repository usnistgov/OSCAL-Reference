---
title: "OSCAL {{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}v{{ getenv "HUGO_REF_VERSION" }}{{ end }} XML Format Outline"
heading: "{{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}v{{ getenv "HUGO_REF_VERSION" }}{{ end }} XML Format Outline"
custom_js:
  - "/js/oscal-metaschema-map-expander.js"
weight: 50
generateanchors: false
sidenav:
  title: XML Outline
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/{{ getenv "HUGO_MODEL_ID" }}/xml-outline/
{{ end }}
---

The following outline is a representation of the XML format for this [model](https://pages.nist.gov/OSCAL/concepts/layer/{{ getenv "HUGO_LAYER_ID" }}/{{ getenv "HUGO_SCHEMA_ID" }}/),
whose schema can be {{ if eq (getenv "HUGO_REF_TYPE") "tag" }}found [here](https://github.com/usnistgov/OSCAL/releases/download/{{ getenv "HUGO_REF_BRANCH" }}/oscal_{{ getenv "HUGO_SCHEMA_ID" }}_schema.xsd){{ else }}built using [the following instructions](https://github.com/usnistgov/OSCAL/blob/{{ getenv "HUGO_REF_BRANCH" }}/build/README.md#artifact-generation){{ end }}.
For each element or attribute, the name links to the corresponding entry in the [XML Format Reference](../xml-reference/).
The cardinality and data type are also provided for each element or attribute where appropriate.

{{< rawhtml >}}
{{ os.ReadFile (printf "%s/%s" (getenv "HUGO_MODEL_DATA_DIR") "xml-outline.html") }}
{{< /rawhtml >}}
---
title: "OSCAL {{ getenv "HUGO_MODEL_NAME" }} Model 
{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
  Development Snapshot
{{ else }}
  {{ getenv "HUGO_REF_BRANCH" }}
{{ end }} JSON Format Metaschema Reference"
heading: "{{ getenv "HUGO_MODEL_NAME" }} Model 
{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
  Development Snapshot
{{ else }}
  {{ getenv "HUGO_REF_BRANCH" }}
{{ end }} Model JSON Metaschema Reference"
weight: 40
generateanchors: false
sidenav:
  title: JSON Metaschema Reference
toc:
  enabled: true
  headingselectors: "h1.toc1, h2.toc2, h3.toc3, h4.toc4, h5.toc5, h6.toc6"
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/{{ getenv "HUGO_MODEL_ID" }}/json-definitions/
{{ end }}
---

The following is a reference for the JSON object definitions derived from the [metaschema](https://github.com/usnistgov/OSCAL/blob/{{ getenv "HUGO_REF_BRANCH" }}//src/metaschema/oscal_{{ getenv "HUGO_SCHEMA_ID" }}_metaschema.xml) for this [model](https://pages.nist.gov/OSCAL/concepts/layer/{{ getenv "HUGO_LAYER_ID" }}/{{ getenv "HUGO_SCHEMA_ID" }}/).

{{< rawhtml >}}
{{ os.ReadFile (printf "%s/%s" (getenv "HUGO_MODEL_DATA_DIR") "json-definitions.html") }}
{{< /rawhtml >}}
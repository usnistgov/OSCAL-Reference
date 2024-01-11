---
title: "OSCAL {{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}{{ getenv "HUGO_REF_BRANCH" }}{{ end }} XML Format Index"
heading: "{{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}{{ getenv "HUGO_REF_BRANCH" }}{{ end }} XML Format Index"
weight: 70
generateanchors: false
sidenav:
  title: XML Index
toc:
  enabled: true
  headingselectors: "h1.toc1"
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/{{ getenv "HUGO_MODEL_ID" }}/xml-index/
{{ end }}
---

The following is a reference for the XML element and attribute types derived from the [metaschema](https://github.com/usnistgov/OSCAL/blob/{{ getenv "HUGO_REF_BRANCH" }}/src/metaschema/oscal_{{ getenv "HUGO_MODEL_RAWNAME" }}_metaschema.xml) for this [model](https://pages.nist.gov/OSCAL/concepts/layer/{{ getenv "HUGO_LAYER_ID" }}/{{ getenv "HUGO_SCHEMA_ID" }}/).

{{< rawhtml >}}
{{ os.ReadFile (printf "%s/%s" (getenv "HUGO_MODEL_DATA_DIR") "xml-index.html") }}
{{< /rawhtml >}}
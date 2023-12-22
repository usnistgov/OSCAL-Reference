---
title: "OSCAL {{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}{{ getenv "HUGO_ORIGINAL_VERSION" }}{{ end }} JSON Format Reference"
heading: "{{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}{{ getenv "HUGO_ORIGINAL_VERSION" }}{{ end }} JSON Format Reference"
weight: 20
generateanchors: false
sidenav:
  title: JSON Reference
toc:
  enabled: true
  headingselectors: "h1.toc1, h2.toc2, h3.toc3, h4.toc4, h5.toc5, h6.toc6"
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/{{ getenv "HUGO_MODEL_ID" }}/json-reference/
{{ end }}
---

The following is the JSON format reference for this [model](https://pages.nist.gov/OSCAL/concepts/layer/{{ getenv "HUGO_LAYER_ID" }}/{{ getenv "HUGO_SCHEMA_ID" }}/), which is organized hierarchically. Each entry represents the corresponding JSON property in the model's JSON format, and provides details about the semantics and use of the property. The [JSON Format Outline](../json-outline/) provides a streamlined, hierarchical representation of this model's JSON format which can be used along with this reference to better understand the JSON representation of this model.

{{< rawhtml >}}
{{ os.ReadFile (printf "%s/%s" (getenv "HUGO_MODEL_DATA_DIR") "json-reference.html") }}
{{< /rawhtml >}}
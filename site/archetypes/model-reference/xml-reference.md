---
title: "OSCAL {{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}{{ getenv "HUGO_ORIGINAL_VERSION" }}{{ end }} XML Format Reference"
heading: "{{ getenv "HUGO_MODEL_NAME" }} Model {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}Development Snapshot{{ else }}{{ getenv "HUGO_ORIGINAL_VERSION" }}{{ end }} XML Format Reference"
weight: 60
generateanchors: false
sidenav:
  title: XML Reference
toc:
  enabled: true
  headingselectors: "h1.toc1, h2.toc2, h3.toc3, h4.toc4, h5.toc5, h6.toc6"
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/{{ getenv "HUGO_MODEL_ID" }}/xml-reference/
{{ end }}
---

The following is the XML format reference for this [model](https://pages.nist.gov/OSCAL/concepts/layer/{{ getenv "HUGO_LAYER_ID" }}/{{ getenv "HUGO_SCHEMA_ID" }}/), which is organized hierarchically. Each entry represents the corresponding XML element or attribute in the model's XML format, and provides details about the semantics and use of the element or attribute. The [XML Format Outline](../xml-outline/) provides a streamlined, hierarchical representation of this model's XML format which can be used along with this reference to better understand the XML representation of this model.

{{< rawhtml >}}
{{ os.ReadFile (printf "%s/%s" (getenv "HUGO_MODEL_DATA_DIR") "xml-reference.html") }}
{{< /rawhtml >}}
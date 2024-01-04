---
title: "{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
          Development Snapshot Reference
        {{ else }}
          {{/* OSCAL v{{ getenv "HUGO_REF_VERSION" }} Reference */}}
          OSCAL {{ getenv "HUGO_REF_BRANCH" }} Reference
        {{ end }}"
summary: "{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
            Development Snapshot
          {{ else if eq (getenv "HUGO_REF_LATEST") "true" }}
            Latest Release ({{ getenv "HUGO_REF_BRANCH" }})
          {{ else }}
            {{ getenv "HUGO_REF_VERSION" }}
          {{ end }}"
layout: reference-release
weight: {{ if eq (getenv "HUGO_REF_VERSION") "develop" }}20{{ else if eq (getenv "HUGO_REF_LATEST") "true" }}50{{ else }}70{{ end }}
sidenav:
  title: "{{ if eq (getenv "HUGO_REF_VERSION") "develop" }}
            Development Snapshot
          {{ else if eq (getenv "HUGO_REF_LATEST") "true" }}
            Latest Release ({{ getenv "HUGO_REF_BRANCH" }})
          {{ else }}{{ getenv "HUGO_REF_BRANCH" }}{{ end }}"
  focusrenderdepth: {{ if eq (getenv "HUGO_REF_LATEST") "true" }}2{{ else }}1{{ end }}
  activerenderdepth: -1
  inactiverenderdepth: 1
  debug: false
oscal:
    type: "{{ getenv "HUGO_REF_TYPE" }}"
    remote: "{{ getenv "HUGO_REF_REMOTE" }}"
    branch: "{{ getenv "HUGO_REF_BRANCH" }}"
    version: "{{ getenv "HUGO_REF_VERSION" }}"
{{ if eq (getenv "HUGO_REF_LATEST") "true" }}
aliases:
  - /models/latest/
{{ end }}
---
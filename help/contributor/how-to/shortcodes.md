---
title: "Shortcodes: Website widgets"
linkTitle: "Shortcodes"
weight: "50"
type: "docs"
---

A list and examples of the custom shortcodes that are currently used and available
in knative.dev.

STAUS: This page is in "draft state" and needs to be completed.


## Knative custom shortcodes

https://github.com/knative/website/tree/main/layouts/shortcodes

All of these Knative shortcodes are added as examples in the smoketest pages

- [root](https://knative.dev/smoketest/)
- [/docs/](https://knative.dev/docs/smoketest/)


## Learn more about shortcodes


- Hugo shortcodes https://github.com/gohugoio/hugo/tree/master/docs/layouts/shortcodes

  - How to create custom shortcodes https://gohugo.io/templates/shortcode-templates/

- Docsy shortcodes https://www.docsy.dev/docs/adding-content/shortcodes/

- Other shortcodes https://github.com/spf13/spf13.com/tree/master/layouts/shortcodes

### Includes

Include files and code samples with the `readfile` shortcode:

https://github.com/knative/website/blob/main/layouts/shortcodes/readfile.md

### Dynamic variables

Use them to reduce release maintenance and ensure content accuracy.

The following variable are dynamically populated based on the URL of the content in knative.dev:

   - The [branch shortcode](https://github.com/knative/website/blob/main/layouts/shortcodes/branch.md) <code>{<code>{< branch >}</code>}</code>  renders:  `{{< branch >}}`
   - The [version shortcode](https://github.com/knative/website/blob/main/layouts/shortcodes/version.md) <code>{<code>{< version >}</code>}</code>  renders:  `{{< version >}}`

### Artifacts

https://github.com/knative/website/pull/129/files


### Tabs

https://github.com/knative/website/pull/124

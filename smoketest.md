# Hidden smoketest page

Use this page to test your changes and ensure that there are not any issues,
unwanted behaviors, or regression that are caused by your changes.

Below are a set of site elements that have causes issues in the past.

## Lists

- Top level:
  1. A nested list item.
     1. another level lower
  1. Nested code sample: <br>Shortcode: <code>{<code>{< readfile
     file="./hack/reference-docs-gen-config.json" code="true"
     lang="json" >}</code>}</code> <br>Example:
     {{< readfile file="./hack/reference-docs-gen-config.json" code="true" lang="json" >}}
  1. This should be the third bullet (3.).
     1. More nested code: <br>Shortcode: <code>{<code>{< readfile
        file="Gopkg.toml" code="true" lang="toml" >}</code>}</code> <br>Example:
        {{< readfile file="Gopkg.toml" code="true" lang="toml" >}}
     1. Another nested ordered list item (2.)

## Code samples

The following use the
[`readfile` shortcode](https://github.com/knative/website/blob/main/layouts/shortcodes/readfile.md)

Shortcode: <code>{<code>{< readfile file="./hack/reference-docs-gen-config.json" code="true" lang="json" >}</code>}</code>
   renders as:
{{< readfile file="./hack/reference-docs-gen-config.json" code="true" lang="json" >}}

Shortcode: <code>{<code>{< readfile file="./docs/serving/samples/cloudevents/cloudevents-nodejs/service.yaml" code="true" lang="yaml" >}</code>}</code>
   renders as:
{{< readfile file="./docs/serving/samples/cloudevents/cloudevents-nodejs/service.yaml" code="true" lang="yaml" >}}

## Install version numbers and Clone branch commands

Examples of how the manual and dynamic version number or branch name can be
added in-line with the
[`version` shortcode](https://github.com/knative/website/blob/main/layouts/shortcodes/version.md)
(uses the define values from
[config/\_default/params.toml](https://github.com/knative/website/blob/main/config/_default/params.toml))

1. Shortcode: <code>{<code>{< version >}</code>}</code>
   renders as: {{< version >}}

   Example:
   `kubectl apply version/{{< version >}}/is-the-latest/docs-version.yaml`

1. Shortcode: <code>{<code>{< version override="v0.2.2" >}</code>}</code>
    renders as: {{< version override="v0.2.2" >}}

   Example:
   `kubectl apply the-version-override/{{< version override="v0.2.2" >}}/is-manually-specified.yaml`

1. Shortcode: <code>{<code>{< version patch=".20" >}</code>}</code>
    renders as: {{< version patch=".20" >}}

   Example:
   `kubectl apply this-is-a-point-release/{{< version patch=".20" >}}/filename.yaml`

1. Shortcode: <code>{<code>{< branch >}</code>}</code>
    renders as: {{< branch >}}

   Example:
   `git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs`

1. Shortcode: <code>{<code>{< branch override="release-0.NEXT" >}</code>}</code>
    renders as: {{< branch override="release-0.NEXT" >}}

   Example:
   `git clone -b "{{< branch override="release-0.NEXT" >}}" https://github.com/knative/docs knative-docs`

## Tabs

How to include tabbed content in your page. Note that you can set a default tab.

[View this file in GitHub](https://github.com/knative/docs/blob/main/docs/smoketest.md)

   {{< tabs name="tabs_example" default="Include example" >}}
{{< tab name="Regular example" >}}
This is a regular example tab.
{{< /tab >}}

{{< tab name="Include example" >}}
{{% readfile file="./docs/serving/samples/multi-container/service.yaml" code="true" lang="yaml" %}}
{{< /tab >}}
{{< /tabs >}}

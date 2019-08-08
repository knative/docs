# Spacer Title

<br>

# Hidden smoketest page

Use this page to test your changes and ensure that there are not any issues,
unwanted behaviors, or regression that are caused by your changes.

Below are a set of site elements that have causes issues in the past.

## Lists

- Top level:
  1. A nested list item.
     1. another level lower
  1. Nested code sample: <br>Syntax: <code>{<code>{< readfile
     file="../community/samples/serving/helloworld-java-quarkus/service.yaml"
     code="true" lang="yaml" >}</code>}</code> <br>Example:
     {{< readfile file="../community/samples/serving/helloworld-java-quarkus/service.yaml" code="true" lang="yaml" >}}
  1. This should be the third bullet (3.).
     1. More nested code: <br>Shortcode: <code>{<code>{< readfile
        file="/serving/samples/hello-world/helloworld-go/Dockerfile" code="true"
        lang="go" >}</code>}</code> <br>Example:
        {{< readfile file="./serving/samples/hello-world/helloworld-go/Dockerfile" code="true" lang="go" >}}
     1. Another nested ordered list item (2.)

## Code samples

The following use the
[`readfile` shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/readfile.md)

{{< readfile file="../hack/reference-docs-gen-config.json" code="true" lang="json" >}}

{{< readfile file="../Gopkg.toml" code="true" lang="toml" >}}

## Install version numbers and Clone branch commands

Examples of how the manual and dynamic version number or branch name can be
added in-line with the
[`version` shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/version.md)
(uses the define values from
[config/\_default/params.toml](https://github.com/knative/website/blob/master/config/_default/params.toml))

1. Shortcode: <code>{<code>{% version %}</code>}</code>

   Example:
   `kubectl apply version/{{% version %}}/is-the-latest/docs-version.yaml`

1. Shortcode: <code>{<code>{% version override="v0.2.2" %}</code>}</code>

   Example:
   `kubectl apply the-version-override/{{% version override="v0.2.2" %}}/is-manually-specified.yaml`

1. Shortcode: <code>{<code>{% version patch=".20" %}</code>}</code>

   Example:
   `kubectl apply this-is-a-point-release/{{% version patch=".20" %}}/filename.yaml`

1. Shortcode: <code>{<code>{% branch %}</code>}</code>

   Example:
   `git clone -b "{{% branch %}}" https://github.com/knative/docs knative-docs`

1. Shortcode: <code>{<code>{% branch override="release-0.NEXT" %}</code>}</code>

   Example:
   `git clone -b "{{% branch override="release-0.NEXT" %}}" https://github.com/knative/docs knative-docs`

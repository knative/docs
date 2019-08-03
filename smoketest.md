# Spacer Title

<br>

# Hidden smoketest page

Use this page to test your changes and ensure that there are not any issues,
unwanted behaviors, or regression that are caused by your changes.

Below are a set of site elements that have causes issues in the past.

## Lists

* Top level:
  1. A nested list item.
     1. another level lower
  1. Nested code sample:
     {{< readfile file="hack/reference-docs-gen-config.json" code="true" lang="json" >}}
  1. This should be the third bullet (3.).
     1. More nested code:
        {{< readfile file="Gopkg.toml" code="true" lang="toml" >}}
     1. Another nested ordered list item (2.)


## Code samples

The following use the [`readfile` shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/readfile.md)

{{< readfile file="hack/reference-docs-gen-config.json" code="true" lang="json" >}}

{{< readfile file="Gopkg.toml" code="true" lang="toml" >}}

## Install version numbers test

Examples of how the manual and dynamic version number can be added in-line with the
[`version` shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/version.md)

`kubectl apply version/{{% version %}}/is-the-latest/docs-version.yaml`

`kubectl apply the-version-override/{{% version override="v0.2.2" %}}/is-manually-specified.yaml`

`kubectl apply this-is-a-point-release/{{% version patch=".20" %}}/filename.yaml`

---
title: "Front matter"
linkTitle: ""
weight: 30
type: "docs"
---

The front matter is YAML code in between triple-dashed lines at the top of each
file and provides important management options for our content. For example, the
front matter allows us to ensure that existing links continue to work for pages
that are moved or deleted entirely. This page explains the front matter
features that are currently available in knative.dev.

The following example shows a front matter with all the required fields
filled by placeholders:

```
---
title: <title>
description: <description>
weight: <weight>
keywords: [<keyword1>,<keyword2>,...]
aliases:
    - <previously-published-at-this-URL>
---
```

More details and options for Hugo frontmatter: https://gohugo.io/content-management/front-matter/#predefined


## Required front matter fields

The following table shows descriptions for all the **required** fields:


|Field              | Description
|-------------------|------------
|`title`            | The page's title.
|`weight`           | The order of the page relative to the other pages in the directory.
|`type`             | Specify `docs`. Required for our docs versioning process.
|`aliases`          | Past URLs where the page was published.


### Rename, move, or delete pages

When you move pages or delete them completely, you must ensure that the existing
links to those pages continue to work. The `aliases` field in the front matter
helps you meet this requirement. Add the path to the page before the move or
deletion to the `aliases` field. Hugo implements automatic redirects from the
old URL to the new URL for our users.

On the _target page_, which is the page where you want users to land, add the `<path>`
of the _original page_ to the front-matter as follows:

```
aliases:
    - </path/from/root>
```

### Example

In this example, the following file is deleted: `/docs/install/knative-with-any-k8s.md`

To ensure that anyone who tries to navigate to the deleted file get redirected
to its replacement, you must add `/docs/install/knative-with-any-k8s.md` as an
`aliase`.

For example, in the `/docs/install/_index.md` file, you add each file that you
want to redirect to this file as `aliase` starting with the path from root:

```
---
title: "Installing Knative"
weight: 05
type: "docs"
aliases:
  - /docs/install/knative-with-any-k8s
  - /docs/install/knative-with-aks
  - /docs/install/knative-with-ambassador
  - /docs/install/knative-with-contour
  - /docs/install/knative-with-docker-for-mac
  - /docs/install/knative-with-gke
  - /docs/install/knative-with-gardener
  - /docs/install/knative-with-gloo
  - /docs/install/knative-with-icp
  - /docs/install/knative-with-iks
  - /docs/install/knative-with-microk8s
  - /docs/install/knative-with-minikube
  - /docs/install/knative-with-minishift
  - /docs/install/knative-with-pks
  - /docs/install/any-kubernetes-cluster
showlandingtoc: "false"
---
```

View the
[`docs/install/_index.md`](https://raw.githubusercontent.com/knative/docs/main/docs/install/_index.md)
file in the repository.

## Optional front matter fields

However, Hugo supports many front matter fields and this page only covers those
implemented on knative.dev.

The following table shows the most commonly used **optional** fields:

|Field              | Description
|-------------------|------------
|`linkTitle`        | A shorter version of the title that is used to ensure that the text fits within the left navigation menu.
|`showlandingtoc`.  | For `_index.md` files only. By default, an in-page TOC is added to the body of the page. Specify `"false"` to hide the in-page TOC.


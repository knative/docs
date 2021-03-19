---
title: "Staging and publishing Knative documentation"
linkTitle: "Website help"
weight: "50"
type: "authoring"
---

## Testing your documentation

- Renders correctly.
- Aliases works as expected.

### Staging

https://app.netlify.com/sites/knative/deploys

### Local builds
mention which Hugo version to use

### Set up a personal staging sandbox

- Published versions: The latest release + 3 past versions + 'master'

- Website infrastructure:
  - Hugo - static site engine
  - Docsy - Hugo template for technical documentation
  - [Markdown processor info](https://gohugo.io/getting-started/configuration-markup/)
  - Netlify - continuous build
  - GitHub repos
    - knative/docs repo
    - knative/website repo
    - knative/community repo

- [ ] Redirect URLs for moved and renamed source files (add `aliases` to frontmatter): https://github.com/knative/docs/issues/1925

- Hugo version - https://github.com/knative/website/blob/master/netlify.toml

- Docsy version

- Bootstrap version

## Knative versioning

Each version of the Knative docs are separated by branches in the knative/docs
repository. The `master` branch represents the "in active development" version
of the docs. All content in the `master` branch is pre-release and might not be
tested nor working. Content in all the other branches of the knative/docs repo
are released versions of the docs and use the convention `release-#.#` where
`#.#` is the version of Knative to which those docs correspond.

### Use "relative URLs"

Early on in the content development, all of the documentation was author in the
GitHub repos and since then, there are many contributors who value the ability
to consume the documentation from within the repo. In addition, the main
Markdown editor and renderer when authoring Knative docs is GitHub. Therefore,
we continue to **use relative URLs throughout** and ensure that all links work as
expected, from the beginning they are rendered in GitHub, through to when those
pages are built and published on knative.dev.

Hugo templating has it's own syntax for linking across your content and treats
the content across the site as a single docset (including a Hugo version of
relative links - *relative to the website domain*). Unfortunately, that type of
linking renders markdown content unusable from with the GitHub repos, does not
allow easy versioning/archiving, and raises the bar for docs contributors.

Using relative linking in the Knative docs does not come for free.

- [ ] Document linking conventions - all ./ are required for "same directory" relative links

- [ ] If there is more than a single .md file in a sub folder, then that folder must include and use an `_index.md` (to define that "[section](https://gohugo.io/content-management/sections/)").

   (ie. need to mention that if you want to add that
   second file to a folder, then you must also add (create) the required
   "section definition" (using an `_index.md` file).

How cross linking between /docs and /community works

- script

## Shortcodes

- [ ] Dynamic variables. Use them to reduce release maintenance and ensure content accuracy. The following variable are dynamically populated based on the URL of the content in knative.dev:
   - [ ] add the corresponding branchname by using the `{{< branch >}}` variable ([shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/branch.md))
   - [ ] add the corresponding version number by using the `{{< version >}}` variable ([shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/version.md))

    See examples in the [smoketest page](https://knative.dev/smoketest/)

## Docsy template

- [ ] How to build knative.dev locally: Run [`https://github.com/knative/website/blob/master/scripts/localbuild.sh`](https://github.com/knative/website/blob/master/scripts/localbuild.sh)

Other "docs contributor" related items:

- [ ] https://github.com/knative/docs/issues/1032
- [ ] https://github.com/knative/docs/issues/1009
- [ ] https://github.com/knative/docs/issues/1282
- [ ] https://github.com/knative/docs/issues/1239
- [ ] https://github.com/knative/docs/issues/1344

Recent items:

[ ] Auto PR staging: https://app.netlify.com/sites/knative/deploys

[ ] How Prow chooses reviewers: https://github.com/kubernetes/test-infra/tree/master/prow/plugins/approve/approvers#blunderbuss-selection-mechanism

[ ] GitHub troubleshooting: https://github.com/knative/docs/issues/2755

## Getting through a PR review and publishing


### Prow


### Integration tests

- Link checking

### Continue integration and deployment

Auto publishing

Must include valid

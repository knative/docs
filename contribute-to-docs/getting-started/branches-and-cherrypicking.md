# Branches and cherrypicking

Knative attempts to [support the last 4 releases](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md).

By default, new documentation should be written on the `main` branch and then
cherry-picked to the release branches if needed. Note that the default view of
[Knative website](https://knative.dev/) is of the most recent release branch, which means that
changes to `main` don't show up unless explicitly cherrypicked. This also
means that documentation changes for a release _should be made during the
development cycle_, rather than at the last minute or after the release.


## Docs versioning

Each version of the Knative docs are separated by branches in the `knative/docs`
repository. The `main` branch represents the "in active development" version
of the docs. All content in the `main` branch is renders on the
[Knative website](https://knative.dev/) under
the **Pre-release** menu and might not be tested nor working.

Content in all the other branches of the `knative/docs` repo
represent "released versions of the docs" and use the naming convention
`release-#.#` where `#.#` is the version of Knative to which those docs
correspond.


## Choosing the correct branch

It is likely that your docs contribution is either for new or changed features
in the product, or for a fix or update existing content.

- **New or changed features**: If you are adding or updating documentation for a
  new or changed feature, you likely want to open your PR against the `main`
  branch. All pre-release content for active Knative development belongs in
  [`main`](https://github.com/knative/docs/tree/main/).

- **Fixes and updates**: If you find an issue in a past release, for example a
  typo or out-of-date content, you likely need to cherrypick your PR.
  Add the "`cherrypick` labels" to your
  original PR to indicate in which of the past release that your change affects.

See a list of the available documentation versions in the
[branches page](https://github.com/knative/docs/branches) of the `knative/docs`
repo.


## Cherrypicking

You can use the [`/cherrypick` tool](https://github.com/kubernetes/test-infra/tree/master/prow/external-plugins/cherrypicker#cherrypicker)
to automatically cherrypick changes from `main` to previous releases.

For example, if you find a typo in a page of the `v1.0` release, then that
page in the `main` branch likely also has that typo.

To fix the typo:

1.  Open a PR against the
    [`main`](https://github.com/knative/docs/tree/main/) branch.
1.  In a comment on your PR, use the
    [`/cherrypick` tool](https://github.com/kubernetes/test-infra/tree/master/prow/external-plugins/cherrypicker#cherrypicker)
    to indicate which of the past release branches should also be fixed. Generally, we only
    maintain the most recent numbered release.

After the original PR is merged, the /cherrypick tool automatically creates a
new PR with your changes on the specified branch.

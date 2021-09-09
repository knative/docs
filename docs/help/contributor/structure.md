# Content structure

**TODO: link to intended documentation layout.** A general warning about
[Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law): documents will
naturally tend to be distributed by team that produced them. Try to fight this,
and organize documents based on where the _reader_ will look for them. (i.e. all
tutorials together, maybe with indications as to which components they use,
rather than putting all serving tutorials in one place)

In some cases, the right place for a document may not be on the docs website — a
blog post, documentation within a code repo, or a vendor site may be the right
place. Be generous with offering to link to such locations; documents in the
main documentation come with an ongoing cost of keeping up to date.

[Learn about documenting code samples](code-samples.md)


## Branches

Knative attempts to
[support the last 4 releases](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md).
By default, new documentation should be written on the `main` branch and then
cherry-picked to the release branches if needed. Note that the default view of
<https://knative.dev/> is of the most recent release branch, which means that
changes to `main` don't show up unless explicitly cherrypicked. This also
means that documentation changes for a release _should be made during the
development cycle_, rather than at the last minute or after the release.

The
[`/cherrypick` tool](https://github.com/kubernetes/test-infra/tree/master/prow/external-plugins/cherrypicker)
can be use to automatically pull back changes from `main` to previous releases
if necessary.


### Putting your docs in the right place

Generally, the `knative/docs` repo contains Knative-specific user-facing content and blog content.

When you add a new document to the /docs directory, the navigation menu updates automatically.
For more information, see the
[MkDocs documentation](https://www.mkdocs.org/user-guide/writing-your-docs/#configure-pages-and-navigation).

Contributor-focused content belongs in one of the other Knative code repositories (`knative/serving`, `knative/eventing`, etc).


### Docs versioning

Each version of the Knative docs are separated by branches in the knative/docs
repository. The `main` branch represents the "in active development" version
of the docs. All content in the `main` branch is renders on Knative.dev under
the **Pre-release** menu and might not be tested nor working.

Content in all the other branches of the knative/docs repo
represent "released versions of the docs" and use the naming convention
`release-#.#` where `#.#` is the version of Knative to which those docs
correspond.


#### Choosing the correct branch

It is likely that your docs contribution is either for new or changed features
in the product, or for a fix or update existing content.

- **New or changed features**: If you are adding or updating documentation for a
  new or changed feature, you likely want to open your PR against the `main`
  branch. All pre-release content for active Knative development belongs in
  [`main`](https://github.com/knative/docs/tree/main/).

- **Fixes and updates**: If you find an issue in a past release, for example a
  typo or out-of-date content, you likely need to open multiple and subsequent
  PRs. If not a followup PR, at least add the "`cherrypick` labels" to your
  original PR to indicate in which of the past release that your change affects.

  For example, if you find a typo in a page of the `v0.5` release, then that
  page in the `main` branch likely also has that typo.

  To fix the typo:

  1.  Open a PR against the
      [`main`](https://github.com/knative/docs/tree/main/) branch.
  1.  Add one or more `cherrypick-#.#` labels to that PR to indicate which of
      the past release branches should also be fixed. Generally, we only
      maintain the most recent numbered release.
  1.  If you want to complete the fix yourself (**best practice**), you then
      open a subsequent PR by running `git cherry-pick [COMMIT#]` against the
      `release-0.21`. Where `[COMMIT#]` is the commit of the PR that you merged
      in `main`.

      Note: Depending on workload and available bandwidth, one of the Knative
      team members might be able to help handle the `git cherry-pick` in order
      to push the fix into the affected release branch(es).

See a list of the available documentation versions in the
[branches page](https://github.com/knative/docs/branches) of the `knative/docs`
repo.

---
title: "About Knative documentation"
linkTitle: "Docs help"
weight: 10
type: "authoring"
---

## Documentation structure

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

[Learn about documenting code samples](./codesamples.md)

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

## Style

[Knative documentation style guide](./styleguide.md)

## Tools

Knative uses several sets of tools to manage pull requests (PR)s and issues in a
more fine-grained way than GitHub permissions allow. In particular, you'll
regularly interact with
[Prow](https://github.com/kubernetes/test-infra/tree/master/prow) to categorize
and manage issues and PRs. Prow allows control of specific GitHub functionality
without granting full "write" access to the repo (which would allow rewriting
history and other dangerous operations). You'll most often use the following
commands, but Prow will also chime in on most bugs and PRs with a link to all
the known commands:

- `/assign @user1 @user2` to assign an issue or PR to specific people for review
  or approval.

- `/lgtm` and `/approve` to approve a PR. Note that _anyone_ may `/lgtm` a PR,
  but only someone listed in an `OWNERS` file may `/approve` the PR. A PR needs
  both an approval and an LGTM — the `/lgtm` review is a good opportunity for
  non-approvers to practice and develop reviewing skills. `/lgtm` is removed
  when a PR is updated, but `/approve` is sticky — once applied, anyone can
  supply an `/lgtm`.

- Both Prow (legacy) and GitHub actions (preferred) can run tests on PRs; once
  all tests are passing and a PR has the `lgtm` and `approved` labels, Prow will
  submit the PR automatically.

- You can also use Prow to manage labels on PRs with `/kind ...`,
  `/good-first-issue`, or `/area ...`

- See [Branches](#branches) for details on the `/cherrypick` command.

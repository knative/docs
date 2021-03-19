---
title: Work with GitHub
---
---
title: "Docs workflow in GitHub"
linkTitle: "Using GitHub"
weight: 30
type: "authoring"
---

The Knative documentation follows the standard [GitHub collaboration flow](https://guides.github.com/introduction/flow/)
for Pull Requests (PRs). This well-established collaboration model helps open
source projects manage the following types of contributions:

- [Add](/about/contribute/add-content) new files to the repository.
- [Edit](#quick-edit) existing files.
- [Review](/about/contribute/review) the added or modified files.
- Manage multiple release or development [branches](#branching-strategy).

The contribution guides assume you can complete the following tasks:

- Fork the [knative/docs repository](https://github.com/knative/docs).
- Create a branch for your changes.
- Add commits to that branch.
- Open a PR to share your contribution.

## Before you begin

To contribute to the Knative documentation, you need to:

1. Create a [GitHub account](https://github.com).

1. Sign the [Contributor License Agreement](https://github.com/Knative/community/blob/master/CONTRIBUTING.md#contributor-license-agreements).

1. Install [Docker](https://www.docker.com/get-started) on your authoring system
   to preview and test your changes.

The Knative documentation is published under the
[Apache 2.0](https://github.com/Knative/community/blob/master/LICENSE) license.

## Opening documentation pull requests

General details about how to open a PR are covered in the
[Knative guidelines](https://github.com/knative/community/blob/main/CONTRIBUTING.md).

**Best practice**: Make sure that you correctly
[assign an owner to PR](#assigning-owners-and-reviewers).

## Fixing Issues (Pull Requests)

<!-- This could use a pass to be more focused on what a PR submitter should do at the start of the process. -->

Here's what generally happens when you open a PR against the `knative/docs`
repo:

1.  One of the assigned repo maintainers will triage the PR by assigning
    relative priority, adding appropriate labels, and performing an initial
    documentation review.

2.  If the PR involves significant technical changes, for example new features,
    or new and changed sample code, the PR is assigned to a Subject Matter
    Expert (SME), typically an engineer working on Knative, for technical review
    and approval.

3.  When both the technical writers and SMEs are satisfied with the quality of
    the writing and the technical accuracy of the content, the PR can be merged.
    A PR requires two labels before it can merge: `lgtm` and `approved`.

    - The SME is responsible for reviewing the technical accuracy and adding the
      `lgtm` label.

    - The
      [Knative technical writers](https://github.com/knative/docs/blob/main/OWNERS_ALIASES)
      are who provide the `approved` label when the content meets quality,
      clarity, and organization standards (see [Style Guide](#style-guide)).

We appreciate contributions to the docs, so if you open a PR we will help you
get it merged. You can also post in the `#docs`
[Slack channel](https://knative.slack.com/) to get input on your ideas or find
areas to contribute before creating a PR.


## Assigning owners and reviewers

All PRs should be assigned to a single owner ("_Assignee_"). It's best to set
the "Assignee" and include other stakeholders as "Reviewers" rather than leaving
it unassigned or allowing [Prow](https://prow.k8s.io/command-help) to auto
assign reviewers.

Use the `/assign` command to set the owner. For example: `/assign @owner_id`

**For code related changes**, initially set the owner of your PR to the SME who
should review for technical accuracy. If you don't know who the appropriate
owner is, nor who your reviewers should be for your PR, you can assign the
[current working group lead](https://github.com/knative/community/tree/main/WORKING-GROUPS.md) of the related component.

If you want to notify and include other stakeholders in your PR review, use the
`/cc` command. For example: `/cc @stakeholder_id1 @stakeholder_id2`


## Perform quick edits {#quick-edit}

Anyone with a GitHub account who signs the CLA can contribute a quick
edit to any page on the Knative website. The process is very simple:

1. Visit the page you wish to edit.
1. Add `preliminary` to the beginning of the URL. For example, to edit
   `https://istio.io/about`, the new URL should be
   `https://preliminary.istio.io/about`
1. Click the pencil icon in the lower right corner.
1. Perform your edits on the GitHub UI.
1. Submit a Pull Request with your changes.

Please see our guides on how to [contribute new content](/about/contribute/add-content)
or [review content](/about/contribute/review) to learn more about submitting more
substantial changes.

## Branching strategy {#branching-strategy}

Active content development takes place using the master branch of the
`istio/istio.io` repository. On the day of an Istio release, we create a release
branch of master for that release. The following button takes you to the
repository on GitHub:

<a class="btn"
href="https://github.com/istio/istio.io/">Browse this site's source
code</a>

The Knative documentation repository uses multiple branches to publish
documentation for all Knative releases. Each Knative release has a corresponding
documentation branch. For example, there are branches called `release-1.0`,
`release-1.1`, `release-1.2` and so forth. These branches were created on the
day of the corresponding release. To view the documentation for a specific
release, see the [archive page](https://archive.istio.io/).

This branching strategy allows us to provide the following Knative online resources:

- The [public site](/docs/) shows the content from the current
  release branch.

- The preliminary site at `https://preliminary.istio.io` shows the content from
  the master branch.

- The [archive site](https://archive.istio.io) shows the content from all prior
  release branches.

Given how branching works, if you submit a change into the master branch,
that change won't appear on `istio.io` until the next major Knative release
happens. If your documentation change is relevant to the current Knative release,
then it's probably worth also applying your change to the current release branch.
You can do this easily and automatically by using the special cherry-pick labels
on your documentation PR. For example, if you introduce a correction in a PR to
the master branch, you can apply the `cherrypick/release-1.4` label in order to
merge this change to the `release-1.4` branch.

When your initial PR is merged, automation creates a new PR in the release
branch which includes your changes. You may need to add a comment to the PR
that reads `@googlebot I consent` in order to satisfy the `CLA` bot that we
use.

On rare occasions, automatic cherry picks don't work. When that happens, the
automation leaves a note in the original PR indicating it failed. When
that happens, you must manually create the cherry pick and deal
with the merge issues that prevented the process from working automatically.

Note that we only ever cherry pick changes into the current release branch,
and never to older branches. Older branches are considered to be archived and
generally no longer receive any changes.


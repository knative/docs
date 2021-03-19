---
title: "Knative documenation contributor guides"
linkTitle: "Contributor guides"
weight: "10"
type: "authoring"
showlandingtoc: "false"
---

<!-- Original file: https://github.com/knative/docs/pull/3269 -->

Learn about how to contribute content to the Knative documentation and publish
to the `knative.dev` website.

**First off, thanks for taking the time to contribute!**

The following are guidelines for contributing to the user facing Knative
documentation. These are just guidelines, not rules. Use your best judgment, and
feel free to propose changes to this document in a pull request.

# Before you begin

You must meet the following prerequisites before you are able to contribute to
the docs. The following steps are specific to docs contributions.
For more information about contributing to the Knative project, see the
[Knative contribution guidelines](https://github.com/knative/community/blob/master/README.md).

1. Become a Knative Member by subscribing to
   [knative-dev@googlegroups.com](https://groups.google.com/forum/#!forum/knative-dev).

   [Learn more about community roles](https://github.com/knative/community/tree/master/ROLES.md)

1. Read and follow the
   [Knative Code of Conduct](https://github.com/knative/community/blob/master/CODE-OF-CONDUCT.md).

   By participating, you are expected to uphold this code. Please report all
   unacceptable behavior to <knative-code-of-conduct@googlegroups.com>.

1. Sign the contributor license agreements (CLA).

   Knative requires the [Google CLA](https://cla.developers.google.com).

   Important: You must fill out the CLA with the same email address that you
   used to create your GitHub account. Also see the note about private accounts.

   Once you are CLA'ed, we'll be able to accept your pull requests. This is
   necessary because you own the copyright to your changes, even after your
   contribution becomes part of this project. So this agreement simply gives us
   permission to use and redistribute your contributions as part of the project.

   Private accounts not supported: Your contributions are verified using the
   email address for which you use to sign the CLA. Therefore,
   [setting your GitHub account to private](https://help.github.com/en/articles/setting-your-commit-email-address)
   is unsupported because all commits from private accounts are sent from the
   `noreply` email address.

# Getting involved

There are a couple of different ways to get started with contributing to the
Knative documentation:

- Look for a
  [Good First Issue](https://github.com/knative/docs/labels/kind%2Fgood-first-issue)
  in the backlog.

- Try out Knative and
  [send us feedback](https://github.com/knative/docs/issues/new?template=docs-feature-request.md).
  For example, run through the [install guides](./docs/install/) and then try
  [Getting Started with Knative Serving](./docs/serving/getting-started-knative-app.md)
  or [Getting Started With Eventing](./docs/eventing/getting-started.md).

  Keep a
  [friction log](https://devrel.net/developer-experience/an-introduction-to-friction-logging)
  of your experience and attach it to a feature request, or use it to open your
  first set of PRs. Examples:

  - What was difficult for you?
  - Did you stumble on something because the steps weren't clear?
  - Was a dependency not mentioned?

## Working group meetings

The [Knative Documentation Working
Group](https://github.com/knative/community/blob/master/working-groups/WORKING-GROUPS.md#documentation)
meetings are used to discuss documentation qustions, strategy, and policy.

See the [Working Group meeting info and times](https://calendar.google.com/calendar/embed?src=knative.team_9q83bg07qs5b9rrslp5jor4l6s%40group.calendar.google.com)

### Getting docs help

- [#docs on the Knative Slack](https://slack.knative.dev) -- The #docs channel
  is the best place to go if you have questions about making changes to the
  documentation. We're happy to help!

- [Documentation working
  group](https://github.com/knative/community/tree/master/working-groups/WORKING-GROUPS.md#documentation)
  -- Come join us in the working group to meet other docs contributors and ask
  any questions you might have.

Individual PR review to happen mostly asynchronously via GitHub, and
[Slack](https://slack.knative.dev).


## Reporting documentation issues

<!-- This could use a pass to reduce the overhead for filing new issues,
and to consolidate items more easily during issue triage. -->

Knative uses Github issues to track documentation issues and requests. If you
see a problem with the documentation that you're not sure how to fix, submit an
issue using the following steps:

1.  Check the [Knative docs issues list](https://github.com/knative/docs/issues)
    before creating an issue to avoid making a duplicate.

2.  Use the [correct template](https://github.com/knative/docs/issues/new) for
    your new issue. There are two templates available:

    - **Bug report**: If you're reporting an error in the existing
      documentation, use this template. This could be anything from broken
      samples to typos. When you create a bug report, include as many details as
      possible and include suggested fixes to the issue. If you know which
      Knative component your bug is related to, you can assign the appropriate
      [Working Group Lead](https://github.com/knative/community/blob/master/working-groups/WORKING-GROUPS.md).

    - **Feature request**: For upcoming changes to the documentation or requests
      for more information on a particular subject.

Note that code issues should be filed against the
[individual Knative repositories](http://github.com/knative), while
documentation issues should go in the
[`knative/docs` repo](https://github.com/knative/docs/issues). If the issue is
specific to the <https://knative.dev> website, open the issue in the
[`knative/website` repo](https://github.com/knative/website/issues).


## Opening documentation pull requests

General details about how to open a PR are covered in the
[Knative guidelines](https://github.com/knative/community/blob/master/CONTRIBUTING.md).

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
      [Knative technical writers](https://github.com/knative/docs/blob/master/OWNERS_ALIASES)
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
[current working group lead](https://github.com/knative/community/tree/master/WORKING-GROUPS.md) of the related component.

If you want to notify and include other stakeholders in your PR review, use the
`/cc` command. For example: `/cc @stakeholder_id1 @stakeholder_id2`

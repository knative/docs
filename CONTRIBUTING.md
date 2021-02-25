- [Your first contribution](#your-first-contribution)
  - [Code of conduct](#code-of-conduct)
  - [Contributor license agreements](#contributor-license-agreements)
  - [Fixing Issues (Pull Requests)](#fixing-issues--pull-requests-)
  - [Reporting Issues](#reporting-issues)
- [Getting involved](#getting-involved)
  - [Working group meetings](#working-group-meetings)
- [Workflow](#workflow)
  - [New Content](#new-content)
  - [Refining and Reviewing Content](#refining-and-reviewing-content)
- [Tech Writer Guide](#tech-writer-guide)
  - [Type of documentation](#type-of-documentation)
  - [Documentation Structure](#documentation-structure)
  - [Branches](#branches)
  - [Tools and Style](#tools-and-style)
- [Engineer Guide](#engineer-guide)
  - [Putting your docs in the right place](#putting-your-docs-in-the-right-place)

**First off, thanks for taking the time to contribute!**

The following are guidelines for contributing to the Knative documentation.
These are just guidelines, not rules. Use your best judgment, and feel free to
propose changes to this document in a pull request.

# Your first contribution

## Code of conduct

Knative follows the
[Knative Code of Conduct](https://github.com/knative/community/blob/master/CODE-OF-CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to <knative-code-of-conduct@googlegroups.com>.

## Contributor license agreements

Knative requires the [Google CLA](https://cla.developers.google.com). Important:
You must fill out the CLA with the same email address that you used to create
your GitHub account.

Once you are CLA'ed, we'll be able to accept your pull requests. This is
necessary because you own the copyright to your changes, even after your
contribution becomes part of this project. So this agreement simply gives us
permission to use and redistribute your contributions as part of the project.

Note: Your contributions are verified using the email address for which you use
to sign the CLA. Therefore,
[setting your GitHub account to private](https://help.github.com/en/articles/setting-your-commit-email-address)
is unsupported because all commits from private accounts are sent from the
`noreply` email address.

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

## Reporting Issues

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

The
[Knative Documentation Working Group](https://github.com/knative/community/blob/master/working-groups/WORKING-GROUPS.md#documentation)
meeting info and times.
[Click here](https://calendar.google.com/calendar/embed?src=knative.team_9q83bg07qs5b9rrslp5jor4l6s%40group.calendar.google.com)
to see the exact dates on the Knative working group calendar.

The Working Group meetings are used to discuss documentation strategy and
policy; we expect individual PR review to happen mostly asynchronously via
GitHub, and [Slack](https://slack.knative.dev).

# Workflow

There are roughly two workflows: writing / contributing new content, and
refining and reviewing existing content.

## New Content

We expect most new content to be written by the subject matter expert (SME)
which would be the contributor who actually worked on the feature or example.

When writing new content, keep the following in mind:

- Write one [type of documentation](#type of documentation) per page.

- If possible, follow the style/template of other documents of the same type.

- Focus mostly on technical correctness; structure and language should be
  roughly correct, but don't need heavy review in this phase.

The goal of adding new content is to get technically correct documentation into
the repo before it is lost. Tech Writers may provide some quick guidance on
getting documentation into the correct location, but won't be providing a
detailed list of items to change.

## Refining and Reviewing Content

Once the raw documentation has made it into the repo, tech writers and other
communications experts will review and revise the documentation to make it
easier to consume. This will be done as a second PR; it's often easier for the
tech writers to clean up or rewrite a section of prose than to teach an engineer
what to do, and most engineers trust the wordsmithing the tech writers produce
more than their own.

When revising the content, the tech writer will create a new PR and send it to
the original author to ensure that the content is technically correct; they may
also ask a few clarifying questions, or add details such as diagrams or notes if
needed. It's not necessarily expected that tech writers will actually execute
the steps of a tutorial — it's expected that the SME is responsible for a
working tutorial or how-to.

# Tech Writer Guide

## Type of documentation

Keep in mind the audience (Developers or Administrators) and type of document
when organizing and reviewing documentation. See
https://documentation.divio.com/ for a more in-depth discussion of documentation
types.

## Documentation Structure

**TODO: link to intended documentation layout.** A general warning about
[Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law): documents will
naturally tend to be distributed by team that produced them. Try to fight this,
and organize documents based on where the _reader_ will look for them. (i.e. all
tutorials together, maybe with indications as to which components they use,
rather than putting all serving tutorials in one place)

Note that some reference documentation may be automatically generated and
checked in to the docs repo. This _should_ be indicated by both a `README.md` in
the top-level directory where the generation happens, and by a header at the top
of the documentation. The `README.md` should include documentation on the
original source material for the documentation as well as the commands needed to
regenerate the documentation. If possible, the generation of documentation the
should be performed automatically via nightly (GitHub actions) automation.

In some cases, the right place for a document may not be on the docs website — a
blog post, documentation within a code repo, or a vendor site may be the right
place. Be generous with offering to link to such locations; documents in the
main documentation come with an ongoing cost of keeping up to date.

## Branches

Knative attempts to
[support the last 4 releases](https://github.com/knative/community/blob/master/mechanics/RELEASE-VERSIONING-PRINCIPLES.md).
By default, new documentation should be written on the `master` branch and then
cherry-picked to the release branches if needed. Note that the default view of
<https://knative.dev/> is of the most recent release branch, which means that
changes to `master` don't show up unless explicitly cherrypicked. This also
means that documentation changes for a release _should be made during the
development cycle_, rather than at the last minute or after the release.

The
[`/cherrypick` tool](https://github.com/kubernetes/test-infra/tree/master/prow/external-plugins/cherrypicker)
can be use to automatically pull back changes from `master` to previous releases
if necessary.

## Tools and Style

Knative documentation follows the
[Google Developer Documentation Style Guide](https://developers.google.com/style/).
Use this as a reference for writing style questions.

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

# Engineer Guide

## Putting your docs in the right place

There are currently two general types of Knative docs, either contributor
related content, or external-facing user content.

### Contributor-focused content

- _Documentation_: Includes content that is component specific and relevant only
  to contributors of a given component. Contributor focused documentation is
  located in the corresponding `docs` folder of that component's repository. For
  example, if you contribute code to the Knative Serving component, you might
  need to add contributor focused information into the `docs` folder of the
  [knative/serving repo](https://github.com/knative/serving/tree/master/docs/).

- _Code samples_: Includes contributor related code or samples. Code or samples
  that are contributor focused also belong in their corresponding component's
  repo. For example, Eventing specific test code is located in the
  [knative/eventing tests](https://github.com/knative/eventing/tree/master/test)
  folder.

### User-focused content

- _Documentation_: Content for developers or administrators using Knative. This
  documentation belongs in the
  [`knative/docs` repo](https://github.com/knative/docs). All content in
  `knative/docs` is published to https://knative.dev.

- _Code samples_: Includes user-facing code samples and their accompanying
  step-by-step instructions. Code samples add a particular burden because they
  sometimes get out of date quickly; as such, not all code samples may be
  suitable for the docs repo.

  - **Knative owned and maintained**: Includes code samples that are actively
    maintained and e2e tested. To ensure content is current and balance
    available resources, only the code samples that meet the following
    requirements are located in the `docs/[*component*]/samples` folders of the
    `knative/docs` repo:

    - _Actively maintained_ - The code sample has an active Knative team member
      who has committed to regular maintenance of that content and ensures that
      the code is updated and working for every product release.

    - _Receives regular traffic_ - To avoid hosting and maintaining unused or
      stale content, if code samples are not being viewed and fail to receive
      attention or use, those samples will be moved into the
      “[community maintained](https://github.com/knative/docs/tree/master/community/samples)”
      set of samples.

    - _Passes e2e testing_ - All code samples within
      `docs/[*component*]/samples` folders must align with (and pass) the
      [`e2e` tests](https://github.com/knative/docs/tree/master/test).

  - **Community owned and maintained samples**: For sample code which doesn't
    meet the above criteria, put the code in a separate repository and link to
    it [from this document](community/samples/README.md). These samples might
    not receive regular maintenance. It is possible that a sample is no longer
    current and is not actively maintained by its original author. While we
    encourage a contributor to maintain their content, we acknowledge that it's
    not always possible for certain reasons, for example other commitments and
    time constraints.

While a sample might be out of date, it could still provide assistance and help
you get up-and-running with certain use-cases. If you find that something is not
right or contains outdated info, open an
[Issue](https://github.com/knative/docs/issues/new). The sample might be fixed
if bandwidth or available resource exists, or the sample might be taken down and
archived into the last release branch where it worked.

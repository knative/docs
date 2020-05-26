# Contributing to knative/docs

- [Before you begin](#before-you-begin)
- [Contributing to the documentation](#contributing-to-the-documentation)
- [Docs contributor roles](#docs-contributor-roles)

**First off, thanks for taking the time to contribute!**

The following are guidelines for contributing to the Knative documentation.
These are just guidelines, not rules. Use your best judgment, and feel free to
propose changes to this document in a pull request.

## Before you begin

### Code of conduct

Knative follows the
[Knative Code of Conduct](https://github.com/knative/community/blob/master/CODE-OF-CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to knative-code-of-conduct@googlegroups.com.

### Contributor license agreements

We'd love to accept your contributions! But before we can take them, you need to
fill out the [Google CLA](https://cla.developers.google.com). Important: You
must fill out the CLA with the same email address that you used to create your
GitHub account.

Once you are CLA'ed, we'll be able to accept your pull requests. This is
necessary because you own the copyright to your changes, even after your
contribution becomes part of this project. So this agreement simply gives us
permission to use and redistribute your contributions as part of the project.

Note: Your contributions are verified using the email address for which you use
to sign the CLA. Therefore,
[setting your GitHub account to private](https://help.github.com/en/articles/setting-your-commit-email-address)
is unsupported because all commits from private accounts are sent from the
`noreply` email address.

### Style guide

Knative documentation follows the
[Google Developer Documentation Style Guide](https://developers.google.com/style/). Use this as a reference for writing style questions.
use it as a reference for writing style questions.

## Contributing to the documentation

### Reporting documentation issues

Knative uses Github issues to track documentation issues and requests. If you
see a problem with the documentation, submit an issue using the following steps:

1. Check the [Knative docs issues list](https://github.com/knative/docs/issues)
   before creating an issue to avoid making a duplicate.
2. Use the [correct template](https://github.com/knative/docs/issues/new) for
   your new issue. There are two templates available:
   - **Bug report**: If you're reporting an error in the existing documentation,
     use this template. This could be anything from broken samples to typos.
     When you create a bug report, include as many details as possible and
     include suggested fixes to the issue. If you know which Knative component
     your bug is related to, you can assign the appropriate
     [Working Group Lead](https://github.com/knative/community/blob/master/working-groups/WORKING-GROUPS.md).
   - **Feature request**: For upcoming changes to the documentation or requests
     for more information on a particular subject.

Note that code issues should be filed against the
[individual Knative repositories](http://github.com/knative), while
documentation issues should go in the
[`knative/docs`repo](https://github.com/knative/docs/issues). If the issue is
specific to the [https://knative.dev](https://knative.dev) website, open the
issue in the [`knative/website`repo](https://github.com/knative/website/issues).

### Working group

The
[Knative Documentation Working Group](https://github.com/knative/community/blob/master/working-groups/WORKING-GROUPS.md#documentation)
meets biweekly on Tuesdays at 9:30am PT.
[Click here](https://calendar.google.com/calendar/embed?src=google.com_18un4fuh6rokqf8hmfftm5oqq4%40group.calendar.google.com)
to see the exact dates on the Knative working group calendar.

If you're interested in becoming more involved in Knative's documentation, start
attending the working group meetings. You'll meet the writers currently steering
our documentation efforts, who are happy to help you get started.

### Getting started

There are a couple of different ways to get started with contributing to the Knative documentation:

- Look for a
  [Good First Issue](https://github.com/knative/docs/labels/kind%2Fgood-first-issue)
  in the backlog.

- Try out Knative and send us feedback. For example, run through one of the
  [install guides](docs/install/README.md) and then try
  [Getting Started with Knative Serving](docs/serving/getting-started-knative-app.md).

  You should keep a
  [friction log](https://devrel.net/developer-experience/an-introduction-to-friction-logging)
  of your experience and then use that to open your first set of PRs. Examples:

  - What was difficult for you?
  - Did you stumble on something because the steps weren't clear?
  - Was a dependency not mentioned?

**A few pointers and other considerations**

- Think about how you can improve the documentation as a whole. For example, how
  can you fix the issue you found so that others don't run into the same
  challenges?

- Are there multiple places the issue could be fixed?

  - Are there other pages which you should also update?

  - Would it help if there was a link to more or related information on a page?
    On a related page?

- Was the title or description misleading? Did you expect to find something
  different in that docs section?

- If you find something and don't have the bandwidth to open a PR, make us aware
  of the pain point and open an
  [Issue](https://github.com/knative/docs/issues/new).

### Submitting documentation PRs - what to expect

Here's what generally happens when you open a PR against the `knative/docs`
repo:

1. One of the assigned repo maintainers will triage the PR by assigning relative
   priority, adding appropriate labels, and performing an initial documentation
   review.
1. If the PR involves significant technical changes, for example new features,
   or new and changed sample code, the PR is assigned to a Subject Matter Expert
   (SME), typically an engineer working on Knative, for technical review and
   approval.
1. When both the technical writers and SMEs are satisfied with the quality of
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
[Slack channel](https://knative.slack.com/) to get input on your ideas before
creating a PR.

### Putting your docs in the right place

There are currently two general types of Knative docs, either contributor
related content, or external-facing user content.

#### Choosing the correct repo

Depending on the type of content that you want to contribute, it might belong in
one of the Knative code repositories (`knative/serving`, `knative/eventing`,
etc.) or in `knative/docs`, the Knative documentation repo.

- **Contributor-focused content**

  - _Documentation_: Includes content that is component specific and relevant
    only to contributors of a given component. Contributor focused documentation
    is located in the corresponding `docs` folder of that component's
    repository. For example, if you contribute code to the Knative Serving
    component, you might need to add contributor focused information into the
    `docs` folder of the
    [knative/serving repo](https://github.com/knative/serving/tree/master/docs/).

  - _Code samples_: Includes contributor related code or samples. Code or
    samples that are contributor focused also belong in their corresponding
    component's repo. For example, Eventing specific test code is located in the
    [knative/eventing tests](https://github.com/knative/eventing/tree/master/test)
    folder.

- **User-focused content**

  - _Documentation_: Includes all content for Knative users. The external-facing
    user documentation belongs in the
    [`knative/docs` repo](https://github.com/knative/docs). All content in
    `knative/docs` is published to [https://knative.dev](https://knative.dev).

  - _Code samples_: Includes user-facing code samples and their accompanying
    step-by-step instructions. User code samples are currently separated into
    two different locations within the `knative/docs` repo. See the following
    section for details about determining where you can add your code sample.

##### Determining where to add user focused code samples

There are currently two categories of user-focused code samples, _Knative owned
and maintained_ and _Community owned and maintained_.

- **Knative owned and maintained**: Includes code samples that are actively
  maintained and e2e tested. To ensure content is current and balance available
  resources, only the code samples that meet the following requirements are
  located in the `docs/[*component*]/samples` folders of the `knative/docs`
  repo:

  - _Actively maintained_ - The code sample has an active Knative team member
    who has committed to regular maintenance of that content and ensures that
    the code is updated and working for every product release.
  - _Receives regular traffic_ - To avoid hosting and maintaining unused or
    stale content, if code samples are not being viewed and fail to receive
    attention or use, those samples will be moved into the
    "[community maintained](https://github.com/knative/docs/tree/master/community/samples)"
    set of samples.
  - _Passes e2e testing_ - All code samples within `docs/[*component*]/samples`
    folders must align with (and pass) the
    [`e2e` tests](https://github.com/knative/docs/tree/master/test).

  Depending on the Knative component covered by the code sample that you want to
  contribute, your PR should add that sample in one of the following folders:

  - Eventing samples:
    [`/docs/eventing/samples`](https://github.com/knative/docs/tree/master/docs/eventing/samples)
  - Serving samples:
    [`/docs/serving/samples`](https://github.com/knative/docs/tree/master/docs/serving/samples)

- **Community owned and maintained samples**: Code samples that have been
  contributed by Knative community members. These samples might not receive
  regular maintenance. It is possible that a sample is no longer current and is
  not actively maintained by its original author. While we encourage a
  contributor to maintain their content, we acknowledge that it's not always
  possible for certain reasons, for example other commitments and time
  constraints.

While a sample might be out of date, it could still provide assistance and help
you get up-and-running with certain use-cases. If you find that something is not
right or contains outdated info, open an
[Issue](https://github.com/knative/docs/issues/new). The sample might be fixed
if bandwidth or available resource exists, or the sample might be taken down and
archived into the last release branch where it worked.

#### Choosing the correct branch

It is likely that your docs contribution is either for new or changed features
in the product, or for a fix or update existing content.

- **New or changed features**: If you are adding or updating documentation for a
  new or changed feature, you likely want to open your PR against the `master`
  branch. All pre-release content for active Knative development belongs in
  [`master`](https://github.com/knative/docs/tree/master/).

- **Fixes and updates**: If you find an issue in a past release, for example a
  typo or out-of-date content, you likely need to open multiple and subsequent
  PRs. If not a followup PR, at least add the "`cherrypick` labels" to your
  original PR to indicate in which of the past release that your change affects.

  For example, if you find a typo in a page of the `v0.5` release, then that
  page in the `master` branch likely also has that typo.

  To fix the typo:

  1.  Open a PR against the
      [`master`](https://github.com/knative/docs/tree/master/) branch.
  1.  Add one or more `cherrypick-#.#` labels to that PR to indicate which of
      the past release branches should also be fixed. Generally, we only
      maintain the most recent numbered release.
  1.  If you want to complete the fix yourself (**best practice**), you then
      open a subsequent PR by running `git cherry-pick [COMMIT#]` against the
      `release-0.5`. Where `[COMMIT#]` is the commit of the PR that you merged
      in `master`.

      Note: Depending on workload and available bandwidth, one of the Knative
      team members might be able to help handle the `git cherry-pick` in order
      to push the fix into the affected release branch(es).

See a list of the available documentation versions in the
[branches page](https://github.com/knative/docs/branches) of the `knative/docs`
repo.

## Assigning owners and reviewers

For both documentation and code samples, you should assign your PR to a single
owner ("_Assignee_") using the `/assign` Prow command. It's best to set the
"Assignee" and include other stakeholders as "Reviewers" rather than leaving it
unassigned or allowing [Prow](https://prow.k8s.io/command-help) to auto assign
reviewers.

Use the `/assign` command to set the owner. For example: `/assign @owner_id`

For code samples, initially set the owner of your PR to the SME who should
review for technical accuracy. If you don't know who the appropriate owner is,
nor who your reviewers should be for your PR, you can assign the
[current working group lead](https://github.com/knative/community/blob/master/working-groups/WORKING-GROUPS.md)
of the related component.

If you want to notify and include other stakeholders in your PR review, use the
`/cc` command. For example: `/cc @stakeholder_id1 @stakeholder_id2`

## Docs contributor roles

Because contributing to the documentation requires a different skill set than
contributing to the Knative code base, we've defined the roles of documentation
contributors separately from the roles of code contributors.

If you're looking for code contributor roles, see
[ROLES](https://github.com/knative/community/blob/master/ROLES.md).

### Member

Established contributor to the Knative docs.

Members are continuously active contributors in the community. They can have
issues and PRs assigned to them, might participate in working group meetings,
and pre-submit tests are automatically run for their PRs. Members are expected
to remain active contributors to the Knative documentation.

All members are encouraged to help with PR reviews, although each PR must be
reviewed by an official [Approver](#approver). In their review, members should
be looking for technical correctness of the documentation, adherence to the
[style guide](https://developers.google.com/style/), good spelling and grammar
(writing quality), intuitive organization, and strong documentation usability.
Members should be proficient in at least one of these review areas.

### Requirements

- Has made multiple contributions to the project or community. Contributions
  might include, but are not limited to:

  - Authoring and reviewing PRs on GitHub in the Docs or Website repos.

  - Filing and commenting on issues on GitHub.

  - Contributing to working group or community discussions.

- Subscribed to
  [knative-dev@googlegroups.com](https://groups.google.com/forum/#!forum/knative-dev).

- Actively contributing to 1 or more areas.

- Sponsored by 1 approver.

  - Done by adding GitHub user to Knative organization.

### Responsibilities and privileges

- Responsive to issues and PRs assigned to them.

- Active owner of documents they have contributed (unless ownership is
  explicitly transferred).

  - Addresses bugs or issues in their documentation in a timely manner.

### Becoming a member

First, reach out to an approver and ask them to sponsor you so that you can
become a member. The easiest way to do this is using Slack.

If they are supportive of your membership, your sponsor will reach out to the
Knative Steering committee to ask that you be added as a member of the Knative
org.

Once your sponsor notifies you that you've been added to the Knative org, open a
PR to add yourself as a docs-reviewer in the
[OWNERS_ALIASES](https://github.com/knative/docs/tree/master/OWNERS_ALIASES)
file.

## Approver

Docs approvers are able to both review and approve documentation contributions.
While documentation review is focused on writing quality and correctness,
approval is focused on holistic acceptance of a contribution including:
long-term maintainability, adhering to style guide conventions, overall
information architecture, and usability from an engineering standpoint. Docs
approvers will enlist help from engineers for reviewing code-heavy contributions
to the Docs repo.

### Requirements

- Reviewer of the Docs repo for at least 3 months.

  - Proficient in reviewing all aspects of writing quality, including grammar
    and spelling, adherence to style guide conventions, organization, and
    usability. Can coach newer writers to improve their contributions in these
    areas.

- Primary reviewer for at least 10 substantial PRs to the docs, showing
  substantial ability to coach for writing development.

- Reviewed or merged at least 30 PRs to the docs.

- Nominated by an area lead (with no objections from other leads).

  - Done through PR to update an OWNERS file.

### Responsibilities and privileges

- Responsible for documentation quality control via PR reviews.

  - Focus on long-term maintainability, adhering to style guide conventions,
    overall information architecture, and usability from an engineering
    standpoint.

- Expected to be responsive to review requests as per
  [community expectations](https://github.com/knative/community/blob/master/REVIEWING.md).

- Mentor members and contributors to improve their writing.

- Might approve documentation contributions for acceptance, but will ask for
  engineering review for code-heavy contributions.

### Becoming an approver

If you want to become an approver, make your goal clear to the current Knative
Docs approvers, either by contacting them in Slack or announcing your intention
to become an approver at a meeting of the Documentation Working Group.

Once you feel you meet the criteria, you can ask one of the current approvers to
nominate you to become an approver. If all existing approvers agree that you
meet the criteria open a PR to add yourself as a docs-approver in the
[OWNERS_ALIASES](https://github.com/knative/docs/tree/master/OWNERS_ALIASES)
file.

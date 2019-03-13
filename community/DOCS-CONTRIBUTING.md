# Contributing to the Knative Documentation

- [Before you begin](#before-you-begin)
- [Contributing to the documentation](#contributing-to-the-documentation)
- [Docs contributor roles](#docs-contributor-roles)

**First off, thanks for taking the time to contribute!**

The following are guidelines for contributing to the Knative documentation.
These are just guidelines, not rules. Use your best judgment, and feel free to
propose changes to this document in a pull request.

## Before you begin

### Code of conduct

Knative follows the [Knative Code of Conduct](./CODE-OF-CONDUCT.md). By
participating, you are expected to uphold this code. Please report unacceptable
behavior to knative-code-of-conduct@googlegroups.com.

### Style guide

Knative documentation follows the
[Google Developer Documentation Style Guide](https://developers.google.com/style/);
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
     [Working Group Lead](./WORKING-GROUPS.md).
   - **Feature request**: For upcoming changes to the documentation or requests
     for more information on a particular subject.

Note that code issues should be filed against the
[individual Knative repositories](http://github.com/knative), while
documentation issues should go in the `docs` repository.


### Working group

The [Knative Documentation Working Group](./WORKING-GROUPS.md#documentation)
meets weekly on Tuesdays and alternates between a 9am PT and a 4:30pm PT time to
accommodate contributors in both the EMEA and APAC timezones.
[Click here](https://calendar.google.com/calendar/embed?src=google.com_18un4fuh6rokqf8hmfftm5oqq4%40group.calendar.google.com)
to see the exact dates on the Knative working group calendar. If you're
interested in becoming more involved in Knative's documentation, start attending
the working group meetings. You'll meet the writers currently steering our
documentation efforts, who are happy to help you get started.

### Getting started

There are a couple different ways to jump in to the Knative doc set:

- Look at issues in the Docs repo labled
  [Good First Issue](https://github.com/knative/docs/labels/kind%2Fgood-first-issue).
- Run through the [install guide](../install/README.md) for the platform of your
  choice, as well as the
  [Getting Started with Knative App Deployment](../install/getting-started-knative-app.md)
  guide, and keep a
  [friction log](https://devrel.net/developer-experience/an-introduction-to-friction-logging)
  of the experience. What was hard for you? Then open a PR with a few
  improvements you could make from the friction log you kept. How can you make
  the documentation better so that others don't run into the same issues you
  did?

### Submitting documentation PRs - what to expect

Here's what will happen after you open a PR in the Docs repo:

1. One of the Docs approvers will triage the PR and provide an initial
   documentation review as soon as possible.
   1. If the PR involves significant changes or additions to sample code, we'll
      flag it for engineer review.
1. Once we're satisfied with the quality of the writing and the accuracy of the
   content, we'll approve the change.

If you're making a change to the documentation, you should submit a PR against
the master branch.

### Putting your docs in the right place

Knative uses the [docs repository](https://github.com/knative/docs) for all
general documentation for Knative components. However, formal specifications or
documentation most relevant to contributors of a component should be placed in
the `docs` folder in a given component's repository. An example of this is the
[spec](https://github.com/knative/serving/tree/master/docs/spec) folder in the
Serving component.

Code samples follow a similar strategy, where most code samples should be
located in the `docs` repository. If there are code samples used for testing
that are only expected to be used by contributors, those samples are put in the
`samples` folder within the component repo.

## Docs contributor roles

Because contributing to the documentation requires a different skill set than
contributing to the Knative code base, we've defined the roles of
documentation contributors seperately from the roles of code contributors.

If you're looking for code contributor roles, see [ROLES](./ROLES.md).

### Member

Established contributor to the Knative docs.

Members are continuously active contributors in the community. They can have
issues and PRs assigned to them, might participate in working group meetings, and
pre-submit tests are automatically run for their PRs. Members are expected to
remain active contributors to the Knative documentation.

All members are encouraged to help with PR reviews, although each PR
must be reviewed by an official [Approver](#approver). In their review,
members should be looking for technical correctness of the documentation,
adherence to the [style guide](https://developers.google.com/style/), good spelling and grammar (writing quality),
intuitive organization, and strong documentation usability. Members should be
proficient in at least one of these review areas.

### Requirements

- Has made multiple contributions to the project or community. Contributions might
  include, but are not limited to:

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

- Active owner of documents they have contributed (unless ownership is explicitly
  transferred).
  
  - Addresses bugs or issues in their documentation in a timely manner.
  
### Becoming a member

First, reach out to an approver and ask them to sponsor you so that you can become a member.
The easiest way to do this is using Slack.

Your sponsor will reach out to the Knative Steering committee to ask that you be added
as a member of the Knative org if they are supportive of you becoming a member. 

Once your sponsor notifies you that you've been added to the Knative org,
open a PR to add yourself as a docs-reviewer in the
[OWNERS_ALIASES](../OWNERS_ALIASES) file.
  
## Approver

Docs approvers are able to both review and approve documentation contributions.
While documentation review is focused on writing quality and correctness,
approval is focused on holistic acceptance of a contribution including:
long-term maintainability, adhering to style guide conventions, overall information
architecture, and usability from an engineering standpoint. Docs approvers will
enlist help from engineers for reviewing code-heavy contributions to the Docs repo.

### Requirements

- Reviewer of the Docs repo for at least 3 months.
  
  - Proficient in reviewing all aspects of writing quality, including grammar and
    spelling, adherence to style guide conventions, organization, and usability.
    Can coach newer writers to improve their contributions in these areas.
  
- Primary reviewer for at least 10 substantial PRs to the docs, showing substantial
  ability to coach for writing development.

- Reviewed or merged at least 30 PRs to the docs.

- Nominated by an area lead (with no objections from other leads).

  - Done through PR to update an OWNERS file.

### Responsibilities and privileges

- Responsible for documentation quality control via PR reviews.

  - Focus on long-term maintainability, adhering to style
    guide conventions, overall information architecture, and usability from
    an engineering standpoint.

- Expected to be responsive to review requests as per
  [community expectations](REVIEWING.md).

- Mentor members and contributors to improve their writing.

- Might approve documentation contributions for acceptance, but will ask for
  engineering review for code-heavy contributions.

### Becoming an approver

If you want to become an approver, make your goal clear to the current
Knative Docs approvers, either by contacting them in Slack or announcing
your intention to become an approver at a meeting of the Documentation
Working Group.

Once you feel you meet the criteria, you can ask one of the current
approvers to nominate you to become an approver. If all existing
approvers agree that you meet the criteria open a PR to add yourself
as a docs-approver in the [OWNERS_ALIASES](../OWNERS_ALIASES) file.

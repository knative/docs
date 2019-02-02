---
title: "Contributing to the Knative documentation"
linkTitle: "Contributing to docs"
weight: 20
type: "docs"
---

**First off, thanks for taking the time to contribute!**

The following are guidelines for contributing to the Knative documentation.
These are just guidelines, not rules. Use your best judgment, and feel free to
propose changes to this document in a pull request.

## Before you begin

### Code of conduct

Knative follows the [Knative Code of Conduct](../CODE-OF-CONDUCT/). By
participating, you are expected to uphold this code. Please report unacceptable
behavior to knative-code-of-conduct@googlegroups.com.

### Style guide

Knative documentation follows the
[Google Developer Documentation Style Guide](https://developers.google.com/style/);
use it as a reference for writing style questions.

## Reporting documentation issues

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
     [Working Group Lead](../WORKING-GROUPS/).
   - **Feature request**: For upcoming changes to the documentation or requests
     for more information on a particular subject.

Note that code issues should be filed against the
[individual Knative repositories](http://github.com/knative), while
documentation issues should go in the `docs` repository.

## Contributing to the documentation

### Working group

The [Knative Documentation Working Group](../WORKING-GROUPS/#documentation)
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
- Run through the [install guide](../../install/docs/README.md) for the platform of your
  choice, as well as the
  [Getting Started with Knative App Deployment](../../install/docs/getting-started-knative-app/)
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

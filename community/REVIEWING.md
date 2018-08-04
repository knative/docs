# Reviewing and Merging Pull Requests for Knative

As a community, we believe in the value of code reviews for all contributions.
Code reviews increase both the quality and readability of our code base, which
in turn produces high quality software.

This document provides guidelines for how the project's
[Members](ROLES.md#member) review issues and merge pull requests (PRs).

*   [Pull requests welcome](#pull-requests-welcome)
*   [Code of Conduct](#code-of-conduct)
*   [Code reviewers](#code-reviewers)
*   [Reviewing changes](#reviewing-changes)
    *   [Holds](#holds)
*   [Project maintainers](#project-maintainers)
*   [Merging PRs](#merging-prs)

## Pull requests welcome

First and foremost: as a potential contributor, your changes and ideas are
welcome at any hour of the day or night, weekdays, weekends, and holidays.
Please do not ever hesitate to ask a question or submit a PR.

## Code of Conduct

Reviewers are often the first points of contact between new members of the
community and are important in shaping the community. We encourage reviewers
to read the [code of conduct](community/CODE-OF-CONDUCT.md) and to go above and beyond
the code of conduct to promote a collaborative and respectful community.

## Code reviewers

The code review process can introduce latency for contributors and additional
work for reviewers, frustrating both parties. Consequently, as a community
we expect all active participants to also be active reviewers. Participate in
the code review process in areas where you have expertise.

## Reviewing changes

Once a PR has been submitted, reviewers should do an initial review to do a
quick "triage" (e.g. close duplicates, identify user errors, etc.), and
potentially identify which maintainers should be the focal points for the
review.

If a PR is closed without accepting the changes, reviewers are expected to
provide sufficient feedback to the originator to explain why it is being closed.

During a review, PR authors are expected to respond to comments and questions
made within the PR - updating the proposed change as appropriate.

After a review of the proposed changes, reviewers can either approve or reject
the PR. To approve, they add an "approved" review to the PR. To reject, they
add a "request changes" review along with a full justification for why they
are not in favor of the change. If a PR gets a "request changes" vote, the
group discusses the issue to resolve their differences.

Reviewers are expected to respond in a timely fashion to PRs that are assigned
to them. Reviewers are expected to respond to *active* PRs with reasonable
latency. If reviewers fail to respond, those PRs may be assigned to other
reviewers. *Active* PRs are those that have a proper CLA (`cla:yes`) label, are
not works in progress (WIP), are passing tests, and do not need rebase to be
merged. PRs that do not have a proper CLA, are WIP, do not pass tests, or
require a rebase are not considered active PRs.

### Holds

Any [Approver](ROLES.md#approver) who wants to review a PR but does not have
time immediately can put a hold on a PR. If you need more time, say so on the
PR discussion and offer an ETA measured in single-digit days at most. Any PR
that has a hold will not be merged until the person who requested the hold
acks the review, withdraws their hold, or is overruled by a majority of
approvers.

## Approvers

Merging of PRs is done by [Approvers](ROLES.md#approver).

As is the case with many open source projects, becoming an Approver is based
on contributions to the project. See our [community roles](ROLES.md) document for
information on how this is done.

## Merging PRs

A PR can be merged only after the following criteria are met:

1.  It has no "request changes" review from a reviewer.
1.  It has at least one "approved" review by at least one of the approvers of
    that repository.
1.  It has all appropriate corresponding documentation and tests.

## Prow

This project uses
[Prow](https://github.com/kubernetes/test-infra/tree/master/prow) to
automatically run tests for every PR. PRs with failing tests might not be
merged. If necessary, you can rerun the tests by simply adding the comment
`/retest` to your PR.

Prow has several other features that make PR management easier, like running the
go linter or assigning labels. For a full list of commands understood by Prow,
see the [command help page](https://prow.knative.dev/command-help).

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).

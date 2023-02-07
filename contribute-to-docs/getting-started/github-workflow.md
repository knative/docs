# GitHub workflow for Knative documentation

Learn how to use GitHub and contribute to the `knative/docs` repo.


## Set up your local machine

To check out your fork of the `knative/docs` repository:

1. Create your own
   [fork](https://help.github.com/articles/fork-a-repo/) of the [`knative/docs` repo](https://github.com/knative/docs).
1. Configure
   [GitHub access through SSH](https://help.github.com/articles/connecting-to-github-with-ssh/).
1. Clone your fork to your machine and set the `upstream` remote to the
   `knative/docs` repository:

    ```bash
    mkdir -p ${GOPATH}/src/knative.dev
    cd ${GOPATH}/src/knative.dev
    git clone git@github.com:${YOUR_GITHUB_USERNAME}/docs.git
    cd docs
    git remote add upstream https://github.com/knative/docs.git
    git remote set-url --push upstream no_push
    ```

You are now able to open PRs, start reviews, and contribute fixes the
`knative/docs` repo. See the following sections to learn more.

**Important**: Remember to regularly [sync your fork](https://help.github.com/articles/syncing-a-fork/).


## Report documentation issues

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
      [Working Group Lead](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md).

    - **Feature request**: For upcoming changes to the documentation or requests
      for more information on a particular subject.

Note that product behavior or code issues should be filed against the
[individual Knative repositories](http://github.com/knative).

Documentation issues should go in the
[`knative/docs` repo](https://github.com/knative/docs/issues).


## Open PRs to fix documentation issues

The Knative documentation follows the standard
[GitHub collaboration flow](https://guides.github.com/introduction/flow/)
for Pull Requests (PRs).

General details about how to open a PR are covered in the
[Knative guidelines](https://github.com/knative/community/).

<!-- This could use a pass to be more focused on what a PR submitter should do at the start of the process. -->

1. [Ensure that your fork is up-to-date](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork).

1. [Create a branch in your fork](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-and-deleting-branches-within-your-repository).

1. Locate or create the file that you want to fix:

   - If you are updating an existing page, locate that file and begin making
     changes.

     For example, from any page on the Knative website, you can click the
     pencil icon in the upper right corner to open that page in GitHub.

   - If you are adding new content, you must follow the
     "new docs" instructions.

1. To edit a file, use the new branch that you created in your fork.

   - Navigate to that same file within your fork using the GitHub UI.

   - Open that file from in your local clone.

1. Create the Pull Request in the
   [`knative/docs` repo](https://github.com/knative/docs/pulls).

1. [Assign an owner to the PR](#assigning-owners-and-reviewers)
   to request a review.

### PR review process

Here's what generally happens after you send the PR for review:

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

    - The [Knative technical writers](https://github.com/knative/docs/blob/main/OWNERS_ALIASES)
      are who provide the `approved` label when the content meets quality,
      clarity, and organization standards (see the [Knative style guide](../style-guide/README.md)).

We appreciate contributions to the docs, so if you open a PR we will help you
get it merged. You can also post in the `#knative-documentation`
[Slack channel](https://cloud-native.slack.com/archives/C04LY5G9ED7) to get input on your ideas or find
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
[current working group lead](https://github.com/knative/community/tree/main/working-groups/WORKING-GROUPS.md) of the related component.

If you want to notify and include other stakeholders in your PR review, use the
`/cc` command. For example: `/cc @stakeholder_id1 @stakeholder_id2`


## Reviewing PRs

[See the Knative community guidelines about reviewing PRs](https://github.com/knative/community/blob/main/REVIEWING.md)


## Using Prow to manage PRs and Issues

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

- See [Cherrypicking](branches-and-cherrypicking.md#cherrypicking) for details about how
  to use the `/cherrypick` command.

### Common GitHub PRs FAQs

* The CLA check fails even though you have signed the CLA. This may occur if you accept and commit
suggestions in a pull request from another person's account, because the email address of that
account doesn't match the address on record for the CLA.
The commit will show up as co-authored, which can cause issues if your public email address has not
signed the CLA.

* One or more tests are failing. If you do not see a specific error related to a change you made,
and instead the errors are related to timeouts, try re-running the test at a later time.
There are running tasks that could result in timeouts or rate limiting if your test runs at the same
time.

* Other Issues/Unsure -- reach out in the `#knative-documentation` Slack channel and someone will be happy to help out.

# Becoming a contributor

## Join to become a contributor

You must meet the following prerequisites before you are able to contribute to
the docs. The following steps are specific to docs contributions.
For more information about contributing to the Knative project, see the
[Knative contribution guidelines](https://github.com/knative/community/blob/main/CONTRIBUTING.md).

1. If you don't already have an account, you must create
   [a new GitHub account](https://github.com/join).

1. Become a Knative Member by subscribing to
   [knative-dev@googlegroups.com](https://groups.google.com/forum/#!forum/knative-dev).

   [Learn more about community roles](https://github.com/knative/community/tree/main/ROLES.md)

1. Read and follow the
   [Knative Code of Conduct](https://github.com/knative/community/blob/main/CODE-OF-CONDUCT.md).

   By participating, you are expected to uphold this code. Please report all
   unacceptable behavior to <knative-code-of-conduct@googlegroups.com>.

1. Sign the the CNCF contributor license agreement (CLA), [EasyCLA](https://easycla.lfx.linuxfoundation.org/).

   **Important:** You must fill out the CLA with the same email address that you
   used to create your GitHub account. Also see the note about private accounts.

   After you have signed the CLA, your pull requests can be accepted. This is necessary because you own the copyright to your changes, even after your contribution becomes part of this project. So this agreement simply gives us permission to use and redistribute your contributions as part of the project.

   Private accounts not supported: Your contributions are verified using the
   email address for which you use to sign the CLA. Therefore,
   [setting your GitHub account to private](https://help.github.com/en/articles/setting-your-commit-email-address)
   is unsupported because all commits from private accounts are sent from the
   `noreply` email address.

## Tips: Get involved

There are a couple of different ways to get started with contributing to the
Knative documentation:

- Look for a
  [Good First Issue](https://github.com/knative/docs/labels/kind%2Fgood-first-issue)
  in the backlog.

- Try out Knative and
  [send us feedback](https://github.com/knative/docs/issues/new?template=docs-feature-request.md).

  Keep a
  [friction log](https://devrel.net/developer-experience/an-introduction-to-friction-logging)
  of your experience and attach it to a feature request, or use it to open your
  first set of PRs. Examples:

  - What was difficult for you?
  - Did you stumble on something because the steps weren't clear?
  - Was a dependency not mentioned?

## Get help from the community

- [#knative-documentation on the CNCF Slack](https://cloud-native.slack.com/archives/C04LY5G9ED7) -- The #docs channel
  is the best place to go if you have questions about making changes to the
  documentation. We're happy to help!

- Attend a Documentation working group meeting
  -- Come join us to ask questions, get help, and meet other docs contributors.

  [See meeting details, times, and the agenda](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md#documentation--user-experience)

## Workflow overview

We expect most new content to be written by the subject matter expert (SME)
which would be the contributor who actually worked on the feature or example.

When writing new content, focus mostly on technical correctness and thoroughness
(it must include all the steps that are required by the target audience).
Language should be roughly correct, but don't need heavy review in this phase.

The goal of adding new content is to get technically correct documentation into
the repo before it is lost. Tech Writers may provide some quick guidance on
getting documentation into the correct location, but won't be providing a
detailed list of items to change.

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

## Further resources

For further resources to help you to contribute to Knative documentation, see
the [Knative docs contributor guide README](../README.md).

For more information about Knative's values and processes, see the
[community repo](https://github.com/knative/community).

# Knative Repository Guidelines

This document outlines a structure for creating and associating code repositories
with the Knative project. It also describes how and when repositories are removed.

## Core Repositories

Core repositories are considered core components of Knative. They are utilities, tools,
applications, or libraries that form or support the foundation of the project.

### Rules

* Repository must live under github.com/knative/project-name
* Must adopt the Knative Code of Conduct
* All code projects use the Apache License version 2.0. Documentation repositories must use
  Creative Commons License version 4.0.
* All OWNERS must be members of the Knative community.
* Repository must be approved by the Technical Oversight Committee.

## Removing Repositories

As important as it is to add new repositories, it is equally important to prune repositories
when necessary.

It is important to the success of Knative that all Knative repositories stay active, healthy,
and aligned with the scope and mission of project.

### Grounds for removal

Core repositories may be removed from the project if they are deemed _inactive_.
Inactive repositories are those that meet any of the following criteria:

* There are no longer any active maintainers for the project, and no replacements can be found.
* All PRs and issues have gone un-addressed for longer than six months.
* There have been no new commits or other changes in more than a year.
* The contents have been folded into another actively maintained project.

### Procedure for removal

When a repository has been deemed eligible for removal, we take the following steps:

* A proposal to remove the repository is brought to the attention of the Technical Oversight Committee
  through a GitHub issue posted in the [docs](https://github.com/knative/docs) repo.
  * Feedback is encouraged during a Technical Oversight Committee meeting before any action is taken.
* Once the TOC has approved of the removal, if the repo is not moving to another actively maintained project:
  * The repo description is edited to start with the phrase "[EOL]"
  * All open issues and PRs are closed
  * All external collaborates are removed
  * All webhooks, apps, integrations, or services are removed
  * GitHub pages are disabled
  * The repo is marked as archived using GitHub's archive feature
  * The removal is announced on the knative-dev mailing list

This procedure maintains the complete record of issues, PRs, and other contributions. It leaves
the repository read-only and makes it clear that the repository is retired and no longer maintained.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
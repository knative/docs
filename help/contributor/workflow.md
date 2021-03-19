---
title: "New and changed docs workflow"
linkTitle: "Docs workflow"
weight: 10
type: "authoring"
---

There are generally two workflows for contributing to the docs, one for creating
new content and another for updating existing content.

Note: These guides are living documents. Guidelines will be added or updated as
we identify other items and refine the style guide and process around the docs.

## New content


- New content templates:
  - [Documenation](./template-docs-page.md) -- Instructions and a template that
    you can use to help you add new documentation.
  - [Blog](./template-blog-entry.md) -- Instructions and a template that
    you can use to help you post to the Knative blog.

We expect most new content to be written by the subject matter expert (SME)
which would be the contributor who actually worked on the feature or example.

When writing new content, keep the following in mind:

- Focus mostly on technical correctness and thoroughness. Language should be
  roughly correct, but don't need heavy review in this phase.

The goal of adding new content is to get technically correct documentation into
the repo before it is lost. Tech Writers may provide some quick guidance on
getting documentation into the correct location, but won't be providing a
detailed list of items to change.

## Existing content

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


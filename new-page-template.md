# Documentation Template

This page is intended to provide best-practices for starting a new document.

## Frontmatter

[Hugo](https://gohugo.io/) uses a set of metadata at the beginning of
the page called
[frontmatter](https://gohugo.io/content-management/front-matter/) to
indicate information like the page title and link rendering in the
sidebar.

Frontmatter needs to be formatted like this:
```yaml
---
# This section is called the "frontmatter" for your page
title: "Title for your page" # Use sentence case for titles
linkTitle: "Template: New docs page"
# The linkTitle field (above) is optional; use it to provide a shorter link if your page title is very long
weight: 50 # This affects the placement of the link in the sidebar on the left. Pages are ordered from top to bottom by weight, lowest to highest.
type: "docs" # You won't need to update this.
#aliases:
#  - /docs/example/redirect/moved-renamed-page
#  - /docs/another-example
# Has the page ever moved? If yes, include the prior location above, starting with path from the site root (for example /docs/, /blog/, or /community/). The old URL will redirect to this new file. For a new pages, "aliases" are not required.
---
```

This guide shows you how to do something very cool. Make sure to include
a value proposition for the user: for example, this guide shows you how to do X,
which is useful for doing Y and Z. Make sure you answer the questions "what does
this guide show you how to do?" and "why would someone want to do this?".

## Before you begin

You need:

- A Kubernetes cluster with [Knative installed](docs/install/README.md). <!-- Update this relative link as needed,
depending on where the new page is located in the file structure. -->
- Anything else?

## Break steps into logical sections

Avoid nesting headings directly on top of each other with no text in between.

1. Use ordered lists for steps.

1. Step number two.

1. Step number three.

<!-- GitHub's markdown processor will correctly automate the numbers in ordered
	 lists if every list item starts with one. Our site has a known issue with
	 rendering the numbers in ordered lists (see https://github.com/knative/docs/issues/1202)
     but we still recommend contributors avoid manually numbered ordered lists. -->

### You can use smaller sections within sections for related tasks

Avoid nesting headings directly on top of each other with no text in between.

Put code into a code block.

1. Here's a code snippet:
   <!-- Use spaces and not tabs to indent code blocks, and leave one blank line before and after the block. -->
   ```bash
   kubectl apply --filename test.yaml
   ```
1. Another code snippet:

   ```bash
   kubectl apply --filename test2.yaml
   ```

Always explain code snippets thoroughly so that how they work or what they do
is clear.

## Cleaning up

If your guide installs a sample application, show the user how to delete it.

## What's next

Provide links to other relevant topics, if applicable. Once someone has
completed these steps, what might they want to do next?

- [Link](./search.md) <!-- Always use relative links if linking to a page within the Docs repo. -->
- [Link](./search.md)
- [Link](./search.md)

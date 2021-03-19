# _index.md page template instructions

An example template with best-practices that you can use for creating a
new `_index.md` file.

Generally, you only need to create a `_index.md` file if are creating a new
folder that contains (or will contain) multiple pages. Best practice is to
avoid creating a folder that includes only a single page.
[Learn more about the `_index.md` file](https://gohugo.io/content-management/organization/#index-pages-_indexmd).

[**Copy a version of this template without the instructions**](#copy-the-template)

## Frontmatter

[Hugo](https://gohugo.io/) uses a set of metadata at the beginning of each page
called [frontmatter](https://gohugo.io/content-management/front-matter/)
to define website build required info as well as other blog page details.

Frontmatter is strict YAML syntax and must be added to the top of every
page. Example formatting template:

```yaml
---
title: ""
#linkTitle: ""
weight: 50
type: "docs"
showlandingtoc: "false"
---
```
```
<!--
# This section is called the "frontmatter" for your page that is defined in YAML.

---
title: ""
# The title of this page (renders at the top of the page). Use sentence case.

linkTitle: ""
# Optional: Use it to provide a shorter title for the page link so that it fits
# in the left navigation menu (to prevent wrapping)

weight: ""
# This specifies the vertical the placement of the page link in the left
#  navigation menu. Pages are ordered from top (lowest weight) to bottom (highest weight).

type: "docs"
# You won't need to update this.

aliases:
  - /docs/example/redirect/moved-renamed-page
  - /docs/another-example
# Optional: Specifies a URL to redirect to this page.
# For example, has this page moved (are you replacing one or more deleted pages)?
# If yes, include the aliases frontmatter and specify the prior location of the
# page(s)/path(s) to redirect to this page. Specify the path and filename starting
# from the site root (for example /docs/, /blog/, or /community/).

showlandingtoc: "false"
# Required only in _index.md files
# Defaults to "true" and renders an in-page TOC of any/all the child pages in
# this section.
---
-->
```
```
<!-- The page title you set in the frontmatter renders here (don't add a duplicate title) -->
```
```
<!--
The content in _index.md files generally fall into two categories (but are not
limited to them).

- Use this page as a top level "landing page" that provides a high-level
  introduction to all the info covered within this section.
- Use this page to introduce a large complex process that has multiple logical
  tasks or options.
  Examples:

  - Use it to introduce large complex process, where each task of the process
    is covered in separate pages. Structure:
    - New-Folder
       - _index.md (introduce process)
       - before-you-begin-steps.md (prerequisites)
       - process-step1.md
       - process-step2.md
       - process-results_cleanup_whatsnext.md

  - Use it to introduce the multiple ways to accomplish the same task, where
    each optional task is covered in separate
    pages. Structure:
    - New-Folder
       - _index.md (introduce options)
       - how-to-opt-1.md
       - how-to-opt-2.md
       - ...
-->
```

The following demonstrates a generic landing page. For more
information about stucturing a how-to guide, see the
[new page template instructions](./template-docs-page.md).

Learn how to do something very cool.

```
<!--
Make sure to state the goal of this section and the value proposition for the
user (why is this important?).
Example:
Learn how to use X to reduce/improve/etc. your Y and Z.

Generally, make sure you answer the questions:
- "what does this section show you how to do?"
- "why would someone want to do this?"
-->
```

You can set `showlandingtoc:` to `"true"` and dynamically render an in-page TOC
below the body of the text you add in this page.

# Copy the template
```yaml
---
title: ""
linkTitle: ""
weight: 50
type: "docs"
showlandingtoc: "false"
---
<!--
# This section is called the "frontmatter" for your page that is defined in YAML.

---
title: ""
# The title of this page (renders at the top of the page). Use sentence case.

linkTitle: ""
# Optional: Use it to provide a shorter title for the page link so that it fits
# in the left navigation menu (to prevent wrapping)

weight: ""
# This specifies the vertical the placement of the page link in the left
#  navigation menu. Pages are ordered from top (lowest weight) to bottom (highest weight).

type: "docs"
# You won't need to update this.

aliases:
  - /docs/example/redirect/moved-renamed-page
  - /docs/another-example
# Optional: Specifies a URL to redirect to this page.
# For example, has this page moved (are you replacing one or more deleted pages)?
# If yes, include the aliases frontmatter and specify the prior location of the
# page(s)/path(s) to redirect to this page. Specify the path and filename starting
# from the site root (for example /docs/, /blog/, or /community/).

showlandingtoc: "false"
# Required only in _index.md files
# Defaults to "true" and renders an in-page TOC of any/all the child pages in
# this section.
---
-->

<!-- The page title you set in the frontmatter renders here (don't add a duplicate title) -->

<!--
The content in _index.md files generally fall into two categories (but are not
limited to them).

- Use this page as a top level "landing page" that provides a high-level
  introduction to all the info covered within this section.
- Use this page to introduce a large complex process that has multiple logical
  tasks or options.
  Examples:

  - Use it to introduce large complex process, where each task of the process
    is covered in separate pages. Structure:
    - New-Folder
       - _index.md (introduce process)
       - before-you-begin-steps.md (prerequisites)
       - process-step1.md
       - process-step2.md
       - process-results_cleanup_whatsnext.md

  - Use it to introduce the multiple ways to accomplish the same task, where
    each optional task is covered in separate
    pages. Structure:
    - New-Folder
       - _index.md (introduce options)
       - how-to-opt-1.md
       - how-to-opt-2.md
       - ...
-->

<!--
The following demonstrates a generic landing page. For more
information about stucturing a how-to guide, see the
[new page template instructions](./template-docs-page.md).
-->

Learn how to do something very cool.

<!--
Make sure to state the goal of this section and the value proposition for the
user (why is this important?).
Example:
Learn how to use X to reduce/improve/etc. your Y and Z.

Generally, make sure you answer the questions:
- "what does this section show you how to do?"
- "why would someone want to do this?"
-->

<!--
You can set `showlandingtoc:` to `"true"` and dynamically render an in-page TOC
below the body of the text you add in this page.
-->
```

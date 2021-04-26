# Blog template instructions

An example template with best-practices that you can use to start drafting an
entry to post on the Knative blog.

[**Copy a version of this template without the instructions**](#copy-the-template)

## Frontmatter

[Hugo](https://gohugo.io/) uses a set of metadata at the beginning of each page
called [frontmatter](https://gohugo.io/content-management/front-matter/)
to define website build required info as well as other blog page details.

Frontmatter is strict YAML syntax and must be added to the top of every
page. Example formatting template:

```yaml
---
# This section is called the "frontmatter" for your page
title: "Title for your page" # Use sentence case for titles and headings
linkTitle: "A shorten title" # Optional: Use/render a shorter title in the navigation menu.
author: "" # Your name
authorHandle: "" # Your GitHub ID
date: "" # Publishing date
description: "" # A short one-liner describing this blog entry
folderWithMediaFiles: "./images/<new-feature-name>" # The relative file path (ie. new folder) to any images, etc.
keywords: "Releases, Steering committee, Demo, Events" # Meta keywords for the content
---
```

Include a commented-out table with tracking info about reviews and approvals:
```
<!--
| Reviewer           | Date       | Approval      |
| ------------------ | ---------- | ------------- |
| <!-- GitHub ID --> | YYYY-MM-DD | :+1:, :monocle_face:, :-1: |
| <!-- GitHub ID --> | YYYY-MM-DD | :+1:, :monocle_face:, :-1: |
-->
```

## Blog content body
```
<!--
Introduce the feature you are going to explain:
 * state what the goal of this blog entry is
 * how you use the feature
 * make sure to link to the corresponding docs
 * why others can find it useful (why its important)
-->
```

```
<!-- Add/create as many distinct Steps or Sections as needed. -->
```
### Example step/section 1:
```
<!--
An introductory sentence about this step or section (ie. why its important and what the result is).
Don't forget to link to any new or related concepts that you mention here.
-->
```

### Example step/section 2:
```
<!--
An introductory sentence about this step or section (ie. why its important, how it relates to the one before, and what the result is)
Don't forget to link to any new or related concepts that you mention here.
-->
```

### Example step/section 3:
```
<!--
An introductory sentence about this step or section (ie. why its important, how it relates to the one before, and what the result is)
Don't forget to link to any new or related concepts that you mention here.
-->
```

### Example section about results
```
<!--
Tie it all together and briefly revisit the main key points and then the overall result/goal/importance
-->
```

## Further reading
```
<!--
Add any links to other related resources that users might find useful.
What's the next step?
-->
```

## About the author
```
<!--
Add a short bio of yourself here
-->
```

# Copy the template

```
---
title: ""
linkTitle: ""
author: ""
authorHandle: ""
date: ""
description: ""
folderWithMediaFiles: ""
keywords: ""
---

<!--
| Reviewer           | Date       | Approval      |
| ------------------ | ---------- | ------------- |
| <!-- GitHub ID --> | YYYY-MM-DD | :+1:, :monocle_face:, :-1: |
| <!-- GitHub ID --> | YYYY-MM-DD | :+1:, :monocle_face:, :-1: |
-->

<!-- The page title you set in the frontmatter renders here (don't add a duplicate title) -->

## Blog content body
<!-- Introduce the feature you are going to explain:
 * state what the goal of this blog entry is
 * how you use the feature
 * make sure to link to the corresponding docs
 * why others can find it useful (why its important)
-->

<!-- Add/create as many distinct Steps or Sections as needed. -->
### Example step/section 1:
<!--
An introductory sentence about this step or section (ie. why its important and what the result is).
Don't forget to link to any new or related concepts that you mention here.
-->

### Example step/section 2:
<!--
An introductory sentence about this step or section (ie. why its important, how it relates to the one before, and what the result is)
Don't forget to link to any new or related concepts that you mention here.
-->

### Example step/section 3:
<!--
An introductory sentence about this step or section (ie. why its important, how it relates to the one before, and what the result is)
Don't forget to link to any new or related concepts that you mention here.
-->

### Example section about results
<!--
Tie it all together and briefly revisit the main key points and then the overall result/goal/importance
-->

## Further reading
<!--
Add any links to related resources that users might find useful.
What's the next step?
-->

## About the author
<!--
Add a short bio of yourself here
-->
```

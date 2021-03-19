---
title: "Front matter"
linkTitle: ""
weight: 50
type: "authoring"
---

The front matter is YAML code in between triple-dashed lines at the top of each
file and provides important management options for our content. For example, the
front matter allows us to ensure that existing links continue to work for pages
that are moved or deleted entirely. This page explains the features currently
available for front matters in Istio.

The following example shows a front matter with all the required fields
filled by placeholders:


---
title: <title>
description: <description>
weight: <weight>
keywords: [<keyword1>,<keyword2>,...]
aliases:
    - <previously-published-at-this-URL>
---


You can copy the example above and replace all the placeholders with the
appropriate values for your page.

## Required front matter fields

The following table shows descriptions for all the **required** fields:

|Field              | Description
|-------------------|------------
|`title`            | The page's title.
|`description`      | A one-line description of the content on the page.
|`weight`           | The order of the page relative to the other pages in the directory.
|`keywords`         | The keywords on the page. Hugo uses this list to create the links under "See Also".
|`aliases`          | Past URLs where the page was published. See [Renaming, moving, or deleting pages](#rename-move-or-delete-pages) below for details on this item

### Rename, move, or delete pages

When you move pages or delete them completely, you must ensure that the existing
links to those pages continue to work. The `aliases` field in the front matter
helps you meet this requirement. Add the path to the page before the move or
deletion to the `aliases` field. Hugo implements automatic redirects from the
old URL to the new URL for our users.

On the _target page_, which is the page where you want users to land, add the `<path>`
of the _original page_ to the front-matter as follows:

aliases:
    - <path>

For example, you could find our FAQ page in the past under `/help/faq`. To help our users find the FAQ page, we moved the page one level up to `/faq/` and changed the front matter as follows:

---
title: Frequently Asked Questions
description: Questions Asked Frequently.
weight: 13
aliases:
    - /help/faq
---

The change above allows any user to access the FAQ when they visit `https://istio.io/faq/` or `https://istio.io/help/faq/`.

Multiple redirects are supported, for example:

---
title: Frequently Asked Questions
description: Questions Asked Frequently.
weight: 13
aliases:
    - /faq
    - /faq2
    - /faq3
---

## Optional front matter fields

However, Hugo supports many front matter fields and this page only covers those
implemented on istio.io.

The following table shows the most commonly used **optional** fields:

|Field              | Description
|-------------------|------------
|`linktitle`        | A shorter version of the title that is used for links to the page.
|`subtitle`         | A subtitle displayed below the main title.
|`icon`             | A path to the image that appears next to the title.
|`draft`            | If true, the page is not shown in the site's navigation.
|`skip_byline`      | If true, Hugo doesn't show a byline under the main title.
|`skip_seealso`     | If true, Hugo doesn't generate a  "See also" section for the page.

Some front matter fields control the auto-generated table of contents (ToC).
The following table shows the fields and explains how to use them:

|Field               | Description
|--------------------|------------
|`skip_toc`          | If true, Hugo doesn't generate a ToC for the page.
|`force_inline_toc`  | If true, Hugo inserts an auto-generated ToC in the text instead of in the sidebar to the right.
|`max_toc_level`     | Sets the heading levels used in the ToC. Values can go from 2 to 6.
|`remove_toc_prefix` | Hugo removes this string from the beginning of every entry in the ToC

Some front matter fields only apply to so-called _bundle pages_. You can
identify bundle pages because their file names begin with an underscore `_`, for
example `_index.md`. In Istio, we use bundle pages as our section landing pages.
The following table shows the front matter fields pertinent to bundle pages.

|Field                 | Description
|----------------------|------------
|`skip_list`           | If true, Hugo doesn't auto-generate the content tiles of a section page.
|`simple_list`         | If true, Hugo uses a simple list for the auto-generated content of a section page.
|`list_below`          | If true, Hugo inserts the auto-generated content below the manually-written content.
|`list_by_publishdate` | If true, Hugo sorts the auto-generated content by publication date, instead of by weight.

Similarly, some front matter fields apply specifically to blog posts. The
following table shows those fields:

|Field            | Description
|-----------------|------------
|`publishdate`    | Date of the post's original publication
|`last_update`    | Date when the post last received a major revision
|`attribution`    | Optional name of the post's author
|`twitter`        | Optional Twitter handle of the post's author
|`target_release` | The release used on this blog. Normally, this value is the current major Istio release at the time the blog is authored or updated.

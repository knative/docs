---
title: "Authoring Knative documentation"
linkTitle: "Authoring"
weight: "25"
type: "authoring"
---

Use this page to learn about the conventions and requirements for creating or
adding content to the pages that are published to knative.dev.

## Style guide

Knative documentation follows the
[Google Developer Documentation Style Guide](https://developers.google.com/style/);
use it as a reference for writing style questions.

## Page attributes

* General info about site:
       - Hugo
       - Docsy
       - [Markdown processor info](https://gohugo.io/getting-started/configuration-markup/)
       - Netlify
       - knative/website repo

* front matter

  ```
  ---
  title: “The file’s title (do not include another H1 title in the body).”
  linkTitle: “optional short title”
  weight: 10
  type: “docs”
  ---
  ```

   - ‘title’ and ‘type: “docs”’ are required.
   - ‘linkTitle’ use to define a shorter alternative title that displays in the navigatiion tree.
  when no `weight` is defined, this value is used by default to order the docs navigation menu alphabetically.
   - ‘weight’ if not defined or specifies an existing value, this page is organized alphabetically in the docs navigation menu
   Use this to explicitly defined where this page is ordered, relative to other pages, in the docs navigation menu.
   By default, `weight` is prioritized before `linkTitle`. [Learn more](https://gohugo.io/templates/lists/#default-weight--date--linktitle--filepath)

   More details and options for Hugo frontmatter: https://gohugo.io/content-management/front-matter/#predefined

* Redirect URLs for moved and renamed source files (add `aliases` to frontmatter): https://github.com/knative/docs/issues/1925

  The following requires a redirect:
   - moved or changed folders
   - filename change

  To add a redirect, you must add the [`aliases` element](https://gohugo.io/content-management/front-matter/#front-matter-variables) to the file's frontmatter.

  ```
  ---
  title: "Page title (Remember: do not duplicate the title in the page body)”
  linkTitle: “optional short title - use to avoid wrapping in the docs navigation menu”
  weight: 10
  type: “docs”
  aliases:
    - /docs/folder/page-without-extension
  ---
  ```

  **Example:**

   * Old deleted file: `/docs/concepts/resources.md`

   * New file that you want the old URL redirected to: `/docs/reference/resources.md`

   * Frontmatter in the [`resources.md`](https://raw.githubusercontent.com/knative/docs/master/docs/reference/resources.md) file:
     ```
     ---
     title: "Additional resources"
     weight: 100
     type: "docs"
     aliases:
        - /docs/concepts/resources
     ---
    ```

## Shortcodes

- Link to Docsy
- Link to Hugo

- Artifacts https://github.com/knative/website/pull/129/files

- Tabs

- [ ] Dynamic variables. Use them to reduce release maintenance and ensure content accuracy. The following variable are dynamically populated based on the URL of the content in knative.dev:
   - [ ] add the corresponding branchname by using the `{{< branch >}}` variable ([shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/branch.md))
   - [ ] add the corresponding version number by using the `{{< version >}}` variable ([shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/version.md))

    See examples in the [smoketest page](https://knative.dev/smoketest/)

- [ ] Document linking conventions - all ./ are required for "same directory" relative links
- [ ] If there is more than a single .md file in a sub folder, then that folder must include and use an `_index.md` (to define that "[section](https://gohugo.io/content-management/sections/)").

   (ie. need to mention that if you want to add that
   second file to a folder, then you must also add (create) the required
   "section definition" (using an `_index.md` file).

### Putting your docs in the right place

Generally, the `knative/docs` repo contains Knative specific user-facing content
and blog content.

Contributor-focused content belongs in one of the other Knative code
repositories (`knative/serving`, `knative/eventing`, etc.).


#### Contributor-focused content

  - _Contributor docs_: Includes content that is component specific and relevant
    only to contributors of a given component. Contributor focused documentation
    is located in the corresponding `docs` folder of that component's
    repository. For example, if you contribute code to the Knative Serving
    component, you might need to add contributor focused information into the
    `docs` folder of the
    [knative/serving repo](https://github.com/knative/serving/tree/master/docs/).

  - _Contributor code_: Includes contributor related code or samples. Code or
    samples that are contributor focused also belong in their corresponding
    component's repo. For example, Eventing specific test code is located in the
    [knative/eventing tests](https://github.com/knative/eventing/tree/master/test)
    folder.



- **User-focused content**

  - _Documentation_: Includes all content for users of Knative. The
    external-facing user documentation belongs in the
    [`knative/docs` repo](https://github.com/knative/docs). All content in
    `knative/docs` is published to [https://knative.dev](https://knative.dev).

  - _Code samples_: Includes user-facing code samples and their accompanying
    step-by-step instructions. User code samples are currently separated into
    the corresponding Knative component sections the `knative/docs` repo. See
    the following section for details about determining where you can add your code sample.

- **Blog content**

  - _Documentation_: Includes content that is component
    - Blog types here

##### Determining where to add user focused code samples

There are currently two categories of user-focused code samples, _Knative owned
and maintained_ and _Community owned and maintained_.

- **Knative owned and maintained**: Includes code samples that are actively
  maintained and e2e tested. To ensure content currency and balance available
  resource, only the code samples that meet the following requirements are
  located in the `docs/[*component*]/samples` folders of the `knative/docs`
  repo:

  - _Actively maintained_ - The code sample has an active Knative team member
    who has committed to regular maintenance of that content and ensures that
    the code is updated and working for every product release.
  - _Receives regular traffic_ - To avoid hosting and maintaining unused or
    stale content, if code samples are not being viewed and fail to receive
    attention or use, those samples will be moved into the
    "[community maintained](https://github.com/knative/docs/tree/master/community/samples)"
    set of samples.
  - _Passes e2e testing_ - All code samples within `docs/[*component*]/samples`
    folders must align with (and pass) the
    [`e2e` tests](https://github.com/knative/docs/tree/master/test).

  Depending on the Knative component covered by the code sample that you want to
  contribute, your PR should add that sample in one of the following folders:

  - Eventing samples:
    [`/docs/eventing/samples`](https://github.com/knative/docs/tree/master/docs/eventing/samples)
  - Serving samples:
    [`/docs/serving/samples`](https://github.com/knative/docs/tree/master/docs/serving/samples)

- **Community owned and maintained samples**: Code samples that have been
  contributed by Knative community members. These samples might not receive
  regular maintenance. It is possible that a sample is no longer current and is
  not actively maintained by its original author. While we encourage a
  contributor to maintain their content, we acknowledge that it's not always
  possible for certain reasons, for example other commitments and time
  constraints.

While a sample might be out of date, it could still provide assistance and help
you get up-and-running with certain use-cases. If you find that something is not
right or contains outdated info, open an
[Issue](https://github.com/knative/docs/issues/new). The sample might be fixed
if bandwidth or available resource exists, or the sample might be taken down and
archived into the last release branch where it worked.

#### Choosing the correct branch

It is likely that your docs contribution is either for new or changed features
in the product, or for a fix or update existing content.

- **New or changed features**: If you are adding or updating documentation for a
  new or changed feature, you likely want to open your PR against the `master`
  branch. All pre-release content for active Knative development belongs in
  [`master`](https://github.com/knative/docs/tree/master/).

- **Fixes and updates**: If you find an issue in a past release, for example a
  typo or out-of-date content, you likely need to open multiple and subsequent
  PRs. If not a followup PR, at least add the "`cherrypick` labels" to your
  original PR to indicate in which of the past release that your change affects.

  For example, if you find a typo in a page of the `v0.5` release, then that
  page in the `master` branch likely also has that typo.

  To fix the typo:

  1.  Open a PR against the
      [`master`](https://github.com/knative/docs/tree/master/) branch.
  1.  Add one or more `cherrypick-#.#` labels to that PR to indicate which of
      the past release branches should also be fixed. Generally, we only
      maintain the most recent numbered release.
  1.  If you want to complete the fix yourself (**best practice**), you then
      open a subsequent PR by running `git cherry-pick [COMMIT#]` against the
      `release-0.5`. Where `[COMMIT#]` is the commit of the PR that you merged
      in `master`.

      Note: Depending on workload and available bandwidth, one of the Knative
      team members might be able to help handle the `git cherry-pick` in order
      to push the fix into the affected release branch(es).

See a list of the available documentaion versions in the
[branches page](https://github.com/knative/docs/branches) of the `knative/docs`
repo.




- [ ] SEO (filename (no capital letters, no product names), titles (sentence case), cross links)

- [ ] Using shortcodes:
   - [ ] Optional: Add the following to the frontmatter of a file to show/hide an in-page TOC (uses the ["landingtoc" partial](https://github.com/knative/website/blob/master/layouts/partials/landingtoc.html))
           By default, the in-page TOC shows in empty/blank _index.md section files to list all the sub-topics in that section.
            - add `showlandingtoc: "true"` to add the in-page TOC
            - add `showlandingtoc: "false"` to prevent the in-page TOC from showing on a blank page or non `docs` type page (for example, a page in the /community section)

   - [ ] Nested shortcodes are NOT supported - results in mixed content (.md + HTML) in the markdown that gets processed to HTML (so code (ie HTML or Markdown) is rendered (not just text))
   - [ ] [`{{% readfile file="FILENAME.md" %}}` shortcode](https://github.com/knative/website/blob/master/layouts/shortcodes/readfile.md):

      - [ ] In the blank _index.md pages that can automatically generate and render an in-page nav tree. Make clear which files are "included" and rendered on the site using the `readfile` shortcode.
        ie. add a comment in the included file
        ```
        <!-- This file is rendered in knative.dev using the "readfile" shortcode.
        See the _index.md file in this directory. -->
        ```

      - [ ] Dynamically add code: `{{< readfile file="code-written-in.go" code="true" lang="go" >}}`

         See examples in the [smoketest page](https://knative.dev/smoketest/)


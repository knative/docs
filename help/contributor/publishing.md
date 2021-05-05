---
title: "Staging and publishing Knative documentation"
linkTitle: "Preview Website"
weight: "60"
type: "docs"
---

## Testing your documentation

Before you kick off a PR review you can verify that:

- The page and any elements like widgets, titles, and links, work and
  renders correctly.
- If you moved or deleted a page, make sure to test that the redirects
  (`aliases`) all work.

### Auto PR preview builds

All PRs are automatically built and a Preview is generated at:
https://app.netlify.com/sites/knative/deploys

This is currently a manual process.

1. Navigate to https://app.netlify.com/sites/knative/deploys
1. Click to view a build log. The list of build logs are ordered from
   most recent to oldest. If you just pushed to your PR, then that build log is
   near the top.
1. Scroll down to see the `PR#` in the log and verify that it's for your PR.
1. When you find the build log for your PR, click the **[Preview]** button to
   view the unique build preview for your PR.

   **Important**: Each "event" in a Knative PR triggers a new/unique build
   (Preview). Therefore, if you push a new commit, a new build with those
   changes will appear at the top of https://app.netlify.com/sites/knative/deploys.

### Local preview builds

You can run a local preview of you fork. See the following setup section for
details about installing the required software.

- Current supported Hugo version https://github.com/knative/website/blob/main/netlify.toml
- How to build knative.dev locally: Run [`https://github.com/knative/website/blob/main/scripts/localbuild.sh`](https://github.com/knative/website/blob/main/scripts/localbuild.sh)

#### Setup the local requirements

1. Clone this repo (or your fork) using `--recurse-submodules`, like so:

   ```shell
   git clone --recurse-submodules https://github.com/knative/website.git
   ```

   If you accidentally cloned this repo without `--recurse-submodules`, you'll
   need to do the following inside the repo:

   ```shell
   git submodule init
   git submodule update
   cd themes/docsy
   git submodule init
   git submodule update
   ```

   (Docsy uses two submodules, but those don't use further submodules.)

1. Clone the docs repo next to (_not inside_) the website repo. This allows you
   to test docs changes alongside the website:

   ```shell
   git clone https://github.com/knative/docs.git
   ```

   You may also want to clone the community repo:

   ```shell
   git clone https://github.com/knative/community.git
   ```

1. (Optional) If you want to change the CSS, install
   [PostCSS](https://www.docsy.dev/docs/getting-started/#install-postcss)

1. Install a supported version of [Hugo](https://www.docsy.dev/docs/getting-started/#install-hugo).

#### Run locally

You can use `./scripts/localbuild.sh` to build and test files locally.
The script uses Hugo's build and server commands in addition to some Knative
specific file scripts that enables optimal user experience in GitHub
(ie. use README.md files, allows our site to use relative linking
(not
[`rel` or `relref`](https://gohugo.io/content-management/cross-references/#use-ref-and-relref)),
etc.) and also meets Hugo/Docsy static site generator
and template requirements (ie. _index.hmtl files, etc.)

The two local docs build options:

- Simple/static HTML file generation for viewing how your Markdown renders in HTML:

  Use this to generate a static build of the documentation site into HTML. This
  uses Hugo's build command [`hugo`](https://gohugo.io/commands/hugo/).

  From your clone of knative/website, you run `./scripts/localbuild.sh`.

  All of the HTML files are built into the `public/` folder from where you can open,
  view, and test how each file renders.

  Notes:

  - This method does not mirror how knative.dev is generated and therefore is
    only recommend to for testing how your files render. That also means that link
    checking might not be 100% accurate. Hugo builds relative links differently
    (all links based on the site root vs relative to the file in which the link
    resides - this is part of the Knative specific file processing that is done)
    therefore some links will not work between the statically built HTML files.
    For example, links like `.../index.html` are converted to `.../` for simplicity
    (servers treat them as the same destination) but when you are browsing a local HTML
    file you need to open/click on the individual `index.html` files to get where you want
    to go.
  - This method does however make it easier to read or use local tools on the HTML build
    output files (vs. fetching the HTML from the server). For example, it is useful for
    refactoring/moving content and ensuring that complicated Markdown renders properly.
  - Using this method also avoids the MacOs specific issue (see below), where the default
    open FD limit exceeds the total number of `inotify` calls that Hugo wants to keep open.

- Mimic how knative.dev is built and hosted:

  Use this option to locally build knative.dev. This uses Hugo's local server
  command [`hugo server`](https://gohugo.io/commands/hugo_server/).

  From your clone of knative/website, you run `./scripts/localbuild.sh -s true`.

  All of the HTML files are temporarily copied into the `content/en/` folder to allow
  the Hugo server to locally host those files at the URL:port specified in your terminal.

  Notes:

  - This method provides the following local build and test build options:
    - test your locally cloned files
    - build and test other user's remote forks (ie. locally build their PRs `./scripts/build.sh -f repofork -b branchname -s`)
    - option to build only a specific branch or all branches (and also from any speicifed fork)
    - fully functioning site links
    - [See all command options in localbuild.sh](https://github.com/knative/website/blob/main/scripts/localbuild.sh)
  - Hugo's live-reload is not completely utilized due to the required Knative specific file processing
    scripts (you need to rerun `./scripts/localbuild.sh -s` to rebuild and reprocess any changes that you
    make to the files from within your local knative/docs clone directory).

    Alternatively, if you want to use Hugo's live-reload feature, you can make temporary
    changes to the copied files within the `content/en/` folder, and then when satisfied, you must
    copy those changes into the corresponding files of your knative/docs clone.
  - Files in `content/en/` are overwritten with a new copy of your local files in your knative/docs
    clone folder each time that you run this script. Note that the last set of built files remain
    in `content/en/` for you to run local tools against but are overwritten each time that you rerun the script.
  - Using this method causes the MacOs specific issue (see below), where the default
    open FD limit exceeds the total number of `inotify` calls that the Hugo server wants to keep open.

## On a Mac

If you want to develop on a Mac, you'll find two obstacles:

### Sed

The scripts assume GNU `sed`. You can install this with
[Homebrew](https://brew.sh/):

```shell
brew install gnu-sed
# You need to put it in your PATH before the built-in Mac sed
PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
```

### File Descriptors in "server mode"

By default, MacOS permits a very small number of open FDs. This will manifest
as:

```
ERROR 2020/04/14 12:37:16 Error: listen tcp 127.0.0.1:1313: socket: too many open files
```

You can fix this with the following (may be needed for each new shell):

```shell
sudo launchctl limit maxfiles 65535 200000
# Probably only need around 4k FDs, but 64k is defensive...
ulimit -n 65535
sudo sysctl -w kern.maxfiles=100000
sudo sysctl -w kern.maxfilesperproc=65535
```

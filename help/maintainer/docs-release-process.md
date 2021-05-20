---
title: "Releasing a version of the Knative documentation"
linkTitle: "Release process"
weight: 75
type: "docs"
---

Learn how to promote the current in-development version of the knative/docs
repo (`main`), to a released version by creating a dedicated `release-#.#`
branch and corresponding section knative.dev.

## Before you begin

* For GitHub
   * [Set up keys for SSH access](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)
   * [Configure two remote repos](https://articles.assembla.com/en/articles/1136998-how-to-add-a-new-remote-to-your-git-repo) for your local /docs and /website clones:
      * "origin" - pointed at main repo (git@github.com:knative/docs.git)
      * "upstream" - pointed at your fork of main repo (git@github.com:<your fork>/docs.git)

* To create combined PRs.
   Make your first pull request, choose Create a new branch.  Give it a name you will remember.
   Then when you make your subsequent updates, make sure you select the branch you just created so you can add all your
   changes to the same PR.

## Check Eventing, Serving, Client, and Operator

Have they created related release branches?
[client](https://github.com/knative/client/releases/)
[eventing](https://github.com/knative/eventing/releases/)
[operator](https://github.com/knative/operator/releases/)
[serving](https://github.com/knative/serving/releases/)

## Create matching branch for Knative docs
Once there are release branches for the four repos listed above, make a matching doc repo release.

### Prepare the 'main' branch
Make sure main is in correct state:
* [Generate the latest set of API reference docs](https://github.com/knative/docs/tree/main/docs/reference#updating-api-reference-docs-for-knative-maintainers) locally
  * Clone the docs repo: git clone git@github.com:knative/docs.git
  * Find the gen-api-reference-docs.sh script in the /docs/hack directory
  * Follow the instructions in the linked doc above. This creates a small set of files that document the APIs in this
    release. Be aware that if there have been significant changes, the script may take hours to run to completion.
*  Push to your personal GitHub repository.
*  Create a PR and check into the Knative main repository.
* At this point the updated versions of the API docs are in knative/docs main
* Check to make sure all changes, including install changes, have been merged into main and all hard-coded version numbers are updated. This is to make sure that any docs that have been committed outside of the normal process don't have mechanical errors in them. This is, alas, a manual step.

### Create branch from updated main
Once everything that needs to be in main is in main you need to create the release branch, using the GitHub UI.

1. Make sure you are logged into GitHub.
2. Select the Code tab in the Knative/docs repo.
3. Click and open the Branch drop-down menu. Make sure that main is selected. This is the source for the new release.
4. In the Find or create a branch text field, enter the name of the new branch you want to create: release-#.#
![branch](https://user-images.githubusercontent.com/35748459/87461583-804c4c80-c5c3-11ea-8105-f9b34988c9af.png)
The branch is created.

### Update links
Make sure all links in new release branch announcement point to the appropriate peer Knative repos
* Update all hard coded URLs to repos from "tree/main" to "tree/release-0.#"
  * For Serving, Eventing, and Eventing-contrib

### Demote the previous release to archive
* Remove the "aliases" field from the frontmatter of files from the previous release so that they look like this:

   title: "Knative contribution guidelines"
   linkTitle: "Contributing"
   weight: 20
   type: "docs"

Or

* Change the "aliases" field to point to the archived version file so  "/docs/<the file name>/" becomes "/<the archived version>-docs/<the file name>/":

   title: "Knative contribution guidelines"
   linkTitle: "Contributing"
   weight: 20
   type: "docs"
   aliases:
   /v0.9-docs/contribution-guidelines/

Not all files will have aliases on them.  You just have to go through them manually. Update one, create a branch for your pull request, then update all of the others using that branch, by committing to that branch. Then create one pull request for all the changes.  **Make sure you make the pull request against the branch you are archiving,** ie, the one before the one you just made.

## Complete the release announcement and create the tag

### Link all the release notes together
* On https://github.com/knative/docs/releases, click Draft a new release.
![release-notes](https://user-images.githubusercontent.com/35748459/87462834-61e75080-c5c5-11ea-83ec-94c556255db8.png)
![tags](https://user-images.githubusercontent.com/35748459/87462941-8e9b6800-c5c5-11ea-951b-2bacdb4061ec.png)
* Using the box in red above, create a tag with the release (v.0.<number>.x). Copy the text of the source content from the previous release, updating the number and linking to the appropriate release notes in each of the three components.
* Check **Pre-release**
* Click **Publish release** (or **Save draft** if you are not ready to finalize).

## Configure the /website build

Update the build configuration to include the new version and remove the oldest by editing the following .toml  (Tom's Obvious, Minimal Language) files.  Tom's files aren't really obvious, but tastes vary.  There are also some traditional script files. Use the github UI In the /website main branch.  Click the link to go to the page to edit and insert the appropriate
 values:

* Configure defaults: [/website/config/_default/params.toml](https://github.com/knative/website/blob/main/config/_default/params.toml)

  This lets the build know what the "default" release is.  Add the release version you just created.
![default](https://user-images.githubusercontent.com/35748459/87463577-81cb4400-c5c6-11ea-8a69-3023b07adba0.png)
* Configure production builds: [/website/confi/production/params.toml]( https://github.com/knative/website/blob/main/config/production/params.toml)

  We build four versions of the docs every time - the version you just created, and the previous three versions.
  Set the version on line 41 to the version you just created. Set the "Archived versions" to the three previous versions.
  Remove any older versions.
![production](https://user-images.githubusercontent.com/35748459/87464225-9cea8380-c5c7-11ea-8f31-fe7872cad81d.png)
* Configure local builds: [/website/config/local/params.toml]()

  This is really just for builds you do on your machine, but update it on github as well to keep everything in sync. Set line 20
   to the version you just created.
![local](https://user-images.githubusercontent.com/35748459/87464508-13878100-c5c8-11ea-840f-25e4ab80e372.png)
* Configure staging builds: [/website/config/staging/params.toml](https://github.com/knative/website/blob/main/config/staging/params.toml)

  Set line 19 to the version you just created.
![staging](https://user-images.githubusercontent.com/35748459/87464866-afb18800-c5c8-11ea-9ce0-74331523d651.png)
* Define the default branch variable:[/website/scripts/docs-version-settings.sh](https://github.com/knative/website/blob/main/scripts/processsourcefiles.sh)

  This variable should be set to the version you just created.
![doc-version](https://user-images.githubusercontent.com/35748459/87465326-4bdb8f00-c5c9-11ea-95c7-8a9e3b8abecd.png)
* Tell Netlify how to get the previous three releases by updating the three git clone commands to point to those three releases: [/website/scripts/processsourcefiles.sh](https://github.com/knative/website/blob/main/scripts/processsourcefiles.sh)
![processsource](https://user-images.githubusercontent.com/35748459/87465528-ad9bf900-c5c9-11ea-8364-d391c1926332.png)

* Add the just created version to line 24 of the Netlify toml file.  The :splat keeps the links to the three previous versions
  alive, so the current version + the previous 3 versions that are still being built. The bottom release that fell out of the top
  four should be added to the redirects below line 29.  Any links to these versions are redirected back to the most current
  version: [/website/netlify.toml](https://github.com/knative/website/blob/main/netlify.toml)
![netlify](https://user-images.githubusercontent.com/35748459/87465963-54809500-c5ca-11ea-8372-3fbcfc965e20.png)

## Test the content
* Update your local versions of the build config files to run a local build.
* Run a local build using from the /website directory: scripts/localbuild.sh. Follow the extensive instructions at the top of the script file.
* Check to make sure everything looks okay.
* Sync your changes to the staging branch with git pull --rebase upstream main and git push upstream staging. {need more detail}

## Check the staging (Deploy Preview) build on Netlify
* Go to [https://app.netlify.com/sites/knative/deploys]( https://app.netlify.com/sites/knative/deploys
)
![Deploys](https://user-images.githubusercontent.com/35748459/87466537-44b58080-c5cb-11ea-9b0e-6f14679dbede.png)

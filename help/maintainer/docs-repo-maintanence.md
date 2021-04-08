---
title: "Maintaining the Knative doc and website repos"
linkTitle: "Repo maintenance"
weight: 100
type: "docs"
---

## How GitHub and Netlify are hooked up

https://knative.dev/ is built and served by [Netlify](https://netlify.com/) on their platform.
When debugging issues on the website, it can be useful to understand what Netlify is doing (as we've
configured it).

Generally, Netlify runs Hugo/Docsy builds and publishes everything that gets merged into the knative/docs and knative/website repos
(anything in knative/community will get picked up when either of the other two repos trigger a build).

The builds are triggered are through [GitHub webhooks](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads).
There are two webhooks sent from knative/docs that are configured to inidicate that they were sent from knative/website:

* One that triggers a "production" build - Any PR that gets merged. (Webhook payload - /website `main` branch)
* One that triggers a "preview" build - Any PR action other than a merge (ie. commit, comment, label, etc). (Webhook payload - /website `staging` branch)

All of our builds (and build logs) are shown here: https://app.netlify.com/sites/knative/deploys (in the order of recent to past)


## Keep knative/website 'staging' with 'main' in sync

Both branches are identical but all PRs get merged into `main`. They can drift
apart since staging only builds the PR owners fork and branch. It's best to keep
in sync to avoid dealing with merge conflicts.

Two branches are used only to align with and use Netlify's built-in continuous
site deployment configuration:

`main` - triggered when any PR gets pushed into knative/docs
`staging` - triggered for any event (other than 'push') in a PR

Assuming that you have a local fork of the knative/website `staging` branch:

1. Copy `main` into `staging`, for example:

   * Merge:

     ```
     git checkout staging
     git pull upstream main
     git push origin staging
     ```

   * Hard reset and force push also works:

     ```
     git checkout staging
     git reset --hard upstream/main
     git push -f origin staging
     ```

1. Open a PR and merge into knative/website staging


## Check for and keep Hugo and Docsy up-to-date:

- Hugo releases: Update local versions if you use scripts/localbuild.sh. Update https://github.com/knative/website/blob/main/netlify.toml#L5
- Docsy releases: https://www.docsy.dev/docs/updating/

## Other notes

- How to hide files from the build: https://github.com/knative/website/blob/main/config/_default/config.toml#L12

Account info (include current owners):

- Netlify

- Google Domains

- Google Analytics

- Google Search

### Website infrastructure:

  - Hugo - static site engine
    - Includes a version of Bootstrap
    - Docsy - Hugo template for technical documentation
    - [Markdown processor info](https://gohugo.io/getting-started/configuration-markup/)
  - Netlify - continuous build
  - GitHub repos
    - knative/docs repo
    - knative/website repo
    - knative/community repo

### Integration tests

- Link checking

- Whitespace lint

## Todos

Other "docs contributor" related items:

- [ ] https://github.com/knative/docs/issues/1032
- [ ] https://github.com/knative/docs/issues/1009
- [ ] https://github.com/knative/docs/issues/1282
- [ ] https://github.com/knative/docs/issues/1239
- [ ] https://github.com/knative/docs/issues/1344

Recent items:

[ ] Auto PR staging: https://app.netlify.com/sites/knative/deploys

[ ] How Prow chooses reviewers: https://github.com/kubernetes/test-infra/tree/master/prow/plugins/approve/approvers#blunderbuss-selection-mechanism

[ ] GitHub troubleshooting: https://github.com/knative/docs/issues/2755

Build scripts:

- How cross linking between /docs and /community works

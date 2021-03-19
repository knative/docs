---
title: "Maintaining the Knative doc and website repos"
linkTitle: "Repo maintenance"
weight: 100
type: "authoring"
---


## Keep knative/website 'staging' with 'main' in sync

Both branches are identical but all PRs get merged into `main`. They can drift
apart since staging only builds the PR owners fork and branch. It's best to keep
in sync to avoid dealing with merge conflicts.

Two branches are used only to align with and use Netlify's built-in continous
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

- Hugo
  - Hide files from the build: https://github.com/knative/website/blob/main/config/_default/config.toml#L12

- Docsy
  - Smoketest pages


Account info:

- Netlify

- Google Domains?

- Google Analytics

- Google Search

## How its all hooked up and connected:
GitHub webhooks:

https://github.com/knative/docs/settings/hooks

* One webhook is sent for any `push` (when content gets merged)
* One webhook is sent for any event in a PR


# Releasing a new version of the Knative documentation

This document describes how to perform a docs release. In general, this should
be done by one of the release managers in the list at
https://github.com/knative/release.

To release a new version of the docs you must:

1. [Check dependencies](#check-dependencies)
1. [Create a release branch](#create-a-release-branch)
1. [Generate the new docs version](#generate-the-new-docs-version)

## Check dependencies

You cannot release a new version of the docs until the Knative components have
built their new release.
This is because the website references these releases in various locations.

Check the following components for the new release:

* [client](https://github.com/knative/client/releases/)
* [eventing](https://github.com/knative/eventing/releases/)
* [operator](https://github.com/knative/operator/releases/)
* [serving](https://github.com/knative/serving/releases/)

## Create a release branch

1. Check on the `#docs` Slack channel to make sure the release is ready.
_In the future, we should automate this so the check isn't needed._

1. Using the GitHub UI, create a `release-X.Y` branch based on `main`.

  ![branch](https://user-images.githubusercontent.com/35748459/87461583-804c4c80-c5c3-11ea-8105-f9b34988c9af.png)

## Generate the new docs version

To generate the new version of the docs, you must update the [`hack/build.sh`](../hack/build.sh)
script in the main branch to reference the new release.

We keep the last 4 releases available per [our support window](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#knative-community-support-window-principle).

To generate the new docs version:

1. In `hack/build.sh` on the main branch, update `VERSIONS`
to include the new version, and remove the oldest. Order matters, most recent first.

    For example:

    ```
    VERSIONS=("1.5" "1.4" "1.3" "1.2")
    ```

1. PR the result to main.

## How GitHub and Netlify are hooked up

Netlify build is configure via [netlify.toml](../netlify.toml)

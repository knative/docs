---
title: "Releasing a version of the Knative documentation"
linkTitle: "Release process"
weight: 75
type: "docs"
---

This document describes how to perform a docs release. In general, this should
be done by one of the release managers in the list at
https://github.com/knative/release.

## Check Eventing, Serving, Client, and Operator

Have they all built releases (since the website references these release pages
in various locations)?

* [client](https://github.com/knative/client/releases/)
* [eventing](https://github.com/knative/eventing/releases/)
* [operator](https://github.com/knative/operator/releases/)
* [serving](https://github.com/knative/serving/releases/)

## Create a release branch

Using the GitHub UI, create a `release-X.Y` branch based on `main`. **Check on
the `#docs` channel to make sure the release is ready.** _In the future, we
should automate this so the check isn't needed._

![branch](https://user-images.githubusercontent.com/35748459/87461583-804c4c80-c5c3-11ea-8105-f9b34988c9af.png)


## Update the main branch to reference the release

### `hack/build.sh`

Find the references to the previous release number and update the lines to
include the new release number as well. We keep the last 4 releases available
per [our support
window](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#knative-community-support-window-principle),
so clean up old versions at the end of the list when there will be more than 4.

Until the old hugo configuration has been aged out (after release 0.27), it's
best to send these PRs to @julz to double-check. You'll also want to remove the
appropriate directory of hugo content under `archived/vX.Y-docs` for the oldest
version, i.e. 0.26 release removed the `archived/v0.22-docs`.


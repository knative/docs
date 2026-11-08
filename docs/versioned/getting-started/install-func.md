---
audience: developer
components:
  - functions
function: tutorial
---

# Installing Knative Functions

For the [local-first Functions exercise](about-knative-functions.md), use standalone `func`. Follow **Executable binary** below, selecting the [`knative-v1.23.0` release](https://github.com/knative/func/releases/tag/knative-v1.23.0) for your operating system and architecture rather than a different release. Its binary reports CLI version `v0.50.0`; the release tag and CLI version use different numbering. This keeps the generated Go HTTP handler aligned with the next lesson.

Verify `func version` before proceeding. If you already have another CLI version installed, do not assume its generated template matches this exercise; use the selected release or consult the [template documentation](../functions/about-functions.md#function-templates) for your version. Other installation methods below are retained as alternatives, not additional steps.

--8<-- "install-functions-intro.md"

## Installing the `func` CLI

--8<-- "install-func-CLI.md"

## Installing the `kn func` CLI plugin

--8<-- "install-kn-func-plugin.md"

The separate plugin installation is not needed when following this exercise with standalone `func`.

**Previous:** [Functions exercise](about-knative-functions.md) · **Next:** [Create a function](create-a-function.md)

If you arrived from Bookstore, [return to sentiment-analysis prerequisites](../bookstore/page-2/sentiment-analysis-service-for-bookstore-reviews.md#install-prerequisites) after verifying installation.

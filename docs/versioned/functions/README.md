---
audience: developer
components:
  - functions
function: explanation
hide_prev: true
hide_next: true
---

# Knative Functions

--8<-- "about-functions.md"

## Start here

New to Knative Functions? Follow [Try Functions](../getting-started/about-knative-functions.md)
to create, edit, and test a Go function locally — no Kubernetes cluster or
registry account required.

## Choose a task

- **[Develop locally](running-functions.md):** install `func`, create a project,
  run it locally, and send HTTP or CloudEvents test requests.
- **[Build an image](building-functions.md):** build a container image locally
  without running or deploying it.
- **[Deploy a function](deploying-functions.md):** deploy from your machine or
  build and deploy remotely on a cluster with Tekton.
- **[Connect events](subscribing-functions.md):** subscribe a function to a
  Knative Broker with Triggers, or consume Apache Kafka topics via sidecar.
- **[Templates and runtimes](language-packs.md):** choose a language and
  HTTP/CloudEvents template, or use custom language-pack repositories.

For the full CLI reference, see the [`func` documentation]({{ funcdocs() }}){target=_blank}.

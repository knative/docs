---
audience: developer
components:
  - functions
function: tutorial
---

# Knative Functions

This is a separate follow-on exercise after [Quickstart](README.md), not a prerequisite for its Serving and Eventing lessons. You will create a Go function project, run it locally, and optionally deploy it as a Knative Service.

--8<-- "about-functions.md"

Use the standalone **`func` CLI** for this route. You need Docker for local builds and runs; deployment also needs a container registry you can push to and a cluster that can pull the image.

1. [Install func](install-func.md).
2. [Create the function project](create-a-function.md).
3. [Run and invoke the function locally](build-run-deploy-func.md#running-a-function). This completes the local exercise.
4. Optionally, [publish to a registry and deploy to your cluster](build-run-deploy-func.md#deploying-a-function) if you have the additional registry and cluster prerequisites.

**Previous:** [Quickstart next steps](next-steps.md) · **Next:** [Install func](install-func.md)

---
audience: developer
components:
  - functions
function: tutorial
hide_prev: true
---

# Knative Functions

Write and run a small **Go HTTP function locally**, then optionally deploy it as a Knative Service. You can start here **without a Kubernetes cluster or completing Quickstart**. It is also a follow-on for readers who have finished [Quickstart](README.md); it is not a prerequisite for its Serving and Eventing lessons.

--8<-- "about-functions.md"

## Your local learning route

Use standalone **`func`** and the **`pack` builder** throughout this exercise. Have a running Docker-compatible daemon, a text editor, and network access to download the CLI, builder images, and Go dependencies. No registry account, running image registry, or Kubernetes credentials are needed for the local steps. The example image prefix is only a local name; nothing is published.

The handler example uses the Go HTTP template from Functions' `knative-v1.24.0` release; its CLI version is `0.51.0`. The installation lesson selects that release so the generated code matches the edit below. The template and taught command options have been checked against this release's source; historical v1.23 tests do not establish that this v1.24 walkthrough has run end to end.

1. [Install func](install-func.md).
2. [Create the project and edit its Go handler](create-a-function.md).
3. [Run and invoke it locally](build-run-deploy-func.md#running-a-function). Confirm the response body says `Hello from Knative Functions!`. This completes the local exercise.
4. Optionally, [publish and deploy](build-run-deploy-func.md#deploying-a-function) after arranging a writable registry and a Knative Serving cluster. If you need a disposable cluster at that point, follow [Quickstart installation](quickstart-install.md).

For alternative workflows after this exercise, use the [Functions task guides](../functions/README.md). You do not need to choose another builder here.

**Previous:** [Tutorial catalog](tutorial.md) · **Next:** [Install func](install-func.md)

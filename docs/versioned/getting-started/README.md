---
audience: developer
components:
  - functions
  - serving
  - eventing
function: tutorial
---

# Welcome to the Knative Quickstart tutorial

Deploy an HTTP Service, watch it scale to zero, split traffic between two Revisions, and send an event back to its source. This is the first hands-on path for newcomers to Knative.

## Your learning route

Use a local **kind** cluster created by the `quickstart` plugin and the **Knative CLI (`kn`)**. You will also use `kubectl`, `curl`, and a browser. No existing Knative installation or container registry account is required for this route. The examples use published container images.

1. [Install the local Quickstart environment](quickstart-install.md).
2. [Deploy and request your first Service](first-service.md).
3. [Observe scale-to-zero and scale-up](first-autoscale.md).
4. [Split traffic between two Revisions](first-traffic-split.md).
5. [Try Eventing](getting-started-eventing.md), then [inspect the Broker](first-broker.md).
6. [Send an event with the CloudEvents Player](first-source.md).
7. [Route the event back with a Trigger](first-trigger.md).
8. [Choose a next step](next-steps.md) and [clean up the cluster](clean-up.md).

Stay on the same cluster in the `default` namespace. Each lesson builds on the preceding lesson. Supporting [YAML examples](yaml-examples.md) are available for comparison, not a second required route.

The installation snippets retain other platform options. For this exercise, choose **kind** when you reach the cluster installation step. [Functions](about-knative-functions.md) is a separate follow-on exercise that requires additional tooling and, for deployment, a container registry.

--8<-- "quickstart-prereqs.md"

Install and start Docker before beginning, and have `curl` available. See [kind's requirements](https://kind.sigs.k8s.io/docs/user/quick-start/) for supported container runtimes and host setup.

**Next:** [Install Quickstart](quickstart-install.md)

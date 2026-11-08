---
audience: developer
components:
  - functions
function: explanation
---

# How Knative Functions fits together

--8<-- "about-functions.md"

## From project to running service

Creating a function gives you a local project, not a deployed Service. Building prepares its container image; running locally lets you exercise the function before deploying it. Publishing transfers the image to a registry but does not create a running Service. Deployment makes it available on a Knative cluster. These are separate goals, so you can return to the relevant task guide without repeating the whole workflow.

A function deployed as a Knative Service uses Serving's routing and autoscaling. See [Knative Serving](../serving/README.md) and [how concurrency affects autoscaling](../serving/autoscaling/concurrency-behavior.md) for the behavior of that deployed Service. To receive events from a Broker, deployment and [subscription to CloudEvents](subscribing-functions.md) are separate steps.

## Function templates

--8<-- "functions-templates-intro.md"

## Language packs

Functions can be written in any language supported by the available [language packs](https://github.com/knative/func/blob/main/docs/language-packs/language-pack-contract.md){target=_blank}. The language-pack contract is maintained in the `func` repository. To use a pack from a repository or a local directory, follow [Using language packs](language-packs.md).

## Local and on-cluster builds

Local requirements depend on the builder. `pack` and `s2i` use a Docker-compatible daemon; the experimental `host` builder in Functions from Knative v1.23.0 uses the local Go or Python toolchain and assembles an OCI image without a Docker daemon. Host-based local run is different again: it starts a process rather than testing the container image. Availability depends on the CLI version and project layout, not just the language name.

An on-cluster build shifts that work to the cluster and requires build infrastructure such as Tekton Pipelines. It can be useful when you do not have a local Docker daemon or when building in a CI/CD workflow. See [Building functions](building-functions.md) for the supported paths and their prerequisites; consult its upstream setup link for the detailed on-cluster build configuration.

## What each verification establishes

A successful local build establishes that an image was produced, not that the handler behaves correctly. A local run and direct invocation exercise the handler in that local environment. A successful push establishes registry publication, not cluster pull access. Service readiness and remote invocation test the deployed endpoint, while a matching event sent through the Broker is needed to test a subscription.

These checks isolate different boundaries. A host-run success can coexist with a container dependency problem; a remotely reachable function can coexist with a missing or mismatched Trigger. Use the [task guides](README.md#accomplish-a-task) to verify the boundary relevant to your goal rather than repeating the entire lifecycle.

## Next steps

- To try one complete workflow, start the [Functions Quickstart](../getting-started/about-knative-functions.md).
- To accomplish a specific goal, choose a task from the [Functions overview](README.md#accomplish-a-task).
- To look up flags and subcommands, use the [upstream command reference]({{ funcdocs() }}){target=_blank} rather than treating this explanation as a command catalog.

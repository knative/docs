---
audience: developer
components:
  - functions
function: explanation
---

# How Knative Functions fits together

--8<-- "about-functions.md"

## From project to running service

Creating a function gives you a local project, not a deployed Service. Building prepares its container image; running locally lets you exercise the function before deploying it. Deployment makes it available on a Knative cluster. These are separate goals, so you can return to the relevant task guide without repeating the whole workflow.

A function deployed as a Knative Service uses Serving's routing and autoscaling. See [Knative Serving](../serving/README.md) and [how concurrency affects autoscaling](../serving/autoscaling/concurrency-behavior.md) for the behavior of that deployed Service. To receive events from a Broker, deployment and [subscription to CloudEvents](subscribing-functions.md) are separate steps.

## Function templates

--8<-- "functions-templates-intro.md"

## Language packs

Functions can be written in any language supported by the available [language packs](https://github.com/knative/func/blob/main/docs/language-packs/language-pack-contract.md){target=_blank}. The language-pack contract is maintained in the `func` repository. To use a pack from a repository or a local directory, follow [Using language packs](language-packs.md).

## Local and on-cluster builds

A local build uses a Docker daemon on your machine. An on-cluster build shifts that work to the cluster and requires build infrastructure such as Tekton Pipelines. It can be useful when you do not have a local Docker daemon or when building in a CI/CD workflow. See [Building functions](building-functions.md) for the supported paths and their prerequisites; consult its upstream setup link for the detailed on-cluster build configuration.

## Next steps

- To try one complete workflow, start the [Functions Quickstart](../getting-started/about-knative-functions.md).
- To accomplish a specific goal, choose a task from the [Functions overview](README.md#accomplish-a-task).
- To look up flags and subcommands, use the [upstream command reference]({{ funcdocs() }}){target=_blank} rather than treating this explanation as a command catalog.

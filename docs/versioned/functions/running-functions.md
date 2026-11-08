---
audience: developer
components:
  - functions
function: how-to
---

# Running functions

--8<-- "run-func-intro.md"

## Prerequisites

- You have [installed the CLI](install-func.md) and [created a function project](creating-functions.md).
- For the containerized procedure below, you have a running Docker-compatible daemon and access to the builder images and dependencies. A registry prefix or explicit image name is needed when building the image; local run does not publish it.

You do not need a Knative cluster to run locally. If you want the experimental Go/Python host-based path instead, see [Run without a container](#run-without-a-container).

## Procedure

--8<-- "proc-running-function.md"

## Run without a container

In Functions from Knative v1.23.0, the experimental `host` builder can run supported Go and Python projects as local processes, without first creating a container image or using a Docker daemon. Install the language toolchain and dependencies required by your generated project. Older Python layouts are not all supported; consult the matching [Python template guide](about-functions.md#function-templates) before using this route.

The [run reference for Functions from Knative v1.23.0](https://github.com/knative/func/blob/knative-v1.23.0/docs/reference/func_run.md){target=_blank} describes this experimental path. Check the corresponding release reference for another installed CLI version. From the project directory, choose the host builder explicitly:

=== "func"

    ```bash
    func run --builder=host
    ```

=== "kn func"

    ```bash
    kn func run --builder=host
    ```

If the CLI prompts for an image registry, it is asking for project/image coordinates, not permission to publish an image. Keep the process running and use the same second-terminal local invocation check as above. A successful host run does not verify the container image or its cluster behavior.

## If local testing fails

- If startup fails, check the selected builder and its daemon or language-toolchain prerequisites. For a containerized run, retry without `--build=false` if no usable image has been built.
- If invocation cannot connect, confirm that `run` is still active and use the address it reports rather than assuming port 8080 is available.
- If the request reaches the handler but fails, compare its format with the selected template and inspect the local process logs. Redact secrets before sharing diagnostics.

After local testing, [deploy the function](deploying-functions.md). Local success does not establish cluster routing, registry pull access, or event delivery.

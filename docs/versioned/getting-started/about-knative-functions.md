---
audience: developer
components:
  - functions
function: tutorial
hide_prev: true
---

<span id="knative-functions"></span><span id="functions-tutorial"></span><span id="your-first-function"></span>

# Get started with Functions

Write a small Go function, change its response, and run it locally. You will
use the standalone `func` CLI and its Go HTTP template. The tool builds a
container image for you; you do not need to write a Dockerfile.

## Before you begin

- Install and start [Docker](https://docs.docker.com/get-started/get-docker/).
- Use a Bash-compatible terminal and have internet access for the CLI, builder
  images, and dependencies.

**You do not need Kubernetes, `kn`, or a registry account for the local lessons.**
The selected container builder supplies the Go toolchain.

## Follow the track

1. [Install func](install-func.md).
2. [Create and change a function](create-a-function.md).
3. [Run and test it locally](build-run-deploy-func.md).

That completes the local track. If you want to run the same function on Knative,
continue with [Deploy to Knative](deploy-a-function.md). That optional lesson
introduces cluster setup and publishing an image.

For other languages and workflows, use the [Functions guides](../functions/README.md)
after completing this example.

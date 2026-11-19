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
The local run command builds the image using Docker and supplies the Go toolchain;
you do not need to install Go separately.

## Follow the track

1. [Install func](install-func.md).
2. [Create and change a function](create-a-function.md).
3. [Run and test it locally](build-run-deploy-func.md).

These three lessons complete the local track. After testing the function, you
can optionally [deploy it to Knative](deploy-a-function.md). You will set up a
cluster and publish an image only if you choose that lesson.

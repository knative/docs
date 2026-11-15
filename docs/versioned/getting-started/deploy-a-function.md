---
audience: developer
components:
  - functions
  - serving
function: tutorial
hide_prev: true
hide_next: true
---

# Deploy your function to Knative

This lesson is optional. Start with the `hello-function` project you changed and
tested in the [local Functions track](about-knative-functions.md).

## Before you begin

- Keep Docker running; this lesson uses the same buildpacks builder as the local lesson.
- [Set up a learning cluster](quickstart-install.md) if you have not already done
  so, then return here. Reuse your existing Quickstart cluster if you still have it.
- Check that `kubectl config current-context` identifies your learning cluster,
  not a production cluster, and that you are using the `default` namespace.
- This example uses [Docker Hub](https://hub.docker.com/). Create an account and
  a **public** repository named `hello-function` in your namespace. A public
  repository lets the learning cluster pull the image without extra credentials.
  Never include secrets in your project or image.

If a Service named `hello-function` already exists in this namespace, use a fresh
learning environment rather than replacing someone else's application.

## Publish and deploy

Log in to Docker Hub, replacing `YOUR-USER` with your username:

```bash
docker login --username YOUR-USER
```

Use your password or access token when prompted; do not put it in a command or
in your source files.

From the `hello-function` directory, replace `YOUR-USER` in the image name:

```bash
func deploy --builder pack --image docker.io/YOUR-USER/hello-function:latest
```

The command builds and pushes an image, then deploys a Knative Service named
`hello-function`. The explicit image name replaces the local-only image name
used in the previous lesson. Wait for deployment to complete and print its URL.

## Call the deployed function

```bash
func invoke --target remote
```

The response body contains the same message you tested locally. The explicit
`remote` target ensures you are calling Knative even if a local process is running.

## Finish up

Your function now runs as a Knative Service. You can [continue learning](next-steps.md)
using the same cluster, or [clean up your environment](clean-up.md) when you are done.
Deleting the cluster does not delete the image from your registry.

The [deployment guide](../functions/deploying-functions.md) covers other registries
and deployment options when you are ready to use your own project.

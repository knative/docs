---
audience: developer
components:
  - serving
function: tutorial
hide_prev: true
---

<span id="deploying-a-knative-service"></span>

# Deploy and call a service

Run a sample HTTP container, then send it a request. You do not need to build an
image or write code for this track.

## Before you begin

[Set up a learning cluster](quickstart-install.md) if you have not already done so,
then return here. Use the `kind-knative` context and the `default` namespace from
that setup. You do not need to complete the Functions or Eventing tracks.

Use the same terminal for these lessons. The examples create a Service named
`hello`; start with no Service of that name in your learning namespace.

## Deploy the container

```bash
kn service create hello \
  --image ghcr.io/knative/helloworld-go:latest \
  --port 8080 \
  --env TARGET=World
```

Wait for `kn` to report that the Service is ready. Knative creates the resources
needed to run the container and give it an HTTP URL.

## Send a request

Read the URL from the Service rather than copying an example hostname:

```bash
SERVICE_URL=$(kn service describe hello -o url)
curl "$SERVICE_URL"
```

The response is:

```text
Hello World!
```

??? help "If the request fails"

    Check that Docker and the learning cluster are running. Your network also
    needs to resolve the `sslip.io` hostname printed by `kn`. If DNS policy blocks
    it, ask your network administrator before changing system-wide DNS settings.
    The [Serving troubleshooting guide](../serving/troubleshooting/debugging-application-issues.md)
    can help diagnose other application issues.

You have deployed a container and reached it over HTTP. Keep the Service running
for the next lesson: [watch it scale to zero](first-autoscale.md).

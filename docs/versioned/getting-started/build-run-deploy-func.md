---
audience: developer
components:
  - functions
function: tutorial
hide_next: true
---

<span id="building-running-or-deploying-functions"></span><span id="running-a-function"></span>

# Run and test locally

Use the `hello-function` project from the previous lesson. Make sure Docker is
running, then run this command **inside the project directory**:

```bash
func run --builder pack --image localhost/hello-function:latest
```

This selects the container-based buildpacks builder, builds your function, and
runs it locally. The first build downloads builder images and dependencies and
can take several minutes. Wait until the function reports that it is listening.

`localhost/hello-function:latest` is a **local image name**, not a registry you
must set up. This command does not push an image or deploy anything to Kubernetes.

Keep this terminal open while testing the function.

<span id="prerequisites"></span><span id="procedure"></span>

## Call your function

Open a **second terminal**, change to the same `hello-function` directory, and run:

```bash
func invoke --target local
```

The response includes your message:

```text
Hello from my function!
```

Additional response information may surround the body. The important result is
that the message you wrote in `function.go` came back from your local function.

## Try another change

Stop `func run` with **Ctrl+C** in the first terminal. Change the message in
`function.go`, save the file, and run the same `func run` command again. When it
is ready, invoke it from the second terminal and confirm the new message.

<span id="deploying-a-function"></span><span id="building-a-function"></span><span id="prerequisites_1"></span><span id="procedure_1"></span><span id="prerequisites_2"></span><span id="procedure_2"></span>

## Next steps

You have created, changed, and tested a function without Kubernetes or a registry
account. Stop the local process with **Ctrl+C** when you are done.

Choose one next step:

- [Deploy this function to Knative](deploy-a-function.md) — optional; requires a
  learning cluster and an image registry.
- [Continue learning](next-steps.md) with another component or your own project.

The [Functions guides](../functions/README.md) cover other builders, languages,
and deployment workflows. They are not required to complete this local track.

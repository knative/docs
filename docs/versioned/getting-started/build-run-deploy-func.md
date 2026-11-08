---
audience: developer
components:
  - functions
function: tutorial
hide_next: true
---

<span id="building-running-or-deploying-functions"></span>

# Run and deploy your first function

**Starting state:** You have [created `hello-function`](create-a-function.md), installed standalone `func`, and started Docker. Begin in the parent directory of `hello-function`.

## Running a function

<span id="prerequisites"></span>

The local prerequisites are the generated `hello-function` project, standalone `func`, and a running Docker daemon; no registry push permission is needed for the local exercise.

<span id="procedure"></span>

The `run` command builds a function image if needed and runs it locally, not on the cluster. Choose an image registry prefix for naming the image. Deployment later requires permission to push to that registry; local running does not publish the image.

```bash
cd hello-function
export FUNC_REGISTRY=<registry-host/your-namespace>
func run
```

Replace the placeholder before running it. Keep this terminal open while the function runs.

!!! success "Expected result"
    The image builds and the function starts locally. Check the reported listening port; the usual host port is 8080.

In a **second terminal**, enter the same `hello-function` directory and invoke the running function at its local address:

```bash
func invoke -t http://localhost:8080
```

Use the port reported by `func run` if it differs. Observe a response from the CLI and the request in the running function's output. Then stop `func run` with `Ctrl+C` in the first terminal.

For rebuilding (`func run --build`), skipping a build (`func run --build=false`), and other local-run options, see [running functions](../functions/running-functions.md).

## Deploying a function

<span id="prerequisites_1"></span>

**Optional:** The local exercise is complete once you have received the local response. You can [choose another next step](next-steps.md) without publishing an image. Continue with deployment only if you have:

- A Knative Serving cluster, such as the disposable [Quickstart cluster](quickstart-install.md).
- Permission to push to the registry prefix used above.
- Images that the cluster can pull. Some registries make new images private by default; for this exercise make your image public unless you have configured private pulls.

<span id="procedure_1"></span>

Authenticate with your registry using its instructions. Do not publish credentials in commands, logs, or source files. Return to the first terminal, still inside `hello-function`, with `FUNC_REGISTRY` set:

```bash
kubectl config current-context
kubectl config set-context --current --namespace=default
func deploy
```

Check that the context is your disposable cluster **before** deployment. The project name becomes the Knative Service name, `hello-function`; deployment builds and publishes the image and deploys that Service.

!!! success "Expected result"
    `func` reports deployment in `default` and a function URL. Use the reported URL, not an example address.

Verify the deployed function explicitly, rather than invoking the earlier local process:

```bash
kn service describe hello-function
func invoke -t "$(kn service describe hello-function -o url)"
```

The Service should be Ready and invocation should receive a response. See [deploying functions](../functions/deploying-functions.md) for private-registry credentials, the alternative `kn func` command form, and the `raw` Kubernetes deployer; those are not needed for this route.

## Building a function

<span id="prerequisites_2"></span>

For a separate local build, use the same function project, Docker daemon, and image-naming prefix as the local-run exercise.

<span id="procedure_2"></span>

Running and deployment already build the image when necessary. To build separately for later use, run `func build` from the function project directory. It names the image using the project name and registry prefix; building alone does not deploy a Service. See [building functions](../functions/building-functions.md) for build options.

## Next steps

For your own function projects, use the [Functions task guides](../functions/README.md) and [invoking functions guide](../functions/invoking-functions.md). For a larger exercise with Python CloudEvent functions, continue to [Bookstore](../bookstore/page-0/welcome-knative-bookstore-tutorial.md). If finished, [clean up the disposable cluster](clean-up.md); deleting it does not remove images you published to your registry.

**Previous:** [Create the function project](create-a-function.md) · **Next:** [Choose another next step](next-steps.md)

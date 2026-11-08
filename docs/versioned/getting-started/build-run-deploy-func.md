---
audience: developer
components:
  - functions
function: tutorial
hide_next: true
---

<span id="building-running-or-deploying-functions"></span>

# Run and deploy your first function

**Starting state:** You have [created `hello-function` and edited its Go HTTP handler](create-a-function.md) using the selected `func` release. You have a running Docker-compatible daemon and network access for builder images and dependencies. Begin in the parent directory of `hello-function`. No Kubernetes cluster is needed for the local exercise.

## Running a function

<span id="prerequisites"></span>

Use the **`pack` builder** for this containerized exercise. It builds the image if needed and runs the function locally; it does not publish an image or deploy a Service. This explicit selection keeps the lesson on the same builder path even if another builder is configured by default.

<span id="procedure"></span>

Enter the project and start it:

```bash
cd hello-function
func run --builder=pack --registry localhost:5001
```

**`localhost:5001` is only an image-naming prefix here.** You do not need an account or a registry listening on that port. This local run does not push the image there. Downloading builder images and dependencies still requires network access; publishing later has separate credentials and destination requirements.

!!! success "Expected result"
    The image builds and the local function starts. Wait for the command to report its listening address, then leave this terminal running.

In a **second terminal**, enter the same `hello-function` directory and explicitly invoke the local HTTP handler:

```bash
func invoke --target=local --format=http
```

!!! success "Check the response body"
    Among the CLI's response output, the handler's body should be:

    ```{ .text .no-copy }
    Hello from Knative Functions!
    ```

This is the text you wrote in `function.go`, not just proof that an arbitrary endpoint answered. If you still see `OK`, check that the file was saved in this project, stop `func run` with `Ctrl+C`, and rerun the same command with `--build` to force a rebuild. If invocation cannot connect, check the listening address and that both terminals use the same project; see [local invocation diagnostics](../functions/invoking-functions.md#verify-and-diagnose).

Stop `func run` with `Ctrl+C` in the first terminal when finished. **The local exercise is complete.** You can [choose another next step](next-steps.md) without installing Kubernetes or publishing anything.

For your own projects, use the [running functions task](../functions/running-functions.md) and [invocation guide](../functions/invoking-functions.md). Alternative builders are outside this chosen tutorial path.

## Deploying a function

<span id="prerequisites_1"></span>

**Optional:** Continue only if you want this function available on Knative and have:

- `kubectl` and a disposable cluster with Knative Serving installed. If you need one, follow [Quickstart installation](quickstart-install.md) now, then return here. Local success does not depend on completing those Serving/Eventing lessons.
- Permission to create or update `hello-function` in the cluster's `default` namespace. Do not replace another application's Service.
- A registry namespace you can publish to and images the cluster can pull. For this exercise, use a public image unless private pulls have already been configured. Your local push credentials do not automatically give the cluster pull access.
- The same edited function project and the Docker-compatible daemon needed by `pack`.

<span id="procedure_1"></span>

Return to the first terminal, still inside `hello-function`, with the local process stopped. **Inspect the context before any deployment:**

```bash
kubectl config current-context
kubectl config get-contexts
```

Confirm that this is the intended disposable cluster and that you are authorized to deploy there. If the context is wrong or unknown, stop. Use [CLI cluster-access guidance](../client/connect-to-cluster.md) to identify/select the intended context, then repeat this inspection. **Do not continue until you approve the selected context.**

After approval, check the destination for an existing Service:

```bash
kubectl get kservice hello-function --namespace default
```

`NotFound` permits creating the tutorial Service. A permission or connection error does not. If a Service exists, continue only if it is your own tutorial deployment and updating it is intended; otherwise stop and use the [deployment task's ownership guidance](../functions/deploying-functions.md#prerequisites).

Use the fresh local project created in this exercise. If `func.yaml` already records a different `deploy.namespace` or `deploy.deployer`, stop before building or publishing: a namespace change can remove the previous deployment, and v1.24 refuses in-place changes of an active deployer. This lesson is not a namespace/deployer migration procedure.

For the local-name → publication-name transition below, do not configure an explicit `image` in `func.yaml` or an image override through `FUNC_IMAGE`. An explicit image takes precedence over `--registry`; it would no longer be the registry-derived naming route taught here. Use the [deployment task](../functions/deploying-functions.md) if you need that separate image-based workflow.

Authenticate with your registry using its instructions, without putting credentials in source files or shared logs. Choose an actual writable registry prefix, **not** the local-only `localhost:5001` name. For example, replace `your-username` below with your authorized namespace (or replace the whole prefix for another registry):

```bash
PUBLISH_REGISTRY=ghcr.io/your-username
```

**Only after context/ownership approval and registry setup**, run this deployment block:

```bash
func deploy --builder=pack --remote=false --deployer=knative \
  --registry "$PUBLISH_REGISTRY" --namespace default
```

This selects a local `pack` build from the edited project, publishes the resulting image to your chosen registry, and creates or updates the Knative Service `hello-function` in `default`. It is not a build-only or push-only command. It does not use repository-source deployment or an already-published `--image` alternative; those have their own source/namespace prerequisites in the [deployment task](../functions/deploying-functions.md).

!!! success "Expected result"
    `func` reports deployment in `default` and the function URL. Use the reported URL rather than an example address.

Verify readiness and explicitly invoke the deployed function rather than the earlier local process:

```bash
kubectl get kservice hello-function --namespace default
func invoke --target=remote --format=http
```

The Service should be Ready, and the response body should again contain `Hello from Knative Functions!`. Ready status alone does not verify the handler. If the response cannot be confirmed, use [deployment diagnostics](../functions/deploying-functions.md#verify-readiness-and-diagnose-failures); do not declare success from a local response.

For private pulls, alternative deployment paths, and a previously published image, use [deploying functions](../functions/deploying-functions.md). These are not additional steps in this exercise.

## Building a function

<span id="prerequisites_2"></span>

A separate build is not required above: local run builds as needed, and deployment builds and publishes. If you want an image without running or deploying, use the same project and Docker-compatible daemon.

<span id="procedure_2"></span>

From `hello-function`, this selected-builder example builds without publishing:

```bash
func build --builder=pack --registry localhost:5001 --push=false
```

The prefix remains a local name, not a running registry. See [building functions](../functions/building-functions.md) for other bounded build tasks, including [publishing without deployment](../functions/building-functions.md#publish-without-deploying).

## Next steps

For your own projects, use the [Functions task guides](../functions/README.md) and [invoking functions guide](../functions/invoking-functions.md). After the Serving and Eventing basics, try [Bookstore](../bookstore/page-0/welcome-knative-bookstore-tutorial.md).

If you created a disposable cluster and are finished with it, [clean it up](clean-up.md). A local-only reader has no cluster to delete. Cluster cleanup does not remove the local project or published registry images.

**Previous:** [Create and edit the function](create-a-function.md) · **Next:** [Choose another next step](next-steps.md)

---
audience: developer
components:
  - functions
function: tutorial
hide_prev: true
hide_next: true
---

<span id="knative-functions"></span><span id="functions-tutorial"></span><span id="your-first-function"></span>

# Try Functions

Write a Go HTTP function, change its response, and run it locally with `func`.
No Kubernetes cluster, registry account, Dockerfile, or local Go toolchain is
required for the local workflow.

<span id="before-you-begin"></span><span id="installing-knative-functions"></span><span id="installing-the-func-cli"></span>

## Prepare

- A running [Docker](https://docs.docker.com/get-started/get-docker/) engine
  and a Bash-compatible terminal (on Windows, use WSL 2 with Docker integration).
- Install the standalone `func` CLI:

=== "Homebrew"

    ```bash
    brew install knative-extensions/kn-plugins/func
    ```

=== "Release binary"

    Download the binary for your OS and architecture from the
    [Functions release page](https://github.com/knative/func/releases) (use a
    Linux binary in WSL 2), make it executable, and place it on your `PATH` as
    `func`.

Verify `func version` prints a version number. For `kn func` plugin installation,
see [Installing Knative Functions](../functions/install-func.md).

<span id="creating-a-function"></span><span id="change-the-response"></span>

## Create and change

1. Create a Go HTTP function in a fresh directory:

    ```bash
    func create -l go -t http hello-function
    cd hello-function
    ```

1. Open `function.go`, find `fmt.Fprintln(res, "OK")` inside `Handle`, and
   replace it with:

    ```go
    fmt.Fprintln(res, "Hello from my function!")
    ```

1. Save the file and leave the rest of the template unchanged (`func.yaml`
   describes the project; `function_test.go` is a starter test).

<span id="building-running-or-deploying-functions"></span><span id="running-a-function"></span><span id="call-your-function"></span>

## Run and test

1. Inside `hello-function`, build and run the function locally with buildpacks:

    ```bash
    func run --builder pack \
      --image localhost/hello-function:latest
    ```

    The first build downloads builder images and dependencies and can take
    several minutes. `localhost/hello-function:latest` is a local image name —
    nothing is pushed or deployed. Wait for a line like:

    ```text
    Function running on 127.0.0.1:8080
    ```

1. Keep that terminal open. In a **second terminal** inside the same
   `hello-function` directory, invoke the local function:

    ```bash
    func invoke --target local
    ```

    The response includes `Hello from my function!`.

1. To iterate, press ++ctrl+c++ in the first terminal, edit the message in
   `function.go`, and re-run `func run` and `func invoke --target local`.

??? help "If the build exits or invoking fails"

    Read the final build error; the container builder needs a running Docker
    engine ([Docker documentation](https://docs.docker.com/)) and network access.
    If invoking cannot find a local function, verify the first terminal is still
    running and the second terminal is inside `hello-function` (`ls func.yaml`).
    If stuck, [get help](next-steps.md#get-help) with the error and `func version`.

<span id="deploying-a-function"></span><span id="deploy-your-function-to-knative"></span>

## Deploy to Knative (optional)

You have finished the local workflow. To run the same function on Knative, you need:

- A learning cluster — [set up a cluster](quickstart-install.md) if you do not have one, and confirm your [context and `default` namespace](quickstart-install.md#create-and-verify).
- Access to a container registry (logged in locally) with push permissions and a public image repository so the cluster can pull the image without pull secrets. Never include secrets in the project.

1. From `hello-function`, build, push, and deploy (replace `<registry>` with your registry and namespace, for example `ghcr.io/alice` or `docker.io/alice`):

    ```bash
    func deploy --builder pack \
      --image <registry>/hello-function:latest
    ```

1. Invoke the remote Service explicitly:

    ```bash
    func invoke --target remote
    ```

    The response contains the same message you tested locally. If the Service is not ready, verify the image is publicly pullable and inspect `kn service describe hello-function`.

## Next steps

Stop `func run` with ++ctrl+c++ when finished. Continue with
[Try Serving](first-service.md), [Try Eventing](getting-started-eventing.md),
or [Next steps and cleanup](next-steps.md).

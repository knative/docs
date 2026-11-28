---
audience: developer
components:
  - functions
function: how-to
hide_prev: true
hide_next: true
---

# Develop locally

Install the `func` CLI, scaffold a function project, run it on your machine,
and test it with HTTP or CloudEvents requests — no Kubernetes cluster or
container registry required.

<span id="installing-knative-functions"></span><span id="installing-the-func-cli"></span><span id="installing-the-kn-func-cli-plugin"></span>

## Prepare

- A running [Docker](https://docs.docker.com/get-started/get-docker/) engine
  for containerized builds (`pack` or `s2i`). For `--builder host`, Docker is
  optional, but the target language toolchain (Go or Python) must be installed
  on your host.
- Install the `func` CLI (or `kn func` plugin):

=== "Homebrew"

    ```bash
    brew install knative-extensions/kn-plugins/func
    ```

    If `kn` is also installed via Homebrew, `kn func` is available automatically.

=== "Release binary"

    Download the binary for your OS and architecture from the
    [`func` release page](https://github.com/knative/func/releases){target=_blank},
    make it executable, and place it on your `PATH` as `func` (or as `kn-func`
    to use it as a `kn` plugin).

=== "Build from source"

    Requires Go and `make`:

    ```bash
    git clone https://github.com/knative/func.git func
    cd func
    make
    ```

    Place the resulting `func` binary on your `PATH`.

Verify the installation using the command matching how you installed it:

```bash
func version
# or, if installed as a kn plugin:
kn func version
```

<span id="creating-functions"></span>

## Create a project

Create a new function directory using `-l` (language) and `-t` (template:
`http` or `cloudevents`, default `http`). See
[Templates and runtimes](language-packs.md) for the full list of supported
languages.

=== "func"

    ```bash
    func create -l go -t http my-function
    cd my-function
    ```

=== "kn func"

    ```bash
    kn func create -l go -t http my-function
    cd my-function
    ```

`func create` writes a new `my-function/` directory containing `func.yaml`,
handler source, and starter tests. Pass `-t cloudevents` if your function will
consume CloudEvents. For all flags, see the
[`func create` reference](https://github.com/knative/func/blob/main/docs/reference/func_create.md){target=_blank}.

## Run locally

Inside the project directory, build and run the function locally. Pass an
explicit `localhost/...` image name so the build stays local without needing a
container registry:

=== "func"

    ```bash
    func run --builder pack \
      --image localhost/my-function:latest
    ```

=== "kn func"

    ```bash
    kn func run --builder pack \
      --image localhost/my-function:latest
    ```

Wait until the function prints its local address, for example:

```text
Function running on 127.0.0.1:8080
```

Useful flags:

- `--builder host` — run Go or Python directly on your host without Docker.
- `--build=true` — force a rebuild even if no source changes were detected.
- `--build=false` — reuse an already-built image without rebuilding (fails if
  no image has been built yet).
- `--address 127.0.0.1:8081` — bind to a different local port.

Keep this terminal open while testing.

<span id="invoking-functions"></span>

## Send test requests

In a **second terminal** inside the same project directory, use `func invoke`
with `--target local` so you are guaranteed to hit the local instance:

=== "HTTP request"

    ```bash
    func invoke --target local \
      --content-type application/json \
      --data '{"message":"Hello local!"}'
    ```

=== "CloudEvent"

    ```bash
    func invoke --target local \
      --format cloudevent \
      --type dev.knative.example \
      --source /local-test \
      --data '{"message":"Hello event!"}'
    ```

(`kn func invoke` accepts the same flags.) Confirm the response body matches
your handler's output. You can also target a deployed instance with
`--target remote` or an arbitrary endpoint with `--target https://...`. See the
[`func invoke` reference](https://github.com/knative/func/blob/main/docs/reference/func_invoke.md){target=_blank}
for all options.

## Iterate and stop

1. Press ++ctrl+c++ in the `func run` terminal to stop the local function.
2. Edit your handler code and save.
3. Re-run `func run` and verify the updated output with `func invoke --target local`.

When you are ready to package or ship the function, continue to
[Build an image](building-functions.md) or [Deploy a function](deploying-functions.md).

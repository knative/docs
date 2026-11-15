---
audience: developer
components:
  - functions
  - serving
  - eventing
function: tutorial
hide_next: true
---

<span id="installing-knative-using-quickstart"></span>

# Set up a learning cluster

Create a local Kubernetes cluster with Knative Serving and Eventing using the
Quickstart plugin and kind. Set this up **once** for the Serving and Eventing
tracks, and reuse it while you learn. You do not need it for local Functions development.

This is a disposable learning environment, not a production installation.
For other installation methods, see the [installation guide](../install/README.md).

## Before you begin

- Use a Bash-compatible terminal. On Windows, use a Linux development environment
  such as WSL 2 with Docker integration enabled.
- Install and start [Docker](https://docs.docker.com/get-started/get-docker/).
  Quickstart does not install a container engine for you.
- Make at least 3 CPUs and 3 GB of RAM available for the cluster.
- Have internet access to download tools and container images, and `curl` to test services.
- Ensure port 80 is available; Quickstart uses it for local HTTP traffic.

The tutorial creates a kind cluster named `knative`. If that cluster already
exists, reuse it only if it is your disposable Knative learning environment.
Do not replace an existing cluster that you need for other work.

<span id="install-the-knative-cli"></span><span id="install-the-knative-quickstart-plugin"></span>

## Install the tools

Install `kind`, `kubectl`, the Knative CLI (`kn`), and its `quickstart` plugin locally.

=== "Homebrew"

    If you use [Homebrew](https://brew.sh/), run:

    ```bash
    brew install kind kubectl knative/client/kn knative-extensions/kn-plugins/quickstart
    ```

=== "Release binaries"

    Download the executable for your operating system and CPU architecture from
    each project's releases:

    | Tool | Download | Executable name |
    | --- | --- | --- |
    | kind | [kind installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) | `kind` |
    | kubectl | [kubectl installation](https://kubernetes.io/docs/tasks/tools/#kubectl) | `kubectl` |
    | Knative CLI | [kn releases](https://github.com/knative/client/releases) | `kn` |
    | Quickstart plugin | [quickstart releases](https://github.com/knative-extensions/kn-plugin-quickstart/releases) | `kn-quickstart` |

    Rename the downloaded files to the executable names above. On Linux and
    macOS, make them executable with `chmod +x <filename>`. Put them in a
    directory on your `PATH`. Keep the `kn-` prefix on `kn-quickstart` so that
    `kn` can discover the plugin.

Check that the tools and Docker are available:

```bash
kind version
kubectl version --client
kn version
kn quickstart --help
docker info
```

If a command is not found, fix its installation before continuing. For other
CLI installation options, see [CLI tools](../client/install-kn.md).

<span id="run-the-knative-quickstart-plugin"></span>

## Create the cluster

```bash
kn quickstart kind
```

Wait for the command to finish. It creates the `knative` kind cluster, installs
Serving and Eventing, and creates an `example-broker` for the Eventing track.

Verify the cluster context before running any tutorial commands:

```bash
kubectl config current-context
```

The context should be `kind-knative`. If it is not, switch to your learning cluster
with `kubectl config use-context kind-knative`. Set its default namespace:

```bash
kubectl config set-context --current --namespace=default
```

Keep this context selected while following the tutorials. Do not use a production
cluster. If setup fails, see the [Quickstart documentation](https://github.com/knative-extensions/kn-plugin-quickstart#readme).

## Choose your track

Your environment is ready. Continue with the track you chose:

- [Serving: deploy and call a service](first-service.md) — the recommended first track.
- [Eventing: explore the Broker](getting-started-eventing.md).
- [Functions: deploy your local function](deploy-a-function.md) — only after completing the local Functions lessons.

You do not need to complete Serving before starting Eventing. Keep the cluster
until you have finished all the tracks you want to try.

<span id="next-steps"></span>

---
audience: developer
components:
  - functions
  - serving
  - eventing
function: tutorial
hide_prev: true
hide_next: true
---

<span id="installing-knative-using-quickstart"></span>

# Set up a cluster

Create a disposable local `kind` cluster with Knative Serving and Eventing.
Set this up once for Serving and Eventing; local Functions development does not
need a cluster. For production clusters, see [Install and Manage](../install/README.md).

<span id="before-you-begin"></span>

## Requirements

- A running [Docker](https://docs.docker.com/get-started/get-docker/) engine.
- A Bash-compatible terminal (on Windows, use WSL 2 with Docker integration).
- At least 3 CPUs, 3 GB of RAM, internet access, `curl`, and a free port 80.

<span id="install-the-knative-cli"></span><span id="install-the-knative-quickstart-plugin"></span><span id="install-the-tools"></span>

## Install tools

=== "Homebrew"

    ```bash
    brew install \
      kind \
      kubectl \
      knative/client/kn \
      knative-extensions/kn-plugins/quickstart
    ```

=== "Release binaries"

    Download the binary for your OS and architecture (use Linux binaries in
    WSL 2), make it executable, and place it on your `PATH`. Keep
    `kn-quickstart` as the plugin filename so `kn` can discover it.

    | Tool | Download | Name |
    | --- | --- | --- |
    | kind | [kind installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) | `kind` |
    | kubectl | [kubectl installation](https://kubernetes.io/docs/tasks/tools/#kubectl) | `kubectl` |
    | Knative CLI | [kn releases](https://github.com/knative/client/releases) | `kn` |
    | Quickstart plugin | [quickstart releases](https://github.com/knative-extensions/kn-plugin-quickstart/releases) | `kn-quickstart` |

<span id="run-the-knative-quickstart-plugin"></span><span id="create-the-cluster"></span><span id="select-your-learning-context"></span>

## Create and verify

Already have the `knative` learning cluster ready? Skip cluster creation and
verify your context below. Do not recreate or repurpose a cluster used for other
work.

```bash
kn quickstart kind
```

This creates a kind cluster named `knative`, installs Serving and Eventing, and
creates `example-broker`. Confirm your context and `default` namespace before
running tutorial commands — do not use a production cluster:

```bash
kubectl config use-context kind-knative
kubectl config set-context --current --namespace=default
kubectl config current-context
kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}'; echo
```

If setup fails, see the [Quickstart documentation](https://github.com/knative-extensions/kn-plugin-quickstart#readme)
or [get help](next-steps.md#get-help).

<span id="choose-your-track"></span><span id="next-steps"></span>

Continue with [Try Serving](first-service.md) (recommended first),
[Try Eventing](getting-started-eventing.md), or
[Try Functions](about-knative-functions.md) (jump directly to
[Deploy to Knative](about-knative-functions.md#deploy-to-knative-optional) if
you have already created and tested your function locally).

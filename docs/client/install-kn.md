---
audience: developer
components:
  - eventing
  - functions
  - serving
function: how-to
---

# Installing CLI Tools

There are three CLI tools available for managing Knative.

- Kubernetes CLI - `kubectl`
- Knative CLI - `kn`
- Knative Operator CLI - `kn`

The `kn` CLI makes Knative operations easier, but all functionality is available in `kubectl` provided you want to primarily use YAML representations of resources. The Knative Operator CLI facilitates the of installing of the Knative Operator and the Serving and Eventing components.

## Install Kubernetes CLI

Install the [Kubernetes CLI (`kubectl`)](https://kubernetes.io/docs/tasks/tools/install-kubectl){target=_blank} to run commands against Kubernetes clusters. You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs.

--8<-- "install-kn.md"

### Install kn using the nightly-built binary

!!! warning
    Nightly container images include features which may not be included in the latest Knative release and are not considered to be stable.

Nightly-built executable binaries are available for users who want to install the latest pre-release build of `kn`.

Links to the latest nightly-built executable binaries are available here:

- [macOS](https://storage.googleapis.com/knative-nightly/client/latest/kn-darwin-amd64){target=_blank}
- [Linux](https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64){target=_blank}
- [Windows](https://storage.googleapis.com/knative-nightly/client/latest/kn-windows-amd64.exe){target=_blank}

### Using kn with Tekton

See the [Tekton documentation](http://hub.tekton.dev/tekton/task/kn){target=_blank}.

## Install the Knative Operator CLI Plugin

Before you install the Knative Operator CLI Plugin, first install the Knative CLI described earlier.

=== "MacOS"

    1. Download the binary `kn-operator-darwin-amd64` for your system from the [release page](https://github.com/knative-extensions/kn-plugin-operator/releases/tag/knative-v1.7.1).

    1. Rename the binary to `kn-operator`:

        ```bash
        mv kn-operator-darwin-amd64 kn-operator
        ```

=== "Linux"

    1. Download the binary `kn-operator-linux-amd64` for your system from the [release page](https://github.com/knative-extensions/kn-plugin-operator/releases/tag/knative-v1.7.1).

    1. Rename the binary to `kn-operator`:

        ```bash
        mv kn-operator-linux-amd64 kn-operator
        ```

Make the plugin executable by running the command:

```bash
chmod +x kn-operator
```

Create the directory for the `kn` plugin:

```bash
mkdir -p ~/.config/kn/plugins
```

Move the file to a plugin directory for `kn`:

```bash
cp kn-operator ~/.config/kn/plugins
```

### Verify the installation of the Knative Operator CLI Plugin

You can run the following command to verify the installation:

```bash
kn operator -h
```

You should see more information about how to use this CLI plugin.


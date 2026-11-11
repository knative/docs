---
audience: developer
components:
  - functions
function: how-to
---

# Creating functions

Creating a function writes a local project and its `func.yaml` configuration. It does not build an image, publish it, or create resources on a cluster.

## Prerequisites

- You have [installed `func` or the `kn func` plugin](install-func.md).
- You have a writable parent directory for the new project. Use a new directory name rather than an existing application directory.

A cluster, Docker daemon, and registry credentials are not required to create a project from the built-in templates.

## Choose a language and template

List the runtime identifiers and templates available to your installed CLI:

=== "func"

    ```bash
    func languages
    func templates
    ```

=== "kn func"

    ```bash
    kn func languages
    kn func templates
    ```

Use the identifier shown by the CLI for `--language`; for example, Node.js uses `node`. Choose `--template http` for an HTTP handler or `--template cloudevents` for a CloudEvents handler. The built-in default is `http`. These choices determine the generated handler signature, not whether a deployed function is subscribed to a Broker.

For example, to create a Go CloudEvents project:

=== "func"

    ```bash
    func create --language go --template cloudevents hello-events
    ```

=== "kn func"

    ```bash
    kn func create --language go --template cloudevents hello-events
    ```

See [function templates](about-functions.md#function-templates) for language-specific handler contracts, or [language packs](language-packs.md) to use an external template.

## Create the project

The following example creates an HTTP project using the default template:

--8<-- "create-a-function.md"

## Verify and continue

Confirm that the new directory contains `func.yaml` and the generated source files. Read the project's README and the language-specific template documentation before changing the handler signature or dependencies.

- To prepare an image without deploying, [build the function](building-functions.md).
- To test it on your machine, [run it locally](running-functions.md).
- To make it available on Knative, [deploy the function](deploying-functions.md).

If creation fails, check the runtime/template identifiers and destination directory first. For external packs, also check repository access and the provider's template layout; installing a pack does not guarantee its build or runtime compatibility.

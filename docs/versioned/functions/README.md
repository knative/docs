---
audience: developer
components:
  - functions
function: explanation
---

# Knative Functions overview

Knative Functions lets you create, build, and deploy function projects as Knative Services using the `func` CLI or the `kn func` plugin. Choose a learning path, a specific task, or an explanation before looking up individual command options.

## Getting started with functions

For a guided first function, follow the [Functions Quickstart](../getting-started/about-knative-functions.md). Start with the [Knative Quickstart environment](../getting-started/README.md) if you do not yet have a development cluster. The Functions lessons take you through installation, creation, building, running, and deployment.

If you already have an environment and know your goal, use the task guides below instead of restarting the tutorial.

## Accomplish a task

| Goal | Guide |
| --- | --- |
| Install the CLI or plugin | [Installing Knative Functions](install-func.md) |
| Start a function project | [Creating functions](creating-functions.md) |
| Build a container image locally or on the cluster | [Building functions](building-functions.md) |
| Test a function on your machine | [Running functions](running-functions.md) |
| Make a function available on Knative | [Deploying functions](deploying-functions.md) |
| Send a request to a function | [Invoking functions](invoking-functions.md) |
| Receive CloudEvents from a Broker | [Subscribe functions to CloudEvents](subscribing-functions.md) |
| Use an additional language pack | [Language packs](language-packs.md) |

## Understand Functions

Read [How Knative Functions fits together](about-functions.md) for the relationship between a project, a container image, a deployed Service, and the local/on-cluster build choices.

### Function templates

Templates initialize a project for a language and invocation format. See [function templates](about-functions.md#function-templates) for the available templates and their upstream documentation.

### Language packs

See [language packs](about-functions.md#language-packs) for their role and the upstream language-pack contract, or [use an additional pack](language-packs.md) if you are ready to configure one.

## Look up commands and contracts

- [`func` command reference]({{ funcdocs() }}){target=_blank} — subcommands, flags, and options, maintained in the `func` repository. This link follows the documentation release branch when configured; otherwise it points to `main`.
- [Function template documentation](about-functions.md#function-templates) — language-specific contracts maintained upstream.
- [CLI tools](../client/README.md) — choose between `kubectl`, `kn`, and `func`, and find cluster-access guidance.

Use reference matching your installed CLI version when checking available flags. The task guides supply workflow context; they are not a replacement for the upstream command reference.

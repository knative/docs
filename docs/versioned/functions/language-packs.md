---
audience: developer
components:
  - functions
function: how-to
---

# Language packs

Language packs can be used to extend Knative Functions to support additional runtimes, function signatures, operating systems, and installed tooling for functions. Language packs are distributed through Git repositories or as directories on disk. This guide selects a pack for a **new** project; adding a repository does not convert an existing project's handler or dependencies.

For more information see the [language pack](https://github.com/knative/func/blob/main/docs/language-packs/language-pack-contract.md){target=_blank} documentation.

## Prerequisites

- You have [installed the CLI](install-func.md) and chosen a new project directory.
- You trust the pack provider and can access its Git repository or local directory. Review its generated code, dependency declarations, and builder/base-image configuration before building or running it.
- You have checked the provider's supported CLI versions, language toolchain, invocation signature, and build/run requirements. An external template's presence is not proof of compatibility with every builder.

The examples below use `func`; the plugin accepts the same subcommands after `kn func`.

## Using external Git repositories

When creating a new function, a Git repository can be specified as the source for the template files. Use a repository maintained by a provider you trust; this guide does not certify an external integration.

Before creation, inspect its available templates:

```{ .console }
func templates --repository <repository-url>
```

Use the runtime and template names shown by the installed CLI:

```{ .console }
func create myfunc --language <runtime> --template <template> \
  --repository <repository-url>
```

Replace the placeholders with your provider's repository URL and identifiers. If a template is no longer available, stop and choose a documented template rather than assuming an old example still works.

## Installing language packs locally

Language-pack repositories can be registered locally by using `func repository`. The `repository` section of the [upstream command reference]({{ funcdocs() }}){target=_blank} covers registration and management.

For example, register your chosen repository under the local name `my-pack`:

```{ .console }
func repository add my-pack <repository-url>
```

Then select one of its templates using that prefix:

```{ .console }
func create --template my-pack/<template> --language <runtime> my-controller-function
```

Confirm registration with `func repository list`, and use `func templates` to inspect the available runtime/template names before creating the project. The `my-pack/` prefix is the local registration name chosen above, not a guarantee of support or certification.

## Use a pack from a local directory

A pack need not be hosted in Git. To use a trusted directory that follows the upstream pack layout, provide a `file://` URI when creating the project:

```bash
func create my-local-function --language node --template http \
  --repository file:///absolute/path/to/language-pack
```

Replace the URI, language, and template with your pack's location and identifiers. The directory must be a pack repository root, not an arbitrary function project.

## Verify the generated project

Check that the new directory contains `func.yaml` and the source/dependency files the provider documents. Review its handler signature and build settings, then [build](building-functions.md), [run](running-functions.md), and [invoke](invoking-functions.md) the function using a builder the pack supports. Neither successful registration nor creation proves that an external pack builds, serves requests, or receives Broker events.

If creation fails, check repository access, runtime/template names, and layout first. If building or invocation fails, use the provider's compatibility guidance and the relevant task's diagnostics rather than changing the handler to an unrelated built-in signature.

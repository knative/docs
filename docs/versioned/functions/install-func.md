---
audience: developer
components:
  - functions
function: how-to
---

# Installing Knative Functions

--8<-- "install-functions-intro.md"

!!! note "Match the Knative release and CLI version"
    Knative release tags and the Functions CLI version number are different. For **Knative v1.24.0** ([`knative-v1.24.0` release](https://github.com/knative/func/releases/tag/knative-v1.24.0){target=_blank}), the [release build](https://github.com/knative/func/blob/knative-v1.24.0/hack/release.sh#L39-L61){target=_blank} sets the CLI version to **`v0.51.0`**, not `1.24.0`. Check your actual artifact with `func version --verbose` or `kn func version --verbose`, recording the reported CLI version, Knative version, and commit when available.

    Earlier checks of the [`knative-v1.23.0` release](https://github.com/knative/func/releases/tag/knative-v1.23.0){target=_blank} reported `0.50.0`; those results are historical, not validation of v1.24. References to Functions from Knative v1.24.0 name the release/source tag. Use the corresponding upstream reference: a current Homebrew package or a build from `main` does not necessarily install that release.

## Installing the `func` CLI

--8<-- "install-func-CLI.md"

## Installing the `kn func` CLI plugin

--8<-- "install-kn-func-plugin.md"

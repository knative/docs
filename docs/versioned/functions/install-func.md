---
audience: developer
components:
  - functions
function: how-to
---

# Installing Knative Functions

--8<-- "install-functions-intro.md"

!!! note "Match the Knative release and CLI version"
    Knative release tags and the Functions CLI version number are different. The Functions CLI distributed with **Knative v1.23.0** ([`knative-v1.23.0` release](https://github.com/knative/func/releases/tag/knative-v1.23.0){target=_blank}) reports **`0.50.0`** when you run `func version` or `kn func version`.

    References in these guides to Functions from Knative v1.23.0 identify that release/source tag, not an expected CLI version of `1.23.0`. Record both the release artifact you installed and its reported CLI version, then use the corresponding upstream reference. Installing a current Homebrew package or building from `main` does not necessarily install that release.

## Installing the `func` CLI

--8<-- "install-func-CLI.md"

## Installing the `kn func` CLI plugin

--8<-- "install-kn-func-plugin.md"

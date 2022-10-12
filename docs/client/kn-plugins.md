# kn plugins

The `kn` CLI supports the use of plugins. Plugins enable you to extend the functionality of your `kn` installation by adding custom commands and other shared commands that are not part of the core distribution of `kn`.

!!! warning
    The plugins must be named with the prefix `kn-` to be detected by `kn`. For example, `kn-func` will be detected but `func` won't be detected.

## kn source plugins

An event source plugin has the following characteristics:

- It has a name that is part of the `kn source` group.
- It provides CRUD sub-commands; `create`, `update`, `delete`, `describe`, and sometimes `apply`.
- It requires a mandatory `--sink` flag to be passed when using the `create` command.

## List of Knative plugins

You can view all available `kn` plugins in the [Knative Sandbox repository](https://github.com/orgs/knative-sandbox/repositories?q=kn+plugin&type=all&language=&sort=).

<!--TODO: If we're including the following table, the Client WG must be responsible for ensuring that the table is kept up to date, otherwise it should be removed from the docs and just the link to the sandbox repo should be provided-->

| Plugin | Description | Available via Homebrew? |
| --- | --- | :---: |
| [kn-plugin-admin](https://github.com/knative-sandbox/kn-plugin-admin) | `kn` plugin for managing a Kubernetes based Knative installation | Y |
| [kn-plugin-diag](https://github.com/knative-sandbox/kn-plugin-diag) | `kn` plugin for diagnosing issues by exposing detailed information for different layers of Knative objects | N |
| [kn-plugin-event](https://github.com/knative-sandbox/kn-plugin-event) | `kn` plugin for sending events to Knative sinks | Y |
| [kn-plugin-func](https://github.com/knative/func) | `kn` plugin for functions | Y |
| [kn-plugin-migration](https://github.com/knative-sandbox/kn-plugin-migration) | `kn` plugin for migrating Knative Services from one cluster to another | N |
| [kn-plugin-operator](https://github.com/knative-sandbox/kn-plugin-operator) | `kn` plugin for managing Knative with Knative Operator | N |
| [kn-plugin-quickstart](https://github.com/knative-sandbox/kn-plugin-quickstart) | `kn` plugin for developers to install a quickstart Knative cluster for experimentation purposes | Y |
| [kn-plugin-service-log](https://github.com/knative-sandbox/kn-plugin-service-log) | `kn` plugin for showing the standard output of Knative Services | N |
| [kn-plugin-source-kafka](https://github.com/knative-sandbox/kn-plugin-source-kafka) | `kn` plugin for managing Kafka event sources | Y |
| [kn-plugin-source-kamelet](https://github.com/knative-sandbox/kn-plugin-source-kamelet) | `kn` plugin for managing Kamelets and KameletBindings | Y |

## Manually install a plugin

You can manually install all plugins. To manually install a plugin:

1. Download the current release of the plugin from GitHub. See the [list of Knative plugins](#list-of-knative-plugins) you can download.
1. Rename the file to remove the OS and architecture information. For example, rename `kn-admin-darwin-amd64` to `kn-admin`.
1. Make the plugin executable. For example, `chmod +x kn-admin`.
1. Move the file to a directory on your `PATH`. For example, `/usr/local/bin`.

## Install a plugin by using Homebrew

You can install some plugins can be installed using the [Knative plugins Homebrew Tap](https://github.com/knative-sandbox/homebrew-kn-plugins/). For example, you can install the `kn-admin` plugin by running `brew install knative-sandbox/kn-plugins/admin`.

## List available plugins

You can list all available (installed) plugins by entering the command:

```bash
kn plugin list
```

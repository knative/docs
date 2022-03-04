# kn plugins

The `kn` CLI supports the use of plugins. Plugins enable you to extend the functionality of your `kn` installation by adding custom commands and other shared commands that are not part of the core distribution of `kn`.

!!! warning
    The plugins must be named with the prefix `kn-` to be detected by `kn`. For example, `kn-func` will be detected but `func` won't be detected.

<!--TODO: Add details about using different available plugins-->

## How to install a plugin

### Manaul installation

All plugins can be installed by downloading the current release from Github and placing it somewhere on your `PATH`. You may need to rename the file to remove any OS/architecture information (for example, `kn-admin-darwin-amd64` should be renamed to `kn-admin`).

### Homebrew

Some plugins can be installed via the [Knative plugins Homebrew Tap](https://github.com/knative-sandbox/homebrew-kn-plugins/)) For example, the `kn-admin` plugin can be installed by running `brew install knative-sandbox/kn-plugins/admin`.

## List of Knative plugins

| Plugin | Description | Available via Homebrew? |
| --- | --- | :---: |
| [kn-plugin-admin](https://github.com/knative-sandbox/kn-plugin-admin) | Kn plugin for managing a Kubernetes based Knative installation | Y |
| [kn-plugin-diag](https://github.com/knative-sandbox/kn-plugin-diag) | Kn plugin for exposing detailed information for different layers of knative objects for diagnose | N |
| [kn-plugin-event](https://github.com/knative-sandbox/kn-plugin-event) | Kn plugin for sending events to Knative sinks | Y |
| [kn-plugin-func](https://github.com/knative-sandbox/kn-plugin-func) | Kn plugin for functions | Y |
| [kn-plugin-migration](https://github.com/knative-sandbox/kn-plugin-migration) | Kn plugin for migrating Knative services from one cluster to another | N |
| [kn-plugin-operator](https://github.com/knative-sandbox/kn-plugin-operator) | Kn plugin for managing Knative with Knative Operator | N |
| [kn-plugin-quickstart](https://github.com/knative-sandbox/kn-plugin-quickstart) | Kn plugin for installation of Knative cluster for developers to quickstart | Y |
| [kn-plugin-service-log](https://github.com/knative-sandbox/kn-plugin-service-log) | Kn plugin for showing the standard output of Knative services | N |
| [kn-plugin-source-kafka](https://github.com/knative-sandbox/kn-plugin-source-kafka) | Kn plugin for managing Kafka event sources | Y |
| [kn-plugin-source-kamelet](https://github.com/knative-sandbox/kn-plugin-source-kamelet) | Kn plugin for managing Kamelets and KameletBindings | Y |


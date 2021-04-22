---
title: "Customizing kn"
weight: 03
type: "docs"
---

You can customize your `kn` CLI setup by creating a `config.yaml` configuration file. The CLI will look for this file under the home directory of the user at `$HOME/.config/kn/config.yaml`, however you can create this file anywhere and use the `--config` flag to specify its path.

## Example configuration file

```yaml
lookupPluginsInPath: true
pluginsdir: ~/.config/kn/plugins
sink:
- prefix: myprefix
  group: eventing.knative.dev
  version: v1alpha1
  resource: brokers
```

Where

- `lookupPluginsInPath` specifies whether `kn` should look for [plugins](./kn-plugins) in the specified `PATH` environment variable. This is a boolean configuration option. The default value is `false`.

- `pluginsdir` specifies the directory where `kn` will look for plugins. The defaults path is `~/.config/kn/plugins`. This can be any directory that is visible to the user.

- `sink` defines the prefix that is used to refer to Kubernetes Addressable resources. To configure a sink prefix, you must define following fields, as shown in the example:
    - `prefix`: The prefix you want to use to describe your sink. Service, `svc`, and `broker` are predefined prefixes in `kn`.
    <!--can be a prefix be anything? Otherwise let's provide a full list of what's allowed, limitations, etc.-->
    - `group`: The API group of the Kubernetes resource.
    - `version`: The version of the Kubernetes resource.
    - `resource`: The plural name of the Kubernetes resource type. For example, `services` or `brokers`.

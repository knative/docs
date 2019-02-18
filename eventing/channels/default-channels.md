<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Default Channels](#default-channels)
  - [Creating a default channel](#creating-a-default-channel)
    - [Caveats](#caveats)
      - [Arguments cannot be specified by default channels](#arguments-cannot-be-specified-by-default-channels)
  - [Setting the default channel configuration](#setting-the-default-channel-configuration)
    - [Caveats](#caveats-1)
      - [Defaults only apply on channel creation](#defaults-only-apply-on-channel-creation)
      - [Default channel arguments cannot be specified](#default-channel-arguments-cannot-be-specified)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Default Channels

The default channel configuration allows channels to be created without
specifying a provisioner. This leaves the selection of channel provisioner and
properties up to the operator. The operator controls the default settings via a
ConfigMap.

## Creating a default channel

To create a default channel, leave the `spec.provisioner` property blank. The
`spec` property must be provided, but should be empty.

_The content of `spec.arguments` will be cleared for default channels._

This is a valid default channel:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Channel
metadata:
  name: default-channel
  namespace: default
spec: {}
```

When the above Channel is created, a mutating admission webhook sets
`spec.provisioner` based on the default provisioner chosen by the operator.

For example, if the default provisioner is named `default-provisioner`:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Channel
metadata:
  name: default-channel
  namespace: default
spec:
  provisioner:
    apiversion: eventing.knative.dev/v1alpha1
￼    kind: ClusterChannelProvisioner
￼    name: default-provisioner
```

### Caveats

#### Arguments cannot be specified by default channels

Currently (v0.3), default channels do not support specifying arguments. If
`spec.arguments` is set when creating a default channel, it will be cleared.
Arguments for default channels may be supported in future versions.

For example:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Channel
metadata:
  name: default-channel
  namespace: default
spec:
  arguments:
    foo: bar
```

Creating the above channel will produce this result:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Channel
metadata:
  name: default-channel
  namespace: default
spec:
  provisioner:
    apiversion: eventing.knative.dev/v1alpha1
￼    kind: ClusterChannelProvisioner
￼    name: default-provisioner
```

## Setting the default channel configuration

The default channel configuration is specified in the ConfigMap named
`default-channel-webhook` in the `knative-eventing` namespace. This ConfigMap
may specify a cluster-wide default channel provisioner and namespace-specific
channel provisioners.

_The namespace-specific defaults override the cluster default for channels
created in the specified namespace._

_Currently (v0.3) default channel arguments cannot be specified, so all default
channels will have empty arguments. Arguments may be supported in future
versions._

The default options are specified like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-channel-webhook
  namespace: knative-eventing
data:
  default-channel-config: |
    clusterdefault:
      apiversion: eventing.knative.dev/v1alpha1
      kind: ClusterChannelProvisioner
      name: in-memory-channel
    namespacedefaults:
      some-namespace:
        apiversion: eventing.knative.dev/v1alpha1
        kind: ClusterChannelProvisioner
        name: some-other-provisioner
```

Namespace-specific default take precedence when matched. In the above example, a
Channel created in the `some-namespace` namespace will receive the
`some-other-provisioner` provisioner, not the `in-memory-channel` provisioner.

### Caveats

#### Defaults only apply on channel creation

Defaults are applied by the webhook on Channel creation only. If the default
settings change, the new defaults will apply to newly-created channels only.
Existing channels will not change.

#### Default channel arguments cannot be specified

Because the `default-channel-webhook` ConfigMap doesn't allow for specifying
default arguments, all default channels will have empty arguments, even if they
were initially specified in the create request.

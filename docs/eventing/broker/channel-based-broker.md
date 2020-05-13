---
title: "Channel Based Broker"
weight: 30
type: "docs"
---

NOTE: This doc assume the shared Knative Eventing components are installed in the `knative-eventing`
namespace. If you installed the shared Knative Eventing components in a different namespace, replace
`knative-eventing` with the name of that namespace.

Knative provides a `Broker` implementation that uses [Channels](../channels/) for
event routing. You will need to have a Channel provider installed, for example
InMemoryChannel (for development purposes), Kafka, Nats, etc. You can choose from
list of [available channels](https://knative.dev/docs/eventing/channels/channels-crds/)

Once you have decided which Channel(s) you want to use and have installed them, you
can configure the Broker by controlling which Channel(s) are used. You can choose
this as a cluster level default, by namespace or by a specific Broker. These are
configured by a `config-br-defaults` `ConfigMap` in knative-eventing namespace.

Here's an example of a configuration that uses Kafka channel for all the
Brokers except namespace `test-broker-6` which uses InMemoryChannels. First
define the `ConfigMap`s to describe how the Channels of each type are created:

```yaml
# Define how InMemoryChannels are created
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: knative-eventing
  name: imc-channel
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1beta1
    kind: InMemoryChannel
```

```yaml
# Define how Kafka channels are created. Note we specify
# extra parameters that are particular to Kakfa Channels, namely
# numPartitions as well as replicationFactor.
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-channel
  namespace: knative-eventing
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1alpha1
    kind: KafkaChannel
    spec:
      numPartitions: 3
      replicationFactor: 1
```

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: ChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: imc-channel
      namespace: knative-eventing
    namespaceDefaults:
      brokerClass: ChannelBasedBroker
      test-broker-6:
        apiVersion: v1
        kind: ConfigMap
        name: kafka-channel
        namespace: knative-eventing
```

## Installing Broker by Annotation

The easiest way to get Broker installed, is to annotate your namespace
(replace `default` with the desired namespace):

```shell
kubectl label namespace default knative-eventing-injection=enabled
```

This will automatically create a `Broker` named `default` in the `default`
namespace. As per above configuration, it would be configured to use Kafka
channels.

```shell
kubectl -n default get broker default
```

_NOTE_ `Broker`s created due to annotation will not be removed if you remove the
annotation. For example, if you annotate the namespace, which will then create
the `Broker` as described above. If you now remove the annotation, the `Broker`
will not be removed, you have to manually delete it.

For example, to delete the injected Broker from the foo namespace:

```shell
kubectl -n foo delete broker default
```

## Installing Broker by Trigger Annotation

Besides the annotation of the namespace, there is an alternative approach to annotate
one of the Triggers, with `knative-eventing-injection: enabled`:

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Trigger
metadata:
  annotations:
    knative-eventing-injection: enabled
  name: testevents-trigger0
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.sources.ping
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: broker-display
```

However, this approach only works _if_ the `Trigger` is coupled to the default `Broker`, and takes only effect
when there is no default `Broker` already present.

Deleting the `Trigger` does not delete the `Broker`. With this approach the same rules from the
[namespace annotation](./#installing-broker-by-annotation) apply here.

## Installing Broker Manually

In order to setup a `Broker` manually, we must first create the required
`ServiceAccount`s and give them the proper RBAC permissions. This setup is
required once per namespace. These instructions will use the `default`
namespace, but you can replace it with any namespace you want to install a
`Broker` into.

Create the `ServiceAccount` objects.

```shell
kubectl -n default create serviceaccount eventing-broker-ingress
kubectl -n default create serviceaccount eventing-broker-filter
```

Then give them the needed RBAC permissions:

```shell
kubectl -n default create rolebinding eventing-broker-ingress \
  --clusterrole=eventing-broker-ingress \
  --serviceaccount=default:eventing-broker-ingress
kubectl -n default create rolebinding eventing-broker-filter \
  --clusterrole=eventing-broker-filter \
  --serviceaccount=default:eventing-broker-filter
```

Note that these commands each use three different objects, all named
`eventing-broker-ingress` or `eventing-broker-filter`. The `ClusterRole` is
installed with Knative Eventing
[here](https://github.com/knative/eventing/blob/master/config/200-broker-clusterrole.yaml).
The `ServiceAccount` was created two commands prior. The `RoleBinding` is
created with this command.

At the time of writing, the broker expects 3 configmaps to run properly: `eventing-config-{logging, observability, tracing}`.
You can manually copy the corresponding configmaps under [`eventing/config/`](https://github.com/knative/eventing/tree/release-0.13/config).
An easier way is to create a `ConfigMapPropagation` object and the configmaps will be automatically
propagated. To do so,
```shell
cat << EOF | kubectl apply -f -
apiVersion: configs.internal.knative.dev/v1alpha1
kind: ConfigMapPropagation
metadata:
  namespace: default
  name: eventing
spec:
  originalNamespace: knative-eventing
  selector:
    # Only propagate configmaps with a specific label.
    matchLabels:
      knative.dev/config-category: eventing
EOF
```

Now we can create the `Broker`. Note that this example uses the name `default`,
but could be replaced by any other valid name. This example uses the defaults
for Channel that we configured above in our `config-br-defaults` `ConfigMap`,
and hence would use Kafka Channels.

```shell
cat << EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1beta1
kind: Broker
metadata:
  namespace: default
  name: default
EOF
```

If you wanted to explicitly specify the Configuration of the Broker, you could do
so by using spec.config, like so (manually overriding it to use InMemoryChannels).

```shell
cat << EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1beta1
kind: Broker
metadata:
  namespace: default
  name: broker-2
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: imc-channel
    namespace: knative-eventing
EOF
```

## Handling failed event delivery

Broker allows you to specify what to do in the case if failed event delivery, say
you have a consumer (function for example) that's failing to process the event.
You can use `delivery` for it:

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Broker
metadata:
  name: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    namespace: knative-eventing
    name: imc-channel
  # Deliver failed events here
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: error-handler
```

You can find out more about delivery spec details [here](https://knative.dev/docs/eventing/event-delivery/).


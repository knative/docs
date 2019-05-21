---
title: "Broker and Trigger"
weight: 20
type: "docs"
---

Broker and Trigger are CRDs providing an event delivery mechanism that hides the
details of event routing from the event producer and event consumer.

## Broker

A Broker represents an 'event mesh'. Events are sent to the Broker's ingress and
are then sent to any subscribers that are interested in that event. Once inside
a Broker, all metadata other than the CloudEvent is stripped away (e.g. unless
set as a CloudEvent attribute, there is no concept of how this event entered the
Broker).

Example:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Broker
metadata:
  name: default
spec:
  channelTemplate:
    provisioner:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: ClusterChannelProvisioner
      name: gcp-pubsub
```

## Trigger

A Trigger represents a desire to subscribe to events from a specific Broker.
Basic filtering on the type and source of events is provided.

Example:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  filter:
    sourceAndType:
      type: dev.knative.foo.bar
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: my-service
```

## Usage

### ClusterChannelProvisioner

`Broker`s use their `spec.channelTemplate` to create their internal `Channel`s,
which dictate the durability guarantees of events sent to that `Broker`. If
`spec.channelTemplate` is not specified, then the
[default provisioner](https://www.knative.dev/docs/eventing/channels/default-channels/)
for their namespace is used.

#### Setup

Have a `ClusterChannelProvisioner` installed and set as the
[default provisioner](https://www.knative.dev/docs/eventing/channels/default-channels/)
for the namespace you are interested in. For development, the
[`in-memory` `ClusterChannelProvisioner`](https://github.com/knative/eventing/tree/master/config/provisioners/in-memory-channel#deployment-steps)
is normally used.

#### Changing

**Note** changing the `ClusterChannelProvisioner` of a running `Broker` will
lose all in-flight events.

If you want to change which `ClusterChannelProvisioner` is used by a given
`Broker`, then determine if the `spec.channelTemplate` is specified or not.

If `spec.channelTemplate` is specified:

1. Delete the `Broker`.
1. Create the `Broker` with the updated `spec.channelTemplate`.

If `spec.channelTemplate` is not specified:

1. Change the
   [default provisioner](https://github.com/knative/docs/blob/master/docs/eventing/channels/default-channels.md#setting-the-default-channel-configuration)
   for the namespace that `Broker` is in.
1. Delete and recreate the `Broker`.

### Broker

There are two ways to create a Broker:

- [namespace annotation](#annotation)
- [manual setup](#manual-setup)

Normally the [namespace annotation](#annotation) is used to do this setup.

#### Annotation

The easiest way to get started, is to annotate your namespace (replace `default`
with the desired namespace):

```shell
kubectl label namespace default knative-eventing-injection=enabled
```

This should automatically create a `Broker` named `default` in the `default`
namespace.

```shell
kubectl -n default get broker default
```

#### Manual Setup

In order to setup a `Broker` manually, we must first create the required
`ServiceAccount`s and give them the proper RBAC permissions. This setup is required
once per namespace. These instructions will use the `default` namespace, but you
can replace it with any namespace you want to install a `Broker` into.

Create the `ServiceAccount`.

```shell
kubectl -n default create serviceaccount eventing-broker-ingress
kubectl -n default create serviceaccount eventing-broker-filter
```

Then give it the needed RBAC permissions:

```shell
kubectl -n default create rolebinding eventing-broker-ingress \
  --clusterrole=eventing-broker-ingress \
  --user=eventing-broker-ingress
kubectl -n default create rolebinding eventing-broker-filter \
  --clusterrole=eventing-broker-filter \
  --serviceaccount=default:eventing-broker-filter
```

Note that the previous commands uses three different objects, all named
`eventing-broker-ingress` or `eventing-broker-filter`. The `ClusterRole` is installed with Knative Eventing
[here](../../config/200-broker-clusterrole.yaml). The `ServiceAccount` was
created two commands prior. The `RoleBinding` is created with this command.

Now we can create the `Broker`. Note that this example uses the name `default`,
but could be replaced by any other valid name.

```shell
cat << EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1alpha1
kind: Broker
metadata:
  namespace: default
  name: default
EOF
```

### Subscriber

Now create a function to receive those events. This document will assume the
following manifest describing a Knative Service is created, but it could be
anything that is `Addressable`.

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: my-service
  namespace: default
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            # This corresponds to
            # https://github.com/knative/eventing-sources/blob/v0.2.1/cmd/message_dumper/dumper.go.
            image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/message_dumper@sha256:ab5391755f11a5821e7263686564b3c3cd5348522f5b31509963afb269ddcd63
```

### Trigger

Create a `Trigger` using the following manifest that sends only events of a
particular type to `my-service`:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: my-service-trigger
  namespace: default
spec:
  filter:
    sourceAndType:
      type: dev.knative.foo.bar
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: my-service
```

#### Defaulting

The Webhook will default certain unspecified fields. For example if
`spec.broker` is unspecified, it will default to `default`. If
`spec.filter.sourceAndType.type` or `spec.filter.sourceAndType.Source` are
unspecified, then they will default to the special value empty string, which
matches everything.

The Webhook will default the YAML above to:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: my-service-trigger
  namespace: default
spec:
  broker: default # Defaulted by the Webhook.
  filter:
    sourceAndType:
      type: dev.knative.foo.bar
      source: "" # Defaulted by the Webhook.
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: my-service
```

You can make multiple `Trigger`s on the same `Broker` corresponding to different
types, sources, and subscribers.

### Source

Now have something emit an event of the correct type (`dev.knative.foo.bar`)
into the `Broker`. We can either do this manually or with a normal Knative
Source.

#### Manual

The `Broker`'s address is well known, it will always be
`<name>-broker.<namespace>.svc.<ending>`. In our case, it is
`default-broker.default.svc.cluster.local`.

While SSHed into a `Pod` and run:

```shell
curl -v "http://default-broker.default.svc.cluster.local/" \
  -X POST \
  -H "X-B3-Flags: 1" \
  -H "CE-CloudEventsVersion: 0.1" \
  -H "CE-EventType: dev.knative.foo.bar" \
  -H "CE-EventTime: 2018-04-05T03:56:24Z" \
  -H "CE-EventID: 45a8b444-3213-4758-be3f-540bf93f85ff" \
  -H "CE-Source: dev.knative.example" \
  -H 'Content-Type: application/json' \
  -d '{ "much": "wow" }'
```

#### Knative Source

Provide the Knative Source the `default` `Broker` as its sink:

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ContainerSource
metadata:
  name: heartbeats-sender
spec:
  image: github.com/knative/eventing-sources/cmd/heartbeats/
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
```

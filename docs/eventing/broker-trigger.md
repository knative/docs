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
  channelTemplateSpec:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: InMemoryChannel
```

## Trigger

A Trigger represents a desire to subscribe to events from a specific Broker.

Example:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

### Trigger Filtering

Exact match filtering on any number of CloudEvents attributes as well as extensions are
supported. If your filter sets multiple attributes, an event must have all of the attributes for the Trigger to filter it. 
Note that we only support exact matching on string values.

Example:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

The example above filters events from the `default` Broker that are of type `dev.knative.foo.bar` AND 
have the extension `myextension` with the value `my-extension-value`.

## Usage

### Channel

`Broker`s use their `spec.channelTemplateSpec` to create their internal
[Channels](./channels/), which dictate the durability guarantees of events sent
to that `Broker`. If `spec.channelTemplateSpec` is not specified, then the
[default channel](./channels/default-channels.md) for their namespace is used.

#### Setup

Have a `Channel` CRD installed and set as the default channel for the namespace
you are interested in. For development, the
[InMemoryChannel](https://github.com/knative/eventing/tree/master/config/channels/in-memory-channel)
is normally used.

#### Changing

**Note** changing the `Channel` of a running `Broker` will lose all in-flight
events.

If you want to change which `Channel` is used by a given `Broker`, then
determine if the `spec.channelTemplateSpec` is specified or not.

If `spec.channelTemplateSpec` is specified:

1. Delete the `Broker`.
1. Create the `Broker` with the updated `spec.channelTemplateSpec`.

If `spec.channelTemplateSpec` is not specified:

1. Change the
   [default channel](./channels/default-channels.md#setting-the-default-channel-configuration)
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

_NOTE_ `Broker`s created due to annotation will not be removed if you remove the
annotation. For example, if you annotate the namespace, which will then create
the `Broker` as described above. If you now remove the annotation, the `Broker`
will not be removed, you have to manually delete it.

For example, to delete the injected Broker from the foo namespace:

```shell
kubectl -n foo delete broker default
```

#### Manual Setup

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

Create RBAC permissions granting access to shared configmaps for logging,
tracing, and metrics configuration.

_These commands assume the shared Knative Eventing components are installed in
the `knative-eventing` namespace. If you installed the shared Knative Eventing
components in a different namespace, replace `knative-eventing` with the name of
that namespace._

```shell
kubectl -n knative-eventing create rolebinding eventing-config-reader-default-eventing-broker-ingress \
  --clusterrole=eventing-config-reader \
  --serviceaccount=default:eventing-broker-ingress
kubectl -n knative-eventing create rolebinding eventing-config-reader-default-eventing-broker-filter \
  --clusterrole=eventing-config-reader \
  --serviceaccount=default:eventing-broker-filter
```

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
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-service
  namespace: default
spec:
  template:
    spec:
      containers:
      -  # This corresponds to
         # https://github.com/knative/eventing-contrib/blob/v0.2.1/cmd/message_dumper/dumper.go.
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
    attributes:
      type: dev.knative.foo.bar
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

#### Defaulting

The Webhook will default the `spec.broker` field to `default`, if left
unspecified.

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
    attributes:
      type: dev.knative.foo.bar
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

You can make multiple `Trigger`s on the same `Broker` corresponding to different
types, sources (or any other CloudEvents attribute), and subscribers.

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
  -H "CE-SpecVersion: 0.2" \
  -H "CE-Type: dev.knative.foo.bar" \
  -H "CE-Time: 2018-04-05T03:56:24Z" \
  -H "CE-ID: 45a8b444-3213-4758-be3f-540bf93f85ff" \
  -H "CE-Source: dev.knative.example" \
  -H 'Content-Type: application/json' \
  -d '{ "much": "wow" }'
```

#### Knative Source

Provide the Knative Source the `default` `Broker` as its sink (note you'll need
to use ko apply -f <source_file>.yaml to create it):

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ContainerSource
metadata:
  name: heartbeats-sender
spec:
  template:
    spec:
      containers:
        - image: github.com/knative/eventing-contrib/cmd/heartbeats/
          name: heartbeats-sender
          args:
            - --eventType=dev.knative.foo.bar
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
```

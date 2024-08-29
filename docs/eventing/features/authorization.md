# Knative Eventing Authorization

**Tracking issue**: [#7256](https://github.com/knative/eventing/issues/7256)

## Overview

Securing event delivery in Knative Eventing is essential to prevent unauthorized access. To enforce fine-grained control over event delivery, Knative Eventing introduces the `EventPolicy` custom resource, which allows users to specify which entities are authorized to send events to specific consumers within a namespace.

## Prerequisites

- [Eventing installation](./../../../install)
- [`authentication-oidc`](./sender-identity.md) feature to be enabled.

!!! note
    As described on the [`authentication-oidc`](./sender-identity.md), `transport-encryption` should be enabled as well for a secure authentication. Take a look at [Transport-Encryption](./transport-encryption.md), which explains how to enable the transport encryption feature flag.

## Compatibility

Authorization is currently supported for the following components:

- Brokers:
    - [MTChannelBasedBroker](./../brokers/broker-types/channel-based-broker/)
    - [Knative Broker for Apache Kafka](./../brokers/broker-types/kafka-broker/)
- Channels:
    - [InMemoryChannel](./../channels/channels-crds.md)
    - [KafkaChannel](./../channels/channels-crds.md)
- Flows:
    - [Sequence](./../flows/sequence/README.md)
    - [Parallel](./../flows/parallel.md)
- Others:
    - [KafkaSink](./../sinks/kafka-sink.md)

## Default Authorization Mode

Administrators can set a default authorization mode using the `defaultAuthorizationMode` feature flag, which Knative Eventing will use whenever no `EventPolicy` applies to a resource. The available modes are:

* `allow-all`: All requests are allowed.
* `deny-all`: All requests are denied, enforcing the creation of EventPolicies.
* `allow-same-namespace`: Only requests from subjects within the same namespace are allowed. (Default)

## Defining an EventPolicy

An `EventPolicy` defines rules for event delivery by specifying which subjects (service accounts or event sources) are allowed to send events to designated event consumers.

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventPolicy
metadata:
  name: my-event-policy
  namespace: default
spec:
  to:
    - ref:
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        name: my-broker
    - selector:
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        matchLabels:
          app: special-app
  from:
    - ref:
        apiVersion: sources.knative.dev/v1
        kind: PingSource
        name: my-source
        namespace: another-namespace
    - sub: system:serviceaccount:default:trusted-app
    - sub: "system:serviceaccount:default:other-*"
  filters:
    - cesql: "type IN ('order.created', 'order.updated', 'order.canceled')"
    - exact:
        type: com.github.push
```

### Specify for who the `EventPolicy` applies

The `.spec.to` section specifies **where** the events are allowed to be sent. This field is optional; if left empty, the policy applies to all resources within the namespace.

There are two ways to define these targets:

1. `to.ref`:
    * **Definition**: Directly references a specific resource.
    * **Example**: In the `EventPolicy` above, the `my-broker` Broker is directly referenced. This means the `EventPolicy` applies to this specific `Broker`.
    * **Use Case**: Use `to.ref` when you want to protect a specific resource by name.
    ```yaml
    to:
      - ref:
          apiVersion: eventing.knative.dev/v1
          kind: Broker
          name: my-broker
    ```
2. `to.selector`:
    * **Definition**: Uses a label selector to match multiple resources of a specific type.
    * **Example**: The `EventPolicy` includes a `Broker` with labels matching `app: special-app`. This means the `EventPolicy` applies to all `Brokers` with these labels.
    * **Use Case**: Use `to.selector` when you want the `EventPolicy` to apply to a group of resources that share common labels.

    ```yaml
    to:
      - selector:
          apiVersion: eventing.knative.dev/v1
          kind: Broker
          matchLabels:
            app: special-app
    ```

### Specify who is allowed to send events

The `.spec.from` section specifies **who** is allowed to send events to the targets defined in `.spec.to`. There are two ways to define these sources:

1. `from.ref`:
    * **Definition**: Directly references a specific event source resource.
    * **Example**: The `my-source` `PingSource` in `another-namespace` is referenced, meaning this specific source is allowed to send events.
    * **Use Case**: Use `from.ref` when you want to authorize a specific event source.
    ```yaml
    from:
      - ref:
          apiVersion: sources.knative.dev/v1
          kind: PingSource
          name: my-source
          namespace: another-namespace
    ```

2. `from.sub`:

    * **Definition**: Specifies a subject, such as a service account, that is allowed to send events. It can include wildcard patterns as a postfix (`*`) for broader matching.
    * **Example**: The `EventPolicy` allows events from the `trusted-app` service account in the default namespace and any service account in `default` namespace that starts with `other-`.
    * **Use Case**: Use `from.sub` to allow specific users or service accounts, or to apply wildcard patterns for more flexibility.
    ```yaml
    from:
      - sub: system:serviceaccount:default:trusted-app
      - sub: "system:serviceaccount:default:other-*"
    ```

### Advanced CloudEvent filtering criterias

The `.spec.filters` section is optional and specifies additional criteria that the event itself must meet to be allowed. 

* **Example:** Only CloudEvents with the `type` equals to `com.github.push` or matching a CESQL expression are allowed.
* **Use Case:** Use `filters` when you want to have more fine grained criterias on allowed CloudEvents.
  ```yaml
  from:
    filters:
      - cesql: "type IN ('order.created', 'order.updated', 'order.canceled')"
      - exact:
          type: com.github.push
  ```

If the filters are specified, an event must match **at least one of them** to be accepted. `.spec.filters` accepts the same filter dialects as [Triggers](../triggers/README.md#supported-filter-dialects).

!!! note
    Filters apply in addition to `.spec.from`. This means, soon as an `EventPolicy` specifies `.spec.filters`, they must match the request, as well as the `.spec.from` (*AND* operand). Only then the `EventPolicy` allows the request.

### Summary of `.spec` fields:

* `to.ref` targets a specific resource.
* `to.selector` targets a set of resources based on labels.
* `from.ref` authorizes a specific event source resource.
* `from.sub` authorizes specific users, service accounts, or patterns of accounts.
* `.spec.filters` allows to define advanced CloudEvent filtering criterias

## EventPolicy status

The status of an `EventPolicy` provides information about resolved sources and readiness:

```yaml
status:
  from:
    - system:serviceaccount:default:my-source-oidc-sources.knative.dev-pingsource
    - system:serviceaccount:default:trusted-app
    - "system:serviceaccount:default:other-*"
  conditions:
    - type: Ready
      status: "True"
    - type: SubjectsResolved
      status: "True"
```

## Applying EventPolicies to Resources

Event consumers, such as a `Broker`, will list the applying EventPolicies in their status:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: my-broker
spec:
  ...
status:
  ...
  policies:
    - name: my-event-policy
      apiVersion: v1alpha1
  conditions:
    - type: Ready
      status: "True"
    - type: EventPoliciesReady
      status: "True"
```

The `EventPoliciesReady` condition indicates whether all applicable EventPolicies for a resource are ready and have been successfully applied.

## Rejection Behavior

If a request does not pass any applicable `EventPolicy`, it will be rejected with a `403 Forbidden` HTTP status code, ensuring that unauthorized event deliveries are blocked.

## Example

In the following, we give a full example how to configure authorization for resources. In this example, we want to protect a Broker (`broker`) in `namespace-1` by only allowing requests from a PingSource (`pingsource-2`) which is in a different namespace (`namespace-2`).

![Example Overview](./images/authz-example.png)

First we create the Namespaces, Broker and PingSources:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: namespace-1
---
apiVersion: v1
kind: Namespace
metadata:
  name: namespace-2
---
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: broker
  namespace: namespace-1
---
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: pingsource-1
  namespace: namespace-1
spec:
  data: '{"message": "Hi from pingsource-1 from namespace-1"}'
  schedule: '*/1 * * * *'
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: broker
      namespace: namespace-1
---
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: pingsource-2
  namespace: namespace-2
spec:
  data: '{"message": "Hi from pingsource-2 from namespace-2"}'
  schedule: '*/1 * * * *'
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: broker
      namespace: namespace-1
```

For debugging we also create an event-display service and Trigger:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
  namespace: namespace-1
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/min-scale: "1"
    spec:
      containers:
      - image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: trigger
  namespace: namespace-1
spec:
  broker: broker
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
```

As long as OIDC is disabled and no EventPolicy is in place, we should see the events from both PingSources in the event-display kservice:

```
$ kubectl -n namespace-1 logs event-display-00001-deployment-56cd8dd644-64xl2
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/namespace-1/pingsources/pingsource-1
  id: 79d7a363-798d-40e2-b95c-6e007c81b05b
  time: 2024-08-28T11:33:00.168602384Z
Extensions,
  knativearrivaltime: 2024-08-28T11:33:00.194124454Z
Data,
  {"message": "Hi from pingsource-1 from namespace-1"}
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/namespace-2/pingsources/pingsource-2
  id: 94cfefc6-57aa-471c-9ce5-1d8c61370c7e
  time: 2024-08-28T11:33:00.287533878Z
Extensions,
  knativearrivaltime: 2024-08-28T11:33:00.296630315Z
Data,
  {"message": "Hi from pingsource-2 from namespace-2"}
```

Now enable OIDC

```
$ kubectl -n knative-eventing patch cm config-features --type merge --patch '{"data":{"authentication-oidc":"enabled"}}'
```

and create the following EventPolicy

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventPolicy
metadata:
  name: event-policy
  namespace: namespace-1
spec:
  to:
    - ref:
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        name: broker
  from:
    - ref:
        apiVersion: sources.knative.dev/v1
        kind: PingSource
        name: pingsource-2
        namespace: namespace-2
```

Afterwards you can see in the Brokers status, that this EventPolicy got applied to it:

```
$ kubectl -n namespace-1 get broker broker -o yaml                                                                      
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: broker
  namespace: namespace-1
  ...
spec:
  ...
status:
  ...
  conditions:
  ...
  - lastTransitionTime: "2024-08-28T11:53:48Z"
    status: "True"
    type: EventPoliciesReady
  - lastTransitionTime: "2024-08-28T11:26:16Z"
    status: "True"
    type: Ready

  policies:
  - apiVersion: eventing.knative.dev/v1alpha1
    name: event-policy
```

And in the event-display, you should see only events from `pingsource-2` anymore:

```
$ kubectl -n namespace-1 logs event-display-00001-deployment-56cd8dd644-64xl2
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/namespace-2/pingsources/pingsource-2
  id: c0b4f5f2-5f95-4c0b-a3c6-6f61b6581a4b
  time: 2024-08-28T11:56:00.200782358Z
Extensions,
  knativearrivaltime: 2024-08-28T11:56:00.20834826Z
Data,
  {"message": "Hi from pingsource-2 from namespace-2"}
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/namespace-2/pingsources/pingsource-2
  id: 6ab79fb0-2cf6-42a0-a43e-6bcd172558e5
  time: 2024-08-28T11:57:00.075390777Z
Extensions,
  knativearrivaltime: 2024-08-28T11:57:00.096497595Z
Data,
  {"message": "Hi from pingsource-2 from namespace-2"}
```

When we remove now the EventPolicy again and keep OIDC disabled, the Broker will fall back to the default authorization mode, which is `allow-same-namespace`:

```
$ kubectl -n namespace-1 delete eventpolicy event-policy
```

This should be reflected in the Brokers status too:

```
$ kubectl -n namespace-1 get broker broker -o yaml           
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: broker
  namespace: namespace-1
  ...
spec:
  ...
status:
  ...
  conditions:
  ...
  - lastTransitionTime: "2024-08-28T12:00:00Z"
    message: Default authz mode is "Allow-Same-Namespace
    reason: DefaultAuthorizationMode
    status: "True"
    type: EventPoliciesReady

  - lastTransitionTime: "2024-08-28T11:26:16Z"
    status: "True"
    type: Ready
```

And we should see only events from `pingsource-1` in the event-display (as `pingsource-1` is in the same namespace as `broker`):

```
$ kubectl -n namespace-1 logs event-display-00001-deployment-56cd8dd644-64xl2
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/namespace-1/pingsources/pingsource-1
  id: cd173aef-373a-4f2b-915e-43c138ac0602
  time: 2024-08-28T12:01:00.2504715Z
Extensions,
  knativearrivaltime: 2024-08-28T12:01:00.276151088Z
Data,
  {"message": "Hi from pingsource-1 from namespace-1"}
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/namespace-1/pingsources/pingsource-1
  id: 22665003-fe81-4203-8896-89594077ae6b
  time: 2024-08-28T12:02:00.121025501Z
Extensions,
  knativearrivaltime: 2024-08-28T12:02:00.13378992Z
Data,
  {"message": "Hi from pingsource-1 from namespace-1"}

```

## Summary

The `EventPolicy` resource in Knative Eventing offers a powerful way to control event delivery securely. By defining which sources can send events to specific consumers, users can ensure that only authorized entities interact within their event-driven architecture.

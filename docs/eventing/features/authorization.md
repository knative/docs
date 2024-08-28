# Knative Eventing Authorization

**Tracking issue**: [#7256](https://github.com/knative/eventing/issues/7256)

## Overview

Securing event delivery in Knative Eventing is essential to prevent unauthorized access. To enforce fine-grained control over event delivery, Knative Eventing introduces the `EventPolicy` custom resource, which allows users to specify which entities are authorized to send events to specific consumers within a namespace.

## Prerequisites

- [Eventing installation](./../../../install)
- [`authentication-oidc`](./sender-identity.md) feature to be enabled.

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
        kind: Trigger
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
    * **Example**: The `EventPolicy` includes a `Trigger` with labels matching `app: special-app`. This means the `EventPolicy` applies to all `Triggers` with these labels.
    * **Use Case**: Use `to.selector` when you want the `EventPolicy` to apply to a group of resources that share common labels.

    ```yaml
    to:
      - selector:
          apiVersion: eventing.knative.dev/v1
          kind: Trigger
          matchLabels:
            app: special-app
    ```

### Specify who is allowed to send events

The `.spec.from` section specifies **who** is allowed to send events to the targets defined in `.spec.to`. There are two ways to define these sources:

1. `from.ref`:
    * **Definition**: Directly references a specific event source resource.
    * **Example**: The `my-source` `PingSource` in another namespace is referenced, meaning this specific source is allowed to send events.
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

The `.spec.filters` section is optional and specifies additional criteria that the event itself must meet to be allowed. If the filters are specified, an event must match at least one of them to be accepted. `.spec.filters` accepts the same filter dialects as [Triggers](../triggers/README.md#supported-filter-dialects).

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

## Default Authorization Mode and Rejection Behavior

When no `EventPolicy` applies to a resource, Knative Eventing falls back to the default authorization mode, configurable via the `defaultAuthorizationMode` feature flag. The available modes are:

* `allow-all`: All requests are allowed.
* `deny-all`: All requests are denied, enforcing the creation of EventPolicies.
* `allow-same-namespace`: Only requests from subjects within the same namespace are allowed. (Default)

If a request does not pass any applicable `EventPolicy`, it will be rejected with a `403 Forbidden` HTTP status code, ensuring that unauthorized event deliveries are blocked.

## Summary

The `EventPolicy` resource in Knative Eventing offers a powerful way to control event delivery securely. By defining which sources can send events to specific consumers, users can ensure that only authorized entities interact within their event-driven architecture.

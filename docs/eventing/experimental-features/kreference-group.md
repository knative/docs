# KReference.Group field

**Flag name**: `kreference-group`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5086](https://github.com/knative/eventing/issues/5086)

**Persona**: Developer

When using the `KReference` type to refer to another Knative resource, you can
just specify the API `group` of the resource, instead of the full `APIVersion`.

For example, in order to refer to an `InMemoryChannel`, instead of the following
spec:

```yaml
apiVersion: messaging.knative.dev/v1
kind: InMemoryChannel
name: my-channel
```

You can use the following:

```yaml
group: messaging.knative.dev
kind: InMemoryChannel
name: my-channel
```

With this feature you can allow Knative to resolve the full `APIVersion` and
further upgrades, deprecations and removals of the referred CRD without
affecting existing resources.

!!! note
    At the moment this feature is implemented only for
    `Subscription.Spec.Subscriber.Ref` and `Subscription.Spec.Channel`.

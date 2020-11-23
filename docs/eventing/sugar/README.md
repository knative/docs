Knative Eventing Sugar Controller will react to special labels and annotations
to produce or control eventing resources in a cluster or namespace. This allows
cluster operators and developers to focus on creating fewer resources. The
underlying eventing infrastructure is created on-demand, and cleaned up when no
longer needed.

Brokers can be managed via the Sugar Controller in the following ways:

| Kind      | Key                                        | Values                                                                     |
| --------- | ------------------------------------------ | -------------------------------------------------------------------------- |
| Namespace | label: eventing.knative.dev/injection      | String, "enabled" or "disabled" - Enables Broker creation from Namespaces. |
| Trigger   | annotation: eventing.knative.dev/injection | String, "enabled" or "disabled" - Enables Broker creation from Triggers.   |

See [Automatic Broker Creation](#automatic-broker-creation).

Triggers can be managed via the Sugar Controller in the following ways:

| Kind        | Key                                                            | Values                                                                                                                                                                       |
| ----------- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Addressable | label: eventing.knative.dev/autotrigger                        | String, "enabled" or "disabled" - Enables Trigger creation.                                                                                                                  |
| Addressable | annotation: autotrigger.eventing.knative.dev/filter.attributes | JSON array of any map of string to string. Default: no filters.                                                                                                              |
| Addressable | annotation: autotrigger.eventing.knative.dev/broker            | String, "<broker-name>" - The name of the Broker to be used by all Triggers created from the Addressable resource. Default: "default".                                       |
| Addressable | annotation: eventing.knative.dev/injection                     | String, "enabled" or "disabled" - This label is propagated to Triggers created by the Sugar Controller. Use this to control the automatic creation of Brokers from Triggers. |

See [Automatic Trigger Creation](#automatic-trigger-creation).

## Installing

The following command installs the Eventing Sugar Controller:

```bash
kubectl apply --filename {{< artifact repo="eventing" file="eventing-sugar-controller.yaml" >}}
```

## Automatic Broker Creation

One way to create a Broker is to manually apply a resource to a cluster using
the default settings:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
EOF
```

There might be cases where automated Broker creation is desirable, such as on
namespace creation, or on Trigger creation. The Sugar controller enables those
use-cases:

- When a Namespace is labeled with `eventing.knative.dev/injection=enabled`, the
  sugar controller will create a default Broker named "default" in that
  namespace.
- When a Trigger is annotated with `eventing.knative.dev/injection=enabled`, the
  controller will create a Broker named by that Trigger in the Trigger's
  Namespace.

When a Broker is deleted and the above labels or annotations are in-use, the
Sugar Controller will automatically recreate a default Broker.

### Namespace Examples

Creating a "default" Broker when creating a Namespace:

```shell
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: example
  labels:
    eventing.knative.dev/injection: enabled
EOF
```

To automatically create a Broker after a namespace exists, label the Namespace:

```shell
kubectl label namespace default eventing.knative.dev/injection=enabled
```

If the Broker named "default" already exists in the Namespace, the Sugar
Controller will do nothing.

### Trigger Examples

Create a Broker named by a Trigger (`spec.broker`) in the Trigger's Namespace:

```shell
kubectl apply -f - << EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar
  namespace: candyland
  annotations:
    eventing.knative.dev/injection: enabled
spec:
  broker: gumdrops
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: event-display
EOF
```

> _Note_: If the named Broker already exists, the Sugar controller will do
> nothing, and the Trigger will not own the existing Broker.

This will make a Broker called "gumdrops" in the Namespace "candyland", and
attempt to send events to the "event-display" service.

If the Broker of the given name already exists in the Namespace, the Sugar
Controller will do nothing.

## Automatic Trigger Creation

The Sugar Controller can also watch for any resource that conforms to the duck
type "Addressable", see [the definition](TODO: add a link for Addressable
definition) or the [Discovery](TODO: link to the discovery documentation)
ClusterDuckType
[addressables.duck.knative.dev](https://github.com/knative-sandbox/discovery/blob/master/config/knative/addressables.duck.knative.dev.yaml).

For any Addressable resource that has been labeled with
`eventing.knative.dev/autotrigger=enabled`, the Sugar Controller will manage the
Trigger(s) for it.

To manage one or more triggers automatically, provide the annotation:

```
annotations:
  autotrigger.eventing.knative.dev/filter.attributes: |
    [{"type":"cloudevents.event.type", "custom-attribute":"match-value"}]
```

`autotrigger.eventing.knative.dev/filter.attributes` is a JSON array of any map
of string to string. Any valid CloudEvents attribute name and value are allowed.
For each map in the array, a new Trigger will be created. If this property is
omitted, a Trigger with no filters will be created for the Addressable resource.

Triggers produced by the Sugar Controller automatically create owner-refs to the
original Addressable resource. When the labeled resource is deleted, the
triggers will also be deleted.

When the `autotrigger.eventing.knative.dev/filter.attributes` is modified, the
Sugar Controller will attempt to realize the new config, which may result in
deleting the triggers created for the old configuration.

For resources that are owned by another Addressable resource, the Sugar
Controller will attempt to not duplicate triggers if the labels and annotations
were reflected down to the owned objects.

The default Broker is used unless the broker annotation is specified:

```
annotations:
  autotrigger.eventing.knative.dev/broker: hello-sugar
```

Using more than one Broker name is not supported for sugar'ed Addressable
resources.

To automatically create a Broker from a Trigger created by the Sugar Controller:

```
annotations:
  eventing.knative.dev/injection: enabled
```

The Sugar Controller uses the label to enable or disable the AutoTrigger
feature, and the annotations to provide the configuration. In this way, you are
able to enable/disable the feature without editing the configuration.

The Sugar Controller does not clean up Triggers if the
`eventing.knative.dev/autotrigger` label is removed, and the Trigger filters
will no longer be updated.

### Simple AutoTrigger Example

When the following Knative Service is created:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-sugar
  namespace: candyland
  labels:
    eventing.knative.dev/autotrigger: enabled
spec:
  template:
    spec:
      containers:
        - image: <some image>
```

The Sugar Controller will notice AutoTrigger is enabled for that resource. It
will create a trigger subscribing the Knative Service "hello-sugar" to all
events sent to the "default" Broker. The Trigger will resemble the example:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar-abc123
  namespace: candyland
  ownerReferences:
    - apiVersion: serving.knative.dev/v1
      kind: Service
      name: hello-sugar
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: hello-sugar
```

If filters are added to the Service,

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-sugar
  namespace: candyland
  labels:
    eventing.knative.dev/autotrigger: enabled
  annotations:
    trigger.eventing.knative.dev/filter.attributes: |
      [{"type":"gumdrops", "sticky":"yes"}]
```

A Trigger with filters will replace the original:

```yaml
kind: Trigger
...
spec:
  ...
  filter:
    attributes:
      type: gumdrops
      sticky: "yes"
```

### Multiple Triggers Example

More than one Trigger could be configured in the filter annotation, when the
following Knative Service is created:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-sugar
  namespace: candyland
  labels:
    eventing.knative.dev/autotrigger: enabled
  annotations:
    trigger.eventing.knative.dev/filter.attributes: |
      [{"type":"gumdrops"}, {"subject":"lollipops"}]
spec:
  template:
    spec:
      containers:
        - image: <some image>
```

Two Triggers will be created like:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar-abc123
  namespace: candyland
  ownerReferences:
    - apiVersion: serving.knative.dev/v1
      kind: Service
      name: hello-sugar
spec:
  broker: default
  filter:
    attributes:
      type: gumdrops
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: hello-sugar

---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar-efg456
  namespace: candyland
  ownerReferences:
    - apiVersion: serving.knative.dev/v1
      kind: Service
      name: hello-sugar
spec:
  broker: default
  filter:
    attributes:
      subject: lollipops
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: hello-sugar
```

### Broker Named Trigger Example

Using the `autotrigger.eventing.knative.dev/broker` annotation, the Addressable
resource can control which Broker name is used in the spec of the managed
Trigger (spec.broker), when the following Knative Service is created:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-sugar
  namespace: candyland
  labels:
    eventing.knative.dev/autotrigger: enabled
  annotations:
    autotrigger.eventing.knative.dev/broker: gloppy
    autotrigger.eventing.knative.dev/filter.attributes: |
      [{"type":"gumdrops"}]
spec:
  template:
    spec:
      containers:
        - image: <some image>
```

A Trigger using the Broker name of "gloppy" will be created like:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar-abc123
  namespace: candyland
  ownerReferences:
    - apiVersion: serving.knative.dev/v1
      kind: Service
      name: hello-sugar
spec:
  broker: gloppy
  filter:
    attributes:
      type: gumdrops
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: hello-sugar
```

### Broker and Trigger Creation Example

It is possible to create both the Broker and Trigger based on annotations on the
Addressable:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-sugar
  namespace: candyland
  labels:
    eventing.knative.dev/autotrigger: enabled
  annotations:
    eventing.knative.dev/injection: enabled
    autotrigger.eventing.knative.dev/broker: gloppy
    autotrigger.eventing.knative.dev/filter.attributes: |
      [{"type":"gumdrops"}]
spec:
  template:
    spec:
      containers:
        - image: <some image>
```

A Trigger using the Broker name of "gloppy" will be created like:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar-abc123
  namespace: candyland
  annotations:
    eventing.knative.dev/injection: enabled
  ownerReferences:
    - apiVersion: serving.knative.dev/v1
      kind: Service
      name: hello-sugar
spec:
  broker: gloppy
  filter:
    attributes:
      type: gumdrops
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: hello-sugar
```

This Trigger will create a Broker like:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: gloppy
  namespace: candyland
spec:
```

See also: [Automatic Broker Creation](#automatic-broker-creation).

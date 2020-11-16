Knative Eventing Sugar Controller will react to special labels and annotations
to produce or control eventing resources in a cluster or namespace.

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
  controller will create a default broker in that namespace.
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

To create a Broker if none exists for the provided Broker name in the Namespace
of the Trigger resource:

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

This will make a Broker called "gumdrops" in the Namespace "candyland", and
attempt to send events to the "event-display" service.

If the Broker of the given name already exists in the Namespace, the Sugar
Controller will do nothing.

## Automatic Trigger Creation

The Sugar Controller can also watch for any resource that conforms to the duck
type "Addressable", see [the defintion](TODO: add a link for addressable
definition) or the [Discovery](TODO: link to the discovery documentation)
ClusterDuckType
[addressables.duck.knative.dev](https://github.com/knative-sandbox/discovery/blob/master/config/knative/addressables.duck.knative.dev.yaml).

For any addressable that is found, the Sugar Controller will react to resources
that have been labeled with the special label
`eventing.knative.dev/autotrigger=enabled`.

To produce one or more triggers automatically, provide the annotation:

```
annotations:
  autotrigger.eventing.knative.dev/filter.attributes: |
    [{"type":"cloudevents.event.type", "custom-attribute":"match-value"}]
```

`autotrigger.eventing.knative.dev/filter.attributes` is a JSON array of any map
of string to string. Any valid CloudEvents attribute name and value are allowed.
For each map in the array, a new Trigger will be created.

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

It is not supported to use more than one broker name with AutoTrigger.

The Sugar Controller uses the label to enable or disable the AutoTrigger
feature, and the annotations to provide the configuration. In this way, you are
able to enable/disable the feature without editing the configuration.

The Sugar Controller does not clean up Triggers if the
`eventing.knative.dev/autotrigger` label is removed, and Trigger filters will no
longer be updated.

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
  annotations:
    trigger.eventing.knative.dev/filter.attributes: |
      [{}]
spec:
  template:
    spec:
      containers:
        - image: <some image>
```

The Sugar Controller will notice AutoTrigger is enabled for that resource, and
produce a trigger subscribing "hello-sugar" to the Knative Service, the cluster
will have a Trigger like:

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

A Trigger with filters will be replace the original:

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

More than one Trigger could be configured in the filter annotaiton, when the
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
    autotrigger.eventing.knative.dev/broker: gloppy
    autotrigger.eventing.knative.dev/filter.attributes: |
      [{"type":"gumdrops"}]
spec:
  template:
    spec:
      containers:
        - image: <some image>
```

A Trigger with the Broker name of "gloppy" will be created like:

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

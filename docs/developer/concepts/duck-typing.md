# Duck typing

Knative enables [loose coupling](https://en.wikipedia.org/wiki/Loose_coupling) of its components by using [duck typing](https://en.wikipedia.org/wiki/Duck_typing).

Duck typing means that the compatibility of a resource for use in a Knative system is determined by certain properties being present that can be used to identify the resource control plane shape and behaviors. These properties are based on a set of common definitions for different types of resources, called duck types.

If a resource has the same fields in the same schema locations as the common definition specifies, and the same control or data plane behaviors as the common definition specifies, Knative can use that resource as if it is the generic duck type, without specific knowledge about the resource type. Some resources may choose to opt-in to multiple duck types.

<!-- TODO: point to Discovery ClusterDuckType documentation. -->

A fundamental use of duck typing in Knative is the use of object references in
resource _specs_ to point to another resource. The definition of the object
containing the reference prescribes the expected duck type of the resource being referenced.

In the following example, a Knative `Example` resource named `pointer` references a `Dog` resource named `pointee` in its spec:

```yaml
apiVersion: sample.knative.dev/v1
kind: Example
metadata:
  name: pointer
spec:
  size:
    apiVersion: extension.example.com/v1
    kind: Dog
    name: pointee
```

Assume the expected shape of a "Sizable" duck type is that in the status, we
expect the following schema shape:

```yaml
<standard metadata>
<spec ignored for Sizable>
status:
  height: <in inches>
  weight: <in pounds>
```

Now the instance of `pointee` could look like this:

```yaml
apiVersion: extension.example.com/v1
kind: Dog
metadata:
  name: pointee
spec:
  owner: Smith Family
  etc: more here
status:
  lastFeeding: 2 hours ago
  hungry: true
  age: 2
  height: 27
  weight: 70
```

When the `Example` resource needs to do its work, it only acts on the
information included in the "Sizable" duck type shape, and the `Dog`
implementation is free to have the information that makes the most sense for
that resource. The power of duck typing is apparent when we extend the system
with a new type, say, `Human`. Assuming the new resource adheres to the contract
set by the "Sizable".

```yaml
apiVersion: sample.knative.dev/v1
kind: Example
metadata:
  name: pointer
spec:
  size:
    apiVersion: people.example.com/v1
    kind: human
    name: pointee
---
apiVersion: people.example.com/v1
kind: Human
metadata:
  name: pointee
spec:
  etc: even more here
status:
  college: true
  hungry: true
  age: 22
  height: 62
  weight: 120
```

The `Example` resource was able to do the logic it is set to do without explicit
knowlage of `Human` or `Dog`.

## Knative Duck Types

Knative defines several duck type contracts that are in use across the project:

- [Addressable](#addressable)
- [Binding](#binding)
- Channelable <!-- TODO -->
- Podspecable <!-- TODO -->
- [Source](#source)

### Addressable

Addressable is expected to be the following shape:

```yaml
apiVersion: group/version
kind: Kind
status:
  address:
    url: http://host/path?query
```

### Binding

Binding is expected to be in the following shape:

(with direct subject)

```yaml
apiVersion: group/version
kind: Kind
spec:
  subject:
    apiVersion: group/version
    kind: SomeKind
    namespace: the-namespace
    name: a-name
```

(with indirect subject)

```yaml
apiVersion: group/version
kind: Kind
spec:
  subject:
    apiVersion: group/version
    kind: SomeKind
    namespace: the-namespace
    selector:
      matchLabels:
        key: value
```

### Source

Source is expected to be in the following shape:

(with ref sink)

```yaml
apiVersion: group/version
kind: Kind
spec:
  sink:
    ref:
      apiVersion: group/version
      kind: AnAddressableKind
      name: a-name
  ceOverrides:
    extensions:
      key: value
status:
  observedGeneration: 1
  conditions:
    - type: Ready
      status: "True"
  sinkUri: http://host
```

(with uri sink)

```yaml
apiVersion: group/version
kind: Kind
spec:
  sink:
    uri: http://host/path?query
  ceOverrides:
    extensions:
      key: value
status:
  observedGeneration: 1
  conditions:
    - type: Ready
      status: "True"
  sinkUri: http://host/path?query
```

(with ref and uri sink)

```yaml
apiVersion: group/version
kind: Kind
spec:
  sink:
    ref:
      apiVersion: group/version
      kind: AnAddressableKind
      name: a-name
    uri: /path?query
  ceOverrides:
    extensions:
      key: value
status:
  observedGeneration: 1
  conditions:
    - type: Ready
      status: "True"
  sinkUri: http://host/path?query
```

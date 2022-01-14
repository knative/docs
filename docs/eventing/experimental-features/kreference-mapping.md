# Knative reference mapping

**Flag name**: `kreference-mapping`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5593](https://github.com/knative/eventing/issues/5593)

**Persona**: Administrator, Developer

When enabled, this feature allows you to provide mappings from
a [Knative reference](https://github.com/knative/specs/blob/main/specs/eventing/overview.md#destination)
to a templated URI.

!!! note
    Currently only PingSource supports this experimental feature.

For example, you can directly reference non-addressable resources anywhere that
Knative Eventing accepts a reference, such as for a PingSource sink, or a
Trigger subscriber.

Mappings are defined by a cluster administrator in
the `config-reference-mapping` ConfigMap. The following example
maps `JobDefinition` to a Job runner service:

{% raw %}

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kreference-mapping
  namespace: knative-eventing
data:
  JobDefinition.v1.mygroup: "https://jobrunner.{{ .SystemNamespace }}.svc.cluster.local/{{ .Name }}"
```

{% endraw %}

The key must be of the form `<Kind>.<version>.<group>`. The value must resolved
to a valid URI. Currently, the following template data are supported:

- Name: The name of the referenced object
- Namespace: The namespace of the referenced object
- UID: The UID of the referenced object
- SystemNamespace: The namespace of where Knative Eventing is installed

Given the above mapping, the following example shows how you can directly
reference
`JobDefinition` objects in a PingSource:

```yaml
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: trigger-job-every-minute
spec:
  schedule: "*/1 * * * *"
  sink:
    ref:
      apiVersion: mygroup/v1
      kind: JobDefinition
      name: ajob
```

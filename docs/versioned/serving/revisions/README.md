---
audience: developer
components:
  - serving
function: explanation
---

# Revisions

--8<-- "about-revisions.md"

Revisions are immutable snapshots of your application code and configuration:
updating a Service's `spec.template` creates a new Revision rather than
modifying the existing Revision's `spec`. You can still update mutable metadata
(such as the `no-gc` annotation below) on an existing Revision.

## Garbage collection

--8<-- "about-revisions-garbage-collection.md"

### Disabling garbage collection for a Revision

To prevent a specific Revision from being garbage collected, add the
`serving.knative.dev/no-gc: "true"` annotation to its metadata:

```bash
kubectl annotate revision <revision-name> serving.knative.dev/no-gc="true"
```

Or in the Revision metadata:

```yaml
apiVersion: serving.knative.dev/v1
kind: Revision
metadata:
  name: <revision-name>
  annotations:
    serving.knative.dev/no-gc: "true"
```

For cluster-wide garbage collection thresholds, see
[Configuring Revision garbage collection](revision-admin-config-options.md).

## Related tasks

- [Split traffic and tag Revisions](../traffic-management.md)
- [Configure gradual rollouts](../rolling-out-latest-revision.md)
- [Configure autoscaling](../autoscaling/README.md)
- [Check Revision status](../troubleshooting/debugging-application-issues.md#check-revision-status)
- [Manage Revisions with `kn revision`](https://github.com/knative/client/blob/main/docs/cmd/kn_revision.md){target=_blank}
- [Revision API specification](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#revision){target=_blank}

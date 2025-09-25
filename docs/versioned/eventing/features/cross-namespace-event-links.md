---
audience: developer
components:
  - eventing
function: how-to
---

# Cross Namespace Event Links

**Flag name**: `cross-namespace-event-links`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#7530](https://github.com/knative/eventing/issues/7530)
## Overview

This feature enables triggers and subscriptions (event links) to refer to a broker
or channel in a different namespace. Without this feature, the trigger or subscription
must be in the same namespace as the broker or channel.

## RBAC

To ensure that users can only subscribe to events from a broker or channel in a separate
namespace when they are allowed to, this feature introduces a new RBAC verb `knsubscribe`
which a user must have to create a trigger or subscription referencing a broker or channel
in another namespace. An example of a role with the correct verb can be seen below:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: example-cross-namespace-role
  namespace: ns-1
rules:
  - apiGroups:
      - "eventing.knative.dev"
    resources:
      - brokers
    verbs:
      - knsubscribe
```

This role will give users the ability to create triggers referring to a broker in namespace
`ns-1` in every namespace they have the ability to create triggers.

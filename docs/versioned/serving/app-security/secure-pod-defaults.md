---
audience: developer
components:
  - serving
function: how-to
---

Knative Serving provides a `secure-pod-defaults` configuration option that  allows operators to default Service configuration to run in the Kubernetes [restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted) Pod Security Standard profile without requiring application developers to explicitly set security properties. 

These settings are controlled by operators so please refer to the [administration documentation](../../configuration/secure-pod-defaults).



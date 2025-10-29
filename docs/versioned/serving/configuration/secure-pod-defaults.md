---
audience: administrator
components:
  - serving
function: how-to
---

!!! important
    The default setting of `disabled` will be changed in the upcoming release of Knative 1.21 to be more secure.

Knative Serving provides a `secure-pod-defaults` configuration option that  allows the default Service configuration to run in the Kubernetes [restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted) Pod Security Standard profile without requiring application developers to explicitly set security properties. This feature offers three security levels: `disabled`, `root-allowed`, and `enabled` allowing organizations to gradually adopt security best practices without breaking container images that require specific permissions. The default is `disabled` to ensure existing deployments continue to work without modification.


## Security Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **disabled** | No security defaults applied | Legacy workloads, maximum compatibility |
| <span style="white-space:nowrap;">**root-allowed**</span> | Implements most of the Kubernetes [restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted) Pod Security Standard profile requirements, with the exception of `runAsNonRoot`, allowing containers to run as root when needed. | Transition period, balanced security |
| **enabled** | Aligns with the Kubernetes [restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted) Pod Security Standard in addition to enforcing non-root execution if not already set | Maximum security for production |

## Key Features

### **Progressive Security Hardening**
When `root-allowed` is configured:
security settings only apply if the field is not set -- if it is explicitly set to any value, it's assumed to be intentional, and not modified.
- Sets `allowPrivilegeEscalation` to `false`
- Sets `seccompProfile` to `RuntimeDefault`, see [Seccomp and Kubernetes](https://kubernetes.io/docs/reference/node/seccomp/) for more details
- Drops all capabilities
  - Conditionally adds `NET_BIND_SERVICE` capability if a container port below 1024 is detected and capabilities are not already configured
- **Does NOT** enforce `runAsNonRoot` (allows root containers)

When `enabled` is configured:

- All of the above, PLUS
- Sets `runAsNonRoot` to `true` if not already specified

### **Respects User Intent**
- Only applies defaults when values are not explicitly set by users
- Never overrides user-specified security contexts

!!! important
    To customize PodSecurityContext properties, you must enable the `kubernetes.podspec-securitycontext` feature flag. When set to `enabled` or `allowed`, it permits the following PodSecurityContext properties:
    
    - `FSGroup`
    - `RunAsGroup`
    - `RunAsNonRoot`
    - `SupplementalGroups`
    - `RunAsUser`
    - `SeccompProfile`
    
    By default, this flag is set to `disabled`. For more information, see [Kubernetes security context](feature-flags.md/#kubernetes-security-context).

## Configuration

See [Configuring the Defaults](config-defaults.md) ConfigMap

Update the `config-features` ConfigMap in `knative-serving` namespace:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-serving
data:
  secure-pod-defaults: "root-allowed"  # or "disabled", "enabled"
```

## Container compatibility

### Breaking Changes
When switching from `disabled` to `enabled`, containers that require root access will fail:

**Example: nginx**
```
nginx: [emerg] chown("/var/cache/nginx/client_temp", 101) failed 
(1: Operation not permitted)
```

**Example: Caddy** (runs as root by default)
```
container has runAsNonRoot and image will run as root
reason: CreateContainerConfigError
```

### Compatible Workloads
Most modern container images following best practices will work with `enabled` mode without modification.

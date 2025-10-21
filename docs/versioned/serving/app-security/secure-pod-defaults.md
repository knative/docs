---
audience: administrator
components:
  - serving
function: how-to
---


## SecurePodDefaults

Knative Serving provides a `secure-pod-defaults` configuration option that gives operators granular control over pod security defaults, enabling progressive adoption of more secure pod configurations while maintaining backward compatibility with existing workloads. This feature offers three security levels—`disabled`, `root-allowed`, and `enabled` allowing organizations to gradually adopt security best practices without breaking container images that require specific permissions. The default is `disabled` to ensure existing deployments continue to work without modification.


### Security Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **disabled** | No security defaults applied | Legacy workloads, maximum compatibility |
| **root-allowed** | Applies security defaults (blocks privilege escalation, runtime-default seccomp, drops capabilities) but allows root containers if not already set | Transition period, balanced security |
| **enabled** | Applies all `root-allowed` defaults plus enforces non-root execution if not already set | Maximum security for production |


## Key Features

### 1. **Backward Compatible Default**
- Default remains `disabled` to prevent breaking existing deployments
- Only affects newly created Revisions (admission webhook behavior)

### 2. **Progressive Security Hardening**
When `root-allowed` is configured:
- Sets `allowPrivilegeEscalation` to `false` if not specified
- Sets `seccompProfile` to `RuntimeDefault` if not specified
- Drops all capabilities if not specified
- Conditionally adds `NET_BIND_SERVICE` capability if a container port below 1024 is detected and capabilities are not already configured
- **Does NOT** enforce `runAsNonRoot` (allows root containers)

When `enabled` is configured:
- All of the above, PLUS
- Sets `runAsNonRoot` to `true` if not already specified

### 3. **Respects User Intent**
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
    
    By default, this flag is set to `disabled`. For more information, see [Kubernetes security context](https://knative.dev/docs/serving/feature-flags/#kubernetes-security-context).

## Configuration

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

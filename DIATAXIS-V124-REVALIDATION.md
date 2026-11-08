# Knative v1.24 revalidation

The user corrected the current release target to **Knative v1.24**. Prior `knative-v1.23.0` source and runtime results remain historical evidence only. Current-version sign-off is withdrawn until the relevant assumptions have been checked against `knative-v1.24.0` and selected runtime paths rerun.

Same experimental worktree/branch; keep existing stable URLs, ownership boundaries and peer consultation. No blind version substitution, no mutation of the user's existing clusters or installed tools, no external/user registry publication. The coordinator alone owns runtime execution and commits.

## Owner checks

- Functions: v1.24 CLI version/release mapping; template/handler contracts; language/builder support and legacy layouts; local versus remote targeting/current-context flags; local upload versus Git builds; build/push/deploy flags and registry-name transitions; raw deployment; generated Trigger creation/update/ownership/collision behavior; response/ack contract in consultation with Eventing.
- Serving: v1.24 target resolution/defaults/validation, explicit Revision-name validation, autoscaling/scale bounds, HTTP port/runtime contract, configuration/observability/encryption keys and issuer references; Operator example API in consultation with Operations.
- Eventing: v1.24 Trigger types/dialect validation, injection/Sugar behavior, DeliverySpec/retry/backoff/failure metadata, response/ack implementation, security/metrics configuration. API/source validation must not be misrepresented as implementation-matrix or timing validation.
- Operations: v1.24 served CRDs, bundle support matrix, default Broker transform, ConfigMap full/short-key precedence, image substitution and upgrade/rollback version resolution/limits.
- Learning: selected v1.24 binary and generated Go HTTP edit, taught builder/deployer flags, namespace/context gates and optional deployment transition; consult Functions before changing the lesson contract.
- Editorial: v1.24 source/test claims and release/CLI numbering, examples in preview guidance, freshness/provenance wording. Preserve old versions where they are explicitly historical rather than making stale claims appear verified.
- Architecture: independent review of revalidated checkpoints, consistency of global reference/lookup paths and explicit legacy/current scope. Do not approve current-version claims solely from prior v1.23 results.

## Review and runtime gate

Each owner records concrete checked files/functions at the newer tag, changed versus unchanged behavior, documentation corrections, remaining uncertainties, and checks. Owners stop at a checkpoint; reviewer findings are relayed for consultation and revision. No source or matrix claim should be marked verified merely because a URL now contains v1.24.

Coordinator will use temporary v1.24 binaries, a private kubeconfig, a distinctly named disposable cluster and local publication destination. Rerun the selected installation, Serving, Functions and event receipt/ack paths. Verify any previously observed failure independently rather than assuming it persists or is fixed. Keep artifact checksums, actual reported versions, test outcomes, limitations and cleanup evidence.

## Status

Revalidation is being dispatched. No v1.24 source/runtime acceptance has been recorded yet.

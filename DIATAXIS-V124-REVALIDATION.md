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

**Bounded v1.24 source and selected-runtime checkpoint accepted by the reviewers.** Current conclusions use newly inspected `knative-v1.24.0` code and newly executed v1.24 binaries; earlier v1.23 results are historical only. The final ordinary strict build and URL/anchor preservation checks passed.

**One build check remains blocked:** the online release-scoped build exhausted GitHub's API rate limit while enumerating integration releases. It timed out rather than completing; it is not recorded as a passed v1.24 release build. Retry that build after quota resets or with an explicitly supplied authorized token before claiming live release-lookup verification. No credentials were searched for or changed to bypass the limit.

## Checkpoint and source provenance

The preceding prototype was preserved at `f09d6954` before retargeting. Seven specialist teams independently rechecked relevant assumptions at the new tag, then consulted and revised concrete findings.

- Functions inspected 34 current source files, including commands, configuration/migrations, builders, deployers, templates and Tekton. Tag commit: `e98dae9b9451e52391fb1998a13fb3c3d867bb38`.
- Eventing inspected current Trigger/DeliverySpec, retry/dependency, response, security and observability paths. Tag commit: `149a64857cf1f23bdf405ff5afe32391b950dc4a`.
- Operator checked both base and Helm CRDs, the actual 19 bundled core manifests, and ConfigMap/Broker/image/version transformations. Tag tree: `33b3be4a98e40141a82185ba4340560a575817ef`.
- Serving rechecked target resolution, defaults/ranges, scale bounds, probes/ports, observability, encryption/issuer handling and Operator examples in current tagged source. Byte comparisons were followed by inspection, not treated as a replacement for it.
- Learning independently obtained Functions and Quickstart tagged source and compared the selected Go HTTP files and command semantics before changing the lesson.
- Editorial and Architecture independently checked material newer-source behavior and the revised reader contracts. Final bounded findings were resolved; neither reviewer claimed to execute coordinator runtime tests.

Detailed temporary checkpoints: `/tmp/dx-functions-v124-checkpoint.md`, `/tmp/dx-learning-v124-checkpoint.md`, `/tmp/dx-eventing-v124-checkpoint.md`, `/tmp/knative-v124-architecture-checkpoint.md`, `/tmp/knative-v124-final-signoff.md`.

## Material corrections and retained behavior

### Changed or newly relevant at v1.24

- Component server minimum and Quickstart's recommended kubectl/default Kind node moved from 1.34 to **1.35**. Client recommendation, default node version and component compatibility are documented separately.
- Functions from Knative v1.24 reports **CLI v0.51.0**, not v1.24.0 or the earlier 0.50.0. Generated project spec version is 0.38.0; these numbers are not interchangeable.
- Remote Git deployment uses `--source`, `--revision`, `--source-dir`; old Git flags/metadata are historical migration context. Explicit repository deployment reads committed configuration, needs no local project, and writes no local deployment state.
- That repository route has a restricted override allowlist. Committed namespace conflicts produce errors; deployer/path/image flags cannot be borrowed from the initialized-local-project route. A committed explicit image wins over registry-derived naming, so the authorized destination must be inspected before deployment.
- v1.24 includes additional deployer/exposure behavior; the main lesson still deliberately selects Knative. Current deployer-switch refusals and namespace-move hazards are stop boundaries, not migration instructions.
- Subscription filter parsing now preserves values after the first `=` and rejects malformed expressions rather than silently accepting them.
- Eventing retry behavior and the new feature-gated `backoffMax` were rechecked at v1.24, including linear-backoff changes and the separate Retry-After path. Old timing assumptions were not reused; source formulas are not a universal runtime schedule.
- Operator's actual v1.24 bundle row is different: Serving 1.21.0–1.21.3, 1.22.0–1.22.1, 1.23.0, 1.24.0; Eventing 1.21.0–1.21.4, 1.22.0–1.22.2, 1.23.0–1.23.1, 1.24.0. Historical rows remain labeled as such.

### Independently checked retained behavior

- Selected Go HTTP handler/signature and its one-line edit remain applicable; generated tests check status, not response text.
- Local pack/host, invocation target/current-context distinctions, initialized-project requirements for local image deployment, and explicit image precedence remain source-supported.
- Knative generated Triggers still ignore AlreadyExists rather than updating filters; identity/UID/routing checks remain necessary. This was also independently observed in the new runtime.
- Event response handling still rejects an unrecognized non-empty response or malformed reply CloudEvent. Fresh receipt alone is not successful acknowledgment or exactly-once proof.
- Operator still serves v1beta1 and uses presence-based full-name ConfigMap selection without merging full/short entries. Relevant transform files were byte-identical across tags and reinspected.
- Ordinary bundled-version resolution and transition limits remain source-supported; they do not establish workload rollback compatibility.

### Inherited errors exposed by the newer-tag audit

These corrections are not mislabeled as features newly introduced in v1.24:

- Burst-capacity default is 211, not the illustrative value 200.
- Activation scale is a floor for positive demand, not a one-shot initial setting; explicit value 1 is invalid.
- HPA CPU targets are utilization percentages, not millicores. Probe handling/default TCP readiness and certificate strategy were clarified.
- CPU/memory/storage quantities in the defaults examples are overrides, not shipped defaults. Omitted global response-start timeout inherits configured revision timeout; per-Revision defaulting has separate conditions.
- Three timeout Service examples incorrectly nested spec in metadata; all were repaired.
- Rollout duration is integer seconds; the Operator fragment now has winning-key/generic-workflow guidance.

## Fresh v1.24 runtime verification

Coordinator-only environment: `/tmp/knative-diataxis-v124.jLI5ld`; new cluster `knative-diataxis-v124`; private kubeconfig/context `kind-knative-diataxis-v124`. Temporary tools did not replace installed tools.

- `kn` v1.24.0; Quickstart v1.24.0; Functions CLI v0.51.0.
- Temporary kubectl v1.35.0, checked against its published checksum; Kubernetes server v1.35.0.
- Serving, Kourier and Eventing installed as v1.24.0.
- Docker Desktop 29.4.3 / ARM64; existing Go 1.27.3. The generated Go project declared Go 1.21.
- Image publication stayed in the newly created local registry, never a user/external registry account.

Computed binary SHA-256 (the kubectl value was also compared to the published checksum; the other values are recorded hashes, not signature/attestation verification):

| Binary | SHA-256 |
| --- | --- |
| kn | `2d1d24f247d2a9c5116337e8002921db38f33f28765ce0a2ff37fdce16df63c0` |
| func | `30ea5fa7c113cd3d013f0b00f67626116b71ef6d677c0324d232560b37d979b9` |
| kn-quickstart | `7294c5f4bc8e348b709b7797966159b1a331deb5f7625aac71035d0d7e1ae15e` |
| kubectl | `cf699c56340dc775230fde4ef84237d27563ea6ef52164c7d078072b586c3918` |

### Passed or directly observed in the new environment

- **Registry-enabled Quickstart:** completed in this run, including components and registry configuration. The earlier v1.23 startup race was not assumed to persist or be universally fixed; one successful current run is not an intermittent-reliability guarantee.
- **Serving:** Hello World create/Ready/URL/response; idle zero and wake; revision update; actual 50/50 status and both responses.
- **Eventing:** Player source → Broker → Trigger → Player with the same fresh ID/payload in SENT and RECEIVED records. CLI path tested, not browser form interaction.
- **Functions:** fresh Go HTTP project; native host local invocation; one-line edit and Go tests; pack local run/invocation; local publication; no-build/no-push published-image deployment and remote invocation.
- **Publication transition:** fresh project built using naming-only `example.com/local`, then changed to the authorized local registry prefix and redeployed; current CLI rebuilt/pushed the changed destination and returned the expected response.
- **Subscription:** current Service owner UID, subscriber, Broker, both filters and Ready checked. Non-compliant plain HTTP reply independently reproduced the current Broker error after receipt. A newly tagged empty-204 fixture then passed fresh-ID receipt, producer completion and the observed acknowledgment-error check; no exactly-once or no-retry claim.
- **Existing Trigger limitation:** changed local filter/redeployed with v0.51.0; live Trigger UID/spec/filter stayed unchanged. Local desired metadata was restored afterward.
- **Filter parser:** later equals signs retained; malformed input rejected without modifying local metadata.
- **Current admission:** actual target 50 in a created Revision; server dry-run accepted target 0.01 and rejected target 0, hard limit 1001 against maximum 1000, activation scale 1, and template change retaining an explicit Revision name. Rejection reasons were inspected, not inferred from exit status alone.
- **Port-80 container:** nginx 1.28-alpine through CLI and YAML, Ready and expected HTTP response. Unhardened disposable environment, not production security-policy validation.
- **Documented context guard:** actual private config allowed the intended context and blocked a mismatch without cluster mutation.

Native first run prompted for image naming when no prefix was supplied. Naming-only `example.com/local` was sufficient; this was not an account/login/publishing requirement. Host process running is not host OCI build validation.

Selected logs/records in the private directory: `quickstart-registry.log`, `quickstart-journey.log`, `kubernetes-versions.json`, `player-messages.json`, `function-host-invoke.log`, `function-pack-invoke.log`, `function-publish-deploy.log`, `event-function-journey.log`, `invalid-filter.log`, `ack-receipt.log`, `ack-filter.log`, `trigger-before-filter-change.json`, `trigger-after-filter-change.json`, `filter-invalid.log`, `validation-*.log`, and `port80-*.body`.

## Builds, preservation, and remaining limits

- Final ordinary strict build passed against the current source: `/tmp/knative-diataxis-v124-final-build.log`.
- Rendered baseline **474 → 474** docs HTML pages: zero missing URLs, lost content IDs/named anchors, or broken internal links. One inherited SVG duplicate-ID set remains unchanged.
- Owner checks covered current source identity, metadata, YAML/Bash structure, relevant schema subsets, anchors, and corrected contracts. Most were source/static checks, not runtime executions by those owners.
- Online `KNATIVE_VERSION=1.24.0 SAMPLES_BRANCH=knative-v1.24.0` build was **blocked**, not passed: GitHub GET `/repositories/294494852/releases?page=2` hit HTTP 403/rate limit, requested roughly 983 seconds of backoff, and the bounded build timed out. Log: `/tmp/knative-diataxis-v124-release-build.log`. No active build was left waiting.
- Direct runtime downloads and tagged-source checks establish their specific current artifacts, not a completed integration-wide release lookup or production multi-release assembly.
- Untested: Tekton explicit/local-metadata Git builds, KEDA/raw exposure, other language/builders and host OCI image builds, private/external registries, Operator runtime install/upgrade/rollback, TLS/metrics enforcement/receipt, extension matrices, Bookstore and Slack/Camel K, visual/observed-user usability, and hosted contributor rendering.

The coordinator verified the registry/node containers were created by this new experiment, then removed only `knative-diataxis-v124` and its local registry. The original three clusters and current `kind-serving-headless` context remained; original five running Docker containers remained. No blanket image/cache cleanup or installed-tool upgrade was performed.

## Rebase onto current upstream main

The draft PR branch was rebased onto upstream `main` at `8d334650d35e03b990f24676c7e8653bc9d4d98a`. The starting typography work had already landed as PR #6757 (`c66bc723`), so the rebase replayed the 17 experiment commits after `c250e7f7` rather than duplicating those merged styling commits.

The previous tested head is preserved locally as `docs/diataxis-pre-rebase-20261107-233942` (`c0a18ba43e9a3c9ee11c30dd142d65c14c2ea2ce`). Earlier commit IDs and runtime evidence below are historical pre-rebase references; rebasing does not constitute another runtime execution.

Conflict resolution retained upstream's removal of retired Backstage/Security Guard/Queue Proxy extension content. The new extension catalog no longer links to the deleted Backstage installer, and external language-pack examples are provider-neutral rather than resurrecting retired `func-tastic` examples. The upstream v1.24 release announcement was added to blog navigation to satisfy strict omitted-page validation.

After syncing the rebased lockfile, the strict local MkDocs build passed with upstream's newer dependencies. Rendered comparison: **474 → 469** docs pages; the five missing pages are exactly the retired upstream Backstage/Queue Proxy/Security Guard pages. The removed `queue-proxy-pod-info` anchor is also an upstream retirement. No other old page/anchor loss and no broken internal links were found; inherited SVG duplicate IDs remain unchanged. No runtime test was repeated for these documentation-only conflict resolutions.

## Navigation feedback revision

The user rejected the expanded sidebar and suggested Kubernetes' documentation home as light inspiration, not a taxonomy to copy. The revision uses its gateway restraint: short orientation and concrete starting links, with detailed background elsewhere.

The sidebar now has Docs home plus five sections: Get started, Functions, Serving, Eventing, and Install & operate. Top entries decreased 11 → 6; intermediate groups 80 → 31; maximum displayed page depth 6 → 3; duplicate destinations 1 → 0. Repeated Diátaxis-mode wrappers and the three competing global sidebar indexes were removed; CLI tools and samples moved under support. Existing guides remain browsable; this does not claim an exhaustive catalog was reduced to a handful of pages.

Docs home is a concise gateway of about 210 words and three headings. The long technical overview is preserved at `explanation/overview.md`; the existing task/explanation/reference indexes remain linked from home and searchable, not extra sidebar trees. All 27 prior home anchors remain as compact gateway aliases with visible overview handoffs. Only four narrow `not_in_nav` patterns were added, rather than suppressing omitted-navigation validation broadly.

Architecture and Editorial reviewed only this navigation/home revision. Strict build and rendered preservation checks passed: 469 → 470 pages (one moved-overview destination added), no missing previous page URLs, no lost content anchors, and no broken internal links. Inherited SVG duplicate IDs remain unchanged. The overview's body was preserved with heading-level/relative-link repairs; this documentation-only revision did not rerun runtime tests.

## Commits

Current-version corrections follow historical prototype checkpoint `f09d6954`:

| Commit | Scope |
| --- | --- |
| `e6434f58` | Functions v1.24 source contracts and explicit Git deployment |
| `5c92a176` | Serving v1.24 defaults, validation, runtime/configuration contracts |
| `0dc4513c` | Eventing v1.24 retries, security, and acknowledgment |
| `bff675e8` | Actual Operator v1.24 bundles/API/transforms and server minimum |
| `006bcc4d` | Current selected learning paths and binaries |
| `e94add68` | v1.24 preview context and revalidation review policy |

The final ledger/plan/history commit follows these changes. Nothing was pushed. Reverting a domain may also require adjusting inbound links and related guidance.

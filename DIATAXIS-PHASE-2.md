# Diátaxis experiment: second pass

Baseline checkpoint: `a5a54001` on `docs/diataxis-experiment`.
Worktree: `/Users/dave/work/knative/docs-diataxis`.

The user approved an independent Functions and Editorial pass, reader-journey review, consultation/revision, and subsequent feasibility/verification of selected instructions. Preserve the accepted first checkpoint. Current exclusive ownership and coordination rules are in `DIATAXIS-PLAN.md`.

## Bounded work, not a restart

- Functions (`dx-functions`): independently examine all Functions pages and function-specific snippets, then implement the highest-impact improvements in its owned files. Review create → build → local run → publish → deploy → invoke → subscribe and language/template claims. Consult Learning on tutorials and Serving on deployment/CLI handoffs; do not edit their files.
- Editorial (`dx-editorial`): evaluate reader contracts, titles, metadata, template selection, and contributor workflow consistency. Implement bounded improvements under `contribute-to-docs/**`; cross-component findings must go to page owners rather than global edits.
- Architecture (`dx-architecture`): independently evaluate the rendered navigation for the six reader goals below; review both authors' checkpoints, integrate approved new destinations, and verify revisions. Preserve component context and avoid imposing empty taxonomy.
- Learning/Serving/Eventing/Operations: perform a read-only reader-journey review from the preview/documentation home. Return actual routes, obstacles, evidence, and bounded recommendations. Do not edit during this initial review; coordinator will relay changes after authors/reviewer consult.
- Coordinator: preserve baseline preview and links/anchors, relay findings/questions, validate integrated builds and reader journeys, evaluate safe runtime-test feasibility, and commit final work by area. Coordination artifacts and runtime testing remain coordinator-owned.

## Reader goals

1. I'm new: where do I start?
2. I have a container: how do I deploy it?
3. I want to write a function.
4. My events aren't arriving.
5. I need to install and operate Knative.
6. What does this setting mean, and what's its default?

An agent's simulated traversal is not an observed-user usability study. Record exactly what was followed and where the page's promise fails; do not claim a browser or cluster test that was not performed.

## Review loop and checkpoints

1. Two authoring teams stop at a coherent, bounded first checkpoint. Return changed paths, navigation manifest, checks, technical uncertainties, and questions for peers. Other teams return read-only journey findings.
2. Architecture and relevant peers review the changes. Coordinator relays prioritized findings. Authors respond with agreement/disagreement/evidence, revise, and stop for recheck.
3. Recheck the concrete fixes and resolve substantive disagreements. Avoid repeatedly expanding into unrelated inherited technical defects; record out-of-scope issues explicitly.
4. Run strict builds, old/new URL and anchor checks, and feasible selected runtime tests. Record environmental blockers and test limits rather than inventing success. Commit separately from the baseline.

## Runtime guardrails

No agent other than the coordinator may create clusters, mutate Kubernetes resources, publish images, or use existing cluster credentials for tests. Inspect tooling/runtime availability first. Use a newly created, distinctly named disposable environment with explicit context targeting, never the user's default or pre-existing cluster. Do not delete an existing environment or publish to a user's external registry without an agreed test destination. Feasibility checks do not imply runtime validation.

## Status

**Historical v1.23 checkpoint only — v1.24 revalidation required.** Architecture and Editorial accepted the bounded changes against the v1.23 evidence recorded below. The user corrected the current target to Knative v1.24; that acceptance does not establish current-version correctness. Source assumptions, references, template contracts, CLI behavior, and runtime checks must be reverified against `knative-v1.24.0`. See [the v1.24 revalidation ledger](DIATAXIS-V124-REVALIDATION.md). All seven specialist teams participated in the preceding pass; its results are preserved as historical evidence, not an exhaustive audit or production certification.

The first checkpoint remains preserved at `a5a54001`. Changes are committed separately by domain below. No changes were pushed.

## What changed

### Functions: an independent local-first developer journey

- Reviewed all Functions pages and function-specific snippets independently.
- Clear create/edit → local pack run → local invocation → optional build/publish → deployment → remote invocation → optional subscription boundaries.
- Builder prerequisites distinguish daemon-based pack/s2i, experimental host OCI building, and host process running.
- Publishing is separate from deployment; an already-published-image path does not require local build tools or push access.
- Explicit effective-kubeconfig/current-context guards and namespaces before cluster-facing commands. `--remote=false` and `--target=remote` are not cluster selectors.
- Raw Kubernetes deployment is separate from Knative resource/verification scope.
- Subscription configuration is local metadata until deployment; existing generated-name collisions require current Service owner UID, destination, Broker, and filter checks.
- Fresh event correlation and successful acknowledgment are separate requirements. Empty successful responses or valid reply CloudEvents are required by the validated event response path; a greeting body is not automatically a compliant acknowledgment.
- Language/template discovery and source-version evidence replace unqualified assumptions. Knative Functions release `knative-v1.23.0` is distinguished from its CLI's reported `0.50.0` version.

### Editorial: contracts, publication, and rendering

- Contributor guidance reflects current `.nav.yml` ownership, stable URLs/fragments, metadata exceptions, and complete alternative procedures.
- GitHub contributor rendering is distinguished from MkDocs website rendering.
- Template examples and copied tabs were corrected without weakening maintained-sample testing requirements.
- Root contributor entry points name Tutorial, How-to, Reference, and Explanation, with Troubleshooting as a how-to context and Blog separately.
- Preview guidance explains requested artifact release context, fallback behavior, separate CLI-reference context, network/API requirements, and process restart.

### Reader-journey improvements across the other owners

- **Architecture:** explicit existing-container entry points; independent local Functions entry; local-first ordering; optional subscription; earlier troubleshooting/security shortcuts; neutral mapping/reference labels. Root language/framework lookup routes to Functions rather than maintaining a duplicate catalog.
- **Serving:** existing HTTP-container prerequisites, port/pull access, explicit context/namespace, Ready/URL/request verification, and failure handoffs. Deployment conversion is an illustrative mapping reference, not an automatic migration promise. Operator examples and mandatory cert-manager/TLS/metrics handoffs respect configuration authority.
- **Eventing:** existing-log retrieval is distinct from installing a collector. Filtering support provenance and effective-default lookup limits are explicit. Metrics/security configuration respects Operator/GitOps authority. The acknowledgment-failure diagnostic explains receipt with an invalid response.
- **Operations:** upgrade/rollback preserves authoritative configuration, checks desired versus installed versions, and does not promise unsupported rollback. Domain/full-name precedence guards remain; a generic managed-ConfigMap workflow prevents component readers from following unrelated domain checks.
- **Learning:** one Go HTTP/pack route, a real one-line handler edit and recognizable response, local-only completion, publication prerequisites deferred, context approval before mutations, and explicit Knative deployer selection.
- **Coordinator:** monitoring setup targets the chosen context in Helm and kubectl. A local-only preview notice distinguishes development/nightly artifacts from requested release lookup and from CLI-reference selection.

## Consultation and independent rechecks

This was not a collection of unreviewed independent drafts:

1. Functions and Editorial authored independent checkpoints; the other teams traversed the six goals using rendered HTML and source.
2. Architecture, Editorial, and peers returned owner-specific findings. Owners answered and revised rather than editing one another's files.
3. Operations independently checked Editorial testing policy and the required security/monitoring handoffs. Eventing checked Functions' Broker, filter, collision, and acknowledgment contracts. Functions and Learning consulted on the selected template, builder, naming, and teacher route.
4. Review identified two particularly important boundaries: explicit `kubectl --context` checks do not select a later `func` command's context, and successful event receipt does not necessarily mean successful acknowledgment.
5. Architecture and Editorial accepted final narrow rechecks, including the remembered-deployer override and version-label clarification.

Simulated HTTP link traversal is not an observed-user usability study. Static/source checks by the teams are not runtime execution.

## Build, rendering, and preservation checks

- Final strict local build passed: `uv run --frozen mkdocs build --strict -f mkdocs.local.yml`.
- Accepted rendered baseline **474 docs HTML pages → 474 pages**: **zero missing old URLs, zero lost old IDs/named anchors, zero broken internal links**.
- No new duplicate-ID issue; one inherited inline-SVG duplicate-ID set remains unchanged.
- Agent checks covered metadata, include directives, relevant YAML/Bash syntax, source examples, local links, legacy anchors, and isolated guard failure cases.
- The actual documented Functions guard was also exercised against the private test kubeconfig: intended context allowed, mismatched context blocked; no cluster mutation in those guard checks.
- A release-scoped build passed with `KNATIVE_VERSION=1.23.0 SAMPLES_BRANCH=knative-v1.23.0`. Generated Serving artifacts and tagged CLI-reference links were inspected; an unmatched CouchDB integration fell back to latest, as the notice/guidance warns. This is a single-checkout build, not production multi-release assembly.
- The live default preview notice was checked on Docs pages and excluded from Community/Blog/About. Default nightly/main behavior and requested-release/non-production conditions were checked separately.
- Contributor Markdown/tab rendering was approximated locally; hosted GitHub rendering and visual browser usability were not tested.

Coordinator build/link evidence:

- `/tmp/knative-diataxis-phase2-final-build.log`
- `/tmp/knative-diataxis-phase2-final-links.json`
- `/tmp/knative-diataxis-phase2-release-build.log`
- `/tmp/knative-diataxis-phase2-release-site/`

## Actual runtime validation

Only the coordinator executed runtime tests, using a distinctly named disposable cluster and a private kubeconfig. Existing clusters and installed tools were not used as mutation targets.

### Environment and provenance

- Host: macOS ARM64; Docker Desktop server `29.4.3`.
- Kind `0.31.0`; disposable Kubernetes `v1.34.0`.
- Temporary `kn` and Quickstart tools from `knative-v1.23.0`, both reporting `v1.23.0`.
- Temporary Functions binary from `knative-v1.23.0`, reporting `v0.50.0`.
- Installed Go toolchain reported `go1.27.3`; generated Go HTTP project declared Go `1.21`.
- Serving, Kourier, and Eventing installed by the standard Quickstart were `v1.23.0`.
- Private runtime directory: `/tmp/knative-diataxis-runtime.cYvIjC`.
- Test cluster: `knative-diataxis-phase2`; context: `kind-knative-diataxis-phase2`.
- Image publication was restricted to the experiment's local registry, never an external/user registry account. Its network/mirror and tag-resolution setup was test-specific, not a claim that arbitrary registries work automatically.

Computed SHA-256 for downloaded binaries (not independent signature/attestation verification):

| Binary | SHA-256 |
| --- | --- |
| `kn` | `d24679ebbd9d8ac472d3b18922df192573a72e06aac96784ae5b661478f24789` |
| `func` | `51e942766de62e26de1ae0660b0aa485ea41a5c475097672dbb5134d5b6fb345` |
| `kn-quickstart` | `157025b4bd90b4cdc40c1add94eaf4257de4c74ca169519747b4e0564e44d26e` |

### Passed selected paths

| Path | Evidence actually checked |
| --- | --- |
| Standard Quickstart installation | Fresh named cluster; Serving/Kourier/Eventing installed; successful completion. |
| Hello World | Create, Ready, URL, and exact `Hello World!` response. |
| Autoscaling | Observed zero Pods after idle; a new request woke the Service and returned the expected response. |
| Revision/traffic update | New greeting; effective status traffic 50/50; both responses observed, not strict alternation assumed. |
| Eventing Player route | Fresh matching ID and payload in both SENT and RECEIVED records through Player → Broker → Trigger → Player. CLI source endpoint tested; browser form interaction was not. |
| Local Functions | Go HTTP project created; one-line greeting edit; generated `go test`; host-process and pack-container local run/invocation returned the edited response. |
| Publish without deployment | Pack build and push to the owned local registry; image/tag/digest lookup. |
| Already-published-image deployment | No-build/no-push Knative deployment, Ready, and explicit remote invocation after registry reachability was established. |
| Naming → publication transition | Built with naming-only `example.com/local`; explicit local publication prefix caused the CLI to rebuild/push the changed image name, deploy, and return the expected remote result. |
| Optional subscription | Local metadata → generated Trigger with current Service owner UID, subscriber, Broker, both filters, and Ready. After correcting the fixture's acknowledgment contract, a fresh ID reached the instrumented function and the producer completed without the prior invalid-reply error in the observed window. |
| Existing port-80 container | `nginx:1.28-alpine` through both CLI and YAML; Ready and `Welcome to nginx!` response. This was an unhardened disposable Quickstart, not a production security-policy test. |

### Failures and recovery are part of the record

- The **registry-enabled Quickstart extension** initially failed during the config-deployment patch with a webhook connection-refused startup race. A retry's “installation skipped”/exit-zero output was not counted as installation success. The owned partial cluster was recreated and the standard non-registry Quickstart succeeded. The registry-enabled extension is not signed off as reliable.
- Initial custom-registry pull failed because the registry container was not connected to Kind's network. The test environment was corrected, node pull verified, and deployment rerun. Namespace metadata had not been saved after the failed CLI deployment; a successful deployment retry restored remote invocation discovery. These are not evidence that every registry failure needs a pull Secret.
- The first instrumented HTTP greeting fixture received the event repeatedly but returned a non-empty non-CloudEvent body. Pinned MTChannelBasedBroker logs reported the invalid response; healthy acknowledgment was not claimed. The fixture was changed to return an empty 204 for events, published under a new tag, and a fresh correlated test succeeded. The negative case led to the documented acknowledgment prerequisite/diagnostic, not a universal exactly-once claim.

Key runtime logs/records in the private directory: `quickstart.log`, `quickstart-stock.log`, `quickstart-journey.log`, `player-messages.json`, `function-pack-invoke.log`, `function-build-publish.log`, `function-full-journey.log`, `function-subscription-filter.log`, `function-ack-receipt.log`, `function-ack-filter.log`, `port80-services.json`, and `final-runtime-resources.json`.

### Cleanup and limits

The coordinator verified the registry/node containers were created after this experiment's runtime directory, then deleted **only** the disposable cluster and local registry. The original `serving-headless`, `serving-headless-ambient`, and `serving-mesh` clusters remained, the current context remained `kind-serving-headless`, and the original five running Docker containers remained. No blanket Docker image/cache cleanup was performed; temporary binaries and evidence remain available.

Not runtime-validated: other language templates/builders, built-in CloudEvents templates, host OCI building, external/private registries, `kn func` alias execution, Tekton remote builds, raw deployment, Operator install/upgrade/rollback, TLS issuance/enforcement, monitoring receipt, Bookstore core/DB, or Slack/Camel K. The subscription test used an explicitly instrumented HTTP handler adapted to the validated response contract, not every built-in event handler. Visual browser and observed-user studies, hosted contributor rendering, comprehensive external-link/support-matrix validation, and production multi-release assembly remain outstanding.

## Checkpoint commits

Content and final-record commits are listed here after integration.

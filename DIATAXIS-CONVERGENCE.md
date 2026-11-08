# Diátaxis experiment: review and convergence log

## Workspace topology

All implementation is isolated in `/Users/dave/work/knative/docs-diataxis`, branch `docs/diataxis-experiment`, based on `c250e7f7` from `typography-refresh`. The original checkout's existing untracked review files are not changed.

Five new Herdr workspaces share the experimental worktree, with exclusive file ownership documented in `DIATAXIS-PLAN.md`:

- `w25` / `dx-architecture`: global navigation, reader-goal indexes, independent architecture review. Its second tab hosts the local preview.
- `w26` / `dx-learning`: Quickstart, Functions follow-on, Bookstore learning routes.
- `w27` / `dx-serving`: Serving, Functions, CLI entry paths.
- `w28` / `dx-eventing`: Eventing task/reference separation and troubleshooting.
- `w29` / `dx-operations`: install/operator/admin/security entry points and contributor templates.
- Existing `w23`: coordinator, integration checks, shared snippet correction, commits.

Five specialist spaces balance parallelism with ownership boundaries. Independent review has a dedicated space; the coordinator does not merely concatenate drafts. Herdr also created parent repository workspace `w24` for its linked-worktree grouping; it is not a sixth specialist team. No unrelated pre-existing Herdr spaces were controlled.

## Implemented direction

- Reader-goal invitations: Learn Knative / Accomplish a task / Understand Knative / Look up details, retaining component and operator collections.
- One main Quickstart Serving → Eventing route, with Functions as a follow-on. YAML equivalents remain supporting material rather than competing instructions at every step.
- Bookstore after basics, with a clear core outcome and separate optional extensions/setup alternatives/acknowledgments.
- Concurrency explanation, configuration task, and settings reference linked deliberately.
- Trigger routing and delivery tasks separated from filter/delivery reference, with symptom-led diagnostics for existing workloads.
- Installation routing separated from method comparison, requirements, extensions catalog, and Operator field/version maps.
- Four author/reviewer contracts and new tutorial/reference templates; landing pages are not forced into lesson metadata.
- Canonical technical material and stable entry URLs retained rather than duplicated into independent authoritative copies.

## Review exchanges

### Architecture → Serving → Architecture

Reviewer found that an absent concurrency target does not always resolve to the cluster default: a nonzero hard concurrency limit supplies the initial target. Author validated pinned Serving v1.23 source and revised reference/explanation into three explicit selection cases. Reviewer independently verified those cases and utilization handling.

Reviewer also found that changing a template while retaining an explicit Revision name falls outside the task's safe path. Author constrained the how-to to generated names and added a preflight check/stop instruction. Reviewer verified against `VerifyNameChange`.

A further review identified legacy Operator API versions in retained concurrency fragments; the author changed all three to the documented `v1beta1` API after checking its CRD, and Operations independently verified the correction. Conditional Git/local-upload build routes and core-CLI versus plugin wording were also corrected and cross-checked.

### Architecture → Eventing → Architecture

Reviewer found invalid inherited filter examples: two dialects in one expression, a mapping instead of a filter list, and subscriber nested inside a filter. Author validated v1.23 types/validation and corrected the examples while preserving their purpose and old anchors.

Author identified an additional nuance during consultation: legacy injection-annotation validation and the Sugar controller's label-based reconciliation are not the same behavior. Reference now distinguishes them instead of promising an annotation alone controls Broker creation.

Delivery consultation separated the API's nonnegative/minimum retry contract from a pinned shared HTTP sender's retry loop and backoff formulas. Contradictory prose and an unconditional exact-attempt promise were replaced with scoped facts. Runtime timing across implementations remains untested.

### Serving → Operations → Serving/Architecture

Cross-review identified inherited Operator problems requiring owner consultation:

- Broker-default class and `spec.config` interaction.
- Bare ellipses inside YAML mappings.
- Shell expansion of unquoted image-template placeholders.
- Full ConfigMap names versus shortened names and precedence.
- An outdated concrete component-version example.
- Linking Operator users to a direct ConfigMap-edit workflow.

These findings are distinct from architectural changes. The author made source-backed bounded corrections, and Serving independently verified all six issues as resolved. A final architecture check found that the newly added cluster-default task could write a shadow shortened ConfigMap entry. The author added an explicit preflight and recovery guard that stops on any full-name entry; architecture verified it against the presence-based precedence rule.

### Eventing → Learning → Eventing/Architecture

Cross-review identified:

- A CLI alternative sending to the Player receive endpoint instead of its source-send endpoint.
- Lookup links pointing to tasks rather than the new reference pages.
- An overconfident database-failure diagnosis.
- Unresolved namespace/scope prerequisites in the optional Camel K extension.
- A minimum-scale setting described as an unconditional availability guarantee.

Reviewer also checked rendered navigation, identifying an optional Slack action styled as the primary next step and competing authored/automatic Next destinations at the end of the Functions exercise. Both endings now suppress automatic Next links; Slack has a secondary, explicitly optional recipe link.

Learning corrected the source-send endpoint using image-artifact and source evidence, added evidence-led database diagnosis, and retained Slack as a prominently labeled pending-runtime-validation reference instead of inventing a verified namespace/ownership route. Eventing independently accepted these responses within the documentation-contract scope.

Learning's cross-review of Eventing caught a transient broad-routing step before filtered creation, unclear resource-name collisions, contradictory failure-field examples/guarantees, and recovery permissions inconsistent with read-only responders. Eventing separated requested routing goals before first apply, added ownership/collision checks, qualified local field semantics, and clarified owner handoffs. Learning independently verified those fixes, the support-table provenance disclosure, and the filter-migration/client-repeatability caveats.

### Coordinator and cross-review of architecture

Coordinator reviewed representative diffs, independently ran strict builds, compared rendered old/new URLs and content anchors, and checked the live HTTP preview. Serving was assigned independent review of the global navigation/home/index changes, so architecture's own implementation is not accepted solely through self-review.

The shared Functions snippet's claim that local build/run automatically publishes images was checked against CLI source and corrected. Containerized local builds/runs do not publish by default; deployment normally builds as necessary and publishes. Usage comments now reflect the relocated explanation.

Installer snippets now use writable user-owned PATH directories for `kn`, standalone `func`, `kn-func`, and Quickstart. The Functions container example preserves created source with a host bind mount and no longer links to the wrong CLI image. The Quickstart warning no longer equates installation with production readiness. These changes were cross-reviewed; coordinator syntax checks covered 36 shared-snippet Bash fences.

Serving reviewed architecture's own pages and found an obsolete `func push` diagram label, unconditional scale-to-zero wording, CLI-reference fallback ambiguity, and an imprecise lesson label. Architecture corrected them, and Serving verified the fixes. The technical overview is retained, but is deliberately no longer byte-identical after these reviewed corrections; its old anchors remain.

## Validation

- Baseline strict local build: passed before integration.
- Isolated worktree dependencies: installed with `uv sync --frozen`.
- Final integrated strict build: passed after all source revisions, with no documentation warnings. Command: `uv run --frozen mkdocs build --strict -f mkdocs.local.yml --site-dir /tmp/knative-diataxis-final-site`.
- Agent-scoped checks: metadata, local destinations/fragments, legacy anchors, Bash syntax, YAML fragments and patch JSON as applicable.
- Final independent rendered comparison: **455 baseline `/docs/` HTML pages → 474 pages**, including redirects; **zero missing baseline URLs, zero lost old content IDs/named anchors, zero broken internal links, zero new duplicate-ID issues**. One inherited inline-SVG duplicate-ID set remains unchanged. Content-fragment preservation is checked separately from generated navigation IDs. Versioned Markdown source grew from 229 to 248 pages.
- An initial rendered-crawl warning for an Eventing Broker configuration fragment was a checker false positive: the destination uses a valid legacy `<a name="configuration-configmap">` anchor. The checker was corrected to recognize both IDs and named anchors; no source change was needed.
- Live preview: `http://127.0.0.1:8014/docs/`, Herdr `w25:t2`, bound to localhost.

## Completion status

**Editorial/structural experimental checkpoint accepted.** All five agents completed their first passes, consultation/revision rounds, and bounded cross-review rechecks. The independent architecture reviewer accepted final sign-off after verifying the last Operator precedence guard and current Eventing contracts. No actionable blocker remains within the reviewed documentation-contract scope.

All agents are left idle at their checkpoints for follow-up work. The preview remains running. This is deliberately not a claim that every Knative page is technically correct or that tutorials/integrations are runtime-tested.

### Checkpoint commits

| Commit | Scope |
| --- | --- |
| `28ea4e87` | Initial assessment and collaboration plan |
| `77f78095` | Serving, Functions, and CLI workflows |
| `0359ca49` | Eventing tasks, reference, and diagnostics |
| `bd34d325` | Quickstart and Bookstore learning routes |
| `63190542` | Installation/operations and contributor contracts |
| `b9fc85ff` | Global navigation, reader-goal indexes, shared snippets |

The final plan/convergence-log commit follows these content checkpoints. No changes were pushed. Domain commits isolate ownership for inspection and reversal, but their cross-links depend on the integration commit: reverting a domain may also require adjusting its navigation and inbound links.

To inspect the complete experiment: `git diff c250e7f7..docs/diataxis-experiment` from this worktree. The original branch remains untouched.

### Preview and evidence

The preview runs in Herdr `w25:t2`. To restart it if needed:

```bash
cd /Users/dave/work/knative/docs-diataxis
uv run --frozen mkdocs serve -f mkdocs.local.yml --dev-addr 127.0.0.1:8014
```

Final coordinator build log: `/tmp/knative-diataxis-final-build.log`.
Rendered URL/anchor/link comparison: `/tmp/knative-diataxis-final-links.json`.
Recovered detailed peer checkpoints: `/tmp/knative-diataxis-learning-checkpoint.md` and `/tmp/knative-diataxis-eventing-final.md`. These temporary evidence files are not required to build the experiment; the durable review decisions are summarized above.

## Limits of this experiment

No tutorial or operator procedure has been executed against a Kubernetes cluster. Source inspection, Bash/YAML syntax checks, and successful rendering are not cluster execution or full admission validation. No production multi-release assembly, comprehensive external-link/capability-matrix validation, or observed-user usability test has been performed. Archived release snapshots remain untouched. Optional external integrations may need release/image-specific testing before being presented as reliable lessons.

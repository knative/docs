# Diátaxis experimental collaboration

Worktree: `/Users/dave/work/knative/docs-diataxis`
Branch: `docs/diataxis-experiment`
Baseline: `c250e7f7` from `typography-refresh`.

**Current verification target: Knative v1.24 (`knative-v1.24.0`).** Earlier v1.23 source checks/runtime results are historical, not current-version sign-off. Reverify version-dependent behavior and references using the newer tag; do not mechanically rename citations or infer unchanged behavior. Track evidence and consultation in `DIATAXIS-V124-REVALIDATION.md`.

The user authorizes substantial experimental changes in this isolated worktree. The original checkout must remain untouched. Read `DIATAXIS-REVIEW.md` for the initial assessment and consult https://diataxis.fr/ as necessary. This is implementation, not merely another report.

## Team and exclusive edit ownership

| Agent | Herdr workspace | Owns |
| --- | --- | --- |
| `dx-architecture` | w25 | `docs/versioned/.nav.yml`; `docs/versioned/README.md`; new global landing pages under `docs/versioned/learn/`, `how-to/`, `explanation/`, `reference/README.md`; architecture review. Do not edit existing security files. |
| `dx-learning` | w26 | `docs/versioned/getting-started/**`, `docs/versioned/bookstore/**` |
| `dx-serving` | w27 | `docs/versioned/serving/**`, `docs/versioned/client/**` (core `kn` and generic CLI guidance; coordinate Functions references with `dx-functions`) |
| `dx-functions` | w2A | `docs/versioned/functions/**`, Functions-specific shared snippets `docs/snippets/*func*.md`; review Functions tutorials with `dx-learning`, but do not edit Learning-owned paths |
| `dx-eventing` | w28 | `docs/versioned/eventing/**` |
| `dx-operations` | w29 | `docs/versioned/install/**`, `docs/versioned/admin/**`, `docs/versioned/reference/security/**` |
| `dx-editorial` | w2B | `contribute-to-docs/**`: authoring guidance, templates, style, metadata policy, and editorial/reviewer checklists; cross-component editorial review is read-only, with changes requested from each page's owner |
| Coordinator | w23 | Integration, coordination artifacts, remaining shared snippets, `mkdocs*`, build/test configuration, redirects, presentation overrides if necessary; commits |

All agents share the same working directory. Do not git commit, stage, reset, stash, switch branches, or revert another agent's changes. Use narrow edits within ownership. Request cross-owner changes in your reply rather than editing their files. Do not add per-subtree `.nav.yml` files: architecture owns all navigation. New pages must be reported with path, title, and intended mode for navigation integration.

## Editorial contract

- Tutorials guide a learner along one reliable path with visible results, not a choices catalog.
- How-tos accomplish a bounded user goal with prerequisites and verification.
- Reference states exact facts, settings, constraints, and short examples.
- Explanation connects concepts, behavior, and trade-offs.
- Landing pages route readers; they need not pretend to be tutorials or force a four-way label.
- Retain existing URLs/anchors where practical; prefer meaningful legacy landing pages to broken links after splitting.
- Preserve technical meaning; do not invent or silently change capability/default claims. Flag uncertainties for technical validation.
- Retain useful examples, warnings, licensing and acknowledgments. Move interruptions rather than deleting obligations.
- Avoid empty taxonomy buckets and duplicated authoritative technical prose.
- Keep release-specific macros/snippets and generated reference behavior intact.

## Architecture to explore

Keep component context and make modes visible. Documentation home should route readers via Learn / Accomplish a task / Understand / Look up details, with component and operator shortcuts. Within Serving, Functions, Eventing, distinguish How-to guides, Explanation, Reference, and links to tutorials. Operators need an accessible install/configure/secure/observe/troubleshoot path.

## Work / review / consultation / revision loop

1. Each implementation team makes a coherent first pass in its owned area and returns a concise change summary, new-page navigation manifest, checks run, questions, and requested cross-owner links. Stop at a reviewable checkpoint rather than endlessly expanding scope.
2. Architecture reviews each implementation team's checkpoint and implements coherent navigation. It returns prioritized findings with concrete paths/sections and questions; implementation teams also cross-review a neighboring area without editing it.
3. Coordinator relays findings and questions. Authors respond, consult the reviewer, revise, and explain disagreements. Reviewer verifies the fixes and responds. Repeat on unresolved substantive issues.
4. Coordinator validates the integrated preview/build, reviews the resulting diff and reader journeys, and records accepted changes and remaining limitations. Do not claim a cluster-tested tutorial without actually executing it.

## First-pass targets

- Learning: clear Quickstart learning routes and next-step handoffs; streamline Bookstore introduction/setup, position after basics, optional extension routes, reliable explicit navigation.
- Serving: separate concurrency explanation/how-to/reference, improve autoscaling entry paths, and clarify core `kn` workflows.
- Functions: independently own the function developer experience, local and remote build/run/deploy workflows, language/template contracts, `func`/`kn func` guidance, and Functions-specific snippets. Coordinate tutorial changes with Learning and review deployment handoffs with Serving; link maintained upstream command reference rather than duplicating it.
- Eventing: separate Trigger filtering and delivery reference from task guides; improve concept/task handoffs and symptom-led troubleshooting as feasible.
- Operations: installation routing versus comparison/reference, bounded Operator entry points, administration, security, configuration authority, and operational verification.
- Editorial: independently maintain Diátaxis authoring guidance, templates, style, metadata policy, and author/reviewer contracts. Review consistency across component pages without taking their edit ownership. Coordinate information architecture with Architecture and technical claims with component owners.
- Architecture: review current structure, devise readable populated mode/component navigation using existing files, then integrate peers' manifests. Conduct independent convergence review.

## Space count rationale

The initial pass used five specialist spaces, combining Serving/Functions and Operations/Editorial for workload balance. The user subsequently requested both pairs be separated. There are now **seven specialist spaces**: Learning, Serving, Functions, Eventing, Operations, Editorial, and independent Architecture/Review; the coordinator remains in the existing eighth space. Functions is not subordinate to Serving, and Editorial is not subordinate to Operations. Keep the review/consultation loop and explicit file boundaries; do not recombine these teams.

## Results

See [the first-pass convergence log](DIATAXIS-CONVERGENCE.md) and [the second-pass results](DIATAXIS-PHASE-2.md) for review exchanges, validation, accepted experimental limitations, and checkpoint commits. The local preview runs in architecture workspace `w25`, tab `w25:t2`, at `http://127.0.0.1:8014/docs/`.

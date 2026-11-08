# Knative documentation review through Diátaxis

## Scope and method

This is an initial information-architecture and editorial review of the local `knative/docs` checkout at commit `c250e7f7`, not an exhaustive technical validation of every page or the live website.

I inventoried all 229 Markdown files under `docs/versioned`, reviewed the complete `docs/versioned/.nav.yml`, and read representative content across onboarding, Serving, Eventing, Functions, installation, troubleshooting, samples, and contributor guidance. Some long pages were sampled rather than read in full. I also inspected relevant MkDocs configuration, templates, and build behavior. I did not run tutorials against a cluster, validate external integration claims, inspect generated API output, or conduct usability tests.

The production build assembles multiple release snapshots and replaces API placeholders (`hack/build.sh`). Findings about this checkout should therefore not be read as claims about every currently published release.

Framework sources:

- [Diátaxis primer](https://diataxis.fr/start-here/)
- [Tutorials](https://diataxis.fr/tutorials/)
- [How-to guides](https://diataxis.fr/how-to-guides/)
- [Reference](https://diataxis.fr/reference/)
- [Explanation](https://diataxis.fr/explanation/)
- [Workflow](https://diataxis.fr/how-to-use-diataxis/)

## Executive assessment

**Knative has substantial useful material. The principal opportunity is to clarify the promise each page makes to the reader and make those promises visible in navigation.**

The site currently combines several organizing dimensions at the same level: documentation type (Tutorials), product component (Functions, Serving, Eventing), tooling (CLI tools), audience (Administration), and artifact format (Code samples). Those dimensions are individually useful, but readers have to infer where their particular need belongs.

This is not a recommendation to replace everything with four empty directories. Diátaxis explicitly recommends small, responsive improvements rather than a top-down reconstruction. Keep good pages and stable URLs; improve a topic cluster, then let the resulting structure inform navigation.

### Existing strengths

- Quickstart contains concrete actions and visible expected output. `getting-started/first-autoscale.md` guides readers through requesting a service, watching it scale down, and seeing it return.
- Explanation already exists: `serving/architecture.md` and `serving/request-flow.md` give useful component relationships and causal accounts.
- Many procedural pages already identify prerequisites and supply commands. `functions/building-functions.md` distinguishes local and on-cluster builds.
- There are dedicated source references, metrics references, and generated API reference infrastructure.
- Sample documentation already distinguishes Knative-maintained, community-owned, and external examples.
- Nearly every versioned page already has Diátaxis-style `function` metadata.

### Metadata inventory—not a quality score

| Existing `function` value | Files |
| --- | ---: |
| `how-to` | 123 |
| `reference` | 40 |
| `tutorial` | 32 |
| `explanation` | 30 |
| Missing | 3 |
| `how to` | 1 |
| **Total** | **229** |

These are declared classifications, not independently confirmed classifications. Landing pages and the Bookstore disclaimer are included in these numbers. Generated API content is not represented faithfully by its source placeholder. There is no reason to aim for equal counts in the four categories.

The inspected overrides and hooks do not use `function` to label or organize reader-facing documentation. The metadata is a useful starting point, but it does not yet resolve the reader's discovery problem.

## Findings and concrete changes

All abbreviated content paths below are relative to `docs/versioned/`.

### 1. Navigation mixes understanding with doing and lookup

**Evidence:** The Eventing “Concepts” branch contains “Creating a Broker,” “Creating a PingSource object,” source references, and sequence exercises. Serving's “Developer Tasks” includes explanatory pages such as “About Revisions” and “About load balancing.” Configuration references are scattered outside the API-only “Reference” branches.

**Reader consequence:** Knowing the task is not enough; the reader must also know Knative's object model and guess how maintainers categorized the page.

**Recommended change:** Separate the modes within component collections:

- Tutorials: guided exercises.
- How-to guides: achievable tasks, grouped by user goals.
- Explanation: architecture, behavior, trade-offs.
- Reference: fields, annotations, settings, metrics, supported capabilities.

Keep role and component as secondary context. Do not duplicate a document just to make it reachable from another collection; use curated links to one canonical page.

### 2. Mixed-purpose pages should be separated where the reader's task changes

**Example: `serving/autoscaling/concurrency.md`**

The title promises a configuration task, but the declared function is `reference`. The body includes soft/hard limit explanation, operational advice, default values and keys, and per-revision, ConfigMap, and Operator examples.

A useful division would be:

1. **Explanation:** “How concurrency targets and hard limits affect scaling.” Discuss buffering, burst behavior, target utilization, and consequences of low hard limits.
2. **How-to:** “Set a concurrency target for a service.” Provide prerequisites, a bounded change, application commands, and verification. Link to a separate administrator task for cluster defaults if needed.
3. **Reference:** “Concurrency settings.” Preserve exact keys, scope, types, defaults, interactions, and short illustrative snippets.

Do not split every paragraph into a new page. Split when the reader changes from understanding behavior to executing a task or looking up a fact.

**Example: `eventing/triggers/README.md`**

“Using Triggers” starts with creation steps, then becomes a filter dialect catalog with support and compatibility information. Split the task (“Route matching events to a subscriber”) from “Trigger filtering reference.” Link both to an explanation of Broker/Trigger routing.

**Example: `eventing/event-delivery.md`**

“Handling Delivery Failure” primarily describes DeliverySpec fields, broker/channel support, and failure extension attributes. It is useful reference material but does not yet constitute a complete recovery-oriented task.

Preserve a delivery reference; add a focused guide to configuring retries and a dead-letter sink, with a controlled failure and confirmation of delivery to the sink. Keep the procedure appropriately scoped rather than assuming all broker implementations behave identically.

The repeated backoff descriptions are also inconsistent enough to warrant a technical check before extraction. This review does not establish which behavior is correct.

### 3. Tutorials should offer a chosen route, not an installation decision tree

**Evidence:** Quickstart pages offer `kn` and YAML alternatives. Bookstore environment setup offers a setup script, manual setup, image-building choices, local cluster options, load-balancer setup, and a link to general installation instructions. Its introduction positions it as suitable for complete beginners while the setup involves several adjacent technologies.

**Reader consequence:** Newcomers must make infrastructure choices before getting an early Knative success. The burden moves from the tutorial author to the learner.

**Recommended change:**

- Keep Quickstart as the primary first encounter.
- Choose one tested default command path in the main narrative; retain YAML equivalents as an explicitly secondary route if they are valuable.
- Give each learning path explicit starting state, expected result, and tested environment.
- Provide an outcome early, then point out what the learner should notice.
- Keep relevant short explanations; link away from long conceptual detours.
- Use explicit Previous/Next links, not only keyboard-navigation guidance.
- Ensure alternative command paths are actually complete. For example, `first-autoscale.md` presents a `kubectl` listing alternative but later uses `kn service describe` for invocation.

For Bookstore specifically:

- Position it after basic Serving/Eventing familiarity, or substantially simplify its beginner route.
- Make the core outcome “submit a review and observe its event-driven processing.”
- Treat Slack/Camel K integration and extra challenges as optional extensions.
- Move the disclaimer and acknowledgments out of the required lesson sequence while keeping them readily available. The navigation currently places Disclaimer between Overview and Environment Setup.
- Keep useful diagrams and verification; reduce decorative interruptions where they break the action/result rhythm.
- Do not market this educational example as production guidance. The tutorial landing page promises “best practices for production applications,” while the Bookstore disclaimer explicitly frames it as educational. Clarify that distinction.

### 4. Explanation needs more decision support, not simply more definitions

**Evidence:** Serving architecture and request flow provide a useful foundation. `eventing/brokers/broker-types/README.md` lists implementations, but does not substantially help choose between them. The autoscaling overview links quickly into settings and experiments.

**Recommended next explanations to validate against user demand:**

- Choosing a Broker implementation: persistence/delivery behavior, operational burden, throughput/ordering considerations, dependencies, and implementation-specific limitations.
- Broker/Trigger versus Channel/Subscription: the different abstractions and when each is useful.
- Autoscaling and cold starts: how concurrency, capacity, and request flow interact.
- Installation choices: YAML, Operator, GitOps, and the responsibility each leaves with the operator.

Some of this information already exists across pages or component repositories. Consolidate and link it before assuming it must be written from scratch. Any capability comparison needs versioned, technically reviewed facts.

### 5. Reference is broader than API documentation

**Evidence:** Serving and Eventing have explicit Reference navigation, largely for their APIs, while settings, filter dialects, support matrices, and source references are elsewhere. The CLI overview sends readers to GitHub documentation, and Functions' remote-build guide sends them to the `func` repository for deeper setup.

**Recommended change:** Provide discoverable reference indexes for:

- Serving API resources, annotations, ConfigMaps, metrics, and feature flags.
- Eventing API resources, source/sink configuration, filtering, delivery parameters, metrics, and implementation support.
- Operator custom resource fields and overrides.
- `kn` and `func` command reference, with clear version-aware destinations.

A reference page should use a consistent pattern: identifier, scope, type, default, valid values, constraints/interactions, version or feature requirements, and concise examples. Reference can contain warnings and examples; it need not become a tutorial.

The Serving API source is intentionally replaced during the build. Do not misdiagnose its placeholder as absent API documentation. Validate the rendered release-specific reference before making claims about coverage.

### 6. Troubleshooting should begin with the reader's actual symptom

**Evidence:** `serving/troubleshooting/debugging-application-issues.md` contains broadly useful checks but moves into Istio-specific routing and ingress commands under a generic application-debugging title. `eventing/troubleshooting/README.md` asks users to apply a demonstration topology before walking through its resources.

**Reader consequence:** Someone debugging an existing service or Broker/Trigger application must translate instructions from a different deployment or transport.

**Recommended change:** Create symptom-led entry points, for example:

- Service is not Ready.
- Service URL is unreachable.
- Requests time out during scale-from-zero.
- Events do not reach a subscriber.
- Events repeatedly fail delivery.

Each guide should establish the affected resource and namespace, check status and logs, branch by confirmed conditions, and give a next action or escalation step. Keep ingress-specific checks in labeled branches. Preserve the demonstration topology as a separate debugging tutorial if it remains useful.

### 7. Installation combines orientation, comparison, procedures, and catalogs

**Evidence:** `install/README.md`, labeled `reference`, includes an installation roadmap, install sequences, YAML/Operator comparison, plugin descriptions, and ecosystem recommendations. `install/operator/configuring-serving-cr.md` is a particularly large collection of distinct configuration tasks.

**Recommended change:**

- Keep a short “Install Knative” routing page: trying locally versus administering an existing cluster.
- Extract installation trade-offs into explanation where they are substantial.
- Keep install and upgrade procedures as administrator how-tos with verification.
- Maintain a factual requirements/compatibility reference.
- Break the long Operator configuration collection into bounded tasks where appropriate, backed by a custom resource reference.

Calling installation “production” should not imply that the install procedure alone establishes production readiness. Link to concrete operational tasks for security, availability, observability, and upgrades. Do not create an empty production-readiness section merely to fill a category.

### 8. Contributor guidance should reinforce the reader contract

**Evidence:** `contribute-to-docs/what-to-contribute/creating-new-docs.md` uses Concept, Reference, Example, Procedure, Setup, FAQ, and Operation guide categories. It describes advanced procedures as reference and only offers Concept, Procedure, Troubleshooting, and Blog templates. A TODO still asks for the intended documentation layout.

**Recommended change:**

- Add tutorial and reference templates.
- Align the editorial types with the existing four `function` values.
- Treat Setup and Troubleshooting as task contexts, not competing Diátaxis categories.
- Treat examples as artifacts that can support any mode, not automatically tutorials.
- Keep Blog and News outside the four technical-documentation collections.
- Distinguish navigation/landing pages from actual lessons; the tutorial catalog, next-steps page, and disclaimer are not tutorials merely because they sit in a tutorial subtree.
- Normalize `how to` in `eventing/sources/apiserversource/getting-started.md`.
- Validate metadata with exceptions for build-replaced content rather than blindly adding it to generated placeholders.

## A presentation model to test

Use a documentation home with four clear invitations, alongside component and role shortcuts:

| Invitation | Reader question | Content promise |
| --- | --- | --- |
| Learn Knative | “Can you guide me through trying this?” | Tutorials with chosen environments and observable outcomes |
| Accomplish a task | “How do I do this?” | How-to guides organized by goals |
| Understand Knative | “How does this work, and why choose it?” | Explanation and trade-offs |
| Look up details | “What is the exact field, default, or limitation?” | Reference organized by product structure |

Retain component collections rather than making users choose only between abstract documentation types. An illustrative target is:

```text
Documentation home
├── Tutorials
│   ├── Quickstart
│   └── Bookstore (after the basics)
├── Functions
│   ├── How-to guides
│   ├── Explanation
│   └── Reference
├── Serving
│   ├── How-to guides
│   ├── Explanation
│   └── Reference
├── Eventing
│   ├── How-to guides
│   ├── Explanation
│   └── Reference
├── Operate Knative
│   ├── Install and upgrade
│   ├── Configure and secure
│   ├── Observe and troubleshoot
│   ├── Architecture and operational trade-offs
│   └── Operator and cluster configuration reference
└── Samples (curated supporting artifacts)
```

This is a testable sketch, not a mandatory full-site rewrite. Publish only collections that contain useful material. Cross-component how-tos should live where the user's goal is best served, not wherever the producing team happens to sit.

Topic landing pages should have two to four concrete entry points rather than lists of everything. For example, an autoscaling landing could link to:

- Try scale-to-zero — tutorial.
- Keep a minimum number of replicas — how-to.
- Understand concurrency and cold starts — explanation.
- Look up autoscaling annotations and defaults — reference.

Use specific links such as “Concurrency settings reference” rather than generic “Learn more.” At the end of Quickstart, link directly to achievable tasks and related explanations, not just to broad component guides.

## A small, publishable first experiment

**Start with Serving autoscaling.** It already has enough material in all four modes to test the approach without a major content-creation project.

1. Separate concurrency explanation from its factual reference; add or refine one verified configuration how-to.
2. Add the four-way autoscaling landing described above, linking existing tutorial and scale-bound content.
3. Improve the Quickstart handoff to that landing.
4. Test whether readers can find the right page for: understanding a hard limit, configuring a target, checking its default, and trying scale-to-zero.
5. Publish the improved cluster. Apply the pattern next to Eventing filtering/delivery only if it helps.

Subsequent small improvements can include moving task pages out of Eventing Concepts, making a single beginner Bookstore route, and updating contributor templates. They need not wait for a complete migration plan.

## Guardrails and evaluation

- Preserve existing URLs wherever possible; navigation changes do not require source-file moves.
- When a split requires a new URL, retain a useful old entry point or configure redirects. Preserve widely linked anchors where practical.
- Maintain one authoritative source for technical facts; reuse snippets selectively, not entire mixed-purpose articles.
- Respect release-specific links and build-generated references. Do not rewrite archived snapshots as though they were current documentation.
- Display concise page context where helpful: mode, audience, required components/permissions, and feature/version conditions. Avoid badges that add noise without helping decisions.
- For samples, expose prerequisites, outcome, ownership, and verification status. For blogs, promote valuable current material into maintained docs rather than treating historical articles as canonical procedures.

Evaluate the experiment with observed users and executable checks:

- Can readers choose the right destination for a real goal without understanding repository structure?
- Can a newcomer complete the selected tutorial from its stated starting state?
- Does each how-to explain how to confirm success?
- Can a reader retrieve an exact default or supported capability without reading an exercise?
- Are troubleshooting checks appropriate to the user's actual ingress or broker?
- Do links and anchors survive the restructure, and do rendered version-specific references point to the intended release?

**Bottom line:** Organize around the question the reader is asking now, while retaining component context. Improve the page contracts first, connect related modes deliberately, and let navigation evolve from demonstrably better content.

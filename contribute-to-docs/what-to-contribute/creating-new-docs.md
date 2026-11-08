# Creating new documentation

Start with the reader's question, not a list of everything known about a feature. Knative technical documentation uses the four [Diátaxis](https://diataxis.fr/) modes: tutorial, how-to, reference, and explanation. Landing pages route readers and are not lessons merely because they sit in a tutorial collection.

## Contribution workflow

1. Identify the audience, their starting knowledge, and the result they need.
1. Choose a [content type and page contract](#content-types). Improve an existing page when it already answers the same question; do not create a duplicate authoritative source.
1. Use the matching [template](../templates/README.md).
1. [Choose a title and filename](#choosing-titles-and-filenames) and a reader-facing location. Check related pages and plan links between the task, its explanation, and its reference.
1. Write the content using the [style guide](../style-guide/README.md). Ask the [DUX working group](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md#documentation--user-experience) if the scope or placement is unclear.
1. Check the draft against the [author and reviewer checklists](#author-and-reviewer-checklists). Record technical validation and unresolved questions.
1. [Preview the documentation in its publishing context](../getting-started/previewing-docs-locally.md), check the reader's route into and out of the page, and open a PR in [knative/docs](https://github.com/knative/docs). Contributor guidance is read on GitHub, not in the MkDocs preview. See the [GitHub workflow](../getting-started/github-workflow.md).

## Identify the audience and intended use

Write a one-sentence promise before drafting: “For readers who already have **starting state**, this page helps them **learn, accomplish, understand, or look up a specific thing**.”

Describe the knowledge, installed components, permissions, and version or feature requirements that matter. Do not assume that an administrator is also an application developer, or that someone looking up a field wants an exercise first.

- If readers want guided practice, choose a reliable learning route for them.
- If readers have a goal, provide the necessary actions and a way to confirm success.
- If readers need a decision, explain the alternatives and trade-offs, then link to the appropriate procedures.
- If readers need an exact setting, make its identifier, scope, default, and constraints easy to find.
- Use diagrams when relationships are easier to show than describe. Use runnable examples when actions are easier to demonstrate than explain abstractly.

Do not add every possible alternative to the main narrative. Link to supporting material when the reader's purpose changes.

## Content types

| Mode and `function` value | Reader question | Page contract | Template |
| --- | --- | --- | --- |
| Tutorial — `tutorial` | “Can you guide me through learning this?” | One chosen environment and route, explicit starting state, guided actions, observable results, and a clear finish. Teach through doing; move infrastructure choices and optional extensions out of the required path. | [Tutorial](../templates/template-tutorial.md) |
| How-to guide — `how-to` | “How do I accomplish this goal?” | A bounded goal, prerequisites, necessary steps, verification, and recovery or cleanup where relevant. Assume the reader knows what they want; link to long explanations and detailed settings. | [How-to (legacy Procedure URL)](../templates/template-procedure.md) |
| Reference — `reference` | “What is the exact field, value, or constraint?” | Consistent lookup structure following the product, exact identifiers, scope, types, defaults, valid values, interactions, and concise examples. Reference may be authored or generated; advanced procedures are still how-tos. | [Reference](../templates/template-reference.md) |
| Explanation — `explanation` | “How does this work, and why choose it?” | Concepts, relationships, behavior, rationale, and trade-offs. Build understanding rather than hiding an installation sequence in conceptual prose. | [Explanation (legacy Concept URL)](../templates/template-concept.md) |

### Page boundaries and related formats

Split a mixed page when the reader's purpose changes meaningfully, not for every paragraph or setting. Keep related reference fields together and provide goal-based links into large collections. A short example or warning can serve any mode without becoming a separate page.

- **Setup and operations** describe task contexts, usually how-tos. A guided local setup can be part of a tutorial.
- **Troubleshooting** is usually a how-to: begin with the observed symptom, establish the affected resource and environment, check evidence, then give conditional remedies and verification. Use the [troubleshooting template](../templates/template-troubleshooting.md).
- **Examples and samples** are supporting artifacts, not automatically tutorials. Follow [code sample guidance](creating-code-samples.md), including its testing requirements.
- **FAQs** can provide short answers and links; place substantial tasks, explanations, or lookup material in their appropriate pages rather than maintaining a second authoritative answer.
- **Blog and News** are publication formats outside the four technical modes. Blog accuracy is not maintained and tested after publication in the same way as technical documentation. Use [blog guidance](creating-blog-posts.md) and the [blog template](../templates/template-blog-entry.md).
- **Landing pages** make destinations discoverable. Give a few concrete entry paths and say what each offers. Do not add tutorial prerequisites or a pretend learning outcome to an index, catalog, disclaimer, or next-steps page.

### Metadata

For authored versioned technical pages, set `function` to exactly one of `tutorial`, `how-to`, `reference`, or `explanation`. Also retain the appropriate `audience` and `components` metadata used by nearby pages.

A routing-only landing page may omit `function`; an explanatory overview is not a routing-only page just because its filename is `README.md`. Do not introduce new `function` values such as `landing` or `how to`. Contributor guides, blog entries, and generated/build-replaced pages need not inherit metadata from the technical-page templates. Keep generated reference behavior intact rather than adding content to placeholders that the build replaces.

Metadata describes the page's main reader purpose, not its quality, testing status, or every kind of paragraph it contains. A reference can include a brief example, and a how-to can explain a necessary decision. Check the rendered title, opening promise, navigation label, and entry-link descriptions before changing a classification. Fix a misleading promise or a missing handoff rather than splitting useful content just to satisfy a label. Consult the navigation/build maintainer on ambiguous exceptions or inherited metadata; do not relabel generated output or whole catalogs from filenames alone.

## Choosing titles and filenames

Use sentence-style capitalization and words readers would search for. Prefer a concrete goal for a how-to, a learning outcome for a tutorial, a subject or relationship for explanation, and the object being described for reference. Titles need not begin with the mode name.

Keep existing URLs and anchors where practical. New filenames should reflect the title using lowercase words separated by hyphens. Create a folder only when grouping multiple related topics; avoid repeating the folder's name in every filename.

## Content structure

Organize content where the reader will look, retaining component context and making the page's purpose clear. Do not reorganize solely around which team wrote the feature. Link between modes instead of duplicating authoritative prose.

User-facing technical content normally belongs under `docs/versioned/`. Docs-contributor guidance belongs under `contribute-to-docs/`. Component implementation/contributor material can belong in the relevant [Serving](https://github.com/knative/serving) or [Eventing](https://github.com/knative/eventing) repository. A vendor site or external project can be a better home for integration-specific documentation; link to the maintained source and make ownership clear.

New files are not necessarily integrated into the curated navigation simply by existing. Follow [Navigation and redirects](../getting-started/navigation-and-redirects.md); include the proposed path, title, mode, and entry links in your PR. Preserve a meaningful legacy entry point or arrange redirects if moving content. Check fragment links as well as filenames.

## Author and reviewer checklists

### Every technical page

- [ ] Audience, starting state, scope, and reader promise are explicit and agree with the body and metadata.
- [ ] Component, permissions, version, and feature requirements are stated where relevant.
- [ ] Existing URLs, anchors, warnings, licensing, and acknowledgments are retained or deliberately handled.
- [ ] Technical facts have an authoritative source; defaults and capability claims were not inferred from an example.
- [ ] Related tasks, explanations, and references have specific links, without duplicating authoritative content.
- [ ] From a plausible entry point, the rendered navigation label, page title, opening promise, and main content agree. The reader can find the prerequisites and an appropriate finish or next destination without restarting an unrelated tutorial.
- [ ] Code, indentation, tabs, release macros, and includes render correctly; local links and anchors resolve in the page's publishing context.
- [ ] The PR records what was tested, the environment/release, results, and remaining uncertainties. Do not call a page cluster-tested merely because it builds.

### Mode-specific review

| Mode | Questions for author and reviewer |
| --- | --- |
| Tutorial | Is there one complete chosen route? Can a learner follow it from the stated starting state? Are expected outputs and what to notice visible? Are alternatives optional, with a clear finish and next step? |
| How-to | Does the page achieve one bounded goal? Are prerequisite resources and permissions sufficient? Are conditional paths evidence-based and applicable to the reader's implementation? Can success be verified, and can risky changes be recovered? |
| Reference | Can readers find a field without following a procedure? Are identifiers, scopes, types, defaults, valid values, and constraints consistent? Are unknown or release-dependent values stated honestly? Is generated content left intact? |
| Explanation | Does the page explain relationships, causes, or trade-offs rather than merely list definitions? Are claims grounded in supported behavior? Are procedures linked rather than embedded as the main narrative? |
| Landing page | Do a few concrete routes answer likely reader questions? Are destination descriptions accurate? Is the page free of a misleading lesson contract? |

### Technical validation and review handoff

Keep the existing testing expectations for procedures, setup, and maintained samples: include or update automated tests as applicable to the project. Also execute tutorial and how-to routes in the stated environment when possible. If execution or automation is not available, say so explicitly in the PR and request technical validation; editorial review and server-side YAML validation do not replace behavioral tests.

Authors and subject matter experts are responsible for technical correctness. Reviewers check both the reader contract and the evidence, consult the author on uncertain behavior, and request revisions rather than silently inventing missing steps or defaults. A rough but scoped draft is welcome; it should still disclose unverified claims. See [the contributor review workflow](../getting-started/becoming-a-contributor.md#workflow-overview).

Keep the review handoff concise and distinguish evidence:

- **Reader route and rendering:** entry link, destination, intended result, publishing context checked, and any obstacle. A reviewer following links is a simulated traversal, not an observed-user usability study.
- **Technical sources:** component/release and authoritative references checked, with uncertain defaults or capability claims assigned to the subject matter expert.
- **Execution and automation:** exact route or tests run, environment/release, observed results, and unexecuted branches or blockers. Syntax checks, API validation, and end-to-end execution establish different things; do not report one as another.

Prioritize findings that prevent the promised result or send readers to the wrong destination. Give the owner a concrete path/section, reader consequence, and proposed correction or question. The author and reviewer should consult on substantive findings; the reviewer checks the revised page and route before approval. Disclosure of an unexecuted route does not waive maintained-sample testing requirements or establish runtime correctness.

## Branches

For choosing a branch and cherrypicking, see [Branches and cherrypicking](../getting-started/branches-and-cherrypicking.md).

## Submit your contribution to GitHub

See the [GitHub workflow](../getting-started/github-workflow.md) to submit documentation changes and respond to review.

# Reference template

Use this template for exact facts about an API, configuration object, setting, metric, or command. Reference can be authored or generated; it is not the place for advanced procedures merely because they are complex.

Contract: consistent lookup structure, exact identifiers and scope, accurate constraints, and concise examples. Organize around the product's structure. Link to procedures and explanation rather than requiring readers to execute a task before finding a value. Review with the [page checklists](../what-to-contribute/creating-new-docs.md#author-and-reviewer-checklists).

Copy the scaffold, select the appropriate audience and components, and replace author prompts. Keep release macros and generated/build-replaced API behavior intact. Do not paste a second API schema into authored documentation when a maintained generated source exists.

````markdown
---
audience: administrator
components:
  - serving
function: reference
---

# Object or settings reference

State what is covered, what is excluded, and the relevant component or release.
Link to the authoritative API schema or implementation-specific reference.

## Settings index

For a collection, provide links organized by object or purpose. Do not duplicate
all definitions here and again below.

## `exact-setting-identifier`

| Property | Value |
| --- | --- |
| Scope | Resource, annotation, ConfigMap, component, or cluster scope |
| Type | Exact type and units |
| Default | Documented default, or explicitly state that it is unset, implementation-dependent, or not established |
| Valid values | Range, enumeration, format, and case sensitivity |
| Requirements | Feature gate, implementation, or version requirements |

Describe constraints, interactions, precedence, and failure behavior when known.
Distinguish omitted values from explicitly supplied values where it matters.

### Example

```yaml
# A small illustrative fragment, clearly labeled as partial where appropriate.
```

State what the example demonstrates; do not turn it into a deployment sequence.
Warn about dangerous combinations where relevant.

## Related information

Link to the bounded configuration task and supporting explanation.
````

Use only properties that apply to the object; never invent a type or default to fill the table. In the PR, identify the source/release used to validate facts and flag any unresolved conflicts for a subject matter expert.

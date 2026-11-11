<a id="troubleshooting-template"></a>

# Troubleshooting how-to template

Troubleshooting is a task context, not a fifth technical documentation mode. Start with the reader's observed symptom in their existing environment, not with a demonstration topology they must install first.

Contract: establish scope, inspect evidence, choose a remedy based on confirmed conditions, and verify recovery. Avoid presenting a guess as the only cause. Review with the [page checklists](../what-to-contribute/creating-new-docs.md#author-and-reviewer-checklists).

````markdown
---
audience: administrator
components:
  - eventing
function: how-to
---

# Resolve a searchable symptom

Describe the symptom, including the exact error text or status when useful.
State which resources and implementations this guide covers.

## Before you begin

Identify the affected resource, namespace, installed implementation, and version.
State required access to status, events, and logs. Warn about sensitive log data.

## Check the affected resource

1. Give a non-destructive inspection command with explained placeholders.
1. Show what evidence to look for and distinguish expected from abnormal output.

## If the evidence shows a specific condition

Explain the confirmed cause briefly, if known, then give the remedy.
Label ingress-, transport-, and version-specific branches explicitly.
Warn before destructive changes and describe how to recover previous values.

## Verify recovery

Repeat the failing operation and state the expected result. Readiness alone
may not prove that requests or events reach their destination.

## If the symptom remains

Give a next diagnostic step or escalation route and the useful evidence to
collect. Do not ask readers to publish secrets or security vulnerability details.
````

## Compact error reference

For a collection of brief, known errors, this lookup table can accompany links to full how-tos. Do not put long numbered procedures inside table cells.

```markdown
| Error or symptom | Confirming evidence | Cause, if known | Remedy |
| --- | --- | --- | --- |
| Exact message or observed behavior | Status or log evidence | Confirmed condition, not a guess | Link to the scoped repair guide |
```

A reproducible debugging exercise belongs in a tutorial with its own chosen setup, not in the mandatory path for someone diagnosing an existing installation.

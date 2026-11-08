# Tutorial template

Use this template for guided learning through doing, not for a catalog of installation choices or an operator's task collection.

Contract: one chosen route, an explicit starting state, observable results, and a clear finish. Choose the environment and commands for the learner. Keep short explanations that help them notice the result; link away from long conceptual detours and optional extensions. Review with the [page checklists](../what-to-contribute/creating-new-docs.md#author-and-reviewer-checklists).

Copy the scaffold below, choose the appropriate audience and components, and replace or remove author prompts. The metadata is for a versioned technical page, not this template catalog.

````markdown
---
audience: developer
components:
  - serving
function: tutorial
---

# Learn a specific capability by building something

Describe what the learner will build or observe and what they will learn.
Do not promise production readiness from an educational exercise.

## Before you begin

State the chosen environment, required tools and versions, installed components,
permissions, and starting resources. Link to the selected setup route.
Tell the learner what prior experience is assumed and what this exercise changes.

## Create the first result

1. Give a concrete action with complete commands. Explain placeholders before use.

    ```bash
    # Replace with a tested command.
    ```

1. Show the check and expected result. Point out what the learner should notice.

    ```text
    Replace with expected output, identifying any variable portions.
    ```

## Observe the next behavior

Continue along the same route with consistent tooling, resource names, and
namespaces. Pair actions with visible results. Give recovery advice for likely
interruptions without turning the lesson into a troubleshooting catalog.

## What you learned

Summarize the observed capability and identify the finished state. Do not add
new required work here.

## Clean up

Show how to remove only the resources created by this exercise. Warn before
any operation that could affect unrelated workloads.

## Next steps

Link explicitly to the next lesson if this is a series. Offer a small number of
bounded tasks, explanations, or references for further work. Label optional
extensions and keep them outside the completed core learning path.
````

In the PR, record execution environment, component release, commands tested, and results. If the tutorial was not executed, disclose that and request technical validation; do not claim that rendering the page tests the lesson.

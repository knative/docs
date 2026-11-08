<a id="concept-template"></a>

# Explanation template

Use this template to explain how Knative works, why it behaves that way, or how to reason about trade-offs. The legacy Concept filename is retained for existing links.

Contract: connect concepts, causes, and consequences for a stated audience. Do not use explanation as a container for procedures or an exhaustive settings catalog. Small examples can illustrate a relationship; link to the how-to and reference for doing and lookup. Review with the [page checklists](../what-to-contribute/creating-new-docs.md#author-and-reviewer-checklists).

## Template

Copy the scaffold, choose the appropriate audience and components, and replace author prompts. Use only sections that help explain the subject; the headings are not a mandatory outline.

```
---
audience: developer
components:
  - serving
function: explanation
---

# A concept or relationship to understand

Introduce the subject and the question this explanation answers. State the
assumed knowledge and scope so readers can tell whether it is for them.
Prefer a concrete relationship or consequence over "This topic describes...".

## Overview

Write a few sentences describing the subject of the topic.

## How the parts interact

Explain the causal relationships and behavior, using a diagram or small example
where useful. Identify assumptions and implementation-specific limits.

## Trade-offs and consequences

Describe why someone would choose an approach and what it costs or constrains.
Ground capability claims in the documented release, not speculation.

## Section Title

Write a sentence or two to describe the content in this section. Create more sections as necessary.
Optionally, add two or more subsections to each section.
Do not skip header levels: H2 >> H3, not H2 >> H4.

### Subsection Title

Write a sentence or two to describe the content in this section.

### Subsection Title

Write a sentence or two to describe the content in this section.

## Related information

Link to a bounded task and authoritative reference for readers ready to act or
look up details. Remove unused scaffold sections before submitting.
```

## Conceptual content samples

This section provides common content types that appear in conceptual topics.
Copy and paste the markdown to use it in your topic.

### Tables

Introduce the table with a sentence. For example, “The following table lists which operations must be
made available to a developer accessing a Knative Route using a minimal profile.”


#### Markdown table template

```
|Header 1|Header 2|
|--------|--------|
|Data1   |Data2   |
|Data3   |Data4   |
```

### Ordered lists

Write a sentence or two to introduce the content of the list.
For example, “If you want to fix or add content to a past release, you can find the source files in
the following folders.”. Optionally, include bold lead-ins before each list item.

**NOTE:** For the formatting to render correctly, you must add an empty line
between the list and the preceding sentence.

#### Markdown ordered list template

```
Introductory sentence:

1. Item 1
1. Item 2
1. Item 3
```

```
Introductory sentence:

1. **Lead-in description:** Item 1
1. **Lead-in description:** Item 2
1. **Lead-in description:** Item 3
```

#### Nested ordered lists template

For formatting to render correctly, nested items must be indented by four spaces
in relation to their parent item.

```
Introductory sentence:

1. Item 1

    1. Item 1a

1. Item 2
```

### Unordered Lists

Write a sentence or two to introduce the content of the list.
For example, “Your own path to becoming a Knative contributor can begin in any of the following
components:”. Optionally, include bold lead-ins before each list item.

**NOTE:** For the formatting to render correctly, you must add an empty line
between the list and the preceding sentence.

#### Markdown unordered list template

```
Introductory sentence:

* List item
* List item
* List item
```

```
Introductory sentence:

* **Lead-in**: List item
* **Lead-in**: List item
* **Lead-in**: List item
```

#### Nested unordered list template

Nested items must be indented by four spaces in relation to their parent item.

```
Introductory sentence:

* List item

    * List sub-item

* List item
```

### Notes

Ensure the text beneath the **note** is indented as much as **note** is.

```
!!! note
    This is a note.
```

### Warnings

If the note regards an issue that could lead to data loss, the note should be a warning.

```
!!! warning
    This is a warning.
```

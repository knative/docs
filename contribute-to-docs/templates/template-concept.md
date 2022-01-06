# Concept Template

Use this template when writing conceptual topics.
Conceptual topics explain how things work or what things mean.
They provide helpful context to readers. They do not include procedures.

## Template

The following template includes the standard sections that should appear in conceptual topics, including a topic introduction sentence, an overview, and placeholders for additional sections and subsections.
Copy and paste the markdown from the template to use it in your topic.

```
This topic describes...
Write a sentence or two that describes the topic itself, not the subject of the topic.
The goal of the topic sentence is to help readers understand if this topic is for them.
For example, "This topic describes what Knative Serving is and how it works."

## Overview

Write a few sentences describing the subject of the topic.

## Section Title

Write a sentence or two to describe the content in this section. Create more sections as necessary.
Optionally, add two or more subsections to each section.
Do not skip header levels: H2 >> H3, not H2 >> H4.

### Subsection Title

Write a sentence or two to describe the content in this section.

### Subsection Title

Write a sentence or two to describe the content in this section.
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

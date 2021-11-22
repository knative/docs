# Formatting content

## Tables

Introduce the table with a sentence. For example, “The following table lists which operations must be
made available to a developer accessing a Knative Route using a minimal profile.”


### Markdown table template

```
|Header 1|Header 2|
|--------|--------|
|Data1   |Data2   |
|Data3   |Data4   |
```

## Ordered lists

Write a sentence or two to introduce the content of the list.
For example, “If you want to fix or add content to a past release, you can find the source files in
the following folders.”. Optionally, include bold lead-ins before each list item.

**NOTE:** For the formatting to render correctly, you must add an empty line
between the list and the preceding sentence.

### Markdown ordered list template

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

### Nested ordered lists template

For formatting to render correctly, nested items must be indented by four spaces
in relation to their parent item.

```
Introductory sentence:

1. Item 1

    1. Item 1a

1. Item 2
```

## Unordered Lists

Write a sentence or two to introduce the content of the list.
For example, “Your own path to becoming a Knative contributor can begin in any of the following
components:”. Optionally, include bold lead-ins before each list item.

**NOTE:** For the formatting to render correctly, you must add an empty line
between the list and the preceding sentence.

### Markdown unordered list template

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

### Nested unordered list template

Nested items must be indented by four spaces in relation to their parent item.

```
Introductory sentence:

* List item

    * List sub-item

* List item
```

## Documenting code and code snippets

For instructions on how to format code and code snippets, see the
[Style guide](../style-guide/documenting-code.md).


## Content Tabs

Content tabs are handy way to organize lots of information in a visually pleasing way.
Place multiple versions of the same procedure (such as a kn CLI procedure vs a YAML procedure)
within tabs. Indent the tab content by four spaces to make the tabs display properly.

For example:

    == "tab1 name"

        This is a stem:

        1. This is a step.

          ```
          This is some code.
          ```

        1. This is another step.

    == "tab2 name"

        This is a stem:

        1. This is a step.

          ```
          This is some code.
          ```

        1. This is another step.


For more information, see the [Material for MkDocs documentation](https://squidfunk.github.io/mkdocs-material/reference/content-tabs/#usage)


## Admonitions

We use the note, tip, and warning admonition boxes only. Use admonitions sparingly; too many
admonitions can be distracting. The formatting for notes is as follows:

### Notes

```
!!! note
    A Note contains information that is useful, but not essential.
    A reader can skip a note without bypassing required information.
    If the information suggests an action to take, use a tip instead.
```

### Tips

```
!!! tip
    A Tip suggests a helpful, but not mandatory, action to take.
```

### Warnings

```
!!! warning
    A Warning draws attention to potential trouble.
```

## Icons and Emojis

Material for MkDocs supports using Material Icons and Emojis using easy shortcodes.
For example, the taco emoji :taco:, is formatted as `:taco:`.

To search a database of Icons and Emojis (all of which can be used on Knative.dev),
as well as usage information, see the
[Material for MkDocs documentation](https://squidfunk.github.io/mkdocs-material/reference/icons-emojis/#search)


## TODO (Add Requests Here)
- Navigation using lukasgeiter/mkdocs-awesome-pages-plugin: An MkDocs plugin that simplifies configuring page titles and their order
- Index.md vs. README.md
- awesome-pages

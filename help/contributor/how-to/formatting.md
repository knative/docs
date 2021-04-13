---
title: "Formatting standards and conventions"
linkTitle: "Formatting standards"
weight: 40
type: "docs"
---

This page shows the formatting standards for the Knative documentation. Knative uses
Markdown to markup the content and Hugo with the Docsy template, to build the website. To ensure
consistency across our documentation, we have agreed on these formatting standards.

[Learn about the Hugo/Docsy requirements for each page](./frontmatter.md)

## Linking: Use relative URLs

For all links within the Knative content, use relative linking (also know as
[relative URLs](https://www.w3.org/TR/WD-html40-970917/htmlweb.html#h-5.1.2)).

Linking conventions:

 - Links between files in the same directory must be prefixed with: `./`

    Example: `[Shortcodes](./shortcodes.md)` renders as [Shortcodes](./shortcodes.md)

 - To link across folders, add `../` for each directory that you must travel
   towards the root docs directory.

    Example: `[FAQs](../../faqs.md)` renders as [FAQs](../../faqs.md)

#### Background

Early on in the content development, all of the documentation was author in the
GitHub repos and since then, there are many contributors who value the ability
to consume the documentation from within the repo. In addition, the main
Markdown editor and renderer when authoring Knative docs is the GitHub UI.
Therefore, we continue to **use relative URLs throughout** to ensure that all
the links work as expected, both when clicked in the GitHub UI and on knative.dev.

Hugo has it's own syntax for linking across your content and treats
the content across the site as a single version of docs (including a Hugo
specific definition of relative links: *relative to the website domain*).
Unfortunately, that type of linking renders markdown content unusable from with
the GitHub repos and does not allow for easy versioning/archiving.

## Don't use capitalization for emphasis

Only use the original capitalization found in the code or configuration files
when referencing those values directly. Use back-ticks \`\` around the
referenced value to make the connection explicit. For example, use
`IstioRoleBinding`, not `Istio Role Binding` or `istio role binding`.

If you are not referencing values or code directly, use normal sentence
capitalization, for example, "The Knative role binding configuration takes place
in a YAML file."

## Use angle brackets for placeholders

Use angle brackets for placeholders in commands or code samples. Tell the reader
what the placeholder represents. For example:


1. Display information about a pod:

    $ kubectl describe pod <pod-name>

    Where `<pod-name>` is the name of one of your pods.


## Use **bold** to emphasize user interface elements

|Do                | Don't
|------------------|------
|Click **Fork**.   | Click "Fork".
|Select **Other**. | Select 'Other'.

## Use _italics_ to emphasize new terms

|Do                                         | Don't
|-------------------------------------------|---
|A _cluster_ is a set of nodes ...          | A "cluster" is a set of nodes ...
|These components form the _control plane_. | These components form the **control plane**.

Use the `gloss` shortcode and add glossary entries for new terms.

## Use `back-ticks` around file names, directories, and paths

|Do                                   | Don't
|-------------------------------------|------
|Open the `foo.yaml` file.         | Open the foo.yaml file.
|Go to the `/content/en/docs/tasks` directory.  | Go to the /content/en/docs/tasks directory.
|Open the `/data/args.yaml` file. | Open the /data/args.yaml file.

## Use `back-ticks` around inline code and commands

|Do                          | Don't
|----------------------------|------
|The `foo run` command creates a `Deployment`. | The "foo run" command creates a `Deployment`.
|For declarative management, use `foo apply`. | For declarative management, use "foo apply".

Use code-blocks for commands you intend readers to execute. Only use inline code
and commands to mention specific labels, flags, values, functions, objects,
variables, modules, or commands.

* [Learn how to include code snippets from source files]().

## Use `back-ticks` around object field names

|Do                                                               | Don't
|-----------------------------------------------------------------|------
|Set the value of the `ports` field in the configuration file. | Set the value of the "ports" field in the configuration file.
|The value of the `rule` field is a `Rule` object.           | The value of the "rule" field is a `Rule` object.

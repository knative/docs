---
title: "Style guide"
linkTitle: ""
weight: 30
type: "docs"
---

All content accepted into the Knative documentation must be **clear** and
**understandable**. Generally, content should aim to be "task oriented" and
thorough.

The standard we use to make that determination is defined by
the [Google Developer Documentation Style
Guide](https://developers.google.com/style/).

**Start here**:

1. [Highlights](https://developers.google.com/style/highlights)
2. [General principles](https://developers.google.com/style/tone)
3. Use the sections below as reference.

## Use sentence case for titles and headings

Use sentence case for all titles and headings. Only capitalize the first
word of the heading, except for proper nouns or acronyms.

|Do                  | Don't
|--------------------|-----
|Configuring feature | Configuring Feature
|Using feature.      | Using Feature
|Using HTTPS         | Using https

## Use present tense

|Do                           | Don't
|-----------------------------|------
|This command starts a proxy. | This command will start a proxy.

Exception: Use future or past tense if it is required to convey the correct
meaning. This exception is extremely rare and should be avoided.

## Use active voice

|Do                                         | Don't
|-------------------------------------------|------
|You can explore the API using a browser.   | The API can be explored using a browser.
|The YAML file specifies the replica count. | The replica count is specified in the YAML file.

## Use simple and direct language

Use simple and direct language. Avoid using unnecessary phrases, such as saying
"please."

|Do                          | |Don't
|----------------------------|--|----
|To create a `ReplicaSet`, ... | | In order to create a `ReplicaSet`, ...
|See the configuration file. |  | Please see the configuration file.
|View the Pods.              |  | With this next command, we'll view the Pods.

## Address the reader as "you"

|Do                                     | Don't
|---------------------------------------|------
|You can create a `Deployment` by ...     | We'll create a `Deployment` by ...
|In the preceding output, you can see...| In the preceding output, we can see ...

## Create useful links

There are good hyperlinks, and bad hyperlinks. The common practice of calling
links *here*  or *click here* are examples of bad hyperlinks. Check out [this
excellent article](https://medium.com/@heyoka/dont-use-click-here-f32f445d1021)
explaining what makes a good hyperlink and try to keep these guidelines in
mind when creating or reviewing site content.

## Avoid using "we"

Using "we" in a sentence can be confusing, because the reader might not know
whether they're part of the "we" you're describing.

|Do                                        | Don't
|------------------------------------------|------
|Version 1.4 includes ...                  | In version 1.4, we have added ...
|Knative provides a new feature for ...    | We provide a new feature ...
|This page teaches you how to use pods.    | In this page, we are going to learn about pods.

## Avoid jargon and idioms

Some readers speak English as a second language. Avoid jargon and idioms to help
make their understanding easier.

|Do                    | Don't
|----------------------|------
|Internally, ...       | Under the hood, ...
|Create a new cluster. | Turn up a new cluster.
|Initially, ...        | Out of the box, ...

## Avoid statements about the future

Avoid making promises or giving hints about the future. If you need to talk
about a feature in development, add a boilerplate under the front matter that
identifies the information accordingly.

### Avoid statements that will soon be out of date

Avoid using wording that becomes outdated quickly like "currently" and
"new". A feature that is new today is not new for long.

|Do                                  | Don't
|------------------------------------|------
|In version 1.4, ...                 | In the current version, ...
|The Federation feature provides ... | The new Federation feature provides ...

## Other related items

* [Page formatting standards]()
* [Include code snippets from source files]()

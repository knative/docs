---
audience: developer
components:
  - functions
  - serving
  - eventing
---

# Learn Knative

Try Knative through guided exercises with visible results. Start with the
Quickstart; use the Bookstore tutorial after you are comfortable deploying a
Service and routing events. These are learning environments, not production
installation recipes.

## Start with the Quickstart

The [Knative Quickstart](../getting-started/README.md) guides you through a local
installation and your first applications. Begin with its prerequisites and
installation steps, then follow the lessons in order.

Along the way, you will:

- [Deploy a Service](../getting-started/first-service.md),
  [observe scale-to-zero](../getting-started/first-autoscale.md), and
  [split traffic between revisions](../getting-started/first-traffic-split.md).
- [Route events with a Broker and Triggers](../getting-started/getting-started-eventing.md)
  using Knative Eventing.

These links identify lessons within the Quickstart, not independent starting
points: each lesson relies on the environment and resources established earlier.

## Try Functions as a separate follow-on

The [Functions learning route](../getting-started/about-knative-functions.md)
guides you through installing `func`, creating a Go function project, and running
it locally. Deployment is optional and requires a registry you can push to and
a cluster that can pull the image. This exercise is not a prerequisite for the
Quickstart's Serving and Eventing lessons.

## Build an event-driven Bookstore after the basics

The [Bookstore tutorial](../bookstore/page-0/welcome-knative-bookstore-tutorial.md)
combines Services, Functions, and Eventing in an application that processes book
reviews. Expect additional environment setup and application dependencies beyond
the Quickstart. Read the [educational scope and disclaimer](../bookstore/disclaimer/README.md)
before beginning.

Start with the introduction and [environment setup](../bookstore/page-0.5/environment-setup.md),
then follow the core lessons through
[routing accepted reviews to the database](../bookstore/page-6/advanced-event-filtering.md).
The core result is a processed review event and an accepted review appearing in
the UI.

[Extra challenges](../bookstore/extra-challenge/README.md) offer optional practice
after that result. The [Slack/Camel K integration recipe](../bookstore/page-7/slack-sink-learning-knative-eventing-and-apache-camel-K-integration.md)
is reference pending runtime validation, **not an executable follow-on lesson**;
it retains the design and examples for technical review. [Setup alternatives](../bookstore/page-0.5/setup-options.md)
preserve other environments and image-build options; they are not additional
steps in the chosen route.

## Choose your next goal

- Ready to work on your own application? [Find a how-to guide](../how-to/README.md).
- Want to make sense of what you observed? [Explore the concepts and behavior](../explanation/README.md).
- Need an exact field or setting? [Look up reference details](../reference/README.md).
- Want more exercises or example applications? Browse the
  [tutorial catalog](../getting-started/tutorial.md) and
  [code samples](../samples/README.md). Samples have different maintainers and
  prerequisites; they are not all guided lessons.

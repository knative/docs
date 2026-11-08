---
audience: developer
components:
  - functions
  - serving
  - eventing
---

# Learn Knative

Try Knative through guided exercises with visible results. You can write and run
a function locally without Kubernetes, or use Quickstart to try Services and
event routing on a local cluster. Use the Bookstore tutorial after those cluster
basics. These are learning environments, not production installation recipes.

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

<span id="try-functions-as-a-separate-follow-on"></span>

## Write and run a function locally

The [Functions learning route](../getting-started/about-knative-functions.md)
can be your first encounter with Knative, without completing Quickstart or
installing Kubernetes. Follow its selected `func` release and `pack` builder to
create a Go HTTP project, edit one response line, and confirm the new response
locally. The local steps need a Docker-compatible daemon and dependency downloads,
but not a registry account or running image registry.

You can stop at that local result. Publishing and deployment are optional and
introduce separate registry, cluster, context, and ownership prerequisites.
Functions is also an independent next exercise after Quickstart; it is not a
prerequisite for the Serving and Eventing lessons.

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

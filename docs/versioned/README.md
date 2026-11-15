---
audience: developer
components:
  - eventing
  - functions
  - serving
---

# Get started with Knative

Knative provides building blocks for serverless applications on Kubernetes:
**Functions** helps you turn code into containers, **Serving** runs and scales
HTTP services, and **Eventing** routes events between applications.

## Try Knative

**New to Knative? Start by running a container with Serving.** You will see how
Knative deploys an HTTP service, scales it to zero, and splits traffic between
revisions. You do not need to write code or complete another tutorial first.

Follow these steps in order; they share a local learning cluster:

1. [Set up your cluster](getting-started/quickstart-install.md). Check the
   prerequisites, then install Knative using the Quickstart plugin.
2. [Deploy a service](getting-started/first-service.md) from a sample container.
3. [Explore autoscaling](getting-started/first-autoscale.md), including scaling to zero.
4. [Split traffic](getting-started/first-traffic-split.md) between two revisions.
5. [Clean up](getting-started/clean-up.md) and choose your [next steps](getting-started/next-steps.md).

[Set up your cluster](getting-started/quickstart-install.md){ .md-button .md-button--primary }

This environment is for learning. To install Knative on a cluster you manage,
use the [installation guide](install/README.md) instead.

## Already have a goal?

| I want to… | Start here |
| --- | --- |
| Write a function | [Create a function project](functions/creating-functions.md) |
| Deploy an existing container | [Create a Knative Service](serving/services/creating-services.md) |
| Connect applications with events | [Explore Knative Eventing](eventing/README.md) |
| Install and operate Knative | [Install and Manage](admin/admin-overview.md) |

These guides describe their own prerequisites; they do not require completing
the walkthrough above first.

<!-- Keep previous documentation-home fragments useful after moving the overview. -->
<span id="knative-technical-overview"></span><span id="what-is-knative"></span><span id="problems-knative-solves"></span><span id="background-knowledge"></span><span id="architecture-overview"></span>
<span id="system-integration-and-interoperability"></span><span id="how-components-work-together"></span><span id="integration-with-kubernetes-ecosystem"></span><span id="use-cases-and-when-to-choose-knative"></span><span id="ideal-use-cases"></span><span id="evaluation-criteria"></span>

## Understand Knative

The [technical overview](overview.md) explains the problems Knative addresses,
how its components work together, and when to use it. It is optional background,
not required reading before the tutorial.

- <span id="knative-functions"></span><span id="functions-development-model"></span><span id="supported-languages-and-runtimes"></span><span id="function-deployment-and-lifecycle"></span>
  [Functions](overview.md#knative-functions): the development model and function lifecycle.
- <span id="knative-serving"></span><span id="key-serving-features"></span><span id="request-flow-in-serving"></span><span id="gpu-resources-and-llm-inference"></span>
  [Serving](overview.md#knative-serving): HTTP services, request flow, and scaling.
- <span id="knative-eventing"></span><span id="key-eventing-concepts"></span><span id="event-flow-in-eventing"></span><span id="eventing-use-cases"></span>
  [Eventing](overview.md#knative-eventing): event sources, routing, and consumers.

<span id="next-steps"></span>

## Keep exploring

- [Your first function](getting-started/about-knative-functions.md): start from code instead of a container.
- [Your first event](getting-started/getting-started-eventing.md): send an event through a Broker to a consumer.
- [Bookstore tutorial](bookstore/page-0/welcome-knative-bookstore-tutorial.md): combine the components in a larger application.
- [CLI tools](client/README.md) for working with Knative from your terminal.
- [Code samples](samples/README.md) for examples to explore and adapt.

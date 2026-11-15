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

**New to Knative? Start with the Quickstart tutorial.** Set up a local learning
cluster, deploy a service, explore autoscaling and traffic splitting, and route
events. Check the prerequisites first, then follow the lessons in order.

[Start the Quickstart tutorial](getting-started/README.md){ .md-button .md-button--primary }

The Quickstart environment is for learning. To install Knative on a cluster you
manage, use the [installation guide](install/README.md) instead.

## Already have a goal?

| I want to… | Start here |
| --- | --- |
| Write a function | [Create a function project](functions/creating-functions.md) |
| Deploy an existing container | [Create a Knative Service](serving/services/creating-services.md) |
| Connect applications with events | [Explore Knative Eventing](eventing/README.md) |
| Install and operate Knative | [Install and Manage](admin/admin-overview.md) |

These guides describe their own prerequisites; they do not require completing
the Quickstart first.

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

- [Functions tutorial](getting-started/about-knative-functions.md): create, build, and run a function.
- [Bookstore tutorial](bookstore/page-0/welcome-knative-bookstore-tutorial.md): build an event-driven application.
- [CLI tools](client/README.md) for working with Knative from your terminal.
- [Code samples](samples/README.md) for examples to explore and adapt.

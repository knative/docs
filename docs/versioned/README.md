---
audience: developer
components:
  - eventing
  - functions
  - serving
hide_next: true
---

<span id="knative-documentation"></span><span id="learn-knative"></span>

# Get started with Knative

Knative extends Kubernetes for HTTP services and event-driven applications.
**Serving** runs and scales HTTP containers; **Eventing** routes CloudEvents.
**Functions** helps you write and test code locally before choosing deployment.

<span id="what-would-you-like-to-do"></span><span id="go-directly-to-your-component-or-role"></span>

## Start here

<span id="start-with-the-quickstart"></span>

- **Try Knative on a local cluster:** [follow Quickstart](getting-started/README.md).
  Start with its prerequisites, then deploy a Service, observe autoscaling, and
  route an event. Follow the lessons in order; they share an environment.
- <span id="try-functions-as-a-separate-follow-on"></span><span id="write-and-run-a-function-locally"></span>**Write your first function without Kubernetes:** [create, edit, and run a Go HTTP function locally](getting-started/about-knative-functions.md).
  The selected route uses a Docker-compatible daemon and dependency downloads,
  but needs no registry account or running image registry. Publishing and cluster
  deployment are optional later steps.

<span id="build-an-event-driven-bookstore-after-the-basics"></span>

After the basics, [build the event-driven Bookstore](bookstore/page-0/welcome-knative-bookstore-tutorial.md).
It adds application setup and dependencies; read its educational scope before
starting. The core tutorial and optional integration recipes are distinct.

## Understand the platform

<span id="knative-technical-overview"></span><span id="what-is-knative"></span><span id="problems-knative-solves"></span><span id="background-knowledge"></span><span id="architecture-overview"></span>

Read the [Knative Technical Overview](explanation/overview.md) for the problems
Knative addresses and how its components fit together. This is optional
background, not a prerequisite for trying the tutorials.

Component background:
<span id="knative-serving"></span><span id="key-serving-features"></span><span id="request-flow-in-serving"></span><span id="gpu-resources-and-llm-inference"></span>
[Serving, requests, and inference](explanation/overview.md#knative-serving) ·
<span id="knative-eventing"></span><span id="key-eventing-concepts"></span><span id="event-flow-in-eventing"></span><span id="eventing-use-cases"></span>
[Eventing and event flow](explanation/overview.md#knative-eventing) ·
<span id="knative-functions"></span><span id="functions-development-model"></span><span id="supported-languages-and-runtimes"></span><span id="function-deployment-and-lifecycle"></span>
[Functions and their lifecycle](explanation/overview.md#knative-functions).

<span id="system-integration-and-interoperability"></span><span id="how-components-work-together"></span><span id="integration-with-kubernetes-ecosystem"></span><span id="use-cases-and-when-to-choose-knative"></span><span id="ideal-use-cases"></span><span id="evaluation-criteria"></span>

For evaluation, see [component integration and trade-offs](explanation/overview.md#system-integration-and-interoperability).

## Already using Knative?

- [Deploy an HTTP container](serving/services/creating-services.md), or browse the [Serving guide](serving/README.md).
- [Route matching events](eventing/triggers/README.md), or browse the [Eventing guide](eventing/README.md).
- Use the [Functions guide](functions/README.md) for your own project.
- [Install and Manage](install/README.md): choose an installation route, then use the [cluster task shortcuts](how-to/README.md#operate-a-knative-cluster).

<span id="next-steps"></span><span id="choose-your-next-goal"></span>

Find more [task guides](how-to/README.md), [reference details](reference/README.md),
[explanatory guides](explanation/README.md), or [code samples](samples/README.md)
when you need them.

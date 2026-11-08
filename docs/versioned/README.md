---
audience: developer
components:
  - eventing
  - functions
  - serving
---

# Knative documentation

Knative extends Kubernetes for HTTP services and event-driven applications.
**Serving** runs and scales HTTP containers; **Eventing** routes CloudEvents
between producers and consumers. **Functions** helps you write and package code
for local testing or deployment as a Knative Service.

<span id="what-would-you-like-to-do"></span><span id="go-directly-to-your-component-or-role"></span>

## Start here

- **Try Knative:** follow [Quickstart](getting-started/README.md) to deploy a
  Service, observe autoscaling, and route an event on a local cluster.
- **Write a function:** [create, edit, and run a Go HTTP function locally](getting-started/about-knative-functions.md)
  without Kubernetes. For your own project, use the [Functions guide](functions/README.md).
- **Deploy an HTTP container:** [create and verify a Knative Service](serving/services/creating-services.md).
  Use the [Serving guide](serving/README.md) for scaling, domains, and traffic.
- **Connect events:** [route matching events to a subscriber](eventing/triggers/README.md).
  Use the [Eventing guide](eventing/README.md) for sources, delivery, and troubleshooting.
- **Install and operate:** [choose an installation route](install/README.md),
  then use the [operator task shortcuts](how-to/README.md#operate-a-knative-cluster)
  for configuration, security, observation, and upgrades.

## Understand the platform

<span id="knative-technical-overview"></span><span id="what-is-knative"></span><span id="problems-knative-solves"></span><span id="background-knowledge"></span><span id="architecture-overview"></span>

Read the [technical overview](explanation/overview.md) for the problems Knative
addresses and how its components fit together.

Component background:
<span id="knative-serving"></span><span id="key-serving-features"></span><span id="request-flow-in-serving"></span><span id="gpu-resources-and-llm-inference"></span>
[Serving, requests, and inference](explanation/overview.md#knative-serving) ·
<span id="knative-eventing"></span><span id="key-eventing-concepts"></span><span id="event-flow-in-eventing"></span><span id="eventing-use-cases"></span>
[Eventing and event flow](explanation/overview.md#knative-eventing) ·
<span id="knative-functions"></span><span id="functions-development-model"></span><span id="supported-languages-and-runtimes"></span><span id="function-deployment-and-lifecycle"></span>
[Functions and their lifecycle](explanation/overview.md#knative-functions).

<span id="system-integration-and-interoperability"></span><span id="how-components-work-together"></span><span id="integration-with-kubernetes-ecosystem"></span><span id="use-cases-and-when-to-choose-knative"></span><span id="ideal-use-cases"></span><span id="evaluation-criteria"></span>

For evaluation, see [component integration and trade-offs](explanation/overview.md#system-integration-and-interoperability).

<span id="next-steps"></span>

Find more [task guides](how-to/README.md), [reference details](reference/README.md),
or [explanatory guides](explanation/README.md) when you need them.

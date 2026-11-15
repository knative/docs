---
audience: developer
components:
  - eventing
  - functions
  - serving
hide_next: true
---

# Get started with Knative

Knative helps you build and run serverless applications on Kubernetes.
**Serving** runs HTTP containers, **Functions** turns your code into an application,
and **Eventing** routes events between applications. Use them separately or together.

## Choose a starting point

Choose one track. You do not need to complete the others first.
**Not sure? Start with Serving** to see Knative run a container without writing code.

- **[Serving](getting-started/first-service.md): run an HTTP container.**
  Deploy a service, watch it scale to zero, and split traffic between revisions.
  Uses a local learning cluster.
- **[Functions](getting-started/about-knative-functions.md): start from code.**
  Create and change a Go function, then run and test it locally.
  Needs Docker and the Functions CLI, but no cluster or registry account.
- **[Eventing](getting-started/getting-started-eventing.md): connect applications with events.**
  Send an event through a Broker and deliver it using a Trigger.
  Uses a local learning cluster.

For Serving and Eventing, [set up a learning cluster](getting-started/quickstart-install.md)
first. Both tracks use the same environment, so set it up only once. Functions
needs a cluster only if you choose its optional deployment lesson.

The setup is for experimentation, not production. To install Knative on a cluster
you manage, use [Install and Manage](admin/admin-overview.md).

<!-- Preserve fragments from the previous documentation home. -->
<span id="knative-technical-overview"></span><span id="what-is-knative"></span><span id="problems-knative-solves"></span><span id="background-knowledge"></span><span id="architecture-overview"></span>
<span id="system-integration-and-interoperability"></span><span id="how-components-work-together"></span><span id="integration-with-kubernetes-ecosystem"></span><span id="use-cases-and-when-to-choose-knative"></span><span id="ideal-use-cases"></span><span id="evaluation-criteria"></span>
<span id="knative-functions"></span><span id="functions-development-model"></span><span id="supported-languages-and-runtimes"></span><span id="function-deployment-and-lifecycle"></span>
<span id="knative-serving"></span><span id="key-serving-features"></span><span id="request-flow-in-serving"></span><span id="gpu-resources-and-llm-inference"></span>
<span id="knative-eventing"></span><span id="key-eventing-concepts"></span><span id="event-flow-in-eventing"></span><span id="eventing-use-cases"></span>
<span id="try-knative"></span><span id="already-have-a-goal"></span>

## Understand Knative

The [technical overview](overview.md) explains the components and how they fit
together. It is optional background, not required reading before the tutorials.

<span id="next-steps"></span><span id="keep-exploring"></span>

## After your first track

[Continue learning](getting-started/next-steps.md) to try another component, find
guides for your own projects, or clean up your environment when you are done.
Keep your learning cluster if you want to use it for another track.

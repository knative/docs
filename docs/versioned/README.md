---
audience: developer
components:
  - eventing
  - functions
  - serving
hide_next: true
hide:
  - toc
---

# Get started with Knative

Knative helps you build and run serverless applications on Kubernetes.
Choose a hands-on tutorial, learn how the components fit together, or find a
guide for the work you need to do.

<span id="choose-a-starting-point"></span>

<div class="grid cards" markdown>

-   ## Try Knative

    Get hands-on with a guided example. **New to Knative? Start with Serving.**

    - [Run your first container](getting-started/first-service.md) with Serving.
    - [Write and run a function](getting-started/about-knative-functions.md) with Functions.
    - [Send and receive an event](getting-started/getting-started-eventing.md) with Eventing.
    - [Set up a learning cluster](getting-started/quickstart-install.md) for Serving and Eventing.

    Choose one track; you do not need to complete the others first.
    Functions starts locally, without a cluster or registry account.

-   ## Understand Knative

    Learn what the components do, how they work, and how they fit together.

    - [Knative technical overview](overview.md).
    - [Serving architecture](serving/architecture.md).
    - [Functions development model](overview.md#functions-development-model).
    - [Eventing concepts](eventing/concepts/event-mesh.md).

-   ## Build with Knative

    Follow task guides for an application or project you already have.

    - [Deploy an existing container](serving/services/creating-services.md).
    - [Build and deploy functions](functions/deploying-functions.md).
    - [Route events to your application](eventing/triggers/README.md).
    - [Troubleshoot an application](serving/troubleshooting/debugging-application-issues.md).

-   ## Install and manage Knative

    Set up and operate Knative on a cluster you manage.

    - [Choose an installation method](install/README.md).
    - [Configure Knative](admin/editing-configmaps.md).
    - [Upgrade an installation](install/upgrade/README.md).
    - [Troubleshoot an installation](install/troubleshooting.md).

</div>

## Looking something up?

[CLI documentation](client/README.md) ·
[Serving API](serving/reference/serving-api.md) ·
[Eventing API](eventing/reference/eventing-api.md) ·
[Code samples](samples/README.md)

<span id="after-your-first-track"></span>

Finished a tutorial? [Continue learning](getting-started/next-steps.md) to try
another component, work on your own project, or clean up your environment.

<!-- Preserve fragments from the previous documentation home. -->
<span id="knative-technical-overview"></span><span id="what-is-knative"></span><span id="problems-knative-solves"></span><span id="background-knowledge"></span><span id="architecture-overview"></span>
<span id="system-integration-and-interoperability"></span><span id="how-components-work-together"></span><span id="integration-with-kubernetes-ecosystem"></span><span id="use-cases-and-when-to-choose-knative"></span><span id="ideal-use-cases"></span><span id="evaluation-criteria"></span>
<span id="knative-functions"></span><span id="functions-development-model"></span><span id="supported-languages-and-runtimes"></span><span id="function-deployment-and-lifecycle"></span>
<span id="knative-serving"></span><span id="key-serving-features"></span><span id="request-flow-in-serving"></span><span id="gpu-resources-and-llm-inference"></span>
<span id="knative-eventing"></span><span id="key-eventing-concepts"></span><span id="event-flow-in-eventing"></span><span id="eventing-use-cases"></span>
<span id="already-have-a-goal"></span><span id="next-steps"></span><span id="keep-exploring"></span>

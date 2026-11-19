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

<div class="knative-docs-home" markdown>

<section class="knative-docs-panel knative-docs-panel--try" aria-labelledby="try-knative" markdown>

## Try Knative

Choose a hands-on tutorial. **Not sure where to begin? Start with Serving.**
You do not need to complete the other tracks first.

<div class="knative-docs-tracks" markdown>

<section class="knative-docs-track knative-docs-track--serving" aria-labelledby="try-serving" markdown>

### Serving { #try-serving }

Run an HTTP container, watch it scale to zero, and split traffic between revisions.

Learning cluster required.
{ .knative-docs-track__requirement }

[Start Serving →](getting-started/first-service.md){ .knative-docs-track__link }

</section>

<section class="knative-docs-track knative-docs-track--functions" aria-labelledby="try-functions" markdown>

### Functions { #try-functions }

Create, change, and run a Go function locally. No Dockerfile needed.

No cluster or registry account required.
{ .knative-docs-track__requirement }

[Start Functions →](getting-started/about-knative-functions.md){ .knative-docs-track__link }

</section>

<section class="knative-docs-track knative-docs-track--eventing" aria-labelledby="try-eventing" markdown>

### Eventing { #try-eventing }

Send and receive an event using a Broker and Trigger, then try filtering by type.

Learning cluster required.
{ .knative-docs-track__requirement }

[Start Eventing →](getting-started/getting-started-eventing.md){ .knative-docs-track__link }

</section>

</div>

[Set up a learning cluster](getting-started/quickstart-install.md) once for Serving
and Eventing. Functions starts locally, without a cluster.

</section>

<section class="knative-docs-panel" aria-labelledby="understand-knative" markdown>

## Understand Knative

Learn what the components do and how they fit together.

- [Technical overview](overview.md)
- [Serving architecture](serving/architecture.md)
- [Functions development model](overview.md#functions-development-model)
- [Eventing concepts](eventing/concepts/event-mesh.md)

</section>

<section class="knative-docs-panel" aria-labelledby="build-with-knative" markdown>

## Build with Knative

Follow task guides for a project you already have.

- [Deploy a container](serving/services/creating-services.md)
- [Build and deploy functions](functions/deploying-functions.md)
- [Route events](eventing/triggers/README.md)
- [Troubleshoot an application](serving/troubleshooting/debugging-application-issues.md)

</section>

<section class="knative-docs-panel" aria-labelledby="install-and-manage-knative" markdown>

## Install and manage { #install-and-manage-knative }

Set up and operate Knative on your own cluster.

- [Choose an installation method](install/README.md)
- [Configure Knative](admin/editing-configmaps.md)
- [Upgrade an installation](install/upgrade/README.md)
- [Troubleshoot an installation](install/troubleshooting.md)

</section>

</div>

<section class="knative-docs-reference" aria-labelledby="looking-something-up" markdown>

## Looking something up?

[CLI documentation](client/README.md) ·
[Serving API](serving/reference/serving-api.md) ·
[Eventing API](eventing/reference/eventing-api.md) ·
[Code samples](samples/README.md)

</section>

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

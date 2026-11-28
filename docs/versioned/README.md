---
title: Get started with Knative
audience: developer
components:
  - eventing
  - functions
  - serving
hide_next: true
hide:
  - toc
---

<span id="knative-documentation"></span>

# Get started with Knative

Knative extends Kubernetes to build, deploy, and manage serverless workloads.
Its three components — **Serving**, **Functions**, and **Eventing** — can be
used independently or together.

<span id="choose-a-starting-point"></span><span id="try-knative"></span>

<div class="knative-docs-tracks" markdown>

<section class="knative-docs-track knative-docs-track--serving" aria-labelledby="try-serving" markdown>

### [Try Serving →](getting-started/first-service.md){ .knative-docs-track__link } { #try-serving }

Deploy a container, observe autoscaling, and split traffic. Recommended first.

</section>

<section class="knative-docs-track knative-docs-track--functions" aria-labelledby="try-functions" markdown>

### [Try Functions →](getting-started/about-knative-functions.md){ .knative-docs-track__link } { #try-functions }

Create, change, and test a Go function locally.

</section>

<section class="knative-docs-track knative-docs-track--eventing" aria-labelledby="try-eventing" markdown>

### [Try Eventing →](getting-started/getting-started-eventing.md){ .knative-docs-track__link } { #try-eventing }

Send an event through a Broker and observe delivery.

</section>

</div>

## Why Knative?

- **Simpler application deployment:** Define a Knative Service instead of wiring
  Deployments, Services, Ingress, and autoscalers by hand.
- **Scale to zero and back:** Automatically scale pods from zero to match demand
  and split traffic across immutable Revisions.
- **Loosely coupled events:** Route CloudEvents over HTTP between producers and
  consumers without hard-coding endpoints into application code.
- **Code-to-container workflow:** Build, run, and test stateless functions
  locally without writing Dockerfiles or Kubernetes manifests first.
- **Portable across Kubernetes:** Run on any Kubernetes cluster — cloud or
  on-premises — without vendor lock-in.

## When to use Knative

Knative is a strong fit for stateless HTTP APIs, event-driven pipelines,
microservices, AI/ML inference (directly or with
[KServe](https://kserve.github.io)), and on-demand development
environments. Consider alternatives if your workloads require sub-100ms cold
starts, persistent in-process state, or long-running stateful processes.

<section class="knative-docs-reference" aria-label="Additional documentation" markdown>

- [Technical overview](overview.md) — Serving, Eventing, and Functions internals and Kubernetes ecosystem integration.
- [Install and Manage](admin/admin-overview.md) — install and operate Knative on your own cluster.
- [Next steps and cleanup](getting-started/next-steps.md) — continue after a tutorial or clean up.

</section>

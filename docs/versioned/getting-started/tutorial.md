---
audience: developer
components:
  - functions
  - serving
  - eventing
---

<span id="welcome-to-the-knative-tutorials"></span>

# Learn Knative with tutorials

<span id="getting-started-with-knative"></span>

## First encounter: Quickstart

Start with the [Knative Quickstart](README.md). On a disposable local kind cluster, deploy a Service, observe autoscaling, split traffic, and send and receive events. Follow one CLI-based route; the tutorial provides explicit Previous and Next links.

You need Docker, kind, kubectl, curl, and at least 3 CPUs and 3 GB of RAM available for the cluster. The [installation lesson](quickstart-install.md) includes `kn` and plugin setup.

[Start Quickstart :octicons-arrow-right-24:](README.md){ .md-button .md-button--primary }

<span id="knative-bookstore-end-to-end-sample-application"></span>

## After the basics: Bookstore

Once you have completed Quickstart's Serving and Eventing lessons, try the [Bookstore tutorial](../bookstore/page-0/welcome-knative-bookstore-tutorial.md). Submit a review, observe its CloudEvent, run two processing functions in a Sequence, and display accepted reviews with sentiment labels.

Bookstore adds Kubernetes Deployments, a PostgreSQL StatefulSet, LoadBalancer access, and function builds with a container registry. Slack and Apache Camel K are **optional extensions**, not prerequisites for the core outcome. This is an educational sample, not production-application guidance; see its [disclaimer and acknowledgments](../bookstore/disclaimer/README.md).

[Continue to Bookstore :octicons-arrow-right-24:](../bookstore/page-0/welcome-knative-bookstore-tutorial.md){ .md-button }

<span id="a-smaller-follow-on-functions"></span>

## A smaller local-first exercise: Functions

To write a Go HTTP function rather than a multi-service sample, follow the [Functions introduction and exercise](about-knative-functions.md). Edit its handler and recognize the response from a local containerized run. You can start without Quickstart, Kubernetes, or a registry account; have a Docker-compatible daemon and a text editor available. Deployment is optional and adds registry and cluster prerequisites.

## Not sure where to start?

Choose [Quickstart](README.md) for your first hands-on encounter, [Functions](about-knative-functions.md) for a smaller local-first exercise, or [Bookstore](../bookstore/page-0/welcome-knative-bookstore-tutorial.md) after the Serving and Eventing basics. For managing a real installation rather than learning on a disposable cluster, use the [installation guides](../install/README.md).

## Prerequisites

Check [Quickstart's installation prerequisites](quickstart-install.md#before-you-begin) or [Bookstore's additional prerequisites](../bookstore/page-0/welcome-knative-bookstore-tutorial.md#before-you-begin) before starting. For Functions, the [local-run lesson](build-run-deploy-func.md#running-a-function) separates local requirements from [optional registry deployment](build-run-deploy-func.md#deploying-a-function).

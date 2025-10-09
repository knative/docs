---
audience: administrator
components:
  - serving
  - eventing
function: reference
---
# Overview

This page provides guidance for administrators on how to install and manage Knative on an existing Kubernetes cluster. It assumes you are familiar with the following:

- Kubernetes and Kubernetes administration.
- The `kubectl` CLI tool. You can use existing Kubernetes management tools (policy, quota, etc) to manage Knative workloads.
- Cloud Native Computing Foundation (CNCF) projects such as Prometheus, Istio, and Strimzi, many of which can be used alongside Knative.
- You should have cluster-admin permissions or equivalent to to install software and manage resources in all clusters in the namespace. For information about permissions, see [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/AC)

To simplify Knative installation and administration, you can use the Knative operator and the Knative CLI tool, but they are not required. Essentially, Knative aims to extend Kubernetes, and build on existing capabilities where feasible.

Knative has three components, Eventing, Serving, and Functions. Severing and Eventing are installed into clusters, but not Functions. Functions does not require installation.

Serving and Eventing support multiple underlying transports plugins within the same cluster. Serving supports pods with pluggable network ingress routes, and Eventing supports pods with pluggable message transports (e.g. Kafka, RabbitMQ).

Knative has default lightweight messaging implementation if you don't already have a solution.

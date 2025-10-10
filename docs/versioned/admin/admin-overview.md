---
audience: administrator
components:
  - serving
  - eventing
function: reference
---
# Overview

This page provides guidance for administrators on how to manage Knative on an existing Kubernetes cluster.

## The Knative model

Each application or developer team is assigned a namespace. Developers generally have the ability to create / edit resources within that namespace.

Namespaces should generally act as independent units. This can be enforced with tools like RBAC, quota, and policy.
Without substantial Kubernetes planning, namespaces are a soft isolation boundary between teams. See the threat model for more details about security between users on the same cluster.

Developers often need access to additional resources related to their namespace in other services, such as observability (logs, metrics, tracing) and dashboards (e.g. Grafana / Backstage). It's expected that the administrator will provision this access alongside creating the namespace and assigning permissions.

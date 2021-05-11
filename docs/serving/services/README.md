---
title: "Knative services"
weight: 02
type: "docs"
---

# Knative services

Knative services are used to deploy an application. Each Knative service is defined by a route and a configuration, which have the same name as the service. The configuration and route are created by the service controller, and their configuration is derived from the configuration of the service. Each time the configuration is updated, a new revision is created. Revisions are immutable snapshots of a particular configuration, and use underlying Kubernetes resources to scale the number of pods based on traffic.

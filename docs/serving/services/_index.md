---
title: "Knative services"
weight: 02
type: "docs"
---

Knative services are used to deploy an application. Each Knative service is defined by a route and a configuration, which have the same name as the service, and are contained in a YAML file. Each time the configuration is updated, a new revision is created. Revisions are each backed by a deployment with two [Kubernetes Services](../knative-kubernetes-services).  

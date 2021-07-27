---
title: "Autoscaling"
linkTitle: "Autoscaling"
weight: 20
type: "docs"
aliases:
    - /docs/serving/configuring-autoscaling/
---

# Autoscaling

One of the main features of Knative is automatic scaling of replicas for an application to closely match incoming demand, including scaling applications to zero if no traffic is being received.
Knative Serving enables this by default, using the Knative Pod Autoscaler (KPA).
The Autoscaler component watches traffic flow to the application, and scales replicas up or down based on configured metrics.

Knative services default to using autoscaling settings that are suitable for the majority of use cases. However, some workloads may require a custom, more finely-tuned configuration.
This guide provides information about configuration options that you can modify to fit the requirements of your workload.

For more information about how autoscaling for Knative works, see the [Autoscaling concepts](./autoscaling-concepts) documentation.

For more information about which metrics can be used to control the Autoscaler, see the [metrics](./autoscaling-metrics) documentation.

## Optional autoscaling configuration tasks

* Configure your Knative deployment to use the Kubernetes Horizontal Pod Autoscaler (HPA)
instead of the default KPA.
For how to install HPA, see [Install optional Serving extensions](../../install/install-extensions#install-optional-serving-extensions).
* Disable scale to zero functionality for your cluster ([global configuration only](./scale-to-zero)).
* Configure the [type of metrics](./autoscaling-metrics) your Autoscaler consumes.
* Configure [concurrency limits](./concurrency) for applications.
* Try out the [Go Autoscale Sample App](./autoscale-go/).

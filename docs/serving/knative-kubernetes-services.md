---
title: "Knative Kubernetes Services"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 9
type: "docs"
---

This document describes what is running when running knative serving.

After applying the serving yaml, this will install a few knative services and
deployments on your kubernetes cluster. This document provides an overview of
the deployments and the motivations for each one.

```sh
$ kubectl get services -n knative-serving

NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
activator-service   ClusterIP   10.96.61.11      <none>        80/TCP,81/TCP,9090/TCP   1h
autoscaler          ClusterIP   10.104.217.223   <none>        8080/TCP,9090/TCP        1h
controller          ClusterIP   10.101.39.220    <none>        9090/TCP                 1h
webhook             ClusterIP   10.107.144.50    <none>        443/TCP                  1h
```

```sh
$ kubectl get deployments -n knative-serving

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
activator                1         1         1            1           1h
autoscaler               1         1         1            1           1h
controller               1         1         1            1           1h
networking-certmanager   1         1         1            1           1h
networking-istio         1         1         1            1           1h
webhook                  1         1         1            1           1h
```

## Service: activator

The responsibilities of the activator are:

- Receiving & buffering requests for inactive Revisions.
- Reporting metrics to the autoscaler.
- Retrying requests to a Revision after the autoscaler scales such Revision
  based on the reported metrics.

## Service: autoscaler

The autoscaler receives request metrics and adjusts the number of pods required
to handle the load of traffic.

## Service: controller

The controller service reconciles all the public knative objects and autoscaling
CRDs. When a user applies a knative service to the kubernetes api, this creates
the config and route. It will convert config into revisions. It will convert
Revision into Deployment and KPA.

## Service: webhook

The webhook intercepts all kubernetes api calls, all crd insertions and updates.
It does two things:

1. Set default values
2. Rejects inconsitent and invalid objects.

It validates and mutates k8s api calls.

## Deployment: networking-certmanager

The certmanager reconciles cluster ingress into cert manager objects.

## Deployment: networking-istio

This reconciles cluster ingress into a virtual service.

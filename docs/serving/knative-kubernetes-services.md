# Kubernetes services

This guide describes the
[Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
that are active when running Knative Serving.

## Before You Begin

1. This guide assumes that you have [installed Knative Serving](../install/yaml-install/serving/install-serving-with-yaml.md).
2. Verify that you have the proper components in your cluster. To view the
   services installed in your cluster, use the command:

     ```bash
     $ kubectl get services -n knative-serving
     ```

     This returns an output similar to the following:

     ```sh
     NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
     activator-service   ClusterIP   10.96.61.11      <none>        80/TCP,81/TCP,9090/TCP   1h
     autoscaler          ClusterIP   10.104.217.223   <none>        8080/TCP,9090/TCP        1h
     controller          ClusterIP   10.101.39.220    <none>        9090/TCP                 1h
     webhook             ClusterIP   10.107.144.50    <none>        443/TCP                  1h
     ```

3. To view the deployments in your cluster, use the following command:

     ```bash
     $ kubectl get deployments -n knative-serving
     ```

      This returns an output similar to the following:

     ```{ .bash .no-copy }
     NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
     activator                    1         1         1            1           1h
     autoscaler                   1         1         1            1           1h
     controller                   1         1         1            1           1h
     net-certmanager-controller   1         1         1            1           1h
     net-istio-controller         1         1         1            1           1h
     webhook                      1         1         1            1           1h
     ```

These services and deployments are installed by the `serving.yaml` file during
install. The next section describes their function.

## Components

### Service: activator

The activator is responsible for receiving & buffering requests for inactive
revisions and reporting metrics to the autoscaler. It also retries requests to a
revision after the autoscaler scales the revision based on the reported metrics.

### Service: autoscaler

The autoscaler receives request metrics and adjusts the number of pods required
to handle the load of traffic.

### Service: controller

The controller service reconciles all the public Knative objects and autoscaling
CRDs. When a user applies a Knative service to the Kubernetes API, this creates
the configuration and route. It will convert the configuration into revisions
and the revisions into deployments and Knative Pod Autoscalers (KPAs).

### Service: webhook

The webhook intercepts all Kubernetes API calls as well as all CRD insertions
and updates. It sets default values, rejects inconsistent and invalid objects,
and validates and mutates Kubernetes API calls.

### Deployment: net-certmanager-controller

The certmanager reconciles cluster ingresses into cert manager objects.

### Deployment: net-istio-controller

The net-istio-controller deployment reconciles a cluster's ingress into an
[Istio virtual service](https://istio.io/docs/reference/config/networking/v1alpha3/virtual-service/).

## What's Next

- For a deeper look at the services and deployments involved in Knative Serving,
  see the [specs](https://github.com/knative/specs/blob/main/specs/serving/overview.md) repository.
- For a high-level analysis of Knative Serving, see the [Knative Serving overview](README.md).
- For hands-on tutorials, see the [Knative Serving code samples](../samples/serving.md).

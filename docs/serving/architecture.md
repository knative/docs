# Knative Serving Architecture

Knative Serving consists of several components forming the backbone of the Serverless Platform.
This page explains the high-level architecture of Knative Serving. Please also refer to [the Knative Serving Overview](./README.md) 
and [the Request Flow](./request-flow.md) for additional information.

## Diagram

![Knative Serving Architecture](images/serving-architecture.png)

## Components

| Component      | Responsibilities                                                                                                                                                                                                                                                                                                                                                 |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Activator      | The activator is part of the **data-plane**. It is responsible to queue incoming requests (if a `Knative Service` is scaled-to-zero). It communicates with the autoscaler to bring scaled-to-zero Services back up and forward the queued requests. Additional details can be found [here](https://github.com/knative/serving/blob/main/docs/scaling/SYSTEM.md). |
| Autoscaler     | The autoscaler is responsible to scale the `Knative Services` based on configuration, metrics and incoming requests.                                                                                                                                                                                                                                             |
| Controller     | It is the controller's job to manage the state of `Knative Resources` within the cluster. It watches several objects, manages the live cycle of dependent resources, and updates the resource state.                                                                                                                                                             |
| Queue-Proxy    | The Queue-Proxy lives as a `sidecar-container` aside from the `user-container` in a `Knative-Service`. It is responsible to collect metrics and making sure, requests are sent to the `user-container` in the configured rate. It can also act as a queue if necessary, similar to the Activator.                                                                |
| Webhooks       | Knative Serving has several webhooks responsible to validate and mutate `Knative Resources`.                                                                                                                                                                                                                                                                     |
| Domain-Mapping | The domain-mapping controller is responsible to manage `DomainMapping` resources. It is an extension of the above `Controller`. It currently is in alpha state and the installation is optional.                                                                                                                                                                 |

## Networking Layer and Ingress

!!! note
    `Ingress` in this case, does not refer to the [Kubernetes Ingress Resource](https://kubernetes.io/docs/concepts/services-networking/ingress/). It refers to the concept of exposing external access to a resource on the cluster. 
    
Knative Serving depends on a `Networking Layer` that fulfils the [Knative Networking Specification](https://github.com/knative/networking). 
For this, Knative Serving defines the `KIngress` resource, which acts as an abstraction for different multiple pluggable networking layers. Currently, three networking layers are available and supported:

* [net-kourier](https://github.com/knative-sandbox/net-kourier)
* [net-contour](https://github.com/knative-sandbox/net-contour)
* [net-istio](https://github.com/knative-sandbox/net-istio)


## Traffic flow and DNS

!!! note
    There are fine differences between the different `Networking Layers`, the following section describes the general concept. Also, there are multiple ways to expose your `Ingress Gateway` and configure DNS. Please refer the installation documentation for more information.

![Knative Serving Architecture Ingress](images/serving-architecture-ingress.png)

* Typically, each `Networking Layer` has a `controller` that is responsible to watch the `KIngress` resources and configure the `Ingress Gateway` accordingly. It will also report back `status` information to the `KIngress` resource.
* The `Ingress Gateway` is used to route requests to the `activator` or directly to the `Knative Service`, depending on the mode (proxy/serve, see [here](https://github.com/knative/serving/blob/main/docs/scaling/SYSTEM.md) for more details). The ingress gateway is handling requests  from inside the cluster and from outside the cluster.
* For the `Ingress Gateway` to be reachable outside the cluster, it must be [exposed](https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/). This is typically achieved with a Kubernetes Service of `type: LoadBalancer` or `type: NodePort` for the `Ingress Gateway`. Then [DNS](../install/yaml-install/serving/install-serving-with-yaml.md#configure-dns) is configured to point to the `IP` or `Name` of the `Ingress Gateway`.

!!! note
    Please note, if you do use/set DNS, you should also set the [same domain](./using-a-custom-domain.md) for Knative.


## Autoscaling

You can find more detailed information on our autoscaling mechanism [here](https://github.com/knative/serving/tree/main/docs/scaling).

Following examples include a simple web app written in the language of your choice that you can use to test knative eventing. It shows how to consume a [CloudEvent](https://cloudevents.io/) in Knative eventing, and optionally how to respond back with another CloudEvent in the http response.

We will deploy the app as a [Knative Serving Service](../../../../serving/README.md). However, you can also deploy the app as a [K8s Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) along with a [K8s Service](https://kubernetes.io/docs/concepts/services-networking/service/).

## Prerequisites

- A Kubernetes cluster with [Knative Serving](../../../../install/README.md) and [Knative Eventing](../../../getting-started.md#installing-knative-eventing) installed.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

# Knative Eventing - Hello World app

Following examples include a simple web app written in the language of your choice that you can
use to test knative eventing. It shows how to consume a [CloudEvent](https://cloudevents.io/)
in Knative eventing, and optionally how to respond back with another CloudEvent in the HTTP response.

We will deploy the app as a
[Kubernetes Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
along with a
[Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/).
However, you can also deploy the app as a [Knative Serving Service](https://knative.dev/docs/serving/).

## Prerequisites

- A Kubernetes cluster with [Knative Eventing](https://knative.dev/docs/install/eventing/install-eventing-with-yaml)
  installed.
  - If you decide to deploy the app as a Knative Serving Service then you will have to install
    [Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

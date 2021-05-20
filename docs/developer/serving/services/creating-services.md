---
title: "Creating Knative services"
linkTitle: "Creating a service"
weight: 02
type: "docs"
---

# Creating Knative services

To create an application using Knative, you must create a YAML file that defines a Knative service. This YAML file specifies metadata about the application, points to the hosted image of the app and allows the service to be configured.

This guide uses the [Hello World sample app in Go](../samples/hello-world/helloworld-go) to demonstrate the structure of a Service YAML file and the basic workflow for deploying an app. These steps can be adapted for your own application if you have an image of it available on Docker Hub, Google Container Registry, or another container image registry.

The Hello World sample app works as follows:
1. Reads an environment variable `TARGET`.
2. Prints `Hello ${TARGET}!`. If `TARGET` is not defined, it will use `World` as the `TARGET`.

## Prerequisites

To create a Knative service, you will need:
* A Kubernetes cluster with [Knative Serving installed](../../install).
* [Custom domains](../using-a-custom-domain/) set up for Knative services.

### Procedure

1. Create a new file named `service.yaml` containing the following information:

    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
     name: helloworld-go
     namespace: default
    spec:
     template:
      spec:
       containers:
        - image: gcr.io/knative-samples/helloworld-go
          env:
            - name: TARGET
              value: "Go Sample v1"
    ```
    * `apiVersion`: The current Knative version.
    * `name`(metadata): The name of the application.
    * `namespace`: The namespace that the application will use.
    * `image`: The URL of the image container.
    * `name`(env): The environment variable printed out by the sample application.

    **NOTE:** If you’re deploying an image of your own app, update the name of the app and the URL of the image accordingly.

1. From the directory where the new `service.yaml` file was created, deploy the application by applying the `service.yaml` file.

    ```
    kubectl apply -f service.yaml
    ```

Now that your app has been deployed, Knative will perform the following steps:

* Create a new immutable revision for this version of the app.
* Perform network programming to create a route, ingress, service, and load balancer for your app.
* Automatically scale your pods up and down based on traffic, including to zero active pods.

## Modifying Knative services

Any changes to specifications, metadata labels, or metadata annotations for a Service must be copied to the Route and Configuration owned by that Service. The `serving.knative.dev/service` label on the Route and Configuration must also be set to the name of the Service. Any additional labels or annotations on the Route and Configuration not specified above must be removed.

The Service updates its `status` fields based on the corresponding `status` value for the owned Route and Configuration.
The Service must include conditions of`RoutesReady` and `ConfigurationsReady` in addition to the generic `Ready` condition. Other conditions can also be present.

## Next steps

* To get started with deploying a Knative application, see the [Getting Started with App Deployment](../getting-started-knative-app/) documentation.
* For more information about the Knative Service object, see the [Resource Types](https://github.com/knative/specs/blob/main/specs/serving/overview.md) documentation.

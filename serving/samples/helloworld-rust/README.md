# Hello World -Rust

A simple web app in Rust that you can use for testing.
It reads in an env variable 'TARGET' and prints "Hello World: ${TARGET}" if
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this.
* You have installed and initalized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.

## Build and deploy this sample

1. Clone this repository and navigate into the `serving/samples/helloworld-rust` directory.

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. To use container builder, execute the following gcloud command:

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-rust
    ```

1. After the build has completed, you can deploy the app into your cluster. Ensure that the container image value in `service.yaml` matches the container you build in the previous step. Apply the configuration using kubectl:

    ```shell
    kubectl apply -f service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use kubectl to list the ingress points in the cluster. You may need to wait a few seconds for the ingress point to be created, if you don't see it right away.

    ```shell
    kubectl get ing --watch

    NAME                        HOSTS                                       ADDRESS        PORTS     AGE
    helloworld-rust-ingress   helloworld-rust.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-rust.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: NOT SPECIFIED
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
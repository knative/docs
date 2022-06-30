# Creating a Service

You can create a Knative service by applying a YAML file or using the `kn service create` CLI command.

## Prerequisites

To create a Knative service, you will need:

* A Kubernetes cluster with Knative Serving installed. For more information, see [Installing Knative Serving](../../install/yaml-install/serving/install-serving-with-yaml.md).
* Optional: To use the `kn service create` command, you must [install the `kn` CLI](../../client/configure-kn.md).

## Procedure

!!! tip

    The following commands create a `helloworld-go` sample service. You can modify these commands, including the container image URL, to deploy your own application as a Knative service.

Create a sample service:

=== "Apply YAML"

    1. Create a YAML file using the following example:

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

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

=== "kn CLI"

    ```
    kn service create helloworld-go --image gcr.io/knative-samples/helloworld-go
    ```

After the service has been created, Knative performs the following tasks:

* Creates a new immutable revision for this version of the app.
* Performs network programming to create a route, ingress, service, and load balancer for your app.
* Automatically scales your pods up and down based on traffic, including to zero active pods.

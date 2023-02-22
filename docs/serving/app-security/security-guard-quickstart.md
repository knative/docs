# Security-Guard monitoring quickstart

This tutorial shows how you can use Security-Guard to protect a deployed Knative Service.

## Before you begin

Before starting the tutorial, make sure to [install Security-Guard](./security-guard-install.md)

## Creating and deploying a service

!!! tip

    The following commands create a `helloworld-go` sample Service while activating and configuring the Security-Guard extension for this Service. You can modify these commands, including changing the Security-Guard configuration for your service using either the `kn` CLI or changing the service yaml based on this example.

Create a sample securedService:

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
            metadata:
                annotations:
                  features.knative.dev/queueproxy-podinfo: enabled
                  qpoption.knative.dev/guard-activate: enable
            spec:
              containers:
                - image: gcr.io/knative-samples/helloworld-go
                  env:
                    - name: TARGET
                      value: "Secured World"
        ```

    1. Apply the YAML file by running the command:

        ```
        kubectl apply -f <filename>.yaml
        ```

        Where `<filename>` is the name of the file you created in the previous step.

=== "kn services CLI"

    Creating a service using CLI

    ```
    kn service create helloworld-go \
        --image gcr.io/knative-samples/helloworld-go \
        --env "TARGET=Secured World" \
        --annotation features.knative.dev/queueproxy-podinfo=enabled \
        --annotation qpoption.knative.dev/guard-activate=enable
    ```

=== "kn func CLI"

    Creating a function using CLI.

    Add the following `deploy.annotations` to your `func.yaml` file located in your project dir"

    ```
    deploy:
      annotations:
        features.knative.dev/queueproxy-podinfo: enabled
        qpoption.knative.dev/guard-activate: enable
    ```

    Deploy as you would deploy any other function

    ```
    kn func deploy
    ```

After the Service has been created, Guard starts monitoring the Service Pods and all Events sent to the Service.

Continue to [Security-Guard alert example](./security-guard-example-alerts.md) to test your installation

See the [Using Security-Guard section](./security-guard-about.md) to learn about managing the security of the service

## Cleanup

To remove the deployed service use:

=== "Apply YAML"

    Delete using the YAML file used to create the service by running the command:

    ```bash
    kubectl delete -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

=== "kn CLI"

    ```bash
    kn service delete helloworld-go
    ```

   To remove the Guardian of the deployed service use:

    ```bash
    kubectl delete guardians.guard.security.knative.dev helloworld-go
    ```

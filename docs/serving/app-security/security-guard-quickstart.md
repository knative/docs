# Security-Guard monitoring quickstart

This tutorial shows how you can use Security-Guard to protect a deployed Knative Service.

## Before you begin

Before starting the tutorial, make sure to [install Security-Guard](./security-guard-install.md)

## Creating and deploying a service

!!! tip

    The following commands create a `helloworld-go` sample Service while activating and configuring the `security-guard` extension for this Service. You can modify these commands, including changing the `security-guard` configuration for your service using either the `kn` CLI or changing the service yaml based on this example.

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

=== "kn CLI"

    ```
    kn service create helloworld-go \
        --image gcr.io/knative-samples/helloworld-go \
        --env "TARGET=Secured World" \
        --annotation features.knative.dev/queueproxy-podinfo=enabled \
        --annotation qpoption.knative.dev/guard-activate=enable
    ```

After the Service has been created, Guard starts monitoring the Service Pods and all Events sent to the Service.

Use [Security-Guard alert example](./security-guard-install.md) to test your installation

## Managing the security of the service

Security-Guard offers situational awareness by writing its alerts to the Service queue proxy log. You may observe the queue-proxy to see alerts.

Security alerts appear in the queue proxy log file and start with the string `SECURITY ALERT!`. The default setup of Security-Guard is to allow any request or response and learn any new pattern after reporting it. When the Service is actively serving requests, it typically takes about 30 min for Security-Guard to learn the patterns of the Service requests and responses and build corresponding micro-rules. After the initial learning period, Security-Guard updates the micro-rules in the Service Guardian, following which, it sends alerts only when a change in behavior is detected.

Note that in the default setup, Security-Guard continues to learn any new behavior and therefore avoids reporting alerts repeatedly when the new behavior reoccurs. Correct security procedures should include reviewing any new behavior detected by Security-Guard.

Security-Guard can also be configured to operate in other modes of operation, such as:

* Move from auto learning to manual micro-rules management after the initial learning period
* Block requests/responses when they do not conform to the micro-rules

For more information or for troubleshooting help, see the [#security](https://knative.slack.com/archives/CBYV1E0TG) channel in Knative Slack.

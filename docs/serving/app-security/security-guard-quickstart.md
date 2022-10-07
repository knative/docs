# Security-Guard Monitoring Quickstart

Before starting the tutorial, learn [about Security-Guard](./security-guard-about.md)

In this tutorial, deploy a Hello World service and protect it with Guard.

## Before you begin

Using Guard requires that your cluster will use an enhanced queue-proxy image.
In addition, Guard include automation for auto-learning a per service Guardian. Auto-learning requires you to deploy a guard-service on your kubernetes cluster.

To start this tutorial, after installing Knative Serving, run the following procedure to replace your queue-proxy image and deploy a guard-service in the current namespace.

=== "Install from source"

    1. Clone the security-guard repository using `git clone git@github.com:knative-sandbox/security-guard.git`

    1. Do `cd security-guard`

    1. Run `ko apply -Rf ./config`

=== "Install from released images"

    Use released images to update your system to enable Guard:

    1. Change in config-features the feature named 'queueproxy.mount-podinfo' to `allowed`
       for example if you are not using an operator, you may update config-features directly using
        `kubectl edit ConfigMaps -n knative-serving config-features` as follows:

        ```
        apiVersion: v1
        kind: ConfigMap
        ...
        data:
            queueproxy.mount-podinfo: allowed
        ```

        If you are not using an operator, you may use the following command to update the config-deployment ConfigMap:
        ```
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/main/deploy/config-features.yaml`
        ```

    1. Replace the queue-sidecar-image with `ghcr.io/knative.dev/security-guard/guard-service`
       for example if you are not using an operator, you may use the following command to update the config-deployment ConfigMap:
        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.1.0/queue-proxy.yaml`
        ```

    1. Add the necessary Guard resources to your cluster using:

        ```
        kubectl apply -Rf https://raw.githubusercontent.com/knative-sandbox/security-guard/main/config/resources/gateAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/main/config/resources/serviceAccount.yaml
        kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/security-guard/main/config/resources/guardiansCrd.yaml
        ```

    1. Deploy the gate-service on your system to enable automated learning of micro-rules.

        ```
        kubectl apply -f https://github.com/knative-sandbox/security-guard/releases/download/v0.1.0/guard-service.yaml`
        ```

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

        ```bash
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

## Managing the security of the service

Guard offers situational awareness by writing its alerts to the Service queue proxy log.

Example output:

    ```text
    [...]
    {"level":"warn","message":"SECURITY ALERT! HttpRequest: Headers: KeyVal: Known Key X-B3-Traceid: Digits: Counter out of Range: 25"}
    [...]
    ```

Security alerts appear in the guard log file and start with the string `SECURITY ALERT!`. The default setup of Guard is to allow any request or response and learn any new pattern after reporting it. When the Service is actively serving requests, it typically takes about 30 min for Guard to learn the patterns of the Service requests and responses and build corresponding micro-rules. After the initial learning period, Guard updates the micro-rules in the Service Guardian, following which, it sends alerts only when a change in behavior is detected.

Note that in the default setup, Guard continues to learn any new behavior and therefore avoids reporting alerts repeatedly when the new behavior reoccurs. Correct security procedures should include reviewing any new behavior detected by Guard.

Guard can also be configured to operate in other modes of operation, such as:

* Move from auto learning to manual micro-rules management after the initial learning period
* Block requests/responses when they do not conform to the micro-rules

For more information or for troubleshooting help, see the [#security](https://knative.slack.com/archives/CBYV1E0TG) channel in Knative Slack.

# Configuring container-freezer

When container-freezer is enabled, queue-proxy calls an endpoint API when its traffic drops to zero or scales up from zero.

Within the community-maintained endpoint API implementation container-freezer, the running process is frozen when the pod's traffic drops to zero, and resumed when the pod's traffic scales up from zero. However, users can also run their own implementation instead (for example, as a billing component to log when requests are being handled).

## Configure min-scale

To use container-freezer, the value of per-revision annotation key `autoscaling.knative.dev/min-scale` must be greater than zero.

**Example:**
=== "Per Revision"
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
            autoscaling.knative.dev/min-scale: "3"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```


## Configure the endpoint API address

Queue-proxy calls the endpoint API address when container-freezer is enabled, so you need to configure the API address.

1. Open the `config-deployment` ConfigMap by running the command:
    ```bash
    kubectl edit configmap config-deployment -n knative-serving
    ```
1. Edit the file to configure the endpoint API address, for example:
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-deployment
      namespace: knative-serving
    data:
      concurrency-state-endpoint: "http://$HOST_IP:9696"
    ```

    !!! note
        If using the community-maintained implementation, use `http://$HOST_IP:9696` as the value for `concurrency-state-endpoint`, as the community-maintained implementation is a daemonset and the appropriate value will be inserted by queue-proxy at runtime. If the user-specific endpoint API implementation is deployed a service in the cluster, use a specific service address such as `http://billing.default.svc:9696`.

## Next
* Implement your own user-specific endpoint API, and deploy it in cluster.
* Use the community-maintained [container-freezer](https://github.com/knative-sandbox/container-freezer) implementation.

# Configuring container-freezer

When container-freezer is enabled, queue-proxy calls an endpoint API when its traffic drops to zero or scales up from zero.

Within the official endpoint API implementation container-freezer, the running process is frozen when the pod's traffic drops to zero, and resumed when the pod's traffic scales up from zero. The endpoint API is a user-specific implementation. For example, you can implement it as a billing component because it knows when the requests are being handled.

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

queue-proxy calls the endpoint API address when container-freezer is enabled, so you need to configure the API address.
1. Open the `config-deployment` ConfigMap by running the command:
    ```bash
    kubectl edit configmap config-deployment -n knative-serving
    ```
2. Edit the file to configure the endpoint API address, for example:
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
        If you use `$HOST_IP`, queue-proxy inserts the appropriate value for each node because the official
implementation is a daemonset. If you implement the endpoint API as a service in the cluster, use a specific service address such as `http://billing.default.svc:9696`.

## Next
* Implement your own user-specific endpoint API, and deploy it in cluster.
* Use the official [container-freezer](https://github.com/knative-sandbox/container-freezer) implementation.

# Configuring container-freezer

When container-freezer is enabled, queue-proxy will call an endpoint API when its traffic drops to zero or scales up from zero.

Within official endpoint API implementation container-freezer, the running process will be frozen when the pod's traffic drop to zero and resumed when the pod's traffic scales up from zero. The endpoint API is user-specific implementation, we can even implement it as a billing component, because it knows when the requests are being handled.

## Configure min-scale

If we want to use container-freezer, the value of per-revision annotation key `autoscaling.knative.dev/min-scale` should be bigger than 0.

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


## Configure endpoint api address

queue-proxy will call endpoint api address when container-freezer is enabled, so we need to configure the api address if we want to use container-freezer.

The endpoint api address can be configured by:
```bash
kubectl edit configmap config-deployment -n knative-serving
```

queue-proxy will swap it as the node IP if using `$HOST_IP` in configuration, because the official implementation is a daemonset. If we implement the endpoint api as a service in the cluster, there should be a specific service address, such as `http://billing.default.svc:9696`.
**Example:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving
data:
  concurrency-state-endpoint: "http://$HOST_IP:9696"
```

## Next
* Implement your own user-specific endpoint api and deploying it in cluster.
* Using the official implementation [container-freezer](https://github.com/knative-sandbox/container-freezer).

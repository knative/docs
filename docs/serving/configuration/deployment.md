# Configure Deployment resources

The `config-deployment` ConfigMap, known as the Deployment ConfigMap, contains settings that determine how Kubernetes `Deployment` resources, which back Knative services, are configured. This ConfigMap is located in the `knative-serving` namespace.

You can view the current `config-deployment` ConfigMap by running the following command:

```bash
kubectl get configmap -n knative-serving config-deployment -oyaml
```

## Example `config-deployment` ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving
  labels:
    serving.knative.dev/release: devel
  annotations:
    knative.dev/example-checksum: "fa67b403"
data:
  # This is the Go import path for the binary that is containerized
  # and substituted here.
  queue-sidecar-image: ko://knative.dev/serving/cmd/queue
  # List of repositories for which tag to digest resolving should be skipped
  registries-skipping-tag-resolving: "kind.local,ko.local,dev.local"
  # digest-resolution-timeout is the maximum time allowed for an image's
  # digests to be resolved.
  digest-resolution-timeout: "10s"
  # progress-deadline is the duration we wait for the deployment to
  # be ready before considering it failed.
  progress-deadline: "600s"
  # queue-sidecar-cpu-request is the requests.cpu to set for the queue proxy sidecar container.
  # If omitted, a default value (currently "25m"), is used.
  queue-sidecar-cpu-request: "25m"
  # queue-sidecar-cpu-limit is the limits.cpu to set for the queue proxy sidecar container.
  # If omitted, no value is specified and the system default is used.
  queue-sidecar-cpu-limit: "1000m"
  # queue-sidecar-memory-request is the requests.memory to set for the queue proxy container.
  # If omitted, no value is specified and the system default is used.
  queue-sidecar-memory-request: "400Mi"
  # queue-sidecar-memory-limit is the limits.memory to set for the queue proxy container.
  # If omitted, no value is specified and the system default is used.
  queue-sidecar-memory-limit: "800Mi"
  # queue-sidecar-ephemeral-storage-request is the requests.ephemeral-storage to
  # set for the queue proxy sidecar container.
  # If omitted, no value is specified and the system default is used.
  queue-sidecar-ephemeral-storage-request: "512Mi"
  # queue-sidecar-ephemeral-storage-limit is the limits.ephemeral-storage to set
  # for the queue proxy sidecar container.
  # If omitted, no value is specified and the system default is used.
  queue-sidecar-ephemeral-storage-limit: "1024Mi"
  # concurrency-state-endpoint is the endpoint that queue-proxy calls when its traffic drops to zero or
  # scales up from zero.
  concurrency-state-endpoint: ""
```

## Configuring progress deadlines

Configuring progress deadline settings allows you to specify the maximum time, either in seconds or minutes, that you will wait for your Deployment to progress before the system reports back that the Deployment has failed progressing for the Knative Revision.

The default progress deadline is 600 seconds. This value is expressed as a Golang `time.Duration` string representation, and must be rounded to a second precision.

The Knative Autoscaler component scales the revision to 0, and the Knative service enters a terminal `Failed` state, if the initial scale cannot be achieved within the time limit defined by this setting.

You may want to configure this setting as a higher value if any of the following issues occur in your Knative deployment:

- It takes a long time to pull the Service image, due to the size of the image.
- It takes a long time for the Service to become `READY`, due to priming of the initial cache state.
- The cluster is relies on cluster autoscaling to allocate resources for new pods.

See the [Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds) for more information.

The following example shows a snippet of an example Deployment Config Map that sets this value to 10 minutes:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving
  labels:
    serving.knative.dev/release: devel
  annotations:
    knative.dev/example-checksum: "fa67b403"
data:
  progress-deadline: "10m"
```

## Skipping tag resolution

You can configure Knative Serving to skip tag resolution for Deployments by modifying the `registries-skipping-tag-resolving` ConfigMap setting.

The following example shows how to disable tag resolution for `registry.example.com`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving
  labels:
    serving.knative.dev/release: devel
  annotations:
    knative.dev/example-checksum: "fa67b403"
data:
  # List of repositories for which tag to digest resolving should be skipped
  registries-skipping-tag-resolving: registry.example.com
```

## Enable container-freezer service

You can configure queue-proxy to pause pods when not in use by enabling the `container-freezer` service. It calls a stand-alone service (via a user-specified endpoint) when a pod's traffic drops to zero or scales up from zero. To enable it, set `concurrency-state-endpoint` to a non-empty value. With this configuration, you can achieve some features like freezing running processes in pods or billing based on the time it takes to process the requests.

Before you configure this, you need to implement the endpoint API. The official implementation is container-freezer. You can install it by following the installation instructions in the [container-freezer README](https://github.com/knative-sandbox/container-freezer).

The following example shows how to enable the container-freezer service. When using `$HOST_IP`, the container-freezer service inserts the appropriate value for each node at runtime:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving
  labels:
    serving.knative.dev/release: devel
  annotations:
    knative.dev/example-checksum: "fa67b403"
data:
  concurrency-state-endpoint: "http://$HOST_IP:9696"
```

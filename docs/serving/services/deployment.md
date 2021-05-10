---
title: "Modifying the Deployment Config Map"
linkTitle: "Deployment Configuration"
weight: 10
type: "docs"
---

# Modifying the Deployment Config Map

The `config-deployment` ConfigMap is located in the `knative-serving` namespace.
This ConfigMap, known as the Deployment ConfigMap, contains settings that determine how Kubernetes `Deployment` resources, that back Knative services, are configured.

## Accessing the Deployment ConfigMap

To view the current Deployment ConfigMap:

```bash
kubectl get configmap -n knative-serving config-deployment -oyaml
```

## Configuring progress deadlines

Configuring progress deadline settings allows you to specify the maximum time, either in seconds or minutes, that you will wait for your Deployment to progress before the system reports back that the Deployment has failed progressing for the Knative Revision.
By default, this value is set to 120 seconds.
The value is expressed as a Go `time.Duration` string representation, but must be rounded to a second precision.

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
data:
  ...
  progressDeadline: "10m"
  ...
```

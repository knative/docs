---
title: "APIServerSource"
linkTitle: "APIServerSource"
weight: 31
type: "docs"
---

![version](https://img.shields.io/badge/API_Version-v1beta1-red?style=flat-square)

An APIServerSource brings Kubernetes API server events into Knative.

## Installation

The APIServerSource source type is enabled by default when you install Knative Eventing.

## Example

This example shows how to create an APIServerSource that listens to Kubernetes Events and
send CloudEvents to the Event Display Service.

### Creating a namespace

Create a new namespace called `apiserversource-example` by entering the following
command:

```shell
kubectl create namespace apiserversource-example
```

### Creating the Event Display Service

In this step, you create one event consumer, `event-display` to verify that
`APIServerSource` is properly working.

To deploy the `event-display` consumer to your cluster, run the following
command:

```shell
kubectl -n apiserversource-example apply -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: event-display
spec:
  replicas: 1
  selector:
    matchLabels: &labels
      app: event-display
  template:
    metadata:
      labels: *labels
    spec:
      containers:
        - name: event-display
          image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display

---

kind: Service
apiVersion: v1
metadata:
  name: event-display
spec:
  selector:
    app: event-display
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF
```

### Creating a Service Account

Create a Service Account that the `ApiServerSource` runs as. The
`ApiServerSource` watches for Kubernetes events and forwards them to the
Knative Eventing Broker.

```shell
kubectl -n apiserversource-example apply -f - << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
 name: events-sa
 namespace: apiserversource-example

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
 name: event-watcher
rules:
 - apiGroups:
     - ""
   resources:
     - events
   verbs:
     - get
     - list
     - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
 name: k8s-ra-event-watcher
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: event-watcher
subjects:
 - kind: ServiceAccount
   name: events-sa
   namespace: apiserversource-example
EOF
```

### Creating the APIServerSource

In order to receive kubernetes events, you need to create a concrete APIServerSource for the namespace.

{{< tabs name="create-source" default="YAML" >}}
{{% tab name="YAML" %}}
```shell
kubectl -n apiserversource-example apply -f - << EOF
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: testevents
 namespace: apiserversource-example
spec:
 serviceAccountName: events-sa
 mode: Resource
 resources:
   - apiVersion: v1
     kind: Event
 sink:
   ref:
     apiVersion: v1
     kind: Service
     name: event-display
EOF
```

{{< /tab >}}

{{% tab name="kn" %}}

```shell
kn source apiserver create testevents \
  --namespace apiserversource-example \
  --mode "Resource" \
  --resource "Event:v1" \
  --service-account events-sa \
  --sink  --sink http://event-display.svc.cluster.local
```

{{< /tab >}}
{{< /tabs >}}

### Creating Events

Create events by launching a pod in the default namespace. Create a `busybox`
container and immediately delete it:

```shell
kubectl -n apiserversource-example run busybox --image=busybox --restart=Never -- ls
kubectl -n apiserversource-example delete pod busybox
```

### Verify

We will verify that the Kubernetes events were sent into the Knative eventing
system by looking at our message dumper function logs.

```shell
kubectl -n apiserversource-example logs -l app=event-display --tail=100
```

You should see log lines similar to:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.apiserver.resource.update
  source: https://10.96.0.1:443
  subject: /apis/v1/namespaces/apiserversource-example/events/testevents.15dd3050eb1e6f50
  id: e0447eb7-36b5-443b-9d37-faf4fe5c62f0
  time: 2020-07-28T19:14:54.719501054Z
  datacontenttype: application/json
Extensions,
  kind: Event
  name: busybox.1626008649e617e3
  namespace: apiserversource-example
Data,
  {
    "apiVersion": "v1",
    "count": 1,
    "eventTime": null,
    "firstTimestamp": "2020-07-28T19:14:54Z",
    "involvedObject": {
      "apiVersion": "v1",
      "fieldPath": "spec.containers{busybox}",
      "kind": "Pod",
      "name": "busybox",
      "namespace": "apiserversource-example",
      "resourceVersion": "28987493",
      "uid": "1efb342a-737b-11e9-a6c5-42010a8a00ed"
    },
    "kind": "Event",
    "lastTimestamp": "2020-07-28T19:14:54Z",
    "message": "Started container",
    "metadata": {
      "creationTimestamp": "2020-07-28T19:14:54Z",
      "name": "busybox.1626008649e617e3",
      "namespace": "default",
      "resourceVersion": "506088",
    "selfLink": "/api/v1/namespaces/apiserversource-example/events/busybox.1626008649e617e3",
      "uid": "2005af47-737b-11e9-a6c5-42010a8a00ed"
    },
    "reason": "Started",
    "reportingComponent": "",
    "reportingInstance": "",
    "source": {
      "component": "kubelet",
      "host": "gke-knative-auto-cluster-default-pool-23c23c4f-xdj0"
    },
    "type": "Normal"
  }
```

### Cleanup

Delete the `apiserversource-example` namespace and all of its resources from your
cluster by entering the following command:

```shell
kubectl delete namespace apiserversource-example
```

## Reference Documentation

See the [APIServerSource specification](../../reference/eventing/#sources.knative.dev/v1beta1.APIServerSource).

## Contact

For any inquiries about this source, please reach out on to the
[Knative users group](https://groups.google.com/forum/#!forum/knative-users).

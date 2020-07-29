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
send CloudEvents to a Knative Service.

### Creating a namespace

Create a new namespace called `apiserversource-example` by entering the following
command:

```shell
kubectl create namespace apiserversource-example
```

### Create a Broker

Create the `default` Broker in the namespace:

   ```shell
   kubectl create -f - <<EOF
   apiVersion: eventing.knative.dev/v1
   kind: Broker
   metadata:
    name: default
    namespace: apiserversource-example
   EOF
   ```

### Create a Service Account

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

### Create the APIServerSource

In order to receive kubernetes events, you need to create a concrete APIServerSource for the namespace.

{{< tabs name="create-source" default="YAML" >}}
{{% tab name="YAML" %}}
```shell
kubectl -n apiserversource-example apply -f - << EOF
apiVersion: sources.knative.dev/v1beta1
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
     apiVersion: eventing.knative.dev/v1
     kind: Broker
     name: default
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
  --sink  http://broker-ingress.knative-eventing.svc.cluster.local/apiserversource-example/default
```

{{< /tab >}}
{{< /tabs >}}

### Create a Trigger

In order to check the `ApiServerSource` is fully working, we will create a
simple Knative Service that dumps incoming messages to its log and creates a
`Trigger` from the `Broker` to that Knative Service.

Create a file named `trigger.yaml` and copy the code block below into it.

```shell
kubectl -n apiserversource-example apply -f - << EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
 name: testevents-trigger
 namespace: apiserversource-example
spec:
 broker: default
 subscriber:
   ref:
     apiVersion: serving.knative.dev/v1
     kind: Service
     name: event-display

---
# This is a very simple Knative Service that writes the input request to its log.

apiVersion: serving.knative.dev/v1
kind: Service
metadata:
 name: event-display
 namespace: apiserversource-example
spec:
 template:
   spec:
     containers:
       - # This corresponds to
         # https://github.com/knative/eventing-contrib/tree/master/cmd/event_display/main.go
         image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
EOF
```

### Create Events

Create events by launching a pod in the default namespace. Create a `busybox`
container and immediately delete it:

```shell
kubectl -n apiserversource-example run busybox --image=busybox --restart=Never -- ls
kubectl -n apiserversource-example delete pod busybox
```

### Verify

We will verify that the Kubernetes events were sent into the Knative eventing
system by looking at our message dumper function logs. If you deployed the
[Trigger](#trigger), continue using this section. If not, you will need to look
downstream yourself:

```shell
kubectl -n apiserversource-example get pods
kubectl -n apiserversource-example logs -l serving.knative.dev/service=event-display -c user-container --tail=200
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
  knativearrivaltime: 2020-07-28T19:14:54.720059098Z
  knativehistory: default-kne-trigger-kn-channel.apiserversource-example.svc.cluster.local
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

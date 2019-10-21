---
title: "Kubernetes Api Server Source"
linkTitle: "Kubernetes event"
weight: 50
type: "docs"
---

Kubernetes Event Source example shows how to wire kubernetes cluster events for
consumption by a function that has been implemented as a Knative Service. The
code for the following files can be found in the
[/kubernetes-event-source/](https://github.com/knative/docs/tree/master/docs/eventing/samples/kubernetes-event-source)
directory.

## Deployment Steps

### Prerequisites

1. Setup [Knative Serving](../../../serving).
1. Setup [Knative Eventing](../../../eventing).

### Broker

1. Create the `default` Broker in your namespace. These instructions assume the
   namespace `default`, feel free to change to any other namespace you would
   like to use instead. If you use a different namespace, you will need to
   modify all the YAML files deployed in this sample to point at that namespace.

```shell
kubectl label namespace default knative-eventing-injection=enabled
```

### Service Account

1. Create a Service Account that the `ApiServerSource` runs as. The
   `ApiServerSource` watches for Kubernetes events and forwards them to the
   Knative Eventing Broker. Create a file named `serviceaccount.yaml` and copy
   the code block below into it.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: events-sa
  namespace: default

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
    namespace: default
```

If you want to re-use an existing Service Account with the appropriate
permissions, you need to modify the `serviceaccount.yaml`.

Enter the following command to create the service account from
`serviceaccount.yaml`:

```shell
kubectl apply --filename serviceaccount.yaml
```

### Create Event Source for Kubernetes Events

1. In order to receive events, you have to create a concrete Event Source for a
   specific namespace. Create a file named `k8s-events.yaml` and copy the code
   block below into it.

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ApiServerSource
metadata:
  name: testevents
  namespace: default
spec:
  serviceAccountName: events-sa
  mode: Resource
  resources:
    - apiVersion: v1
      kind: Event
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
```

If you want to consume events from a different namespace or use a different
`Service Account`, you need to modify `k8s-events.yaml` accordingly.

Enter the following command to create the event source:

```shell
kubectl apply --filename k8s-events.yaml
```

### Trigger

In order to check the `ApiServerSource` is fully working, we will create a
simple Knative Service that dumps incoming messages to its log and creates a
`Trigger` from the `Broker` to that Knative Service.

Create a file named `trigger.yaml` and copy the code block below into it.

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: testevents-trigger
  namespace: default
spec:
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
  namespace: default
spec:
  template:
    spec:
      containers:
        - # This corresponds to
          # https://github.com/knative/eventing-contrib/blob/release-0.5/cmd/event_display/main.go
          image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display@sha256:bf45b3eb1e7fc4cb63d6a5a6416cf696295484a7662e0cf9ccdf5c080542c21d
```

1. If the deployed `ApiServerSource` is pointing at a `Broker` other than
   `default`, modify `trigger.yaml` by adding `spec.broker` with the `Broker`'s
   name.

1. Deploy `trigger.yaml`.

```shell
kubectl apply --filename trigger.yaml
```

### Create Events

Create events by launching a pod in the default namespace. Create a busybox
container and immediately delete it.

```shell
kubectl run busybox --image=busybox --restart=Never -- ls
kubectl delete pod busybox
```

### Verify

We will verify that the Kubernetes events were sent into the Knative eventing
system by looking at our message dumper function logs. If you deployed the
[Trigger](#trigger), then continue using this section. If not, then you will
need to look downstream yourself.

```shell
kubectl get pods
kubectl logs -l serving.knative.dev/service=event-display -c user-container
```

You should see log lines similar to:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.3
  type: dev.knative.apiserver.resource.add
  source: https://10.96.0.1:443
  subject: /apis/v1/namespaces/default/events/busybox.15cec7980c1702d1
  id: 6ea84c37-c2b4-4687-866b-fb1b2c0fe969
  time: 2019-10-18T15:32:55.855413776Z
Data,
  {
    "apiVersion": "v1",
    "count": 1,
    "eventTime": null,
    "firstTimestamp": "2019-05-10T23:27:06Z",
    "involvedObject": {
      "apiVersion": "v1",
      "fieldPath": "spec.containers{busybox}",
      "kind": "Pod",
      "name": "busybox",
      "namespace": "default",
      "resourceVersion": "28987493",
      "uid": "1efb342a-737b-11e9-a6c5-42010a8a00ed"
    },
    "kind": "Event",
    "lastTimestamp": "2019-05-10T23:27:06Z",
    "message": "Started container",
    "metadata": {
      "creationTimestamp": "2019-05-10T23:27:06Z",
      "name": "busybox.159d7608e3a3572c",
      "namespace": "default",
      "resourceVersion": "506088",
      "selfLink": "/api/v1/namespaces/default/events/busybox.159d7608e3a3572c",
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

You can remove the `ServiceAccount`, `ClusterRoles`, `ClusterRoleBinding`,
`ApiSeverSource`, `Service` and `Trigger` via:

```shell
kubectl --namespace default delete --filename serviceaccount.yaml
kubectl --namespace default delete --filename k8s-events.yaml
kubectl --namespace default delete --filename trigger.yaml

```

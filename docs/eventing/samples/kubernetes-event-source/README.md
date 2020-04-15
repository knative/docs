---
title: "Kubernetes event using the API Server Source"
linkTitle: "Kubernetes event"
weight: 50
type: "docs"
---

This example shows how to wire
[Kubernetes cluster events](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.17/#event-v1-core),
using the API Server Source, for consumption by a function that has been
implemented as a Knative Service.

## Before you begin

1. You must have a Knative cluster running both the Serving and Eventing
   components. To learn how to install the required components, see
   [Installing Knative](../../../install).
1. You can follow the steps below to create new files, or you clone a copy from
   the repo by running:

   ```shell
   git clone -b "release-0.14" https://github.com/knative/docs knative-docs
   cd knative-docs/docs/eventing/samples/kubernetes-event-source
   ```

## Deployment Steps

### Create a Knative Service

To verify that `ApiServerSource` is working, create a simple Knative Service
that dumps incoming messages to its log.

{{< tabs name="create-service" default="By YAML" >}} {{% tab name="By YAML" %}}
Use following command to create the service from STDIN:

```shell
cat <<EOF | kubectl create -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
EOF
```

{{< /tab >}}

{{% tab name="By filename" %}} Use following command to create the service from
the `service.yaml` file:

```shell
kubectl apply --filename service.yaml
```

{{< /tab >}} {{< /tabs >}}

### Broker

These instructions assume the namespace `default`, which you can change to your
preferred namespace. If you use a different namespace, you will need to modify
all the YAML files deployed in this sample to point at that namespace.

1. Create the `default` Broker in your namespace:

   ```shell
   kubectl label namespace default knative-eventing-injection=enabled
   ```

### Service Account

1. Create a Service Account that the `ApiServerSource` runs as. The
   `ApiServerSource` watches for Kubernetes events and forwards them to the
   Knative Eventing Broker.

   {{< tabs name="create-service-account" default="By YAML" >}}
   {{% tab name="By YAML" %}} Use following command to create the service
   account from STDIN:

   ```shell
   cat <<EOF | kubectl create -f -
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
   EOF
   ```

   {{< /tab >}}

   {{% tab name="By filename" %}} Use following command to create the service
   account from the `serviceaccount.yaml` file:

   ```shell
   kubectl apply --filename serviceaccount.yaml
   ```

   If you want to re-use an existing Service Account with the appropriate
   permissions, you need to modify the `serviceaccount.yaml`.

   {{< /tab >}} {{< /tabs >}}

### Create Event Source for Kubernetes Events

In order to receive events, you have to create a concrete Event Source for a
specific namespace.

{{< tabs name="create-source" default="By YAML" >}} {{% tab name="By YAML" %}}
Use following command to create the source from STDIN:

```shell
cat <<EOF | kubectl create -f -
apiVersion: sources.knative.dev/v1alpha2
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
    ref:
      apiVersion: eventing.knative.dev/v1beta1
      kind: Broker
      name: default
EOF
```

{{< /tab >}}

{{% tab name="By filename" %}} Use following command to create the source from
the `k8s-events.yaml` file:

```shell
kubectl apply --filename k8s-events.yaml
```

{{< /tab >}} {{< /tabs >}}

If you want to consume events from a different namespace or use a different
`Service Account`, you need to modify the command or `k8s-events.yaml`
accordingly.

### Trigger

In order to check the `ApiServerSource` is fully working, we will use the
created service as the subscriber on a new `Trigger` from the `Broker`.

{{< tabs name="create-trigger" default="By YAML" >}} {{% tab name="By YAML" %}}
Use following command to create the trigger from STDIN:

```shell
cat <<EOF | kubectl create -f -
apiVersion: eventing.knative.dev/v1beta1
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
EOF
```

{{< /tab >}}

{{% tab name="By filename" %}} Use following command to create the trigger from
the `trigger.yaml` file:

```shell
kubectl apply --filename trigger.yaml
```

{{< /tab >}} {{< /tabs >}}

### Create Events

Create events by launching a pod in the default namespace. Create a `busybox`
container and immediately delete it:

```shell
kubectl run busybox --image=busybox --restart=Never -- ls
kubectl delete pod busybox
```

### Verify

We will verify that the Kubernetes events were sent into the Knative eventing
system by looking at our message dumper function logs. If you deployed the
[Trigger](#trigger), continue using this section. If not, you will need to look
downstream yourself:

```shell
kubectl get pods
kubectl logs -l serving.knative.dev/service=event-display -c user-container
```

You should see log lines similar to:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.apiserver.resource.update
  source: https://10.96.0.1:443
  subject: /apis/v1/namespaces/default/events/testevents.15dd3050eb1e6f50
  id: e0447eb7-36b5-443b-9d37-faf4fe5c62f0
  time: 2019-12-04T14:09:30.917608978Z
  datacontenttype: application/json
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
`ApiServerSource`, `Service` and `Trigger`:

{{< tabs name="delete" default="By name" >}} {{% tab name="By name" %}}

```shell
kubectl delete triggers.eventing.knative.dev testevents-trigger
kubectl delete service.serving.knative.dev event-display
kubectl delete apiserversources.sources.knative.dev testevents
kubectl delete ServiceAccount events-sa
kubectl delete ClusterRole event-watcher
kubectl delete ClusterRoleBinding k8s-ra-event-watcher
```

{{< /tab >}} {{% tab name="By filename" %}}

```shell
kubectl --namespace default delete --filename serviceaccount.yaml
kubectl --namespace default delete --filename k8s-events.yaml
kubectl --namespace default delete --filename service.yaml
kubectl --namespace default delete --filename trigger.yaml
```

{{< /tab >}}

{{< /tabs >}}

Kubernetes Event Source example shows how to wire kubernetes cluster events for
consumption by a function that has been implemented as a Knative Service.

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
   Knative Eventing Broker. If you want to re-use an existing Service Account
   with the appropriate permissions, you need to modify the
   `serviceaccount.yaml`.

```shell
kubectl apply --filename serviceaccount.yaml
```

### Create Event Source for Kubernetes Events

1. In order to receive events, you have to create a concrete Event Source for a
   specific namespace. If you want to consume events from a different namespace
   or use a different `Service Account`, you need to modify `k8s-events.yaml`
   accordingly.

```shell
kubectl apply --filename k8s-events.yaml
```

### Trigger

In order to check the `ApiServerSource` is fully working, we will create a
simple Knative Service that dumps incoming messages to its log and creates a
`Trigger` from the `Broker` to that Knative Service.

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
☁️  CloudEvent: valid ✅
Context Attributes,
  SpecVersion: 0.2
  Type: dev.knative.apiserver.resource.add
  Source: https://10.39.240.1:443
  ID: 716d4536-3b92-4fbb-98d9-14bfcf94683f
  Time: 2019-05-10T23:27:06.695575294Z
  ContentType: application/json
  Extensions:
    knativehistory: default-broker-b7k2p-channel-z7mqq.default.svc.cluster.local
    subject: /apis/v1/namespaces/default/events/busybox.159d7608e3a3572c
Transport Context,
  URI: /
  Host: auto-event-display.default.svc.cluster.local
  Method: POST
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

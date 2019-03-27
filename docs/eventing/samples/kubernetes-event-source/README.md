
Kubernetes Event Source example shows how to wire kubernetes cluster events for
consumption by a function that has been implemented as a Knative Service.

## Deployment Steps

### Prerequisites

1. Setup [Knative Serving](../../../serving).
1. Setup
   [Knative Eventing](../../../eventing).

### Broker

1. Create the `default` Broker in your namespace. These instructions assume the namespace `default`, feel free to change to any other namespace you would like to use instead. If you use a different namespace, you will need to modify all the YAML files deployed in this sample to point at that namespace.

```shell
kubectl label namespace default knative-eventing-injection=enabled
```

### Service Account

1. Create a Service Account that the `Receive Adapter` runs as. The
   `Receive Adapater` watches for Kubernetes events and forwards them to the
   Knative Eventing Broker. If you want to re-use an existing Service Account
   with the appropriate permissions, you need to modify the
   `serviceaccount.yaml`.

```shell
kubectl apply --filename serviceaccount.yaml
```

### Create Event Source for Kubernetes Events

1. In order to receive events, you have to create a concrete Event Source for a
   specific namespace. If you want to consume events from a different
   namespace or use a different `Service Account`, you need to modify the yaml
   accordingly.

```shell
kubectl apply --filename k8s-events.yaml
```

### Trigger

In order to check the `KubernetesEventSource` is fully working, we will create a
simple Knative Service that dumps incoming messages to its log and create a
`Trigger` from the `Broker` to that Knative Service.

1. If the deployed `KubernetesEventSource` is pointing at a `Broker` other than
   `default`, modify `trigger.yaml` by adding `spec.broker` with the `Broker`'s name.

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

We will verify that the kubernetes events were sent into the Knative eventing
system by looking at our message dumper function logs. If you deployed the
[Trigger](#trigger), then continue using this section. If not, then you
will need to look downstream yourself.

```shell
kubectl get pods
kubectl logs -l serving.knative.dev/service=message-dumper -c user-container
```

You should see log lines similar to:

```
{"metadata":{"name":"busybox.15644359eaa4d8e7","namespace":"default","selfLink":"/api/v1/namespaces/default/events/busybox.15644359eaa4d8e7","uid":"daf8d3ca-e10d-11e8-bf3c-42010a8a017d","resourceVersion":"7840","creationTimestamp":"2018-11-05T15:17:05Z"},"involvedObject":{"kind":"Pod","namespace":"default","name":"busybox","uid":"daf645df-e10d-11e8-bf3c-42010a8a017d","apiVersion":"v1","resourceVersion":"681388"},"reason":"Scheduled","message":"Successfully assigned busybox to gke-knative-eventing-e2e-default-pool-575bcad9-vz55","source":{"component":"default-scheduler"},"firstTimestamp":"2018-11-05T15:17:05Z","lastTimestamp":"2018-11-05T15:17:05Z","count":1,"type":"Normal","eventTime":null,"reportingComponent":"","reportingInstance":""}
Ce-Source: /apis/v1/namespaces/default/pods/busybox
{"metadata":{"name":"busybox.15644359f59f72f2","namespace":"default","selfLink":"/api/v1/namespaces/default/events/busybox.15644359f59f72f2","uid":"db14ff23-e10d-11e8-bf3c-42010a8a017d","resourceVersion":"7841","creationTimestamp":"2018-11-05T15:17:06Z"},"involvedObject":{"kind":"Pod","namespace":"default","name":"busybox","uid":"daf645df-e10d-11e8-bf3c-42010a8a017d","apiVersion":"v1","resourceVersion":"681389"},"reason":"SuccessfulMountVolume","message":"MountVolume.SetUp succeeded for volume \"default-token-pzr6x\" ","source":{"component":"kubelet","host":"gke-knative-eventing-e2e-default-pool-575bcad9-vz55"},"firstTimestamp":"2018-11-05T15:17:06Z","lastTimestamp":"2018-11-05T15:17:06Z","count":1,"type":"Normal","eventTime":null,"reportingComponent":"","reportingInstance":""}
Ce-Source: /apis/v1/namespaces/default/pods/busybox
```

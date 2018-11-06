# Kubernetes Event Source example

Kubernetes Event Source example shows how to wire kubernetes cluster events for
consumption by a function that has been implemented as a Knative Service.

## Deployment Steps

### Prerequisites

1. Setup [Knative Eventing](https://github.com/knative/docs/tree/master/eventing).
1. Install [Knative Eventing Sources](https://github.com/knative/docs/tree/master/eventing-sources).
1. Install the [in-memory `ClusterChannelProvisioner`](https://github.com/knative/eventing/tree/master/config/provisioners/in-memory-channel).
    - Note that you can skip this if you choose to use a different type of `Channel`. If so, you will need to modify `channel.yaml` before deploying it.
1. Create a `Channel`. You can use your own `Channel` or use the provided sample, which creates a channel called `testchannel`. If you use your own `Channel` with a different name, then you will need to alter other commands later.

```shell
kubectl -n default apply -f eventing/samples/kubernetes-event-source/channel.yaml
```

### Service Account

1. Create a Service Account that the `Receive Adapter` runs as. The `Receive Adapater` watches for Kubernetes events and forwards them to the Knative Eventing Framework. If you want to re-use an existing Service Account with the appropriate permissions, you need to modify the 

```shell
kubectl apply -f eventing/samples/kubernetes-event-source/serviceaccount.yaml
```


### Deploy Event Sources

1. Deploy the `KubernetesEventSource` controller as part of eventing-source's controller. This makes kubernetes events available for subscriptions.

```shell
ko apply -f config/default.yaml
```
    

### Create Event Source for Kubernetes Events

1. In order to receive events, you have to create a concrete Event Source for a specific namespace. If you are wanting to consume events from a differenet namespace or using a different `Service Account`, you need to modify the yaml accordingly.

```shell
kubectl apply -f eventing/samples/kubernetes-event-source/k8s-events.yaml
```

### Subscriber

In order to check the `KubernetesEventSource` is fully working, we will create a simple Knative Service that dumps incoming messages to its log and create a `Subscription` from the `Channel` to that Knative Service.

1. Setup [Knative Serving](https://github.com/knative/docs/tree/master/serving).
1. If the deployed `KubernetesEventSource` is pointing at a `Channel` other than `testchannel`, modify `subscriber.yaml` by replacing `testchannel` with that `Channel`'s name.
1. Deploy `subscriber.yaml`.

```shell
ko apply -f eventing/samples/kubernetes-event-source/subscription.yaml
```


### Create Events

Create events by launching a pod in the default namespace. Create a busybox container

```shell
kubectl run -i --tty busybox --image=busybox --restart=Never -- sh
```

Once the shell comes up, just exit it and kill the pod.

```shell
kubectl delete pods busybox
```


### Verify

We will verify that the kubernetes events were sent into the Knative eventing system by looking at our message dumper function logsIf you deployed the [Subscriber](#subscriber), then continue using this section. If not, then you will need to look downstream yourself.

```shell
kubectl get pods
kubectl logs message-dumper-XXXX user-container
```

You should see log lines similar to:
```
{"metadata":{"name":"busybox.15644359eaa4d8e7","namespace":"default","selfLink":"/api/v1/namespaces/default/events/busybox.15644359eaa4d8e7","uid":"daf8d3ca-e10d-11e8-bf3c-42010a8a017d","resourceVersion":"7840","creationTimestamp":"2018-11-05T15:17:05Z"},"involvedObject":{"kind":"Pod","namespace":"default","name":"busybox","uid":"daf645df-e10d-11e8-bf3c-42010a8a017d","apiVersion":"v1","resourceVersion":"681388"},"reason":"Scheduled","message":"Successfully assigned busybox to gke-knative-eventing-e2e-default-pool-575bcad9-vz55","source":{"component":"default-scheduler"},"firstTimestamp":"2018-11-05T15:17:05Z","lastTimestamp":"2018-11-05T15:17:05Z","count":1,"type":"Normal","eventTime":null,"reportingComponent":"","reportingInstance":""}
Ce-Source: /apis/v1/namespaces/default/pods/busybox
{"metadata":{"name":"busybox.15644359f59f72f2","namespace":"default","selfLink":"/api/v1/namespaces/default/events/busybox.15644359f59f72f2","uid":"db14ff23-e10d-11e8-bf3c-42010a8a017d","resourceVersion":"7841","creationTimestamp":"2018-11-05T15:17:06Z"},"involvedObject":{"kind":"Pod","namespace":"default","name":"busybox","uid":"daf645df-e10d-11e8-bf3c-42010a8a017d","apiVersion":"v1","resourceVersion":"681389"},"reason":"SuccessfulMountVolume","message":"MountVolume.SetUp succeeded for volume \"default-token-pzr6x\" ","source":{"component":"kubelet","host":"gke-knative-eventing-e2e-default-pool-575bcad9-vz55"},"firstTimestamp":"2018-11-05T15:17:06Z","lastTimestamp":"2018-11-05T15:17:06Z","count":1,"type":"Normal","eventTime":null,"reportingComponent":"","reportingInstance":""}
Ce-Source: /apis/v1/namespaces/default/pods/busybox
```



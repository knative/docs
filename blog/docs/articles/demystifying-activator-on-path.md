# Demystifying Activator on path

**Author: [Stavros Kontopoulos](https://twitter.com/s_kontopoulos), Principal Software Engineer @ RedHat**

**Date: 2023-10-11**

_In this blog post you will learn how to recognize when activator is on the data path and what it triggers that behavior._

A knative service can operate in two modes: proxy mode and serve mode.
When in proxy mode, Activator is on the data path, and it will stay on the path until certain conditions (more on this later) are met.
When these conditions are met Activator is removed from the path and the service transitions to serve mode.
However, it was not always like that when a service scales from/to zero, the activator is added by default to the data path.
This default setting often confuses users for reasons we will see next as it is possible that activator will not
be removed unless enough capacity is available. This is intended as one of the Activator's roles is to offer backpressure capabilities so that a Knative service is not overloaded by incoming traffic.


## Background

The default pod autoscaler in Knative (KPA) is a sophisticated algorithm that uses metrics from pods to
make scaling decisions. Let's see in detail what happens when a new Knative service is created.

Once the user creates a new service the corresponding Knative reconciler creates a Knative Configuration and a Knative Route for that service. Then the Configuration reconciler creates a Revision resource and
the reconciler for the latter will create a Pod Autoscaler(PA) resource along with the K8s deployment for the service.
The Route reconciler will create the ingress resource that will be picked up by the Knative net-* components responsible
for managing traffic locally in the cluster and externally to the cluster.

Now the creation of the PA earlier triggers the KPA reconciler which goes through certain steps in order to setup an autoscaling configuration for the revision:

- creates an internal Decider resource that holds the initial desired scale in `decider.Status.DesiredScale`and
sets up a pod scaler via the multi-scaler component. The pod scaler every two seconds calculates a new Scale
result and makes a decision based on the condition `decider.Status.DesiredScale != sRes.DesiredPodCount` whether to trigger a new reconciliation for the KPA reconciler. Goal is the KPA to get the latest scale result.

- creates a Metric resource that triggers the metrics collector controller to setup a scraper for the revision pods.

- calls a scale method that decides the number of wanted pods and also updates the revision deployment

- creates/updates a ServerlessService (SKS) that holds info about the operation mode (proxy or serve) and stores the activators used in proxy mode. That SKS create/update event triggers a reconciliation for the SKS from its specific controller that creates the required public and private K8s services so traffic can be routed to the K8s deployment.
This in combination with the networking setup done by the net-* components is the

- updates the PA and reports the active and wanted pods in its status

## Capacity and Operation Modes in Practice

As described earlier Activator will be removed if enough capacity is available and there is an invariant that needs to
hold, that is EBC (excess burst capacity)>0, where EBC = TotalCapacity - ObservedInPanicMode - TargetBurstCapacity(TBC).

Let's see an example of a service that has a target concurrency of 10 and tbc=10:

```
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: autoscale-go
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/target: "10"
        autoscaling.knative.dev/target-burst-capacity: "10"
    spec:
      containers:
      - image: ghcr.io/knative/autoscale-go:latest
```

Initially when the ksvc was deployed there was no traffic and one pod is created by default for verification reasons.

Until the pod is up we have:
```bash
$ kubectl get sks
NAME                 MODE    ACTIVATORS   SERVICENAME          PRIVATESERVICENAME           READY     REASON
autoscale-go-00001   Proxy   2            autoscale-go-00001   autoscale-go-00001-private   Unknown   NoHealthyBackends
```
When the pod is up we have:

```bash
$ oc get po
NAME                                             READY   STATUS    RESTARTS   AGE
autoscale-go-00001-deployment-6cc679b9d6-xgrkf   2/2     Running   0          24s

$ oc get sks
NAME                 MODE    ACTIVATORS   SERVICENAME          PRIVATESERVICENAME           READY   REASON
autoscale-go-00001   Serve   2            autoscale-go-00001   autoscale-go-00001-private   True    
```

The reason why we are in Serve mode is because EBC=0. In the logs we get:


```bash
{"severity":"DEBUG","timestamp":"2023-10-10T15:29:37.241575214Z","logger":"autoscaler","caller":"scaling/autoscaler.go:286","message":"PodCount=1 Total1PodCapacity=10.000 ObsStableValue=0.000 ObsPanicValue=0.000 TargetBC=10.000 ExcessBC=0.000","commit":"f1617ef","knative.dev/key":"default/autoscale-go-00001"}
```

EBC = 10 - 0 - 10 = 0

Note that due to the fact that there is no traffic we see no observations during panic or stable windows.

Since there is no traffic we scale back to zero and sks is back to proxy mode:

```bash
$ kubectl get sks
NAME                 MODE    ACTIVATORS   SERVICENAME          PRIVATESERVICENAME           READY     REASON
autoscale-go-00001   Proxy   2            autoscale-go-00001   autoscale-go-00001-private   Unknown   NoHealthyBackends
```

In debug mode also in the logs you can see the state that the autoscaler operates for the specific revision.
In this case we go directly to:

```
{"severity":"DEBUG","timestamp":"2023-10-10T15:29:37.241523364Z","logger":"autoscaler","caller":"scaling/autoscaler.go:247","message":"Operating in stable mode.","commit":"f1617ef","knative.dev/key":"default/autoscale-go-00001"}
```

Let's send some traffic (experiment was run on Minikube):

```bash
hey -z 600s -c 20 -q 1 -host "autoscale-go.default.example.com" "http://192.168.39.43:32718?sleep=1000"
```

Initially activator when get a request in it sends stats to the autoscaler which tries to
scale from zero based on some initial scale (default 1):

```
{"severity":"DEBUG","timestamp":"2023-10-10T15:32:56.178498172Z","logger":"autoscaler.stats-websocket-server","caller":"statserver/server.go:193","message":"Received stat message: {Key:default/autoscale-go-00001 Stat:{PodName:activator-59dff6d45c-9rdxh AverageConcurrentRequests:1 AverageProxiedConcurrentRequests:0 RequestCount:1 ProxiedRequestCount:0 ProcessUptime:0 Timestamp:0}}","commit":"f1617ef","address":":8080"}
{"severity":"DEBUG","timestamp":"2023-10-10T15:32:56.178733422Z","logger":"autoscaler","caller":"statforwarder/processor.go:64","message":"Accept stat as owner of bucket autoscaler-bucket-00-of-01","commit":"f1617ef","bucket":"autoscaler-bucket-00-of-01","knative.dev/key":"default/autoscale-go-00001"}
```

```
{"severity":"DEBUG","timestamp":"2023-10-10T15:32:56.178920551Z","logger":"autoscaler","caller":"scaling/autoscaler.go:286","message":"PodCount=0 Total1PodCapacity=10.000 ObsStableValue=1.000 ObsPanicValue=1.000 TargetBC=10.000 ExcessBC=-11.000","commit":"f1617ef","knative.dev/key":"default/autoscale-go-00001"}
```

Later on as traffic continues we get proper statistics from activator closer to the rate:

```
{"severity":"DEBUG","timestamp":"2023-10-10T15:32:56.949001622Z","logger":"autoscaler.stats-websocket-server","caller":"statserver/server.go:193","message":"Received stat message: {Key:default/autoscale-go-00001 Stat:{PodName:activator-59dff6d45c-9rdxh AverageConcurrentRequests:18.873756322609804 AverageProxiedConcurrentRequests:0 RequestCount:19 ProxiedRequestCount:0 ProcessUptime:0 Timestamp:0}}","commit":"f1617ef","address":":8080"}
```

```
{"severity":"INFO","timestamp":"2023-10-10T15:32:56.432854252Z","logger":"autoscaler","caller":"kpa/kpa.go:188","message":"Observed pod counts=kpa.podCounts{want:1, ready:0, notReady:1, pending:1, terminating:0}","commit":"f1617ef","knative.dev/controller":"knative.dev.serving.pkg.reconciler.autoscaling.kpa.Reconciler","knative.dev/kind":"autoscaling.internal.knative.dev.PodAutoscaler","knative.dev/traceid":"7988492e-eea3-4d19-bf5a-8762cf5ff8eb","knative.dev/key":"default/autoscale-go-00001"}

{"severity":"DEBUG","timestamp":"2023-10-10T15:32:57.241052566Z","logger":"autoscaler","caller":"scaling/autoscaler.go:286","message":"PodCount=0 Total1PodCapacity=10.000 ObsStableValue=19.874 ObsPanicValue=19.874 TargetBC=10.000 ExcessBC=-30.000","commit":"f1617ef","knative.dev/key":"default/autoscale-go-00001"}
```

Since the pod is not up yet: EBS = 0*10 - floor(19.874) - 10 = -30


Given the new statistics kpa decides to scale to 3 pods.

```
{"severity":"INFO","timestamp":"2023-10-10T15:32:57.241421042Z","logger":"autoscaler","caller":"kpa/scaler.go:370","message":"Scaling from 1 to 3","commit":"f1617ef","knative.dev/controller":"knative.dev.serving.pkg.reconciler.autoscaling.kpa.Reconciler","knative.dev/kind":"autoscaling.internal.knative.dev.PodAutoscaler","knative.dev/traceid":"6dcf87c9-15d8-41d3-95ae-5ca9b3d90705","knative.dev/key":"default/autoscale-go-00001"}
```

But let's see why is this so. The log above comes from the multi-scaler which reports
a scaled result that contains EBS as reported above and a desired pod count for different windows.

Roughly the final desired number is (there is more logic that covers corner
  cases and checking against min/max scale limits):

```
dspc := math.Ceil(observedStableValue / spec.TargetValue)
dppc := math.Ceil(observedPanicValue / spec.TargetValue)
```


The target value is the utilization in terms of concurrency and that is is 0.7*(revision_target).
In this case this is 7. So we have for example for the panic window: ceil(19.874/7)=3

**Note:** if RPS is used then the utilization factor is 0.75.

Later on when revision is scaled we have:

```
{"severity":"INFO","timestamp":"2023-10-10T15:33:01.320912032Z","logger":"autoscaler","caller":"kpa/kpa.go:158","message":"SKS should be in Serve mode: want = 3, ebc = 0, #act's = 2 PA Inactive? = false","commit":"f1617ef","knative.dev/controller":"knative.dev.serving.pkg.reconciler.autoscaling.kpa.Reconciler","knative.dev/kind":"autoscaling.internal.knative.dev.PodAutoscaler","knative.dev/traceid":"f0d22038-130a-4560-bd67-2751ecf3975d","knative.dev/key":"default/autoscale-go-00001"}

{"severity":"DEBUG","timestamp":"2023-10-10T15:33:03.24101879Z","logger":"autoscaler","caller":"scaling/autoscaler.go:286","message":"PodCount=3 Total1PodCapacity=10.000 ObsStableValue=16.976 ObsPanicValue=15.792 TargetBC=10.000 ExcessBC=4.000","commit":"f1617ef","knative.dev/key":"default/autoscale-go-00001"}
```

EBS = 3*10 - floor(15.792) - 10 = 4

Later on the sks transitions to Serve mode as we have enough capacity until traffic stops and deployment is scaled back to zero.

### Conclusion

It is often confusing of how and why services stuck in proxy mode or how users can manage Activator on path.
This is important especially when you just started with Knative Serving. With the detailed example above hopefully we have demystified this fundamental behavior of the Serving data plane.

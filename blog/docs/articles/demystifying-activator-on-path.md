# Demystifying Activator on path

**Author: [Stavros Kontopoulos](https://twitter.com/s_kontopoulos), Principal Software Engineer @ RedHat**

**Date: 2023-11-14**

_In this blog post you will learn how to recognize when activator is on the data path and what it triggers that behavior._

The activator acts as a component on the data path to enable traffic buffering when a service is scaled-to-zero.
One lesser known feature of activator is, that it can act as a request buffer that handles back-pressure with the goal to not overload a Knative service.
For this, a Knative service can define how much traffic it can handle using [annotations](https://knative.dev/docs/serving/autoscaling/autoscaling-targets/#configuring-targets).
The autoscaler component will use this information to calculate the amount of pods needed to handle the incoming traffic for a specific Knative service

In detail when serving traffic, a Knative service can operate in two modes: proxy mode and serve mode.
When in proxy mode, Activator is on the data path (which means the incoming requests are routed through the Activator component), and it will stay on the path until certain conditions (more on this later) are met.
When these conditions are met, Activator is removed from the data path, and the service transitions to serve mode.
For example, when a service scales from/to zero, the activator is added by default to the data path.
This default setting often confuses users for reasons we will see next as it is possible that activator will not be removed unless enough capacity is available.
This is intended as one of the Activator's roles is to offer backpressure capabilities so that a Knative service is not overloaded by incoming traffic.

## Background

The default pod autoscaler in Knative (KPA) is a sophisticated algorithm that uses metrics from pods to make scaling decisions.
Let's see in detail what happens when a new Knative service is created.

Once the user creates a new service the corresponding Knative reconciler creates a Knative `Configuration` and a Knative `Route` for that service. 
Then the Configuration reconciler creates a `Revision` resource and the reconciler for the latter will create a Pod Autoscaler(PA) resource along with the K8s deployment for the service.
The Route reconciler will create the `Ingress` resource that will be picked up by the Knative net-* components responsible for managing traffic locally in the cluster and externally to the cluster.

Now, the creation of the PA triggers the KPA reconciler which goes through certain steps in order to setup an autoscaling configuration for the revision:

- creates an internal Decider resource that holds the initial desired scale in `decider.Status.DesiredScale`and
sets up a pod scaler via the multi-scaler component. The pod scaler calculates a new Scale result every two seconds and makes a decision based on the condition `decider.Status.DesiredScale != scaledResult.DesiredPodCount` whether to trigger a new reconciliation for the KPA reconciler. Goal is the KPA to get the latest scale result.

- creates a Metric resource that triggers the metrics collector controller to setup a scraper for the revision pods.

- calls a scale method that decides the number of wanted pods and also updates the K8s raw deployment that corresponds to the revision.

- creates/updates a ServerlessService (SKS) that holds info about the operation mode (proxy or serve) and stores the number of activators that should be used in proxy mode.
  The number of activators specified in the SKS depends on the capacity that needs to be covered.

- updates the PA and reports the active and wanted pods in its status

!!! note

    The SKS create/update event above triggers a reconciliation for the SKS from its specific controller that creates the required public and private K8s services so traffic can be routed to the raw K8s deployment.
    Also in proxy mode that SKS controller will pick up the number of activators and configure an equal number of endpoints for the revision's [public service](https://github.com/knative/serving/blob/main/docs/scaling/SYSTEM.md#data-flow-examples).
    This in combination with the networking setup done by the net-* components (driven by the Ingress resource) is roughly the end-to-end networking setup that needs to happen for a ksvc to be ready to serve traffic.


## Capacity and Operation Modes in Practice

As described earlier Activator will be removed if enough capacity is available. Let's see how this capacity is calculated
but before that let's introduce two concepts: the `panic` and `stable` windows. 
The `panic` window is the time duration where we don't have enough capacity to serve the traffic. It happens usually with a sudden burst of traffic.
The condition that describes when to enter the panic mode and start the panic window is:

```
dppc/readyPodsCount >= spec.PanicThreshold
```
where
```
dppc := math.Ceil(observedPanicValue / spec.TargetValue)
```
The target value is the utilization in terms of concurrency and that is 0.7*(revision_target).
0.7 is the utilization factor for each replica and when reached we need to scale out.

**Note:** if the KPA metrics Requests Per Second(RPS) is used then the utilization factor is 0.75.

The `observedPanicValue` is the calculated average value seen during the panic window for the concurrency metric.
The panic threshold is configurable (default 2) and expresses the ratio of desired versus available pods.

After we enter panic mode in order to exit we need to have enough capacity for a period that is equal to the stable window size.

To quantify the idea of enough capacity to deal with bursts of traffic we introduce the notion of the Excess Burst Capacity(EBC) that needs to be >=0.
It is defined as:

```
EBC = TotalCapacity - ObservedPanicValue - TargetBurstCapacity(TBC).
```

Let's see an example of how these are calculated in practice. Here is a service that has a target concurrency of 10 and tbc=10:

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

The scenario we are going to demonstrate is deploye the ksvc, let it scale down to zero and then send traffic for 10 minutes.
We then collect the logs from the autoscaler and visualize the EBC, ready pods and panic mode over time.
The graphs are shown next.

![Excess burst capacity over time](/blog/articles/images/ebc.png)
![Ready pods over time](/blog/articles/images/readypods.png)
![Panic mode over time](/blog/articles/images/panic.png)


Let's describe inde tail what we see above. Initially when the ksvc is deployed there is no traffic and one pod is created by default for verification reasons.

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

The reason why we are in Serve mode is that because EBC=0. When you enable debug logs, in the logs you get:

```
  "severity": "DEBUG",
  "timestamp": "2023-10-10T15:29:37.241575214Z",
  "logger": "autoscaler",
  "caller": "scaling/autoscaler.go:286",
  "message": "PodCount=1 Total1PodCapacity=10.000 ObsStableValue=0.000 ObsPanicValue=0.000 TargetBC=10.000 ExcessBC=0.000",
  "commit": "f1617ef",
  "knative.dev/key": "default/autoscale-go-00001"
```

EBC = 10 - 0 - 10 = 0

Note that due to the fact that there is no traffic we see no observations during panic or stable windows.

Since there is no traffic we scale back to zero and sks is back to proxy mode:

```bash
$ kubectl get sks
NAME                 MODE    ACTIVATORS   SERVICENAME          PRIVATESERVICENAME           READY     REASON
autoscale-go-00001   Proxy   2            autoscale-go-00001   autoscale-go-00001-private   Unknown   NoHealthyBackends
```

Let's send some traffic (experiment was run on Minikube):

```bash
hey -z 600s -c 20 -q 1 -host "autoscale-go.default.example.com" "http://192.168.39.43:32718?sleep=1000"
```

Initially activator when get a request in it sends stats to the autoscaler which tries to scale from zero based on some initial scale (default 1):

```
  "severity": "DEBUG",
  "timestamp": "2023-10-10T15:32:56.178498172Z",
  "logger": "autoscaler.stats-websocket-server",
  "caller": "statserver/server.go:193",
  "message": "Received stat message: {Key:default/autoscale-go-00001 Stat:{PodName:activator-59dff6d45c-9rdxh AverageConcurrentRequests:1 AverageProxiedConcurrentRequests:0 RequestCount:1 ProxiedRequestCount:0 ProcessUptime:0 Timestamp:0}}",
  "commit": "f1617ef",
  "address": ":8080"

  "severity": "DEBUG",
  "timestamp": "2023-10-10T15:32:56.178733422Z",
  "logger": "autoscaler",
  "caller": "statforwarder/processor.go:64",
  "message": "Accept stat as owner of bucket autoscaler-bucket-00-of-01",
  "commit": "f1617ef",
  "bucket": "autoscaler-bucket-00-of-01",
  "knative.dev/key": "default/autoscale-go-00001"
```

The autoscaler enters panic mode since we don't have enough capacity, EBS is 10*0 -1 -10 = -11
```
  "severity": "DEBUG",
  "timestamp": "2023-10-10T15:32:56.178920551Z",
  "logger": "autoscaler",
  "caller": "scaling/autoscaler.go:286",
  "message": "PodCount=0 Total1PodCapacity=10.000 ObsStableValue=1.000 ObsPanicValue=1.000 TargetBC=10.000 ExcessBC=-11.000",
  "commit": "f1617ef",
  "knative.dev/key": "default/autoscale-go-00001"

  "severity": "INFO",
  "timestamp": "2023-10-10T15:32:57.24099875Z",
  "logger": "autoscaler",
  "caller": "scaling/autoscaler.go:215",
  "message": "PANICKING.",
  "commit": "f1617ef",
  "knative.dev/key": "default/autoscale-go-00001"

```
Later on as traffic continues we get proper statistics from activator closer to the rate:

```
   "severity":"DEBUG",
   "timestamp":"2023-10-10T15:32:56.949001622Z",
   "logger":"autoscaler.stats-websocket-server",
   "caller":"statserver/server.go:193",
   "message":"Received stat message: {Key:default/autoscale-go-00001 Stat:{PodName:activator-59dff6d45c-9rdxh AverageConcurrentRequests:18.873756322609804 AverageProxiedConcurrentRequests:0 RequestCount:19 ProxiedRequestCount:0 ProcessUptime:0 Timestamp:0}}",
   "commit":"f1617ef",
   "address":":8080"

   "severity":"INFO",
   "timestamp":"2023-10-10T15:32:56.432854252Z",
   "logger":"autoscaler",
   "caller":"kpa/kpa.go:188",
   "message":"Observed pod counts=kpa.podCounts{want:1, ready:0, notReady:1, pending:1, terminating:0}",
   "commit":"f1617ef",
   "knative.dev/controller":"knative.dev.serving.pkg.reconciler.autoscaling.kpa.Reconciler",
   "knative.dev/kind":"autoscaling.internal.knative.dev.PodAutoscaler",
   "knative.dev/traceid":"7988492e-eea3-4d19-bf5a-8762cf5ff8eb",
   "knative.dev/key":"default/autoscale-go-00001"

   "severity":"DEBUG",
   "timestamp":"2023-10-10T15:32:57.241052566Z",
   "logger":"autoscaler",
   "caller":"scaling/autoscaler.go:286",
   "message":"PodCount=0 Total1PodCapacity=10.000 ObsStableValue=19.874 ObsPanicValue=19.874 TargetBC=10.000 ExcessBC=-30.000",
   "commit":"f1617ef",
   "knative.dev/key":"default/autoscale-go-00001"
```
Since the pod is not up yet: EBS = 0*10 - floor(19.874) - 10 = -30

Given the new statistics kpa decides to scale to 3 pods at some point.

```
  "severity": "INFO",
  "timestamp": "2023-10-10T15:32:57.241421042Z",
  "logger": "autoscaler",
  "caller": "kpa/scaler.go:370",
  "message": "Scaling from 1 to 3",
  "commit": "f1617ef",
  "knative.dev/controller": "knative.dev.serving.pkg.reconciler.autoscaling.kpa.Reconciler",
  "knative.dev/kind": "autoscaling.internal.knative.dev.PodAutoscaler",
  "knative.dev/traceid": "6dcf87c9-15d8-41d3-95ae-5ca9b3d90705",
  "knative.dev/key": "default/autoscale-go-00001"
```

But let's see why is this is the case. The log above comes from the multi-scaler which reports a scaled result that contains EBS as reported above and a desired pod count for different windows.

Roughly the final desired number is (there is more logic that covers corner cases and checking against min/max scale limits)
derived from the dppc we saw earlier.

In this case the target value is 0.7*10=10. So we have for example for the panic window: dppc=ceil(19.874/7)=3

As metrics get stabilized and revision is scaled enough we have:

```
  "severity": "INFO",
  "timestamp": "2023-10-10T15:33:01.320912032Z",
  "logger": "autoscaler",
  "caller": "kpa/kpa.go:158",
  "message": "SKS should be in Serve mode: want = 3, ebc = 0, #act's = 2 PA Inactive? = false",
  "commit": "f1617ef",
  "knative.dev/controller": "knative.dev.serving.pkg.reconciler.autoscaling.kpa.Reconciler",
  "knative.dev/kind": "autoscaling.internal.knative.dev.PodAutoscaler",
  "knative.dev/traceid": "f0d22038-130a-4560-bd67-2751ecf3975d",
  "knative.dev/key": "default/autoscale-go-00001"


  "severity": "DEBUG",
  "timestamp": "2023-10-10T15:33:03.24101879Z",
  "logger": "autoscaler",
  "caller": "scaling/autoscaler.go:286",
  "message": "PodCount=3 Total1PodCapacity=10.000 ObsStableValue=16.976 ObsPanicValue=15.792 TargetBC=10.000 ExcessBC=4.000",
  "commit": "f1617ef",
  "knative.dev/key": "default/autoscale-go-00001"
```

EBS = 3*10 - floor(15.792) - 10 = 4

Then when we reach the required pod count and metrics are stable we get EBC=3*10 - floor(19.968) - 10=0:

```
  "severity": "DEBUG",
  "timestamp": "2023-10-10T15:33:59.24118625Z",
  "logger": "autoscaler",
  "caller": "scaling/autoscaler.go:286",
  "message": "PodCount=3 Total1PodCapacity=10.000 ObsStableValue=19.602 ObsPanicValue=19.968 TargetBC=10.000 ExcessBC=0.000",
  "commit": "f1617ef",
  "knative.dev/key": "default/autoscale-go-00001"
```

A few seconds later, one minute after we get in panicking mode we get to stable mode (un-panicking):

```
  "severity": "INFO",
  "timestamp": "2023-10-10T15:34:01.240916706Z",
  "logger": "autoscaler",
  "caller": "scaling/autoscaler.go:223",
  "message": "Un-panicking.",
  "commit": "f1617ef",
  "knative.dev/key": "default/autoscale-go-00001"
```

The sks also transitions to Serve mode as we have enough capacity until traffic stops and deployment is scaled back to zero (activator is removed from path).
For the experiment above since we have stable traffic for almost 10 minutes we don't observe any changes as soon as we have enough pods ready.
Note that when traffic goes down and until we adjust the pod count, for some short period of time, we have more ebc than we need.

The major events are also depected in the timeline bellow:

![timeline](/blog/articles/images/timeline.png)

### Conclusion

It is often confusing of how and why services stuck in proxy mode or how users can manage Activator on path.
This is important especially when you just started with Knative Serving. With the detailed example above hopefully we have demystified this fundamental behavior of the Serving data plane.

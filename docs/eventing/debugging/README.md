---
title: "Debugging Knative Eventing"
linkTitle: "Debugging"
weight: 100
type: "docs"
---

This is an evolving document on how to debug a non-working Knative Eventing
setup.

## Audience

This document is intended for people that are familiar with the object model of
[Knative Eventing](../README.md). You don't need to be an expert, but do need to
know roughly how things fit together.

## Version

This Debugging content supports version v0.8.0 or later of
[Knative Eventing](https://github.com/knative/eventing/releases/) and the
[Eventing-contrib resources](https://github.com/knative/eventing-contrib/releases/).

## Prerequisites

1. Setup [Knative Eventing and an Eventing-contrib resource](../README.md).

## Example

This guide uses an example consisting of an event source that sends events to a
function.

![src -> chan -> sub -> svc -> fn](ExampleModel.png)

See [example.yaml](example.yaml) for the entire YAML. For any commands in this
guide to work, you must apply [example.yaml](example.yaml):

```shell
kubectl apply --filename example.yaml
```

## Triggering Events

Knative events will occur whenever a Kubernetes
[`Event`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#event-v1-core)
occurs in the `knative-debug` namespace. We can cause this to occur with the
following commands:

```shell
kubectl --namespace knative-debug run to-be-deleted --image=image-that-doesnt-exist --restart=Never
# 5 seconds is arbitrary. We want K8s to notice that the Pod needs to be scheduled and generate at least one event.
sleep 5
kubectl --namespace knative-debug delete pod to-be-deleted
```

Then we can see the Kubernetes `Event`s (note that these are not Knative
events!):

```shell
kubectl --namespace knative-debug get events
```

This should produce output along the lines of:

```shell
LAST SEEN   FIRST SEEN   COUNT     NAME                             KIND      SUBOBJECT                        TYPE      REASON                   SOURCE                                         MESSAGE
20s         20s          1         to-be-deleted.157aadb9f376fc4e   Pod                                        Normal    Scheduled                default-scheduler                              Successfully assigned knative-debug/to-be-deleted to gke-kn24-default-pool-c12ac83b-pjf2
```

## Where are my events?

You can check if events were delivered by lokking int logs of subscribers.

```
kubectl -n knative-debug get pods
NAME                                             READY   STATUS    RESTARTS   AGE
apiserversource-src-skzlm-54c6bbdccd-w27ms       1/1     Running   0          19m
event-display-prxh4-deployment-89c744b59-kv8zt   2/2     Running   0          91s
fn-bfb44f975-2s68r                               1/1     Running   0          64m

kubectl -n knative-debug -c user-container logs event-display-prxh4-deployment-89c744b59-45d8g|less
☁️  CloudEvent: valid ✅
Context Attributes,
  SpecVersion: 0.2
  Type: dev.knative.apiserver.resource.update
  Source: https://172.21.0.1:443
  ID: ee2abbc5-1f94-4fbc-9598-531dbea9af92
  Time: 2019-06-18T13:51:19.729381233Z
  ContentType: application/json
  Extensions:
    subject: /apis/v1/namespaces/knative-debug/pods/event-display-2hqvh-deployment-6fcdbf5bd6-j6ghb
    knativehistory: chan-channel-p9wzl.knative-debug.svc.cluster.local
Transport Context,
  URI: /
  Host: event-display.knative-debug.svc.cluster.local
  Method: POST
Data,
  {
    "apiVersion": "v1",
    "kind": "Pod",
    "metadata": {
      "annotations": {
        "kubernetes.io/psp": "ibm-privileged-psp",
        "sidecar.istio.io/inject": "true",
        "traffic.sidecar.istio.io/includeOutboundIPRanges": "172.30.0.0/16,172.20.0.0/16,10.10.10.0/24"
      },
      "creationTimestamp": "2019-06-18T13:49:34Z",
      "deletionGracePeriodSeconds": 300,
      "deletionTimestamp": "2019-06-18T13:56:19Z",
      "generateName": "event-display-2hqvh-deployment-6fcdbf5bd6-",
      "labels": {
        "app": "event-display-2hqvh",
        "pod-template-hash": "6fcdbf5bd6",
        "serving.knative.dev/configuration": "event-display",
        "serving.knative.dev/configurationGeneration": "1",
        "serving.knative.dev/revision": "event-display-2hqvh",
        "serving.knative.dev/revisionUID": "a97708df-91c9-11e9-a15f-56e246950a1a",
        "serving.knative.dev/service": "event-display"
      },
      "name": "event-display-2hqvh-deployment-6fcdbf5bd6-j6ghb",
      "namespace": "knative-debug",
      "ownerReferences": [
        {
          "apiVersion": "apps/v1",
          "blockOwnerDeletion": true,
          "controller": true,
          "kind": "ReplicaSet",
          "name": "event-display-2hqvh-deployment-6fcdbf5bd6",
          "uid": "a98b76f1-91c9-11e9-8cc0-06c1da8f3461"
        }
      ],
      "resourceVersion": "66156",
      "selfLink": "/api/v1/namespaces/knative-debug/pods/event-display-2hqvh-deployment-6fcdbf5bd6-j6ghb",
      "uid": "e8145b1d-91cf-11e9-8cc0-06c1da8f3461"
    },
    "spec": {
      "containers": [
        {
          "env": [
            {
              "name": "PORT",
              "value": "8080"
            },
            {
              "name": "K_REVISION",
              "value": "event-display-2hqvh"
            },
            {
              "name": "K_CONFIGURATION",
              "value": "event-display"
            },
            {
              "name": "K_SERVICE",
              "value": "event-display"
            }
          ],
          "image": "gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display@sha256:bf45b3eb1e7fc4cb63d6a5a6416cf696295484a7662e0cf9ccdf5c080542c21d",
          "imagePullPolicy": "IfNotPresent",
          "lifecycle": {
            "preStop": {
              "httpGet": {
                "path": "/wait-for-drain",
                "port": 8022,
                "scheme": "HTTP"
              }
            }
          },
          "name": "user-container",
          "ports": [
            {
              "containerPort": 8080,
              "name": "user-port",
              "protocol": "TCP"
            }
          ],
          "resources": {},
          "terminationMessagePath": "/dev/termination-log",
          "terminationMessagePolicy": "FallbackToLogsOnError",
          "volumeMounts": [
            {
              "mountPath": "/var/log",
              "name": "varlog"
            },
            {
              "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
              "name": "default-token-qm8bb",
              "readOnly": true
            }
          ]
        },
        {
          "env": [
            {
              "name": "SERVING_NAMESPACE",
              "value": "knative-debug"
            },
            {
              "name": "SERVING_SERVICE",
              "value": "event-display"
            },
            {
              "name": "SERVING_CONFIGURATION",
              "value": "event-display"
            },
            {
              "name": "SERVING_REVISION",
              "value": "event-display-2hqvh"
            },
            {
              "name": "QUEUE_SERVING_PORT",
              "value": "8012"
            },
            {
              "name": "CONTAINER_CONCURRENCY",
              "value": "0"
            },
            {
              "name": "REVISION_TIMEOUT_SECONDS",
              "value": "300"
            },
            {
              "name": "SERVING_POD",
              "valueFrom": {
                "fieldRef": {
                  "apiVersion": "v1",
                  "fieldPath": "metadata.name"
                }
              }
            },
            {
              "name": "SERVING_POD_IP",
              "valueFrom": {
                "fieldRef": {
                  "apiVersion": "v1",
                  "fieldPath": "status.podIP"
                }
              }
            },
            {
              "name": "SERVING_LOGGING_CONFIG",
              "value": "{\n  \"level\": \"info\",\n  \"development\": false,\n  \"outputPaths\": [\"stdout\"],\n  \"errorOutputPaths\": [\"stderr\"],\n  \"encoding\": \"json\",\n  \"encoderConfig\": {\n    \"timeKey\": \"ts\",\n    \"levelKey\": \"level\",\n    \"nameKey\": \"logger\",\n    \"callerKey\": \"caller\",\n    \"messageKey\": \"msg\",\n    \"stacktraceKey\": \"stacktrace\",\n    \"lineEnding\": \"\",\n    \"levelEncoder\": \"\",\n    \"timeEncoder\": \"iso8601\",\n    \"durationEncoder\": \"\",\n    \"callerEncoder\": \"\"\n  }\n}"
            },
            {
              "name": "SERVING_LOGGING_LEVEL",
              "value": "info"
            },
            {
              "name": "SERVING_REQUEST_LOG_TEMPLATE"
            },
            {
              "name": "SERVING_REQUEST_METRICS_BACKEND"
            },
            {
              "name": "USER_PORT",
              "value": "8080"
            },
            {
              "name": "SYSTEM_NAMESPACE",
              "value": "knative-serving"
            }
          ],
          "image": "icr.io/ext/knative/serving/cmd/queue:1e40c99ff5977daa2d69873fff604c6d09651af1f9ff15aadf8849b3ee77ab45",
          "imagePullPolicy": "IfNotPresent",
          "name": "queue-proxy",
          "ports": [
            {
              "containerPort": 8022,
              "name": "queueadm-port",
              "protocol": "TCP"
            },
            {
              "containerPort": 9090,
              "name": "queue-metrics",
              "protocol": "TCP"
            },
            {
              "containerPort": 8012,
              "name": "queue-port",
              "protocol": "TCP"
            }
          ],
          "readinessProbe": {
            "failureThreshold": 3,
            "httpGet": {
              "path": "/health",
              "port": 8022,
              "scheme": "HTTP"
            },
            "periodSeconds": 1,
            "successThreshold": 1,
            "timeoutSeconds": 10
          },
          "resources": {
            "requests": {
              "cpu": "25m"
            }
          },
          "terminationMessagePath": "/dev/termination-log",
          "terminationMessagePolicy": "File",
          "volumeMounts": [
            {
              "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
              "name": "default-token-qm8bb",
              "readOnly": true
            }
          ]
        }
      ],
      "dnsPolicy": "ClusterFirst",
      "enableServiceLinks": true,
      "nodeName": "10.171.147.102",
      "priority": 0,
      "restartPolicy": "Always",
      "schedulerName": "default-scheduler",
      "securityContext": {},
      "serviceAccount": "default",
      "serviceAccountName": "default",
      "terminationGracePeriodSeconds": 300,
      "tolerations": [
        {
          "effect": "NoExecute",
          "key": "node.kubernetes.io/not-ready",
          "operator": "Exists",
          "tolerationSeconds": 300
        },
        {
          "effect": "NoExecute",
          "key": "node.kubernetes.io/unreachable",
          "operator": "Exists",
          "tolerationSeconds": 300
        }
      ],
      "volumes": [
        {
          "emptyDir": {},
          "name": "varlog"
        },
        {
          "name": "default-token-qm8bb",
          "secret": {
            "defaultMode": 420,
            "secretName": "default-token-qm8bb"
          }
        }
      ]
    },
    "status": {
      "conditions": [
        {
          "lastProbeTime": null,
          "lastTransitionTime": "2019-06-18T13:49:35Z",
          "status": "True",
          "type": "Initialized"
        },
        {
          "lastProbeTime": null,
          "lastTransitionTime": "2019-06-18T13:49:39Z",
          "status": "True",
          "type": "Ready"
        },
        {
          "lastProbeTime": null,
          "lastTransitionTime": "2019-06-18T13:49:39Z",
          "status": "True",
          "type": "ContainersReady"
        },
        {
          "lastProbeTime": null,
          "lastTransitionTime": "2019-06-18T13:49:34Z",
          "status": "True",
          "type": "PodScheduled"
        }
      ],
      "containerStatuses": [
        {
          "containerID": "containerd://ab211b11e00c23b961eb0dde78fa3f2ad1497e11240d807f92be537bce11739c",
          "image": "icr.io/ext/knative/serving/cmd/queue:1e40c99ff5977daa2d69873fff604c6d09651af1f9ff15aadf8849b3ee77ab45",
          "imageID": "icr.io/ext/knative/serving/cmd/queue@sha256:6c6d30ec4bef7bfddec66d44e6f33e964b52a0c8731773e7ead07f3ff7c473ce",
          "lastState": {},
          "name": "queue-proxy",
          "ready": true,
          "restartCount": 0,
          "state": {
            "running": {
              "startedAt": "2019-06-18T13:49:38Z"
            }
          }
        },
        {
          "containerID": "containerd://e1b32e765e38bce2002ed58db83fd1e224a6805e29a293d7039e76fb0f7a6a95",
          "image": "sha256:73bc780983f889919fd7748ce13f51f7f850dcb9346b1a58951551b4d0068fe0",
          "imageID": "gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display@sha256:bf45b3eb1e7fc4cb63d6a5a6416cf696295484a7662e0cf9ccdf5c080542c21d",
          "lastState": {},
          "name": "user-container",
          "ready": true,
          "restartCount": 0,
          "state": {
            "running": {
              "startedAt": "2019-06-18T13:49:38Z"
            }
          }
        }
      ],
      "hostIP": "10.171.147.102",
      "phase": "Running",
      "podIP": "172.30.123.200",
      "qosClass": "Burstable",
      "startTime": "2019-06-18T13:49:35Z"
    }
  }
```



You've applied [example.yaml](example.yaml) and you are inspecting `fn`'s logs:

```shell
kubectl --namespace knative-debug logs -l app=fn -c user-container
```

But you don't see any events arrive. Where is the problem?

### Control Plane

We will first check the control plane, to ensure everything should be working
properly.

#### Resources

The first thing to check are all the created resources, do their statuses
contain `ready` true?

We will attempt to determine why from the most basic pieces out:

1. `fn` - The `Deployment` has no dependencies inside Knative.
1. `svc` - The `Service` has no dependencies inside Knative.
1. `chan` - The `Channel` depends on its backing `channel implementation` and
   somewhat depends on `sub`.
1. `src` - The `Source` depends on `chan`.
1. `sub` - The `Subscription` depends on both `chan` and `svc`.

##### `fn`

```shell
kubectl --namespace knative-debug get deployment fn -o jsonpath='{.status.availableReplicas}'
```

We want to see `1`. If you don't, then you need to debug the `Deployment`. Is
there anything obviously wrong mentioned in the `status`?

```shell
kubectl --namespace knative-debug get deployment fn --output yaml
```

If it is not obvious what is wrong, then you need to debug the `Deployment`,
which is out of scope of this document.

Verify that the `Pod` is `Ready`:

```shell
kubectl --namespace knative-debug get pod -l app=fn -o jsonpath='{.items[*].status.conditions[?(@.type == "Ready")].status}'
```

This should return `True`. If it doesn't, then try to debug the `Deployment`
using the
[Kubernetes Application Debugging](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application-introspection/)
guide.

##### `svc`

```shell
kubectl --namespace knative-debug get service svc
```

We just want to ensure this exists and has the correct name. If it doesn't
exist, then you probably need to re-apply [example.yaml](example.yaml).

Verify it points at the expected pod.

```shell
svcLabels=$(kubectl --namespace knative-debug get service svc -o go-template='{{range $k, $v := .spec.selector}}{{ $k }}={{ $v }},{{ end }}' | sed 's/.$//' )
kubectl --namespace knative-debug get pods -l $svcLabels
```

This should return a single Pod, which if you inspect is the one generated by
`fn`.

##### `chan`

`chan` uses the
[`in-memory-channel`]( https://github.com/knative/eventing/tree/master/config/channels/in-memory-channel).
This is a very basic channel and has few
failure modes that will be exhibited in `chan`'s `status`.

```shell
kubectl --namespace knative-debug get channel.messaging.knative.dev chan -o jsonpath='{.status.conditions[?(@.type == "Ready")].status}'
```

This should return `True`. If it doesn't, get the full resource:

```shell
kubectl --namespace knative-debug get channel.messaging.knative.dev chan --output yaml
```

If `status` is completely missing, it implies that something is wrong with the
`in-memory-channel` controller. See [Channel Controller](#channel-controller).

Next verify that `chan` is addressable:

```shell
kubectl --namespace knative-debug get channel.messaging.knative.dev chan -o jsonpath='{.status.address.hostname}'
```

This should return a URI, likely ending in '.cluster.local'. If it doesn't, then
it implies that something went wrong during reconciliation. See
[Channel Controller](#channel-controller).

We will verify that the two resources that the `chan` creates exist and are
`Ready`.

###### `Service`

`chan` creates a K8s `Service`.

```shell
kubectl --namespace knative-debug get service -l messaging.knative.dev/role=in-memory-channel
```

It's spec is completely unimportant, as Istio will ignore it. It just needs to
exist so that `src` can send events to it. If it doesn't exist, it implies that
something went wrong during `chan` reconciliation. See
[Channel Controller](#channel-controller).

##### `src`

`src` is a
[`ApiServerSource`](https://github.com/knative/eventing/blob/master/pkg/apis/sources/v1alpha1/apiserver_types.go),
which creates an underlying

First we will verify that `src` is writing to `chan`.

```shell
kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.spec.sink}'
```

Which should return
`map[apiVersion:messaging.knative.dev/v1alpha1 kind:Channel name:chan]`. If it
doesn't, then `src` was setup incorrectly and its `spec` needs to be fixed.
Fixing should be as simple as updating its `spec` to have the correct `sink`
(see [example.yaml](example.yaml)).

Now that we know `src` is sending to `chan`, let's verify that it is `Ready`.

```shell
kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.status.conditions[?(.type == "Ready")].status}'
```

This should return `True`. If it doesn't, then we need to investigate why. First
we will look at the owned `ContainerSource` that underlies `src`, and if that is
not fruitful, look at the [Source Controller](#source-controller).

##### ContainerSource

`src` is backed by a `ContainerSource` resource.

Is the `ContainerSource` `Ready`?

```shell
srcUID=$(kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.metadata.uid}')
kubectl --namespace knative-debug get containersource -o jsonpath="{.items[?(.metadata.ownerReferences[0].uid == '$srcUID')].status.conditions[?(.type == 'Ready')].status}"
```

That should be `True`. If it is, but `src` is not `Ready`, then that implies the
problem is in the [Source Controller](#source-controller).

If `ContainerSource` is not `Ready`, then we need to look at its entire
`status`:

```shell
srcUID=$(kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.metadata.uid}')
containerSourceName=$(kubectl --namespace knative-debug get containersource -o jsonpath="{.items[?(.metadata.ownerReferences[*].uid == '$srcUID')].metadata.name}")
kubectl --namespace knative-debug get containersource $containerSourceName --output yaml
```

The most useful condition (when `Ready` is not `True`), is `Deployed`.

```shell
srcUID=$(kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.metadata.uid}')
containerSourceName=$(kubectl --namespace knative-debug get containersource -o jsonpath="{.items[?(.metadata.ownerReferences[*].uid == '$srcUID')].metadata.name}")
kubectl --namespace knative-debug get containersource $containerSourceName -o jsonpath='{.status.conditions[?(.type == "Deployed")].message}'
```

You should see something like `Updated deployment src-xz59f-hmtkp`. Let's see
the health of the `Deployment` that `ContainerSource` created (named in the
message, but we will get it directly in the following command):

```shell
srcUID=$(kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.metadata.uid}')
containerSourceUID=$(kubectl --namespace knative-debug get containersource -o jsonpath="{.items[?(.metadata.ownerReferences[*].uid == '$srcUID')].metadata.uid}")
deploymentName=$(kubectl --namespace knative-debug get deployment -o jsonpath="{.items[?(.metadata.ownerReferences[*].uid == '$containerSourceUID')].metadata.name}")
kubectl --namespace knative-debug get deployment $deploymentName --output yaml
```

If this is unhealthy, then it should tell you why. E.g.
`'pods "src-xz59f-hmtkp-7bd4bc6964-" is forbidden: error looking up service account knative-debug/events-sa: serviceaccount "events-sa" not found'`.
Fix any errors so that it the `Deployment` is healthy.

If the `Deployment` is healthy, but the `ContainerSource` isn't, that implies
something went wrong in
[ContainerSource Controller](#containersource-controller).

#### `sub`

`sub` is a `Subscription` from `chan` to `fn`.

Verify that `sub` is `Ready`:

```shell
kubectl --namespace knative-debug get subscription sub -o jsonpath='{.status.conditions[?(.type == "Ready")].status}'
```

This should return `True`. If it doesn't then, look at all the status entries.

```shell
kubectl --namespace knative-debug get subscription sub --output yaml
```

#### Controllers

Each of the resources has a Controller that is watching it. As of today, they
tend to do a poor job of writing failure status messages and events, so we need
to look at the Controller's logs.

##### Deployment Controller

The Kubernetes Deployment Controller, controlling `fn`, is out of scope for this
document.

##### Service Controller

The Kubernetes Service Controller, controlling `svc`, is out of scope for this
document.

##### Channel Controller

There is not a single `Channel` Controller. Instead, there is one
Controller for each Channel CRD. `chan` uses the
`InMemoryChannel` `Channel CRD`, whose Controller is:

```shell
kubectl --namespace knative-eventing get pod -l messaging.knative.dev/channel=in-memory-channel,messaging.knative.dev/role=controller --output yaml
```

See its logs with:

```shell
kubectl --namespace knative-eventing logs -l messaging.knative.dev/channel=in-memory-channel,messaging.knative.dev/role=controller
```

Pay particular attention to any lines that have a logging level of `warning` or
`error`.

##### Source Controller

Each Source will have its own Controller. `src` is a `ApiServerSource`, so
its Controller is:

```shell
kubectl --namespace knative-eventing get pod -l app=sources-controller
```

This is actually a single binary that runs multiple Source Controllers,
importantly including [ContainerSource Controller](#containersource-controller).

The `ApiServerSource` is fairly simple, as it delegates all functionality
to an underlying [ContainerSource](#containersource), so there is likely no
useful information in its logs. Instead more useful information is likely in the
[ContainerSource Controller](#containersource-controller)'s logs. If you want to
look at `ApiServerSource` Controller's logs anyway, they can be see with:

###### ApiServerSource Controller

The `ApiServerSource` Controller is run in the same binary as some other Source
Controllers from Eventing. It is:

```shell
kubectl --namespace knative-debug get pod -l eventing.knative.dev/sourceName=src,eventing.knative.dev/source=apiserver-source-controller
```

View its logs with:

```shell
kubectl --namespace knative-debug logs -l eventing.knative.dev/sourceName=src,eventing.knative.dev/source=apiserver-source-controller
```

Pay particular attention to any lines that have a logging level of `warning` or
`error`.

##### Subscription Controller

The `Subscription` Controller controls `sub`. It attempts to resolve the
addresses that a `Channel` should send events to, and once resolved, inject
those into the `Channel`'s `spec.subscribable`.

```shell
kubectl --namespace knative-eventing get pod -l app=eventing-controller
```

View its logs with:

```shell
kubectl --namespace knative-eventing logs -l app=eventing-controller
```

Pay particular attention to any lines that have a logging level of `warning` or
`error`.

### Data Plane

The entire [Control Plane](#control-plane) looks healthy, but we're still not
getting any events. Now we need to investigate the data plane.

The Knative event takes the following path:

1. Event is generated by `src`.

   - In this case, it is caused by having a Kubernetes `Event` trigger it, but
     as far as Knative is concerned, the `Source` is generating the event denovo
     (from nothing).

1. `src` is POSTing the event to `chan`'s address,
   `http://chan-kn-channel.knative-debug.svc.cluster.local`.

1. The Channel Dispatcher receives the request and introspects the Host header
   to determine which `Channel` it corresponds to. It sees that it corresponds
   to `knative-debug/chan` so forwards the request to the subscribers defined in
   `sub`, in particular `svc`, which is backed by `fn`.

1. `fn` receives the request and logs it.

We will investigate components in the order in which events should travel.

#### `src`

Events should be generated at `src`. First let's look at the `Pod`s logs:

```shell
srcUID=$(kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.metadata.uid}')
containerSourceName=$(kubectl --namespace knative-debug get containersource -o jsonpath="{.items[?(.metadata.ownerReferences[*].uid == '$srcUID')].metadata.name}")
kubectl --namespace knative-debug logs -l source=$containerSourceName -c source
```

Note that a few log lines within the first ~15 seconds of the `Pod` starting
like the following are fine. They represent the time waiting for the Istio proxy
to start. If you see these more than a few seconds after the `Pod` starts, then
something is wrong.

```shell
E0116 23:59:40.033667       1 reflector.go:205] github.com/knative/eventing-sources/pkg/adapter/kubernetesevents/adapter.go:73: Failed to list *v1.Event: Get https://10.51.240.1:443/api/v1/namespaces/kna tive-debug/events?limit=500&resourceVersion=0: dial tcp 10.51.240.1:443: connect: connection refused
E0116 23:59:41.034572       1 reflector.go:205] github.com/knative/eventing-sources/pkg/adapter/kubernetesevents/adapter.go:73: Failed to list *v1.Event: Get https://10.51.240.1:443/api/v1/namespaces/kna tive-debug/events?limit=500&resourceVersion=0: dial tcp 10.51.240.1:443: connect: connection refused
```

The success message is `debug` level, so we don't expect to see anything. If you
see lines with a logging level of `error`, look at their `msg`. For example:

```shell
"msg":"[404] unexpected response \"\""
```

Which means that `src` correctly got the Kubernetes `Event` and tried to send it
to `chan`, but failed to do so. In this case, the response code was a 404. We
will look at the Istio proxy's logs to see if we can get any further
information:

```shell
srcUID=$(kubectl --namespace knative-debug get apiserversource src -o jsonpath='{.metadata.uid}')
containerSourceName=$(kubectl --namespace knative-debug get containersource -o jsonpath="{.items[?(.metadata.ownerReferences[*].uid == '$srcUID')].metadata.name}")
kubectl --namespace knative-debug logs -l source=$containerSourceName -c istio-proxy
```

We see lines like:

```shell
[2019-01-17T17:16:11.898Z] "POST / HTTP/1.1" 404 NR 0 0 0 - "-" "Go-http-client/1.1" "4702a818-11e3-9e15-b523-277b94598101" "chan-channel-45k5h.knative-debug.svc.cluster.local" "-"
```

These are lines emitted by [Envoy](https://www.envoyproxy.io). The line is
documented as Envoy's
[Access Logging](https://www.envoyproxy.io/docs/envoy/latest/configuration/access_log).
That's odd, we already verified that there is a
[`VirtualService`](#virtualservice) for `chan`. In fact, we don't expect to see
`chan-channel-45k5h.knative-debug.svc.cluster.local` at all, it should be
replaced with `chan.knative-debug.channels.cluster.local`. We keep looking in
the same Istio proxy logs and see:

```shell
 [2019-01-16 23:59:41.408][23][warning][config] bazel-out/k8-opt/bin/external/envoy/source/common/config/_virtual_includes/grpc_mux_subscription_lib/common/config/grpc_mux_subscription_impl.h:70] gRPC     config for type.googleapis.com/envoy.api.v2.RouteConfiguration rejected: Only unique values for domains are permitted. Duplicate entry of domain chan.knative-debug.channels.cluster.local
```

This shows that the [`VirtualService`](#virtualservice) created for `chan`,
which tries to map two hosts,
`chan-channel-45k5h.knative-debug.svc.cluster.local` and
`chan.knative-debug.channels.cluster.local`, is not working. The most likely
cause is duplicate `VirtualService`s that all try to rewrite those hosts. Look
at all the `VirtualService`s in the namespace and see what hosts they rewrite:

```shell
kubectl --namespace knative-debug get virtualservice -o custom-columns='NAME:.metadata.name,HOST:.spec.hosts[*]'
```

In this case, we see:

```shell
NAME                 HOST
chan-channel-38x5a   chan-channel-45k5h.knative-debug.svc.cluster.local,chan.knative-debug.channels.cluster.local
chan-channel-8dc2x   chan-channel-45k5h.knative-debug.svc.cluster.local,chan.knative-debug.channels.cluster.local
```

```
Note: This shouldn't happen normally. It only happened here because I had local edits to the Channel controller and created a bug. If you see this with any released Channel Controllers, open a bug with all relevant information (Channel Controller info and YAML of all the VirtualServices).
```

Both are owned by `chan`. Deleting both, causes the
[Channel Controller](#channel-controller) to recreate the correct one. After
deleting both, a single new one is created (same command as above):

```shell
NAME                 HOST
chan-channel-9kbr8   chan-channel-45k5h.knative-debug.svc.cluster.local,chan.knative-debug.channels.cluster.local
```

After [forcing a Kubernetes event to occur](#triggering-events), the Istio proxy
logs now have:

```shell
[2019-01-17T18:04:07.571Z] "POST / HTTP/1.1" 202 - 795 0 1 1 "-" "Go-http-client/1.1" "ba36be7e-4fc4-9f26-83bd-b1438db730b0" "chan.knative-debug.channels.cluster.local" "10.48.1.94:8080"
```

Which looks correct. Most importantly, the return code is now 202 Accepted. In
addition, the request's Host is being correctly rewritten to
`chan.knative-debug.channels.cluster.local`.

#### Channel Dispatcher

The Channel Dispatcher is the component that receives POSTs pushing events into
`Channel`s and then POSTs to subscribers of those `Channel`s when an event is
received. For the `in-memory-channel` used in this example, there is a single
binary that handles both the receiving and dispatching sides for all
`in-memory-channel` `Channel`s.

First we will inspect the Dispatcher's logs to see if it is anything obvious:

```shell
kubectl --namespace knative-eventing logs -l messaging.knative.dev/channel=in-memory-channel,messaging.knative.dev/role=dispatcher -c dispatcher
```

Ideally we will see lines like:

```shell
{"level":"info","ts":"2019-08-16T13:50:55.424Z","logger":"inmemorychannel-dispatcher.in-memory-channel-dispatcher","caller":"provisioners/message_receiver.go:147","msg":"Request mapped to channel: knative-debug/chan-kn-channel","knative.dev/controller":"in-memory-channel-dispatcher"}
{"level":"info","ts":"2019-08-16T13:50:55.425Z","logger":"inmemorychannel-dispatcher.in-memory-channel-dispatcher","caller":"provisioners/message_dispatcher.go:112","msg":"Dispatching message to http://svc.knative-debug.svc.cluster.local/","knative.dev/controller":"in-memory-channel-dispatcher"}
{"level":"info","ts":"2019-08-16T13:50:55.981Z","logger":"inmemorychannel-dispatcher.in-memory-channel-dispatcher","caller":"provisioners/message_receiver.go:140","msg":"Received request for chan-kn-channel.knative-debug.svc.cluster.local","knative.dev/controller":"in-memory-channel-dispatcher"}
```

Which shows that the request is being received and then sent to `svc`, which is
returning a 2XX response code (likely 200, 202, or 204).

However if we see something like:

<!--
 NOTE: This error has been produced by settings spec.ports[0].port to 8081
 kubectl patch -n knative-debug svc svc -p '{"spec":{"ports": [{"port": 8081, "targetPort":8080}]}}' --type='merge' 
-->
```shell
{"level":"info","ts":"2019-08-16T16:10:16.859Z","logger":"inmemorychannel-dispatcher.in-memory-channel-dispatcher","caller":"provisioners/message_receiver.go:140","msg":"Received request for chan-kn-channel.knative-debug.svc.cluster.local","knative.dev/controller":"in-memory-channel-dispatcher"}
{"level":"info","ts":"2019-08-16T16:10:16.859Z","logger":"inmemorychannel-dispatcher.in-memory-channel-dispatcher","caller":"provisioners/message_receiver.go:147","msg":"Request mapped to channel: knative-debug/chan-kn-channel","knative.dev/controller":"in-memory-channel-dispatcher"}
{"level":"info","ts":"2019-08-16T16:10:16.859Z","logger":"inmemorychannel-dispatcher.in-memory-channel-dispatcher","caller":"provisioners/message_dispatcher.go:112","msg":"Dispatching message to http://svc.knative-debug.svc.cluster.local/","knative.dev/controller":"in-memory-channel-dispatcher"}
{"level":"error","ts":"2019-08-16T16:10:38.169Z","logger":"inmemorychannel-dispatcher.in-memory-channel-dispatcher","caller":"fanout/fanout_handler.go:121","msg":"Fanout had an error","knative.dev/controller":"in-memory-channel-dispatcher","error":"Unable to complete request Post http://svc.knative-debug.svc.cluster.local/: dial tcp 10.4.44.156:80: i/o timeout","stacktrace":"knative.dev/eventing/pkg/provisioners/fanout.(*Handler).dispatch\n\t/Users/xxxxxx/go/src/knative.dev/eventing/pkg/provisioners/fanout/fanout_handler.go:121\nknative.dev/eventing/pkg/provisioners/fanout.createReceiverFunction.func1.1\n\t/Users/i512777/go/src/knative.dev/eventing/pkg/provisioners/fanout/fanout_handler.go:95"}
```

Then we know there was a problem posting to
`http://svc.knative-debug.svc.cluster.local/`.

TODO Finish this section. Especially after the Channel Dispatcher emits K8s
events about failures.

#### `fn`

TODO Fill in this section.

# TODO Finish the guide.

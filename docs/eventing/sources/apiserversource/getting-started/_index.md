---
title: "Getting started"
weight: 01
type: "docs"
aliases:
  - /docs/eventing/samples/kubernetes-event-source
---

## Prerequisites

Before you can create an API server source, you must install Knative Eventing and the `kubectl` CLI tool.

## Create an API server source

1. Optional: Create a namespace for the API server source instance:

    ```
    kubectl create namespace <new_namespace_name>
    ```

    Creating a namespace for your API server source and related components allows you to view changes and events for this workflow more easily, since these are isolated from the many other components that may exist in your `default` namespace. It also makes removing the source easier, since you can simply delete the namespace to remove all of the resources.

1. Create a service account:

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: <service_account_name>
      namespace: <your_namespace>
    ```

1. Create a cluster role:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: <cluster_role_name>
    rules:
    - apiGroups:
      - ""
      resources:
      - events
      verbs:
      - get
      - list
      - watch
    ```

1. Create a cluster role binding:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: <cluster_role_binding_name>
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: <your_cluster_role>
    subjects:
    - kind: ServiceAccount
      name: <your_service_account>
      namespace: <your_namespace>
    ```

1. Create a `ApiServerSource` object:

    {{< tabs name="create-source" default="YAML" >}}
    {{% tab name="YAML" %}}

    ```yaml
    apiVersion: sources.knative.dev/v1
    kind: ApiServerSource
    metadata:
     name: <source_name>
     namespace: <your_namespace>
    spec:
     serviceAccountName: <your_service_account>
     mode: Resource
     resources:
       - apiVersion: v1
         kind: Event
     sink:
       ref:
         apiVersion: v1
         kind: Service # Service is an example, you can use any PodSpecable object
         name: <sink_name>
    ```

    {{< /tab >}}
    {{% tab name="kn" %}}

    ```
    kn source apiserver create testevents \
      --namespace apiserversource-example \
      --mode "Resource" \
      --resource "Event:v1" \
      --service-account events-sa \
      --sink  --sink http://event-display.svc.cluster.local
    ```

    {{< /tab >}}
    {{< /tabs >}}

1. Create events by launching a test pod in your namespace:

    ```
    kubectl run busybox --image=busybox --namespace=<your_namespace> --restart=Never -- ls
    ```

1. Delete the test pod:

    ```
    kubectl --namespace=<your_namespace> delete pod busybox
    ```

1. View the logs to verify that Kubernetes events were sent to the Knative Eventing system:

    ```
    kubectl logs --namespace=<your_namespace> -l app=<your_sink_name> --tail=100
    ```

    Example log output:

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
## Delete the API server source

Deleting the namespace removes the API server source and all of the related resources that were created in this namespace:

```
kubectl delete namespace <your_namespace>
```

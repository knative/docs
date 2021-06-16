# Creating an ApiServerSource object

![version](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

This topic describes how to create an ApiServerSource object.

## Before you begin

Before you can create an ApiServerSource object:

- You must have [Knative Eventing](../../../../../admin/install/eventing/install-eventing-with-yaml)
installed on your cluster.
- You must install the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
tool.
- Optional: If you want to use the `kn` commands, install the [`kn`](../../../../../client/install-kn/) tool.

## Create an ApiServerSource object

1. Optional: Create a namespace for the API server source instance by running the
command:

    ```bash
    kubectl create namespace <namespace>
    ```
    Where `<namespace>` is the name of the namespace that you want to create.

    !!! note
        Creating a namespace for your ApiServerSource and related components
        allows you to view changes and events for this workflow more easily, since
        these are isolated from the many other components that may exist in your `default` namespace.<br><br>
        It also makes removing the source easier, since you can simply delete the namespace to remove all of the resources.

1. Create a ServiceAccount by running the command:

    ```yaml
    kubectl create -f - <<EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: <service-account>
      namespace: <namespace>
    EOF
    ```
    Where:

    - `<service-account>` is the name of the ServiceAccount that you want to create.
    - `<namespace>` is the namespace that you created in step 1 above.

1. Create a ClusterRole by running the command:

    ```yaml
    kubectl create -f - <<EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: <cluster-role>
    rules:
    - apiGroups:
      - ""
      resources:
      - events
      verbs:
      - get
      - list
      - watch
    EOF
    ```
    Where `<cluster-role>` is the name of the ClusterRole that you want to create.

1. Create a ClusterRoleBinding by running the command:

    ```yaml
    kubectl create -f - <<EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: <cluster-role-binding>
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: <cluster-role>
    subjects:
    - kind: ServiceAccount
      name: <service-account>
      namespace: <namespace>
    EOF
    ```
    Where:

    - `<cluster-role-binding>` is the name of the ClusterRoleBinding that you want to create.
    - `<cluster-role>` is the name of the ClusterRole that you created in step 3 above.
    - `<service-account>` is the name of the ServiceAccount that you created in step 2 above.
    - `<namespace>` is the name of the namespace that you created in step 1 above.

1. Create the ApiServerSource object by running the command:

    === "kn"

        ```bash
        kn source apiserver create <apiserversource> \
          --namespace <namespace> \
          --mode "Resource" \
          --resource "Event:v1" \
          --service-account <service-account> \
          --sink <sink>
        ```
        Where:

        - `<apiserversource>` is the name of the source that you want to create.
        - `<namespace>` is the name of the namespace that you created in step 1 above.
        - `<service-account>` is the name of the ServiceAccount that you created in step 2 above.
        - `<sink>` is the name of the PodSpecable object that you want to use as a sink.

    === "YAML"

        ```yaml
        kubectl create -f - <<EOF
        apiVersion: sources.knative.dev/v1
        kind: ApiServerSource
        metadata:
         name: <apiserversource>
         namespace: <namespace>
        spec:
         serviceAccountName: <service-account>
         mode: Resource <!-- should this be a placeholder? -->
         resources:
           - apiVersion: v1
             kind: Event
         sink:
           ref:
             apiVersion: v1
             kind: Service
             name: <sink>
        EOF
        ```
        Where:

        - `<apiserversource>` is the name of the source that you want to create.
        - `<namespace>` is the name of the namespace that you created in step 1 above.
        - `<service-account>` is the name of the ServiceAccount that you created in step 2 above.
        - `<sink>` is the name of the Knative Service that you want to use as a sink. A Service is used here as an example, however you can use any supported PodSpecable object by updating the `kind` from `Service` to another object type.


## Verify the ApiServerSource object

1. Make the Kubernetes API server create events by launching a test pod in your namespace by running the command:

    ```bash
    kubectl run busybox --image=busybox --namespace=<namespace> --restart=Never -- ls
    ```
    Where `<namespace>` is the name of the namespace that you created in step 1 above.

1. Delete the test pod by running the command:

    ```bash
    kubectl --namespace=<namespace> delete pod busybox
    ```
    Where `<namespace>` is the name of the namespace that you created in step 1 above.

1. View the logs to verify that Kubernetes events were sent to the sink by the Knative Eventing system by running the command:

    ```bash
    kubectl logs --namespace=<namespace> -l app=<sink> --tail=100
    ```
    Where:

    - `<namespace>` is the name of the namespace that you created in step 1 above.
    - `<sink>` is the name of the PodSpecable object that you used as a sink in step 5 above.

    Example log output:

    ```{ .bash .no-copy }
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

## Delete the ApiServerSource

To remove the ApiServerSource object and all of the related resources:

- Delete the namespace by running the command:

    ```bash
    kubectl delete namespace <namespace>
    ```
    Where `<namespace>` is the name of the namespace that you created in step 1 above.

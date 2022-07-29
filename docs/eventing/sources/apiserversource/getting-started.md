# Creating an ApiServerSource object

![version](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

This topic describes how to create an ApiServerSource object.

## Before you begin

Before you can create an ApiServerSource object:

- You must have [Knative Eventing](../../../install/yaml-install/eventing/install-eventing-with-yaml.md)
installed on your cluster.
- You must install the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
tool.
- Optional: If you want to use the `kn` commands, install the [`kn`](../../../client/configure-kn.md) tool.

## Create an ApiServerSource object

1. Optional: Create a namespace for the API server source instance by running the
command:

    ```bash
    kubectl create namespace <namespace>
    ```
    Where `<namespace>` is the name of the namespace that you want to create.

    !!! note
        Creating a namespace for your ApiServerSource and related components
        allows you to view changes and events for this workflow more easily, because
        these are isolated from the other components that might exist in your `default` namespace.<br><br>
        It also makes removing the source easier, because you can delete the namespace to remove all of the resources.

1. Create a ServiceAccount:

    1. Create a YAML file using the following template:

        ```yaml
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: <service-account>
          namespace: <namespace>
        ```
        Where:

        - `<service-account>` is the name of the ServiceAccount that you want to create.
        - `<namespace>` is the namespace that you created in step 1 earlier.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Create a Role:

    1. Create a YAML file using the following template:

        ```yaml
        apiVersion: rbac.authorization.k8s.io/v1
        kind: Role
        metadata:
          name: <role>
          namespace: <namespace>
        rules:
          <rules>
        ```
        Where:

        - `<role>` is the name of the Role that you want to create.
        - `<namespace>` is the name of the namespace that you created in step 1 earlier.
        - `<rules>` are the set of permissions you want to grant to the APIServerSource object.
        This set of permissions must match the resources you want to receive events from.
        For example, to receive events related to the `events` resource, use the following set of permissions:
        ```yaml
        - apiGroups:
          - ""
          resources:
          - events
          verbs:
          - get
          - list
          - watch
        ```

            !!! note
                The only required verbs are `get`, `list` and `watch`.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Create a RoleBinding:

    1. Create a YAML file using the following template:

        ```yaml
        apiVersion: rbac.authorization.k8s.io/v1
        kind: RoleBinding
        metadata:
          name: <role-binding>
          namespace: <namespace>
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: Role
          name: <role>
        subjects:
        - kind: ServiceAccount
          name: <service-account>
          namespace: <namespace>
        ```
        Where:

        - `<role-binding>` is the name of the RoleBinding that you want to create.
        - `<namespace>` is the name of the namespace that you created in step 1 earlier.
        - `<role>` is the name of the Role that you created in step 3 earlier.
        - `<service-account>` is the name of the ServiceAccount that you created in step 2 earlier.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Create a sink. If you do not have your own sink, you can use the following example Service that dumps incoming messages to a log:

    1. Copy the YAML below into a file:

        ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: event-display
          namespace: <namespace>
        spec:
          replicas: 1
          selector:
            matchLabels: &labels
              app: event-display
          template:
            metadata:
              labels: *labels
            spec:
              containers:
                - name: event-display
                  image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display

        ---

        kind: Service
        apiVersion: v1
        metadata:
          name: event-display
          namespace: <namespace>
        spec:
          selector:
            app: event-display
          ports:
          - protocol: TCP
            port: 80
            targetPort: 8080
        ```

        Where `<namespace>` is the name of the namespace that you created in step 1 above.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Create the ApiServerSource object:

    === "kn"
        - To create the ApiServerSource, run the command:

            ```bash
            kn source apiserver create <apiserversource> \
              --namespace <namespace> \
              --mode "Resource" \
              --resource "Event:v1" \
              --service-account <service-account> \
              --sink <sink-name>
            ```
            Where:

            - `<apiserversource>` is the name of the source that you want to create.
            - `<namespace>` is the name of the namespace that you created in step 1 earlier.
            - `<service-account>` is the name of the ServiceAccount that you created in step 2 earlier.
            - `<sink-name>` is the name of your sink, for example, `http://event-display.pingsource-example.svc.cluster.local`.

            For a list of available options, see the [Knative client documentation](https://github.com/knative/client/blob/main/docs/cmd/kn_source_apiserver_create.md#kn-source-apiserver-create).

    === "YAML"
        1. Create a YAML file using the following template:

            ```yaml
            apiVersion: sources.knative.dev/v1
            kind: ApiServerSource
            metadata:
             name: <apiserversource-name>
             namespace: <namespace>
            spec:
             serviceAccountName: <service-account>
             mode: <event-mode>
             resources:
               - apiVersion: v1
                 kind: Event
             sink:
               ref:
                 apiVersion: v1
                 kind: <sink-kind>
                 name: <sink-name>
            ```
            Where:

            - `<apiserversource-name>` is the name of the source that you want to create.
            - `<namespace>` is the name of the namespace that you created in step 1 earlier.
            - `<service-account>` is the name of the ServiceAccount that you created in step 2 earlier.
            - `<event-mode>` is either `Resource` or `Reference`. If set to `Resource`, the event payload contains the entire resource that the event is for. If set to `Reference`, the event payload only contains a reference to the resource that the event is for. The default is `Reference`.
            - `<sink-kind>` is any supported Addressable object that you want to use as a sink, for example, a `Service` or `Deployment`.
            - `<sink-name>` is the name of your sink.

            For more information about the fields you can configure for the ApiServerSource object, see [ApiServerSource reference](reference.md).

        1. Apply the YAML file by running the command:

            ```bash
            kubectl apply -f <filename>.yaml
            ```
            Where `<filename>` is the name of the file you created in the previous step.

## Verify the ApiServerSource object

1. Make the Kubernetes API server create events by launching a test Pod in your namespace by running the command:

    ```bash
    kubectl run busybox --image=busybox --namespace=<namespace> --restart=Never -- ls
    ```
    Where `<namespace>` is the name of the namespace that you created in step 1 earlier.

1. Delete the test Pod by running the command:

    ```bash
    kubectl --namespace=<namespace> delete pod busybox
    ```
    Where `<namespace>` is the name of the namespace that you created in step 1 earlier.

1. View the logs to verify that Kubernetes events were sent to the sink by the Knative Eventing system by running the command:

    ```bash
    kubectl logs --namespace=<namespace> -l app=<sink> --tail=100
    ```
    Where:

    - `<namespace>` is the name of the namespace that you created in step 1 earlier.
    - `<sink>` is the name of the PodSpecable object that you used as a sink in step 5 earlier.

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

## Delete the ApiServerSource object

To remove the ApiServerSource object and all of the related resources:

- Delete the namespace by running the command:

    ```bash
    kubectl delete namespace <namespace>
    ```
    Where `<namespace>` is the name of the namespace that you created in step 1 earlier.

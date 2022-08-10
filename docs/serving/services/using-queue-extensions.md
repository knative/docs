# Using Queue Proxy Extensions

Once your cluster is setup to allow services to use Queue Proxy Extensions, a service can decide which extensions it wish to use and how to configure such extensions. Activating and configuring extensions is described here.

## Prerequisites for preparing the cluster

1. Make sure you are using a Queue Proxy Image that was built with the extensions that you wish to use - See [Enabling Queue Proxy Pod Info](../queue-extensions.md)
1. Make sure that the cluster config-features is set with: `queueproxy.mount-podinfo: allowed`  - See [Enabling Queue Proxy Pod Info](../configuration/feature-flags.md#queue-proxy-pod-info) for more details

## Overview

A service can activate and configure queue proxy extensions by adding `qpextension.knative.dev/*` annotations under the: `spec.template.metadata` of the service custom resource definition.

Setting a value of: `qpextension.knative.dev/<ExtensionName>-activate: "enable"` will activate the extension.

Setting a value of: `qpextension.knative.dev/<ExtensionName>-config-<Key>: "<Val>"` will add a configuration of Key: Val to the extension.

In addition, the service need to ensure that the Pod Info volume is mounted by adding the `features.knative.dev/queueproxy-podinfo: enabled` annotation under the: `spec.template.metadata` of the service custom resource definition.

You can create a Knative service by applying a YAML file or by using the `kn service create` CLI command.

## Prerequisites for creating a service

See [Creating a Service](./creating-services.md) for prerequisites to create a service.

## Procedure

!!! tip

    The following commands create a `helloworld-go` sample service while activating and configuring the `test-gate` extension for this service. You can modify these commands, including the extension(s) to be activated and the extension configuration.

Create a sample service:

=== "Apply YAML"

1. Create a YAML file using the following example:
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
            annotations:
              features.knative.dev/queueproxy-podinfo: enabled
              qpextention.knative.dev/testgate-activate: enable
              qpextention.knative.dev/testgate-config-response: CU
              qpextention.knative.dev/testgate-config-sender: Joe
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
              env:
                - name: TARGET
                  value: "World"
    ```
1. Apply the YAML file by running the command:
```bash
kubectl apply -f <filename>.yaml
```
Where `<filename>` is the name of the file you created in the previous step.

=== "kn CLI"
```sh
kn service create helloworld-go \
    --image gcr.io/knative-samples/helloworld-go \
    --env TARGET=World \
    --annotation features.knative.dev/queueproxy-podinfo: enabled \
    --annotation qpextension.knative.dev/testgate-activate=enable \
    --annotation qpextension.knative.dev/testgate-config-response=Goodbye \
    --annotation qpextension.knative.dev/testgate-config-sender=Joe
```

After the service has been created, Knative propagates the annotations to the podSpec of the service deployment. When a pod is created, the queue proxy container will mount a volume that contains the pod annotations and activate the `testgate` extension (if such an extension is available in the queue proxy image). The `testgate` extension will than be configured with the configuration: `{ sender: "Joe", response: "CU"}`.

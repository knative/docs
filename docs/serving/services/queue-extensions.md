# Configuring Queue Proxy Extensions

In order to use queue proxy extensions, make sure that the queue proxy image you are using was built with the extensions you wish to activate. See [Queue Proxy Runtime Extensions](../queue-runtime-extensions.md).

Building a queue proxy image with extensions enable you to later activate and use the added extensions through configuration.
A service can activate and configure queue proxy extensions by adding `qpextension.knative.dev/*` annotations under the: `spec.template.metadata` of the service custom resource definition.

Setting a value of: `qpextension.knative.dev/<ExtensionName>-activate: "enable"` will activate the extension.

Setting a value of: `qpextension.knative.dev/<ExtensionName>-config-<Key>: "<Val>"` will add aconfiguration of Key: Val to the extension.

You can create a Knative service by applying a YAML file or using the `kn service create` CLI command.

## Prerequisites

See [Creating a Service](./creating-services.md) for prerequisites to create a service. 

## Procedure

!!! tip

    The following commands create a `helloworld-go` sample service while activating and configuring the `testgate` extension for this service. You can modify these commands, including the extension(s) to be activated and the extension configuration.

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
          template:
            metadata:
               annotations:
                 qpextension.knative.dev/testgate-activate: enable
                 qpextension.knative.dev/testgate-config-response: CU
                 qpextension.knative.dev/testgate-config-sender: Joe
            spec:
              containers:
                - image: gcr.io/knative-samples/helloworld-go
                  env:
                    - name: TARGET
                      value: "Go Sample v1"
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

=== "kn CLI"

    ```
    kn service create helloworld-go \
        --image gcr.io/knative-samples/helloworld-go \
        --env TARGET=World \
        --annotation qpextension.knative.dev/testgate-activate=enable \
        --annotation qpextension.knative.dev/testgate-config-response=CU \
        --annotation qpextension.knative.dev/testgate-config-sender=Joe
    ```

After the service has been created, Knative propogate the annotations to the podSpec of the service deployment. When a pod is created, the queue proxy container will try to activate the `testgate` extension (if such an extension is avaliable in the queue proxy image) and configure it with: `{ sender: "Joe", response: "CU"}` 

See also [Extensions Default Configuration](../configuration/deployment.md) for adding default `qpextension.knative.dev/*` annotations for cluster services.  

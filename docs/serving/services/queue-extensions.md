## Activate and Configure Queue Proxy Extensions Per Service

In order to use queue proxy extensions, make sure that the queue proxy image you are using was built with the extensions you wish to activate.
Building a queue proxy image with extensions enable you to later activate and use the added extensions through configuration.
A service can activate and configure queue proxy extensions by adding `qpextention.knative.dev/*` annotations under the: `spec.template.metadata` of the service custom resource definition.

Setting a value of: `qpextention.knative.dev/<ExtensionName>-activate: "enable"` will activate the extension.

Setting a value of: `qpextention.knative.dev/<ExtensionName>-config-<Key>: "<Val>"` will add aconfiguration of Key: Val to the extension.

For example, the following config will activate the extension `testgate` and configure it with: `{ sender: "Joe", response: "CU"}` 

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
spec:
  template:
    metadata:
      annotations:
        qpextention.knative.dev/testgate-activate: enable
        qpextention.knative.dev/testgate-config-response: CU
        qpextention.knative.dev/testgate-config-sender: Joe
```

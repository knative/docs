# Using extensions enabled by QPOptions

QPOptions is a Queue Proxy feature that enables extending Queue Proxy with additional Go packages. For example, the [security-guard](https://knative.dev/security-guard#section-readme) repository extends Queue Proxy by adding runtime security features to protect user services.

Once your cluster is setup with extensions enabled by QPOptions, a Service can decide which extensions it wish to use and how to configure such extensions. Activating and configuring extensions is described here.

## Overview

A Service can activate and configure extensions by adding `qpoption.knative.dev/*` annotations under the: `spec.template.metadata` of the Service Custom Resource Definition (CRD).

Setting a value of: `qpoption.knative.dev/<ExtensionName>-activate: "enable"` activates the extension.

Setting a value of: `qpoption.knative.dev/<extension-name>-config-<key>: "<value>"` adds a configuration of `key: value` to the extension.

In addition, the Service must ensure that the Pod Info volume is mounted by adding the `features.knative.dev/queueproxy-podinfo: enabled` annotation under the: `spec.template.metadata` of the Service CRD.

You can create a Knative Service by applying a YAML file or by using the `kn service create` CLI command.

## Prerequisites

Before you can use extensions enabled by QPOptions, you must:

- Prepare your cluster:
  - Make sure you are using a Queue Proxy image that was built with the extensions that you wish to use - See [Extending Queue Proxy image with QPOptions](../queue-extensions.md).
  - Make sure that the cluster config-features is set with `queueproxy.mount-podinfo: allowed`. See [Enabling Queue Proxy Pod Info](../configuration/feature-flags.md#queue-proxy-pod-info) for more details.
- Meet the prerequisites in [Creating a Service](./creating-services.md)

## Procedure

!!! tip

    The following commands create a `helloworld-go` sample Service while activating and configuring the `test-gate` extension for this Service. You can modify these commands, including the extension(s) to be activated and the extension configuration.

Create a sample Service:


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
                  qpoption.knative.dev/testgate-activate: enable
                  qpoption.knative.dev/testgate-config-response: CU
                  qpoption.knative.dev/testgate-config-sender: Joe
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

    ```
    kn service create helloworld-go \
        --image gcr.io/knative-samples/helloworld-go \
        --env TARGET=World \
        --annotation features.knative.dev/queueproxy-podinfo=enabled \
        --annotation qpoption.knative.dev/testgate-activate=enable \
        --annotation qpoption.knative.dev/testgate-config-response=Goodbye \
        --annotation qpoption.knative.dev/testgate-config-sender=Joe
    ```

After the Service has been created, Knative propagates the annotations to the podSpec of the Service deployment. When a Service pod is created, the Queue Proxy sidecar will mount a volume that contains the pod annotations and activate the `testgate` extension. This occurs if the `testgate` extension is available in the Queue Proxy image. The `testgate` extension will then be configured with the configuration: `{ sender: "Joe", response: "CU"}`.

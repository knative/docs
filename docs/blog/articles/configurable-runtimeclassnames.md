# Configurable RuntimeClassNames

**Author: Caleb Woodbine**

Starting in Knative Serving v1.15, administrators are now able to configure the default the RuntimeClassName field for deployments as default and via a Knative Service label selector.

## Runtime Classes

**What is a Runtime Class?**

Runtime Classes configure the runtime of a container with settings and handler programs, such as `runc`, `crun`, `runsc`, `nvidia`/`nvidia-cdi` or `kata`. These are programs which are responsible for creating a container, such as through making system calls to the kernel or bringing up VMs. `runc` is the defacto which provides kernel-level isolation which is often unsuitable for running untrusted workloads.

See documentation at the Kubernetes docs [here](https://kubernetes.io/docs/concepts/containers/runtime-class/).

## Why is this important?

RuntimeClasses enable several things, including:

- security
    - isolation such as through Kata or gVisor 
- functionality
    - such as enabling GPU (e.g NVIDIA) or WASM (e.g Spinkube) support
    
For example, a cluster administrator or cloud provider may wish to configure Knative Serving to specificly not use `runc` to run untrusted workloads that would be deployed by users on their platform.

By default, Kubernetes does not have a default RuntimeClass feature/annotation (like StorageClass does) and it must be altered at a container runtime level as it is also inherited therein. This feature along with the ease of Knative Service config, it elevates the abilities of Knative Serving above standard Kubernetes.

## Existing configuration options

There are several feature flags in Knative Serving, one of which is enabling the field `.spec.template.spec.runtimeClassName` in Knative Service.

This may be useful for self-service and is a helpful feature flag.

See the documentation [here](https://knative.dev/docs/serving/configuration/feature-flags/#kubernetes-runtime-class).

## Configuring deployments in Knative Serving

Knative Serving is able to be configured with either the ConfigMaps if deployed with plain manifests or the KnativeServing resource if deployed with the operator. The following examples will be using just the plain manifests.

See this example where Knative Serving will configure deployments managed by Knative through Services to use Kata by default or gVisor when the Knative Service has a label matching `my-label=selector`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving
data:
  runtime-class-name: |
    kata: {}
    gvisor:
      selector:
        my-label: selector
```

The keys, like `kata` and `gvisor` must match existing Kubernetes RuntimeClasses.

**Please note**: _often the config above may not necessarily make sense for real world use but does display how it can be configured._

For Knative docs, [see here](https://knative.dev/docs/serving/configuration/deployment/#configuring-selectable-runtimeclassname).

## Closing

Runtime Classes are an important piece in container platform infrastructure.
Whether you're setting up a platform for production or just playing around, Runtime Classes can enhance or lockdown your workloads.

Now with the Knative Serving deployment configuration settings for RuntimeClass, there's even more ability to configure Knative Services in a locked down and specific manner.

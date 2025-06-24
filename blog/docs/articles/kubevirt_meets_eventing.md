# Monitoring Virtual Machines with Knative Eventing

**Authors: Robert Guske, Senior Specialist Solution Architect OpenShift @ Red Hat, Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In this blog post you will learn how to easily monitor state of Kubevirt VMs with Knative Eventing's powerful building blocks._

Event-Driven Architecture (EDA) and the use of event sources fundamentally transform how applications interact, fostering a highly decoupled and scalable environment where services react dynamically to changes. By abstracting the origin of information, event sources empower systems to integrate seamlessly and respond in real-time to a vast array of occurrences across diverse platforms.

### The Knative ApiServerSource

Knative `ApiServerSource` is a Knative Eventing Kubernetes custom resource that acts as an event source. Its primary function is to listen for events emitted by the Kubernetes API server and forward them as CloudEvents to a designated sink. Some common use cases include:

* Auditing and monitoring: Triggering actions or notifications when specific custom Kubernetes resources are _created_, _updated_, or _deleted_.
* Automating workflows: Initiating a serverless function when a new Pod is _deployed_, a Deployment _scales_, or a ConfigMap is _modified_.
* Integrating with external systems: Sending Kubernetes events to data warehouses or databases, AI applications or even logging systems for analysis.

### Entering Kubevirt

<type some text and describe the use-case>


### Using the ApiServerSource

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
...
more
```

The `ApiServerSource` routes the raw CloudEvents to a Knative Broker, from there we can process those events further with the `EventTransform` CRD


### Event transformation with an low-code approach


```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: event-transformer
spec:
  sink:
    ref:
      apiVersion: 
      kind: 
      name: 
  jsonata:
    expression: |
      {
      }
```

### Routing the events

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: transformer-trigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: EventTransform
      name: event-transformer
```

### Custom code for DB updates

TEXT


### Conclusion 



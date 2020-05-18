---
title: "Design and Theory Behind an Event Source"
linkTitle: "Design of an Event Source"
weight: 10
type: "docs"
---

# Topics
What are the personas and critical paths?

* Contributor: implement a new source with minimal k8s overhead (don't have to learn controller/k8s internals)
* Operator: easily install Sources and verify that they are "safe"
* Developer: easily discover what Sources they can pull from on this cluster
* Developer: easily configure a Source based on existing knowledge of other Sources.

## Separation of concerns
### Contributor:
* Receive Adapter (RA) - process that receives incoming events.
* Implement CloudEvent binding interfaces, [cloudevent's go sdk](https://github.com/cloudevents/sdk-go) provides libraries for standard access to configure interfaces as needed.
* Passing configuration from the Source `CRD` YAML, that the controller needs to configure the `Receive Adapter`

### Source library (provided by Knative):
* Controller runtime (this is what we share via injection) incorporates protocol specific config into "generic controller" CRD.
* Identifying specific event characteristics (i.e. value of interest, relevant metadata, etc) to pass along to the serverless system
* Propagating events internally to the system (i.e. cloudevents)

# Theory
Quick Introduction to Knative Eventing Sources
A Knative Source is Kubernetes Custom Resource that generates or imports an event and pushes that event to another endpoint on the cluster via a [CloudEvents](https://github.com/cloudevents/spec/blob/v1.0/primer.md).

[The specification](https://github.com/knative/eventing/blob/master/docs/spec/sources.md)
for Knative Eventing Sources contains a number of requirements that
together define a well-behaved Knative Source.


To achieve this, there are several separations of concerns that we have to keep in mind:
1. A controller to run our Event Source and reconcile the underlying `Receive Adapter` deployments
2. A "receive adapter" which generates or imports the actual events
3. A series of identifying characteristics for our event
4. Transporting a valid event to the serverless system for further processing

There are also two different classes of developer to consider:
1. A "contributor" knows about the foreign protocol but is not a Knative expert.
2. Knative Eventing expert knows how Knative Eventing components are implemented, configured and deployed, but is not an expert in all the foreign protocols that sources may implement.

These two roles will often not be the same person.  We want to confine the job of the "contributor" to implementing the `Receive Adapter`, and specifying what configuration their adapter needs connect, subscribe, or do whatever it does.

The Knative Eventing developer exposes the protocol configuration as part of the Source `CRD`, and the controller passes any required configuration (which may include resolved data like URLs) to the `Receive Adapter`.

API Resources required:

* `KubeClientSet.Appsv1.Deployment` (Inherited via the Eventing base reconciler)
Used to deploy the `Receive Adapter` for "importing" events
* `EventingClientSet.EventingV1Alpha1` (Inherited via the Eventing base reconciler)
Used to interact with Events within the Knative system
* `SourceClientSet.SourcesV1Alpha1`
Used for source &mdash; in this case, `samplesource` &mdash; specific config and translated to the underlying deployment (via the inherited KubeClientSet)

To ease writing a new event source, the eventing subsystem has offloaded several core functionalities (via injection) to the `eventing-sources-controller`.


![Simplified Controller](https://raw.githubusercontent.com/knative/docs/master/docs/eventing/samples/writing-receive-adapter-source/simplified-controller.png)

Fig 1. - Via shared [Knative Dependency Injection](https://docs.google.com/presentation/d/1aK5xCBv7wbfdDZAvnUE4vGWGk77EYZ6AbL0OR1vKPq8/edit#slide=id.g596dcbbefb_0_40)


Specifically, the `clientset`, `cache`, `informers`, and `listers` can all be generated and shared. Thus, they can be generated, imported, and assigned to the underlying reconciler when creating a new controller source implementation:

```golang
import (
    // ...
    sampleSourceClient "knative.dev/sample-source/pkg/client/injection/client"
    samplesourceinformer "knative.dev/sample-source/pkg/client/injection/informers/samples/v1alpha1/samplesource"
)
// ...
func NewController(ctx context.Context, cmw configmap.Watcher) *controller.Impl {
    sampleSourceInformer := samplesourceinformer.Get(ctx)

    r := &Reconciler{
        // ...
        samplesourceClientSet: sampleSourceClient.Get(ctx),
        samplesourceLister:    sampleSourceInformer.Lister(),
        // ...
}
```

Sample source's [`update-codegen.sh`](https://github.com/knative/sample-source/blob/master/hack/update-codegen.sh) have the configuration
to have the required things above generated and injected:
```bash
# Generation
${CODEGEN_PKG}/generate-groups.sh "deepcopy,client,informer,lister" \
  knative.dev/sample-source/pkg/client knative.dev/sample-source/pkg/apis \
  "samples:v1alpha1" \
  --go-header-file ${REPO_ROOT}/hack/boilerplate/boilerplate.go.txt

# Injection
${KNATIVE_CODEGEN_PKG}/hack/generate-knative.sh "injection" \
  knative.dev/sample-source/pkg/client knative.dev/sample-source/pkg/apis \
  "samples:v1alpha1" \
  --go-header-file ${REPO_ROOT}/hack/boilerplate/boilerplate.go.txt
```

File Layout & Hierarchy:

* `cmd/controller/main.go` - Pass source’s NewController implementation to the shared main
* `cmd/receive_adapter/main.go` - Translate resource variables to underlying adapter struct (to eventually be passed into the serverless system) 
* `pkg/reconciler/controller.go` - NewController implementation to pass to sharedmain
* `pkg/reconciler/samplesource.go` - reconciliation functions for the receive adapter
* `pkg/apis/samples/VERSION/samplesource_types.go` - schema for the underlying api types (variables to be defined in the resource yaml)
* `pkg/apis/samples/VERSION/samplesource_lifecycle.go` - status updates for the source’s reconciliation details
  * Source ready
  * Sink provided
  * Deployed
  * Eventtype Provided
  * K8s Resources Correct
* `pkg/adapter/adapter.go` - receive_adapter functions supporting translation of events to CloudEvents

# Topics
What are the personas and critical paths?
* Contributor: implement a new source with minimal k8s overhead (don't have to learn controller/k8s internals)
* Operator: easily install Sources and verify that they are "safe"
* Developer: easily discover what Sources they can pull from on this cluster
* Developer: easily configure a Source based on existing knowledge of other Sources.

## Separation of concerns
### Contributor:
* Receive Adapter(RA) - process that receives incoming events.
* Implement CloudEvent binding interfaces, we provide libraries for standard access to config.
* Configuration description (yaml, Go Struct, JSON?) links RA to controller runtime.

### Source library (provided by Knative):
* Controller runtime (this is what we share via injection) incorporates protocol specific config into "generic controller" CRD.
* Identifying event aspects to pass along to the serverless system
* Propagating events internally to the system (ie, cloudevents)

# Theory
Quick Introduction to Knative Eventing Sources
A Source is any Kubernetes object that generates or imports an event and relays that event to another endpoint on the cluster via [CloudEvents](https://github.com/cloudevents/spec/blob/v1.0/primer.md). 

[The specification](https://github.com/knative/eventing/blob/master/docs/spec/sources.md)
for Knative Eventing Sources contains a number of requirements that
together define a well-behaved Knative Source


To achieve this, there are several separations of concerns that we have to keep in mind:
1. A controller to run our Event Source and reconcile the underlying deployments
2. A ‘receive adapter’ which imports the actual events
3. A series of identifying characteristics for our event
4. Transporting a valid event to the serverless system for further processing

There are also two different classes of developer to consider:
1. A "contributor" knows about the foreign protocol but not a Knative expert.
2. Knative-eventing expert knows how knative eventing components are implemented, configured and deployed, but is not an expert in all the foreign protocols that sources may implement.
These two roles will often not be the same person.  We want to confine the job of the "contributor" to implementing the `Receive Adapter`, and specifying what configuration their adapter needs connect, subscribe, or do whatever it does.

The Knative-eventing developer exposes protocol configuration as part of the `CRD`, and the controller passes configuration (which may include resolved data like URLs) to the `Recieve Adapter`.

API Resources required
* `KubeClientSet.Appsv1.Deployment` (Inherited via eventing base reconciler)
Used to deploy the Receive Adapter for ‘importing’ events
* `EventingClientSet.EventingV1Alpha1` (Inherited via eventing base reconciler)
Used to interact with Events within the knative system
* `SourceClientSet.SourcesV1Alpha1`
Used for source -- in this case, `addressableservice` -- specific config and translated to the underlying deployment (via the inherited KubeClientSet)

To ease writing a new event source, the eventing subsystem has offloaded several core functionalities (via injection) to the `eventing-sources-controller`.


Fig 1. - Via shared [Knative Dependency Injection](https://docs.google.com/presentation/d/1aK5xCBv7wbfdDZAvnUE4vGWGk77EYZ6AbL0OR1vKPq8/edit#slide=id.g596dcbbefb_0_40)
presentation in the knative community drive


Specifically, the `clientset`, `cache`, `informers`, and `listers` can all be generated and shared. Thus, they can be generated, imported, and assigned to the underlying reconciler when creating a new controller source implementation:

```golang
import (
…
asclient "knative.dev/sample-controller/pkg/client/injection/client"
Asinformer “knative.dev/sample-controller/pkg/client/injection/informers/samples/v1alpha1/addressableservice"
)
…
asInformer := asinformer.Get(ctx)
svcInformer := svcinformer.Get(ctx)

r := &Reconciler{
		Client:        asclient.Get(ctx),
		Lister:        asInformer.Lister()
```
Ensure that the specific source subdirectory has been added to the injection portion of the `hack/update-codegen.sh` script.

File Layout & Hierarchy
* `cmd/controller/main.go` - Pass source’s NewController implementation to the shared main
* `cmd/recieve_adapter/main.go` - Translate resource variables to underlying adapter struct (to eventually be passed into the serverless system) 
* `pkg/reconciler/addressableservice/controller.go` - NewController implementation to pass to sharedmain
* `pkg/reconciler/addressableservice/addressableservice.go` - reconciliation functions for the receive adapter
* `pkg/apis/samples/VERSION/addressable_service_types.go` - schema for the underlying api types (variables to be defined in the resource yaml)
* `pkg/apis/sources/VERSION/addressable_service_lifecycle.go` - status updates for the source’s reconciliation details 
  * Source ready
  * Sink provided
  * Deployed
  * Eventtype Provided
  * K8s Resources Correct
* `pkg/adapter/adapter.go` - receive_adapter functions supporting translation of events to CloudEvents

# Step-by-step guide
## API Definition
1. Define the types required in the resource’s schema in
`pkg/apis/samples/v1alpha1/addressable_service_types.go`
This includes the fields that will be required in the resource yaml as
well as what will be referenced in the controller using the source’s
clientset and API

```go
// AddressableService is a Knative abstraction that encapsulates the interface by which Knative
// components express a desire to have a particular image cached.
type AddressableService struct {
	metav1.TypeMeta `json:",inline"`
	// +optional
	metav1.ObjectMeta `json:"metadata,omitempty"`

	// Spec holds the desired state of the AddressableService (from the client).
	// +optional
	Spec AddressableServiceSpec `json:"spec,omitempty"`

	// Status communicates the observed state of the AddressableService (from the controller).
	// +optional
	Status AddressableServiceStatus `json:"status,omitempty"`
}

// AddressableServiceSpec holds the desired state of the AddressableService (from the client).
type AddressableServiceSpec struct {
	// ServiceName holds the name of the Kubernetes Service to expose as an "addressable".
	ServiceName string `json:"serviceName"`
}

// AddressableServiceStatus communicates the observed state of the AddressableService (from the controller).
type AddressableServiceStatus struct {
	duckv1beta1.Status `json:",inline"`

	// Address holds the information needed to connect this Addressable up to receive events.
	// +optional
	Address *duckv1beta1.Addressable `json:"address,omitempty"`
}
```
Define the lifecycle that will be reflected in the status and SinkURI fields

```go
const (
	// AddressableServiceConditionReady is set when the revision is starting to materialize
	// runtime resources, and becomes true when those resources are ready.
	AddressableServiceConditionReady = apis.ConditionReady
…
)
```
Define the functions that will be called from the Reconciler functions to set the lifecycle conditions.  This is typically done in
`pkg/apis/sources/VERSION/addressable_service_lifecycle.go`

```go
func (ass *AddressableServiceStatus) InitializeConditions() {
	condSet.Manage(ass).InitializeConditions()
}

func (ass *AddressableServiceStatus) MarkServiceUnavailable(name string) {
	condSet.Manage(ass).MarkFalse(
		AddressableServiceConditionReady,
		"ServiceUnavailable",
		"Service %q wasn't found.", name)
}

func (ass *AddressableServiceStatus) MarkServiceAvailable() {
	condSet.Manage(ass).MarkTrue(AddressableServiceConditionReady)
}
```
Controller Implementation
Pass the new controller implementation to the shared main
```go
import (
	// The set of controllers this controller process runs.
	"knative.dev/sample-controller/pkg/reconciler/addressableservice"

	// This defines the shared main for injected controllers.
	"knative.dev/pkg/injection/sharedmain"
)

func main() {
	sharedmain.Main("controller",
		addressableservice.NewController,
	)
}
```
Define the NewController implementation, it will be passed a configmap.Watcher, as well as a context which the injected listers will use for the reconciler struct arguments
```go
const (
	controllerAgentName = "addressableservice-controller"
)

func NewController(
	ctx context.Context,
	cmw configmap.Watcher,
) *controller.Impl {
…
	asInformer := asinformer.Get(ctx)
	svcInformer := svcinformer.Get(ctx)

	c := &Reconciler{
		Client:        asclient.Get(ctx),
		Lister:        asInformer.Lister(),
		ServiceLister: svcInformer.Lister(),
		Recorder: record.NewBroadcaster().NewRecorder(
			scheme.Scheme, corev1.EventSource{Component: controllerAgentName}),
	}
```
The base reconciler is imported from the knative.dev/pkg dependency:
```go
import (
…
"knative.dev/eventing/pkg/reconciler"
…
)
```
Ensure the correct informers have EventHandlers filtered to them
```go
	asInformer.Informer().AddEventHandler(controller.HandleAll(impl.Enqueue))
```

# Reconciler Functionality
General steps the reconciliation process needs to cover:
1. Target the specific addressableservice via the `asclientset`:
```go
// Get the resource with this namespace/name.
original, err := r.Lister.AddressableServices(namespace).Get(name)
```
2. Update the ObservedGeneration
Initialize the Status conditions (as defined in `addressable_service_lifecycle.go` and `addressable_service_types.go`)
3. Reconcile the Sink and MarkSink with the result
Create the Receive Adapter (detailed below)
    3. If successful, update the Status and MarkDeployed
4. Reconcile the EventTypes and corresponding Status
Creation and deletion of the events is done with the inherited `EventingClientSet().EventingV1alpha1()` api
5. Update the full status field from the resulting reconcile attempt via the source’s clientset and api
`r.Client.SamplesV1alpha1().AddressableServices(desired.Namespace).UpdateStatus(existing)`


# Adding Receive Adapter Example via [sample-source](https://github.com/knative/sample-source)
## Reconcile/Create The Receive Adapter
As part of the source reconciliation, we have to create and deploy
(and update if necessary) the underlying receive adapter.  The two
client sets used in this process is the `kubeClientSet` for the
Deployment tracking, and the `EventingClientSet` for the event
recording.

Verify the specified kubernetes resources are valid, and update the `Status` accordingly

Assemble the ReceiveAdapterArgs
```go
raArgs := resources.ReceiveAdapterArgs{
		Image:         r.receiveAdapterImage,
		Source:        src,
		Labels:        resources.GetLabels(src.Name),
		LoggingConfig: loggingConfig,
		SinkURI:       sinkURI,
	}
```
NB The exact arguments may change based on functional requirements
Create the underlying deployment from the arguments provided, matching pod templates, labels, owner references, etc as needed to fill out the deployment
Example: [pkg/reconciler/resources/receive_adapter.go](https://github.com/knative/sample-source/tree/master/pkg/reconciler/resources/receive_adapter.go)

1. Fetch the existing receive adapter deployment
```go
	ra, err := r.KubeClientSet.AppsV1().Deployments(src.Namespace).Get(expected.Name, metav1.GetOptions{})
```
2. Otherwise, create the deployment
```go
ra, err = r.KubeClientSet.AppsV1().Deployments(src.Namespace).Create(expected)
```
3. Check if the expected vs existing spec is different, and update the deployment if required
```go
} else if podSpecChanged(ra.Spec.Template.Spec, expected.Spec.Template.Spec) {
		ra.Spec.Template.Spec = expected.Spec.Template.Spec
		if ra, err = r.KubeClientSet.AppsV1().Deployments(src.Namespace).Update(ra); err != nil {
			return ra, err
        }
```
4. If updated, record the event
```go
		r.Recorder.Eventf(src, corev1.EventTypeNormal, AddressableServiceDeploymentUpdated, "Deployment updated")
		return ra, nil
```


# Using the Knative sandbox sample source

You can use the files provided in the [Knative sandbox sample repository](https://github.com/knative-sandbox/sample-source) to create an event source. This method requires you to create an event source controller and receiver adapter.

Sources must implement CloudEvent binding interfaces. The [Go SDK for CloudEvents](https://github.com/cloudevents/sdk-go) provides libraries for standard access to configure interfaces.

## Creating a contoller

1. Pass the sample controller implementation to the shared `main` method:

    ````go
    import (
    	// The set of controllers this controller process runs.
    	"knative.dev/sample-source/pkg/reconciler/sample"

    	// This defines the shared main for injected controllers.
    	"knative.dev/pkg/injection/sharedmain"
    )

    func main() {
    	sharedmain.Main("sample-source-controller", sample.NewController)
    }
    ````

1. Define the `NewController` implementation:

    ````go
    func NewController(
    	ctx context.Context,
    	cmw configmap.Watcher,
    ) *controller.Impl {
        // ...
    	deploymentInformer := deploymentinformer.Get(ctx)
    	sinkBindingInformer := sinkbindinginformer.Get(ctx)
    	sampleSourceInformer := samplesourceinformer.Get(ctx)

    	r := &Reconciler{
    	dr:  &reconciler.DeploymentReconciler{KubeClientSet: kubeclient.Get(ctx)},
    	sbr: &reconciler.SinkBindingReconciler{EventingClientSet: eventingclient.Get(ctx)},
    	// Config accessor takes care of tracing/config/logging config propagation to the receive adapter
    	configAccessor: reconcilersource.WatchConfigurations(ctx, "sample-source", cmw),
    }
    ````

    A `configmap.Watcher` is passed to the implementation, as well as a `context` object, which the injected listers will use for the reconciler struct arguments.

1. Import the base reconciler from the `knative.dev/pkg` dependency:

    ````go
    import (
        // ...
        reconcilersource "knative.dev/eventing/pkg/reconciler/source"
        // ...
    )
    ````

1. Ensure that the `EventHandlers` are being filtered to the correct informers:

    ````go
    	sampleSourceInformer.Informer().AddEventHandler(controller.HandleAll(impl.Enqueue))
    ````

1. Ensure that the informers are set up correctly to use secondary sources, namely the Deployment and SinkBinding resources:

    ````go
        deploymentInformer.Informer().AddEventHandler(cache.FilteringResourceEventHandler{
            FilterFunc: controller.FilterGroupKind(v1alpha1.Kind("SampleSource")),
            Handler:    controller.HandleAll(impl.EnqueueControllerOf),
        })

        sinkBindingInformer.Informer().AddEventHandler(cache.FilteringResourceEventHandler{
            FilterFunc: controller.FilterGroupKind(v1alpha1.Kind("SampleSource")),
            Handler:    controller.HandleAll(impl.EnqueueControllerOf),
        })
    ````

    The controller of the sample source uses Deployment and SinkBinding resources to deploy and bind the event source and the receive adapter.




























### NOTES

implementing the `Receive Adapter`, and specifying what configuration their adapter needs to connect, subscribe, or do whatever it does.

The Knative Eventing developer exposes the protocol configuration as part of the Source `CRD`, and the controller passes any required configuration (which may include resolved data like URLs) to the `Receive Adapter`.

API Resources required:

* `KubeClientSet.Appsv1.Deployment` (Inherited via the Eventing base reconciler)
Used to deploy the `Receive Adapter` for "importing" events
* `EventingClientSet.EventingV1Alpha1` (Inherited via the Eventing base reconciler)
Used to interact with Events within the Knative system
* `SourceClientSet.SourcesV1Alpha1`
Used for source &mdash; in this case, `samplesource` &mdash; specific config and translated to the underlying deployment (via the inherited KubeClientSet)

To ease writing a new event source, the eventing subsystem has offloaded several core functionalities (via injection) to the `eventing-sources-controller`.

![Simplified Controller](https://raw.githubusercontent.com/knative/docs/main/docs/eventing/samples/writing-event-source/simplified-controller.png)

Fig 1. - Via shared [Knative Dependency Injection](https://docs.google.com/presentation/d/e/2PACX-1vQbpISBvY7jqzu2wy2t1_0R4LSBEBS0JrUS7M7V3BMVqy2K1Zk_0Xhy7WPPaeANLHE0yqtz1DuWlSAl/pub?resourcekey=0-mf6dN2vu9SS3bo2TUeCk9Q&slide=id.g596dcbbefb_0_40)

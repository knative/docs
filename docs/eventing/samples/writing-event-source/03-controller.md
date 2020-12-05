---
title: "Controller Implementation and Design"
linkTitle: "Controller Implemetation"
weight: 30
type: "docs"
---

# Controller Implementation
## cmd/controller
Pass the new controller implementation to the shared main
```go
import (
	// The set of controllers this controller process runs.
	"knative.dev/sample-source/pkg/reconciler/sample"

	// This defines the shared main for injected controllers.
	"knative.dev/pkg/injection/sharedmain"
)

func main() {
	sharedmain.Main("sample-source-controller", sample.NewController)
}
```
Define the NewController implementation, it will be passed a `configmap.Watcher`, as well as a context which the injected listers will use for the reconciler struct arguments
```go
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
```
The base reconciler is imported from the knative.dev/pkg dependency:
```go
import (
    // ...
    reconcilersource "knative.dev/eventing/pkg/reconciler/source"
    // ...
)
```
Ensure the correct informers have EventHandlers filtered to them
```go
	sampleSourceInformer.Informer().AddEventHandler(controller.HandleAll(impl.Enqueue))
```
Controller for the `SampleSource` uses `Deployment` and `SinkBinding` resources to deploy and also bind the event source and the receive adapter. Also ensure the informers are set up correctly for these secondary resources
```go
    deploymentInformer.Informer().AddEventHandler(cache.FilteringResourceEventHandler{
        FilterFunc: controller.FilterGroupKind(v1alpha1.Kind("SampleSource")),
        Handler:    controller.HandleAll(impl.EnqueueControllerOf),
    })

    sinkBindingInformer.Informer().AddEventHandler(cache.FilteringResourceEventHandler{
        FilterFunc: controller.FilterGroupKind(v1alpha1.Kind("SampleSource")),
        Handler:    controller.HandleAll(impl.EnqueueControllerOf),
    })
```

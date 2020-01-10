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
	"knative.dev/sample-source/pkg/reconciler"

	// This defines the shared main for injected controllers.
	"knative.dev/pkg/injection/sharedmain"
)

func main() {
	sharedmain.Main("sample-sourcecontroller",
		reconciler.NewController,
	)
}
```
Define the NewController implementation, it will be passed a configmap.Watcher, as well as a context which the injected listers will use for the reconciler struct arguments
```go
const (
	controllerAgentName = "sample-source-controller"
)

func NewController(
	ctx context.Context,
	cmw configmap.Watcher,
) *controller.Impl {
…
	sampleSourceInformer := samplesourceinformer.Get(ctx)

	r := &Reconciler{
		Base:                  reconciler.NewBase(ctx, controllerAgentName, cmw),
		samplesourceLister:    sampleSourceInformer.Lister(),
		deploymentLister:      deploymentInformer.Lister(),
		samplesourceClientSet: samplesourceClient.Get(ctx),
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
	sampleSourceInformer.Informer().AddEventHandler(controller.HandleAll(impl.Enqueue))
```

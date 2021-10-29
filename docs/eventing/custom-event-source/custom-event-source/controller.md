# Create a controller

You can use the sample repository [`update-codegen.sh`](https://github.com/knative-sandbox/sample-source/blob/main/hack/update-codegen.sh) script to generate and inject the required components (the `clientset`, `cache`, `informers`, and `listers`) into your custom controller.

**Example controller:**

```go
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

## Procedure

1. Generate the components by running the command:

    ```bash
    ${CODEGEN_PKG}/generate-groups.sh "deepcopy,client,informer,lister" \
      knative.dev/sample-source/pkg/client knative.dev/sample-source/pkg/apis \
      "samples:v1alpha1" \
      --go-header-file ${REPO_ROOT}/hack/boilerplate/boilerplate.go.txt
    ```

1. Inject the components by running the command:

    ```bash
    # Injection
    ${KNATIVE_CODEGEN_PKG}/hack/generate-knative.sh "injection" \
      knative.dev/sample-source/pkg/client knative.dev/sample-source/pkg/apis \
      "samples:v1alpha1" \
      --go-header-file ${REPO_ROOT}/hack/boilerplate/boilerplate.go.txt
    ```

1. Pass the new controller implementation to the `sharedmain` method:

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

1. Define the `NewController` implementation:

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

    A `configmap.Watcher` and a context, which the injected listers use for the reconciler struct arguments, are passed to this implementation.

1. Import the base reconciler from the `knative.dev/pkg` dependency:

    ```go
    import (
        // ...
        reconcilersource "knative.dev/eventing/pkg/reconciler/source"
        // ...
    )
    ```

1. Ensure that the event handlers are being filtered to the correct informers:

    ```go
        sampleSourceInformer.Informer().AddEventHandler(controller.HandleAll(impl.Enqueue))
    ```

1. Ensure that informers are configured correctly for the secondary resources used by the sample source to deploy and bind the event source and the receive adapter:

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

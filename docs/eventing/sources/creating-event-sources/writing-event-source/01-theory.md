# Topics

### Source library (provided by Knative):
* Controller runtime (this is what we share via injection) incorporates protocol specific config into "generic controller" CRD.
* Identifying specific event characteristics (i.e. value of interest, relevant metadata, etc) to pass along to the serverless system
* Propagating events internally to the system (i.e. cloudevents)

# Theory

To achieve this, there are several separations of concerns that we have to keep in mind:
1. A controller to run our Event Source and reconcile the underlying `Receive Adapter` deployments
2. A "receive adapter" which generates or imports the actual events
3. A series of identifying characteristics for our event
4. Transporting a valid event to the serverless system for further processing

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

Sample source's [`update-codegen.sh`](https://github.com/knative-sandbox/sample-source/blob/main/hack/update-codegen.sh) have the configuration
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
* `pkg/reconciler/sample/controller.go` - NewController implementation to pass to sharedmain
* `pkg/reconciler/sample/samplesource.go` - reconciliation functions for the receive adapter
* `pkg/apis/samples/VERSION/samplesource_types.go` - schema for the underlying api types (variables to be defined in the resource yaml)
* `pkg/apis/samples/VERSION/samplesource_lifecycle.go` - status updates for the source’s reconciliation details
  * Source ready
  * Sink provided
  * Deployed
  * Eventtype Provided
  * K8s Resources Correct
* `pkg/adapter/adapter.go` - receive_adapter functions supporting translation of events to CloudEvents

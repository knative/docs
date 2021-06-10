# Using the Knative sandbox sample source

You can use the files provided in the [Knative sandbox sample repository](https://github.com/knative-sandbox/sample-source) to create an event source. This method requires you to create an event source controller and receiver adapter.

To simplify writing a new event source, the Knative Eventing provides several core functionalities in the `eventing-sources-controller` by using [dependency injection](https://docs.google.com/presentation/d/e/2PACX-1vQbpISBvY7jqzu2wy2t1_0R4LSBEBS0JrUS7M7V3BMVqy2K1Zk_0Xhy7WPPaeANLHE0yqtz1DuWlSAl/pub?resourcekey=0-mf6dN2vu9SS3bo2TUeCk9Q&slide=id.g596dcbbefb_0_40).

![Simplified controller](https://raw.githubusercontent.com/knative/docs/main/docs/eventing/samples/writing-event-source/simplified-controller.png)

Sources must implement CloudEvent binding interfaces. The [Go SDK for CloudEvents](https://github.com/cloudevents/sdk-go) provides libraries for standard access to configure interfaces.

## Prerequisites

- You are familiar with Kubernetes and Go development.
- You have installed Git.
- You have installed Go.
- Clone the [sample source](https://github.com/knative-sandbox/sample-source).
- Install the [ko](https://github.com/google/ko/) CLI tool.
- Install the [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) CLI tool.
- Set up [minikube](https://github.com/kubernetes/minikube).

## Creating a contoller

1. Pass the sample controller implementation to the shared `main` method:

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

    A `configmap.Watcher` is passed to the implementation, as well as a `context` object, which the injected listers will use for the reconciler struct arguments.

1. Import the base reconciler from the `knative.dev/pkg` dependency:

    ```go
    import (
    // ...
    reconcilersource "knative.dev/eventing/pkg/reconciler/source"
    // ...
    )
    ```

1. Ensure that the `EventHandlers` are being filtered to the correct informers:

    ```go
    	sampleSourceInformer.Informer().AddEventHandler(controller.HandleAll(impl.Enqueue))
    ```

1. Ensure that the informers are set up correctly to use secondary sources, namely the Deployment and SinkBinding resources:

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

    The controller of the sample source uses Deployment and SinkBinding resources to deploy and bind the event source and the receive adapter.

## Creating a receiver adapter

When you expose the protocol configuration as part of the Source resource, the controller passes any required configuration, such as resolved data like URLs, to the receiver adapter.

The following API resources are required:

- The `KubeClientSet.Appsv1.Deployment` is inherited from the Knative Eventing base reconciler, and is used to deploy the receiver adapter for importing events.
- The `EventingClientSet.EventingV1Alpha1` is inherited from the Knative Eventing base reconciler, and is used to interact with events within the Knative system.
* The `SourceClientSet.SourcesV1Alpha1` is used to specify the configuration of the event source, and is translated to the underlying Deployment by the inherited KubeClientSet.

### Receiver adapter cmd

Similarly to the controller, you need an injection based `main.go` under `cmd/receiver_adapter/main.go`:

    ```go
    // This Adapter generates events at a regular interval.
    package main

    import (
    	"knative.dev/eventing/pkg/adapter"
    	myadapter "knative.dev/sample-source/pkg/adapter"
    )

    func main() {
    	adapter.Main("sample-source", myadapter.NewEnv, myadapter.NewAdapter)
    }

    ```

### Defining the NewAdapter implementation and Start function

The `pkg` implementation for the receiver adapter consists of two main functions:

1. A `NewAdapter(ctx context.Context, aEnv adapter.EnvConfigAccessor, ceClient cloudevents.Client) adapter.Adapter {}` call, which creates the new adapter with variables passed from the `EnvConfigAccessor`.

    The CloudEvent client, which is sometimes referred to as a sink, or `ceClient` in the Knative ecosystem, is passed to the adapter. The return value is a reference to the adapter as defined by the local `struct` of the adapter.

    ```go
    // Adapter generates events at a regular interval.
    type Adapter struct {
    	logger   *zap.Logger
    	interval time.Duration
    	nextID   int
    	client   cloudevents.Client
    }
    ```

1. A `Start` function, which is implemented as an interface to the adapter `struct`:

    ```go
    func (a *Adapter) Start(stopCh <-chan struct{}) error {
    ```

    `stopCh` is the signal to stop the adapter. The role of this function is to process the next event. In the case of the `sample-source`, it creates an event to forward to the specified CloudEvent client, or sink, at every X interval, as specified by the loaded `EnvConfigAccessor`. The `EnvConfigAccessor`is loaded by the resource YAML.

    ```go
    func (a *Adapter) Start(stopCh <-chan struct{}) error {
        a.logger.Infow("Starting heartbeat", zap.String("interval", a.interval.String()))
    	for {
    		select {
    		case <-time.After(a.interval):
    			event := a.newEvent()
    			a.logger.Infow("Sending new event", zap.String("event", event.String()))
    			if result := a.client.Send(context.Background(), event); !cloudevents.IsACK(result) {
                    a.logger.Infow("failed to send event", zap.String("event", event.String()), zap.Error(result))
                    // We got an error but it could be transient, try again next interval.
                    continue
                }
    		case <-stopCh:
    			a.logger.Info("Shutting down...")
    			return nil
    		}
    	}
    }
    ```

# Publishing the new Source to your Kubernetes cluster

1. Run the sample source locally, by starting a minikube cluster.

    ```sh
    minikube start
    ```

    !!! note
        If you have an existing Kubernetes 1.15+ cluster you can use this instead.

1. Setup `ko` to use the minikube docker instance and local registry:

    ```sh
    eval $(minikube docker-env)
    export KO_DOCKER_REPO=ko.local
    ```

1. Apply the CRD and configuration YAML:

    ```sh
    ko apply -f config
    ```

1. Once the `sample-source-controller-manager` is running in the `knative-samples` namespace, you can apply the `example.yaml` to connect the `sample-source` every `10s` directly to a Knative Service.

    ```yaml
    kubectl apply -f - <<<EOF
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: event-display
      namespace: knative-samples
    spec:
      template:
        spec:
          containers:
            - image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
    ---
    apiVersion: samples.knative.dev/v1alpha1
    kind: SampleSource
    metadata:
      name: sample-source
      namespace: knative-samples
    spec:
      interval: "10s"
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: event-display
    EOF
    ```

    ```sh
    ko apply -f example.yaml
    ```

1. Once it has reconciled, confirm that the Service is outputting valid CloudEvents every `10s` to align with the specified interval:

    ```sh
    % kubectl -n knative-samples logs -l serving.knative.dev/service=event-display -c user-container -f
    ```

    The output looks similar to the following:

    ```
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: dev.knative.sample
      source: http://sample.knative.dev/heartbeat-source
      id: d4619592-363e-4a41-82d1-b1586c390e24
      time: 2019-12-17T01:31:10.795588888Z
      datacontenttype: application/json
    Data,
      {
        "Sequence": 0,
        "Heartbeat": "10s"
      }
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: dev.knative.sample
      source: http://sample.knative.dev/heartbeat-source
      id: db2edad0-06bc-4234-b9e1-7ea3955841d6
      time: 2019-12-17T01:31:20.825969504Z
      datacontenttype: application/json
    Data,
      {
        "Sequence": 1,
        "Heartbeat": "10s"
      }
    ```

## Moving the event source to knative-sandbox

If you would like to move your source over to the [`knative-sandbox`](https://github.com/knative-sandbox) organization follow the instructions to [create a sandbox repository](https://knative.dev/community/contributing/mechanics/creating-a-sandbox-repo/).

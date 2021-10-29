# Create a receive adapter

As part of the source reconciliation process, you must create and deploy the underlying receive adapter.

The receive adapter requires an injection-based `main` method that is located in `cmd/receiver_adapter/main.go`:

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

The receive adapter's `pkg` implementation consists of two main functions:

1. A `NewAdapter(ctx context.Context, aEnv adapter.EnvConfigAccessor, ceClient cloudevents.Client) adapter.Adapter {}` call, which creates the
new adapter with passed variables via the `EnvConfigAccessor`. The created adapter is passed the CloudEvents client (which is where the events are forwarded to). This is sometimes referred to as a sink, or `ceClient` in the Knative ecosystem.  The return value is a reference to the adapter as defined by the adapter's local struct.

    In the case of the sample source:

    ```go
    // Adapter generates events at a regular interval.
    type Adapter struct {
    	logger   *zap.Logger
    	interval time.Duration
    	nextID   int
    	client   cloudevents.Client
    }
    ```

1. A `Start` function, implemented as an interface to the adapter `struct`:

    ```go
    func (a *Adapter) Start(stopCh <-chan struct{}) error {
    ```

    `stopCh` is the signal to stop the adapter. Otherwise, the role of the function is to process the next event.

    In the case of the `sample-source`, this function creates a CloudEvent to forward to the specified sink every X interval, as specified by the `EnvConfigAccessor` parameter, which is loaded by the resource YAML:

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

## Managing the Receive Adapter in the Controller

1. Update the `ObservedGeneration` and initialize the `Status` conditions, as defined in the `samplesource_lifecycle.go` and `samplesource_types.go` files:

    ```go
    src.Status.InitializeConditions()
    src.Status.ObservedGeneration = src.Generation
    ```

1. Create a receive adapter.

    1. Verify that the specified Kubernetes resources are valid, and update the `Status` accordingly.

    1. Assemble the `ReceiveAdapterArgs`:

        ```go
        raArgs := resources.ReceiveAdapterArgs{
        		EventSource:    src.Namespace + "/" + src.Name,
                Image:          r.ReceiveAdapterImage,
                Source:         src,
                Labels:         resources.Labels(src.Name),
                AdditionalEnvs: r.configAccessor.ToEnvVars(), // Grab config envs for tracing/logging/metrics
        	}
        ```

        !!! note
            The exact arguments may change based on functional requirements. Create the underlying deployment from the arguments provided, matching pod templates, labels, owner references, etc as needed to fill out the deployment. Example: [pkg/reconciler/sample/resources/receive_adapter.go](https://github.com/knative-sandbox/sample-source/blob/main/pkg/reconciler/sample/resources/receive_adapter.go)

    1. Fetch the existing receive adapter deployment:

        ```go
        namespace := owner.GetObjectMeta().GetNamespace()
        ra, err := r.KubeClientSet.AppsV1().Deployments(namespace).Get(expected.Name, metav1.GetOptions{})
        ```

    1. If there is no existing receive adapter deployment, create one:

        ```go
        ra, err = r.KubeClientSet.AppsV1().Deployments(namespace).Create(expected)
        ```

    1. Check if the expected spec is different from the existing spec, and update the deployment if required:

        ```go
        } else if r.podSpecImageSync(expected.Spec.Template.Spec, ra.Spec.Template.Spec) {
            ra.Spec.Template.Spec = expected.Spec.Template.Spec
            if ra, err = r.KubeClientSet.AppsV1().Deployments(namespace).Update(ra); err != nil {
                return ra, err
            }
        ```

    1. If updated, record the event:

        ```go
        return pkgreconciler.NewEvent(corev1.EventTypeNormal, "DeploymentUpdated", "updated deployment: \"%s/%s\"", namespace, name)
        ```

    1. If successful, update the `Status` and `MarkDeployed`:

        ```go
        src.Status.PropagateDeploymentAvailability(ra)
        ```

1. Create a SinkBinding to bind the receive adapter with the sink.

    1. Create a `Reference` for the receive adapter deployment. This deployment is the SinkBinding's source:

        ```go
        tracker.Reference{
            APIVersion: appsv1.SchemeGroupVersion.String(),
            Kind:       "Deployment",
            Namespace:  ra.Namespace,
            Name:       ra.Name,
        }
        ```

    1. Fetch the existing SinkBinding:

        ```go
        namespace := owner.GetObjectMeta().GetNamespace()
        sb, err := r.EventingClientSet.SourcesV1alpha2().SinkBindings(namespace).Get(expected.Name, metav1.GetOptions{})
        ```

    1. If there is no existing SinkBinding, create one:

        ```go
        sb, err = r.EventingClientSet.SourcesV1alpha2().SinkBindings(namespace).Create(expected)
        ```

    1. Check if the expected spec is different to the existing spec, and update the SinkBinding if required:

        ```go
        else if r.specChanged(sb.Spec, expected.Spec) {
            sb.Spec = expected.Spec
            if sb, err = r.EventingClientSet.SourcesV1alpha2().SinkBindings(namespace).Update(sb); err != nil {
                return sb, err
            }
        ```

    1. If updated, record the event:

        ```go
        return pkgreconciler.NewEvent(corev1.EventTypeNormal, "SinkBindingUpdated", "updated SinkBinding: \"%s/%s\"", namespace, name)
        ```

    1. `MarkSink` with the result:

        ```go
        src.Status.MarkSink(sb.Status.SinkURI)
        ```

1. Return a new reconciler event stating that the process is done:

    ```go
    return pkgreconciler.NewEvent(corev1.EventTypeNormal, "SampleSourceReconciled", "SampleSource reconciled: \"%s/%s\"", namespace, name)
    ```

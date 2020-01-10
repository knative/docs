---
title: "Receive Adapter Implementation and Design"
linkTitle: "Receieve Adapter Implementation"
weight: 50
type: "docs"
---

## Receive Adapter cmd
Similar to the controller, we'll need an injection based main.go similar to the controller
under `cmd/receiver_adapter/main.go`
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

## Defining NewAdapter implmentation and Start function
The adapter's `pkg` implemenation constists of two main functions;

a `NewAdapter(ctx context.Context, aEnv adapter.EnvConfigAccessor, sink cloudevents.Client, reporter source.StatsReporter) adapter.Adapter {}` call.  Which creates the new adapter with passed variables via the EnvConfigAccessor, and sets up the cloudevents client (which is where the events are forwarded to).  This is sometimes refered to as a sink, or ceClient in the knative ecosystem.  The return value is a refernce to the adapter as defined by the adapter's local struct.

In our `sample-source`'s case;
```go
// Adapter generates events at a regular interval.
type Adapter struct {
	logger   *zap.Logger
	interval time.Duration
	nextID   int
	sink     cloudevents.Client
}
```

The second required function is the `Start` function implmented as an interface to the adapter struct.
for example:
```go
func (a *Adapter) Start(stopCh <-chan struct{}) error {
```
Where `stopCh` is the signal to stop the Adapter.  Otherwise the role of the funtion is to process the next
event.  In the case of the `sample-source`, it creates an event to forward to the specificed cloudevent sink/client
every X interval, as specified by the loaded EnvConfigAccessor (loaded via the resource yaml).
```go
func (a *Adapter) Start(stopCh <-chan struct{}) error {
	a.logger.Info("Starting with: ",
		zap.String("Interval: ", a.interval.String()))
	for {
		select {
		case <-time.After(a.interval):
			event := a.newEvent()
			a.logger.Info("Sending new event: ", zap.String("event", event.String()))
			_, _, err := a.sink.Send(context.Background(), event)
			if err != nil {
				return err
			}
		case <-stopCh:
			a.logger.Info("Shutting down...")
			return nil
		}
	}
}
```

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
		r.Recorder.Eventf(src, corev1.EventTypeNormal, samplesourceDeploymentUpdated, "Deployment updated")
		return ra, nil
```

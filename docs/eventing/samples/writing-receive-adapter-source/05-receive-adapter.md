---
title: "Receive Adapter Implementation and Design"
linkTitle: "Receieve Adapter Implementation"
weight: 50
type: "docs"
---

## Receive Adapter cmd
Similar to the controller, we'll need an injection based `main.go` similar to the controller under `cmd/receiver_adapter/main.go`
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

## Defining NewAdapter implementation and Start function
The adapter's `pkg` implementation consists of two main functions;

1. A `NewAdapter(ctx context.Context, aEnv adapter.EnvConfigAccessor, ceClient cloudevents.Client) adapter.Adapter {}` call, which creates the
new adapter with passed variables via the `EnvConfigAccessor`. The created adapter will be passed the cloudevents client (which is where the events are forwarded to). This is sometimes referred
to as a sink, or `ceClient` in the Knative ecosystem.  The return value is a reference to the adapter as defined by the adapter's local struct.

In our `sample-source`'s case;
```go
// Adapter generates events at a regular interval.
type Adapter struct {
	logger   *zap.Logger
	interval time.Duration
	nextID   int
	client   cloudevents.Client
}
```

2. `Start` function implemented as an interface to the adapter struct.
```go
func (a *Adapter) Start(stopCh <-chan struct{}) error {
```
`stopCh` is the signal to stop the Adapter.  Otherwise the role of the function is to process the next
event.  In the case of the `sample-source`, it creates an event to forward to the specified cloudevent sink/client
every X interval, as specified by the loaded `EnvConfigAccessor` (loaded via the resource yaml).
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

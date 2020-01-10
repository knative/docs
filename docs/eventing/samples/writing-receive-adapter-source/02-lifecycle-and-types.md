---
title: "Sample Source Lifecycle and Types"
linkTitle: "Lifecycle and Types"
weight: 20
type: "docs"
---

## API Definition
1. Define the types required in the resource’s schema in
`pkg/apis/samples/v1alpha1/samplesource_types.go`
This includes the fields that will be required in the resource yaml as
well as what will be referenced in the controller using the source’s
clientset and API

```go
type SampleSource struct {
	metav1.TypeMeta `json:",inline"`
	// +optional
	metav1.ObjectMeta `json:"metadata,omitempty"`

	// Spec holds the desired state of the SampleSource (from the client).
	Spec SampleSourceSpec `json:"spec"`

	// Status communicates the observed state of the SampleSource (from the controller).
	// +optional
	Status SampleSourceStatus `json:"status,omitempty"`
}

// SampleSourceSpec holds the desired state of the SampleSource (from the client).
type SampleSourceSpec struct {
	// ServiceAccountName holds the name of the Kubernetes service account
	// as which the underlying K8s resources should be run. If unspecified
	// this will default to the "default" service account for the namespace
	// in which the SampleSource exists.
	// +optional
	ServiceAccountName string `json:"serviceAccountName,omitempty"`

	// Interval is the time interval between events.
	//
	// The string format is a sequence of decimal numbers, each with optional
	// fraction and a unit suffix, such as "300ms", "-1.5h" or "2h45m". Valid time
	// units are "ns", "us" (or "µs"), "ms", "s", "m", "h".
	Interval string `json:"interval"`

	// Sink is a reference to an object that will resolve to a host
	// name to use as the sink.
	Sink *duckv1.Destination `json:"sink"`
}

// SampleSourceStatus communicates the observed state of the SampleSource (from the controller).
type SampleSourceStatus struct {
	duckv1.Status `json:",inline"`

	// SinkURI is the current active sink URI that has been configured
	// for the SampleSource.
	// +optional
	SinkURI *apis.URL `json:"sinkUri,omitempty"`
}
```
Define the lifecycle that will be reflected in the status and SinkURI fields

```go
const (
	// SampleConditionReady has status True when the SampleSource is ready to send events.
	SampleConditionReady = apis.ConditionReady
    // ...
)

```
Define the functions that will be called from the Reconciler functions to set the lifecycle conditions.  This is typically done in
`pkg/apis/samples/VERSION/sampleservice_lifecycle.go`

```go
// InitializeConditions sets relevant unset conditions to Unknown state.
func (s *SampleSourceStatus) InitializeConditions() {
	SampleCondSet.Manage(s).InitializeConditions()
}

...

// MarkSink sets the condition that the source has a sink configured.
func (s *SampleSourceStatus) MarkSink(uri *apis.URL) {
	s.SinkURI = uri
	if len(uri.String()) > 0 {
		SampleCondSet.Manage(s).MarkTrue(SampleConditionSinkProvided)
	} else {
		SampleCondSet.Manage(s).MarkUnknown(SampleConditionSinkProvided, "SinkEmpty", "Sink has resolved to empty.%s", "")
	}
}

// MarkNoSink sets the condition that the source does not have a sink configured.
func (s *SampleSourceStatus) MarkNoSink(reason, messageFormat string, messageA ...interface{}) {
	SampleCondSet.Manage(s).MarkFalse(SampleConditionSinkProvided, reason, messageFormat, messageA...)
}
```

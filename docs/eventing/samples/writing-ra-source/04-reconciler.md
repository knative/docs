---
title: "Receive Adapter Implementation and Design"
linkTitle: "Receieve Adapter Implementation"
weight: 40
type: "docs"
---

## Reconciler Functionality
General steps the reconciliation process needs to cover:
1. Target the specific samplesource via the `sampleServiceClientSet`:
```go
// Get the resource with this namespace/name.
original, err := r.Lister.SampleSources(namespace).Get(name)
```
2. Update the ObservedGeneration
Initialize the Status conditions (as defined in `samplesource_lifecycle.go` and `samplesource_types.go`)
3. Reconcile the Sink and MarkSink with the result
Create the Receive Adapter (detailed below)
    3. If successful, update the Status and MarkDeployed
4. Reconcile the EventTypes and corresponding Status
Creation and deletion of the events is done with the inherited `EventingClientSet().EventingV1alpha1()` api
5. Update the full status field from the resulting reconcile attempt via the source’s clientset and api
`r.samplesourceClientSet.SamplesV1alpha1().SampleSources(desired.Namespace).UpdateStatus(existing)`


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


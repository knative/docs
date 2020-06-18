---
title: "Reconciler Implementation and Design"
linkTitle: "Reconciler Implementation"
weight: 40
type: "docs"
---

## Reconciler Functionality
General steps the reconciliation process needs to cover:
1. Update the `ObservedGeneration` and initialize the `Status` conditions (as defined in `samplesource_lifecycle.go` and `samplesource_types.go`)
```go
src.Status.InitializeConditions()
src.Status.ObservedGeneration = src.Generation
```
2. Create/reconcile the Receive Adapter (detailed below)
3. If successful, update the `Status` and `MarkDeployed`
```go
src.Status.PropagateDeploymentAvailability(ra)
```
4. Create/reconcile the `SinkBinding` for the Receive Adapter targeting the `Sink` (detailed below)
5. MarkSink with the result
```go
src.Status.MarkSink(sb.Status.SinkURI)
```
6. Return a new reconciler event stating that the process is done
```go
return pkgreconciler.NewEvent(corev1.EventTypeNormal, "SampleSourceReconciled", "SampleSource reconciled: \"%s/%s\"", namespace, name)
```

## Reconcile/Create The Receive Adapter
As part of the source reconciliation, we have to create and deploy
(and update if necessary) the underlying receive adapter.

Verify the specified kubernetes resources are valid, and update the `Status` accordingly

Assemble the ReceiveAdapterArgs
```go
raArgs := resources.ReceiveAdapterArgs{
		EventSource:    src.Namespace + "/" + src.Name,
        Image:          r.ReceiveAdapterImage,
        Source:         src,
        Labels:         resources.Labels(src.Name),
        AdditionalEnvs: r.configAccessor.ToEnvVars(), // Grab config envs for tracing/logging/metrics
	}
```
NB The exact arguments may change based on functional requirements
Create the underlying deployment from the arguments provided, matching pod templates, labels, owner references, etc as needed to fill out the deployment
Example: [pkg/reconciler/sample/resources/receive_adapter.go](https://github.com/knative/sample-source/blob/master/pkg/reconciler/sample/resources/receive_adapter.go)

1. Fetch the existing receive adapter deployment
```go
namespace := owner.GetObjectMeta().GetNamespace()
ra, err := r.KubeClientSet.AppsV1().Deployments(namespace).Get(expected.Name, metav1.GetOptions{})
```
2. Otherwise, create the deployment
```go
ra, err = r.KubeClientSet.AppsV1().Deployments(namespace).Create(expected)
```
3. Check if the expected vs existing spec is different, and update the deployment if required
```go
} else if r.podSpecImageSync(expected.Spec.Template.Spec, ra.Spec.Template.Spec) {
    ra.Spec.Template.Spec = expected.Spec.Template.Spec
    if ra, err = r.KubeClientSet.AppsV1().Deployments(namespace).Update(ra); err != nil {
        return ra, err
    }
```
4. If updated, record the event
```go
return pkgreconciler.NewEvent(corev1.EventTypeNormal, "DeploymentUpdated", "updated deployment: \"%s/%s\"", namespace, name)
```

## Reconcile/Create The SinkBinding
Instead of directly giving the details of the sink to the receive adapter, use a `SinkBinding` to bind the receive adapter with the sink.

Steps here are almost the same with the `Deployment` reconciliation above, but it is for another resource, `SinkBinding`.

1. Create a `Reference` for the receive adapter deployment. This deployment will be `SinkBinding`'s source:
```go
tracker.Reference{
    APIVersion: appsv1.SchemeGroupVersion.String(),
    Kind:       "Deployment",
    Namespace:  ra.Namespace,
    Name:       ra.Name,
}
```
2. Fetch the existing `SinkBinding`
```go
namespace := owner.GetObjectMeta().GetNamespace()
sb, err := r.EventingClientSet.SourcesV1alpha2().SinkBindings(namespace).Get(expected.Name, metav1.GetOptions{})
```
2. If it doesn't exist, create it
```go
sb, err = r.EventingClientSet.SourcesV1alpha2().SinkBindings(namespace).Create(expected)
```
3. Check if the expected vs existing spec is different, and update the `SinkBinding` if required
```go
else if r.specChanged(sb.Spec, expected.Spec) {
    sb.Spec = expected.Spec
    if sb, err = r.EventingClientSet.SourcesV1alpha2().SinkBindings(namespace).Update(sb); err != nil {
        return sb, err
    }
```
4. If updated, record the event
```go
return pkgreconciler.NewEvent(corev1.EventTypeNormal, "SinkBindingUpdated", "updated SinkBinding: \"%s/%s\"", namespace, name)
```

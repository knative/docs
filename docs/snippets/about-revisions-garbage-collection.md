<!-- Snippet used in the following topics:
- docs/serving/revisions/revision-admin-config-options.md
- docs/serving/revisions/revision-developer-config-options.md
-->
When Revisions of a Knative Service are inactive, they are automatically cleaned up and cluster resources are reclaimed after a set time period. This is known as *[garbage collection](https://kubernetes.io/docs/concepts/architecture/garbage-collection/){target=_blank}*.

You can configure garbage collection parameters a specific Revision if you are a developer. You can also configure default, cluster-wide garbage collection parameters for all the Revisions of all the Services on a cluster if you have cluster administrator permissions.

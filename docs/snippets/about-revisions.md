<!-- Snippet used in the following topics:
- /docs/serving/revisions/README.md
- /docs/serving/README.md
-->

A Revision is an [immutable object](https://en.wikipedia.org/wiki/Immutable_object) that captures a point-in-time snapshot of the code and Configuration for each change made to a Knative Service.
<!--TODO: explain Configuration and link to docs for this-->

Revisions can be retained for as long as useful. Revisions that are not addressable via a Route may be garbage collected and all underlying Kubernetes resources will be deleted. Revisions that are addressable via a Route will have resource utilization proportional to the load they are under.

Service can be defined to always route traffic to the latest revision or to a pinned revision.

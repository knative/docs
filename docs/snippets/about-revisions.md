<!-- Snippet used in the following topics:
- /docs/concepts/servng-resources/revisions.md
- /docs/serving/revisions/README.md
-->
Revisions are Knative Serving resources that contain point-in-time snapshots of the application code and configuration for each change made to a Knative Service.

You cannot create Revisions or update a Revision spec directly; Revisions are always created in response to updates to a Configuration spec. However, you can force the deletion of Revisions, to handle leaked resources as well as for removal of known bad Revisions to avoid future errors when managing a Knative Service.

Revisions are generally immutable, except where they may reference mutable core Kubernetes resources such as ConfigMaps and Secrets. Revisions can also be mutated by changes in Revision defaults. Changes to defaults that mutate Revisions are generally syntactic and not semantic.

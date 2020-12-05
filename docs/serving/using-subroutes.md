---
title: "Creating and using Subroutes"
weight: 20
type: "docs"
---

Subroutes are most effective when used with multiple revisions. When defining a Knative service/route, the traffic section of the spec can split between the different revisions. For example:

```yaml
traffic:
- percent: 0
  revisionName: foo
- percent: 40
  revisionName: bar
- percent: 60
  revisionName: baz
```

This allows anyone targeting the main route to have a 0% chance of hitting revision `foo`, 40% chance of hitting revision `bar` and 60% chance of hitting revision `baz`.

## Using tags to create target URLs

The spec defines an attribute called `tag`. When a `tag` is applied to a route, an address for the specific traffic target is created.

```yaml
traffic:
- percent: 0
  revisionName: foo
  tag: staging
- percent: 40
  revisionName: bar
- percent: 60
  revisionName: baz
```

In the above example, you can access the staging target by accessing `staging-<route name>.<namespace>.<domain>`. The targets for `bar` and `baz` can only be accessed using the main route, `<route name>.<namespace>.<domain>`.

When a traffic target gets tagged, a new Kubernetes service is created for it so that other services can also access it within the cluster. From the above example, a new Kubernetes service called `staging-<route name>` will be created in the same namespace. This service has the ability to override the visibility of this specific route by applying the label `serving.knative.dev/visibility` with value `cluster-local`. See [cluster local routes](./cluster-local-route.md#label-a-service-to-be-cluster-local) for more information about how to restrict visibility on the specific route.

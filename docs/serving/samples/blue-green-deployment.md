---
title: "Routing and managing traffic with blue/green deployment"
linkTitle: "Routing and managing traffic"
weight:
type: "docs"
---

This sample demonstrates updating an application to a new version using a
blue/green traffic routing pattern. With Knative, you can safely reroute traffic
from a live version of an application to a new version by changing the routing
configuration.

## Before you begin

You need:

- A Kubernetes cluster with [Knative installed](../../install/README.md).
- (Optional) [A custom domain configured](../using-a-custom-domain.md) for use
  with Knative.

Note: The source code for the gcr.io/knative-samples/knative-route-demo image
that is used in this sample, is located at
https://github.com/mchmarny/knative-route-demo.

## Deploying Revision 1 (Blue)

We'll be deploying an image of a sample application that displays the text "App
v1" on a blue background.

First, create a new file called `blue-green-demo-config.yaml`and copy this into
it:

```yaml
apiVersion: serving.knative.dev/v1
kind: Configuration
metadata:
  name: blue-green-demo
  namespace: default
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-samples/knative-route-demo:blue # The URL to the sample app docker image
          env:
            - name: T_VERSION
              value: "blue"
```

Save the file, then deploy the configuration to your cluster:

```bash
kubectl apply --filename blue-green-demo-config.yaml

configuration "blue-green-demo" configured
```

This will deploy the initial revision of the sample application. Before we can
route traffic to this application we need to know the name of the initial
revision which was just created. Using `kubectl` you can get it with the
following command:

```bash
kubectl get configurations blue-green-demo -o=jsonpath='{.status.latestCreatedRevisionName}'
```

The command above will return the name of the revision, it will be similar to
`blue-green-demo-lcfrd`. In the rest of this document we will use this revision
name, but yours will be different.

To route inbound traffic to it, we need to define a route. Create a new file
called `blue-green-demo-route.yaml` and copy the following YAML manifest into it
(do not forget to edit the revision name):

```yaml
apiVersion: serving.knative.dev/v1
kind: Route
metadata:
  name: blue-green-demo # The name of our route; appears in the URL to access the app
  namespace: default # The namespace we're working in; also appears in the URL to access the app
spec:
  traffic:
    - revisionName: blue-green-demo-lcfrd
      percent: 100 # All traffic goes to this revision
```

Save the file, then apply the route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

You'll now be able to view the sample app at the URL shown by:

```
kubectl get route blue-green-demo
```

## Deploying Revision 2 (Green)

Revision 2 of the sample application will display the text "App v2" on a green
background. To create the new revision, we'll edit our existing configuration in
`blue-green-demo-config.yaml` with an updated image and environment variables:

```yaml
apiVersion: serving.knative.dev/v1
kind: Configuration
metadata:
  name: blue-green-demo # Configuration name is unchanged, since we're updating an existing Configuration
  namespace: default
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-samples/knative-route-demo:green # URL to the new version of the sample app docker image
          env:
            - name: T_VERSION
              value: "green" # Updated value for the T_VERSION environment variable
```

Save the file, then apply the updated configuration to your cluster:

```bash
kubectl apply --filename blue-green-demo-config.yaml

configuration "blue-green-demo" configured
```

Find the name of the second revision with the following command:

```bash
kubectl get configurations blue-green-demo -o=jsonpath='{.status.latestCreatedRevisionName}'
```

In the rest of this document we will assume that the second revision is called
`blue-green-demo-m9548`, however yours will differ. Make sure to use the correct
name of the second revision in the manifests that follow.

At this point, the first revision (`blue-green-demo-lcfrd`) and the second
revision (`blue-green-demo-m9548`) will both be deployed and running. We can
update our existing route to create a new (test) endpoint for the second
revision while still sending all other traffic to the first revision. Edit
`blue-green-demo-route.yaml`:

```yaml
apiVersion: serving.knative.dev/v1
kind: Route
metadata:
  name: blue-green-demo # Route name is unchanged, since we're updating an existing Route
  namespace: default
spec:
  traffic:
    - revisionName: blue-green-demo-lcfrd
      percent: 100 # All traffic still going to the first revision
    - revisionName: blue-green-demo-m9548
      percent: 0 # 0% of traffic routed to the second revision
      tag: v2 # A named route
```

Save the file, then apply the updated route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

Revision 2 of the app is staged at this point. That means:

- No traffic will be routed to revision 2 at the main URL,
  `http://blue-green-demo.default.[YOUR_CUSTOM_DOMAIN].com`
- Knative creates a new route named v2 for testing the newly deployed version.
  The URL of this can be seen in the status section of your Route.

```bash
kubectl get route blue-green-demo --output jsonpath="{.status.traffic[*].url}"
```

This allows you to validate that the new version of the app is behaving as
expected before switching any traffic over to it.

## Migrating traffic to the new revision

We'll once again update our existing route to begin shifting traffic away from
the first revision and toward the second. Edit `blue-green-demo-route.yaml`:

```yaml
apiVersion: serving.knative.dev/v1
kind: Route
metadata:
  name: blue-green-demo # Updating our existing route
  namespace: default
spec:
  traffic:
    - revisionName: blue-green-demo-lcfrd
      percent: 50 # Updating the percentage from 100 to 50
    - revisionName: blue-green-demo-m9548
      percent: 50 # Updating the percentage from 0 to 50
      tag: v2
```

Save the file, then apply the updated route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

Refresh the original route
(`http://blue-green-demo.default.[YOUR_CUSTOM_DOMAIN].com`) a few times to see that
some traffic now goes to version 2 of the app.

> Note: This sample shows a 50/50 split to assure you don't have to refresh too
> much, but it's recommended to start with 1-2% of traffic in a production
> environment

## Rerouting all traffic to the new version

Lastly, we'll update our existing route to finally shift all traffic to the
second revision. Edit `blue-green-demo-route.yaml`:

```yaml
apiVersion: serving.knative.dev/v1
kind: Route
metadata:
  name: blue-green-demo # Updating our existing route
  namespace: default
spec:
  traffic:
    - revisionName: blue-green-demo-lcfrd
      percent: 0
      tag: v1 # Adding a new named route for v1
    - revisionName: blue-green-demo-m9548
      percent: 100
      # Named route for v2 has been removed, since we don't need it anymore
```

> Note: You can remove the first revision blue-green-demo-lcfrd instead of 0% of traffic
> when you will not roll back the revision anymore.
> Then the non-routeable revision object will be garbage collected.

Save the file, then apply the updated route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

Refresh the original route
(`http://blue-green-demo.default.[YOUR_CUSTOM_DOMAIN].com`) a few times to verify
that no traffic is being routed to v1 of the app.

We added a named route to v1 of the app, so you can now access it at the URL
listed in the traffic block of the status section. To get the URL, enter the
following command:

```bash
kubectl get route blue-green-demo --output jsonpath="{.status.traffic[*].url}"
```

With all inbound traffic being directed to the second revision of the
application, Knative will soon scale the first revision down to 0 running pods
and the blue/green deployment can be considered complete. Using the named `v1`
route will reactivate a pod to serve any occasional requests intended
specifically for the initial revision.

## Cleaning up

To delete the sample app, enter the following commands:

```
kubectl delete route blue-green-demo
kubectl delete configuration blue-green-demo
```

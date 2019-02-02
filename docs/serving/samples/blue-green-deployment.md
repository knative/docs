---
title: "Routing and managing traffic with blue/green deployment"
linkTitle: "Routing and managing traffic"
weight:
---

This sample demonstrates updating an application to a new version using a
blue/green traffic routing pattern. With Knative, you can safely reroute traffic
from a live version of an application to a new version by changing the routing
configuration.

## Before you begin

You need:

- A Kubernetes cluster with [Knative installed](../../../install/).
- (Optional)
  [A custom domain configured](../../../serving/using-a-custom-domain/) for use
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
apiVersion: serving.knative.dev/v1alpha1
kind: Configuration
metadata:
  name: blue-green-demo
  namespace: default
spec:
  revisionTemplate:
    metadata:
      labels:
        knative.dev/type: container
    spec:
      container:
        image: gcr.io/knative-samples/knative-route-demo:blue # The URL to the sample app docker image
        imagePullPolicy: Always
        env:
          - name: T_VERSION
            value: "blue"
```

Save the file, then deploy the configuration to your cluster:

```bash
kubectl apply --filename blue-green-demo-config.yaml

configuration "blue-green-demo" configured
```

This will deploy the initial revision (`blue-green-demo-00001`) of the sample
application. To route inbound traffic to it, we'll define a route. Create a new
file called `blue-green-demo-route.yaml` and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: blue-green-demo # The name of our route; appears in the URL to access the app
  namespace: default # The namespace we're working in; also appears in the URL to access the app
spec:
  traffic:
    - revisionName: blue-green-demo-00001
      percent: 100 # All traffic goes to this revision
```

Save the file, then apply the route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

You'll now be able to view the sample app at
http://blue-green-demo.default.YOUR_CUSTOM_DOMAIN.com (replace
`YOUR_CUSTOM_DOMAIN`) with the
[custom domain](../using-a-custom-domain/) you configured for use
with Knative.

> Note: If you don't have a custom domain configured for use with Knative, you
> can interact with your app using cURL requests if you have the host URL and IP
> address:
> `curl -H "Host: blue-green-demo.default.example.com" http://IP_ADDRESS`
>  Knative creates the host URL by combining the name of your Route object, the namespace,
> and `example.com`, if you haven't configured a custom domain. For example, `[route-name].[namespace].example.com`.
> You can get the IP address by entering `kubectl get svc istio-ingressgateway --namespace istio-system` (or
> `kubectl get svc istio-ingressgateway --namespace istio-system` if using Knative 0.2.x or prior versions)
> and copying the `EXTERNAL-IP` returned by that command. See [Interacting with your app](../../../install/getting-started-knative-app/#interacting-with-your-app)
> for more information.

## Deploying Revision 2 (Green)

Revision 2 of the sample application will display the text "App v2" on a green
background. To create the new revision, we'll edit our existing configuration in
`blue-green-demo-config.yaml` with an updated image and environment variables:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Configuration
metadata:
  name: blue-green-demo # Configuration name is unchanged, since we're updating an existing Configuration
  namespace: default
spec:
  revisionTemplate:
    metadata:
      labels:
        knative.dev/type: container
    spec:
      container:
        image: gcr.io/knative-samples/knative-route-demo:green # URL to the new version of the sample app docker image
        imagePullPolicy: Always
        env:
          - name: T_VERSION
            value: "green" # Updated value for the T_VERSION environment variable
```

Save the file, then apply the updated configuration to your cluster:

```bash
kubectl apply --filename blue-green-demo-config.yaml

configuration "blue-green-demo" configured
```

At this point, the first revision (`blue-green-demo-00001`) and the second
revision (`blue-green-demo-00002`) will both be deployed and running. We can
update our existing route to create a new (test) endpoint for the second
revision while still sending all other traffic to the first revision. Edit
`blue-green-demo-route.yaml`:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: blue-green-demo # Route name is unchanged, since we're updating an existing Route
  namespace: default
spec:
  traffic:
    - revisionName: blue-green-demo-00001
      percent: 100 # All traffic still going to the first revision
    - revisionName: blue-green-demo-00002
      percent: 0 # 0% of traffic routed to the second revision
      name: v2 # A named route
```

Save the file, then apply the updated route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

Revision 2 of the app is staged at this point. That means:

- No traffic will be routed to revision 2 at the main URL,
  http://blue-green-demo.default.YOUR_CUSTOM_DOMAIN.com
- Knative creates a new route named v2 for testing the newly deployed version at
  http://v2.blue-green-demo.default.YOUR_CUSTOM_DOMAIN.com

This allows you to validate that the new version of the app is behaving as
expected before switching any traffic over to it.

## Migrating traffic to the new revision

We'll once again update our existing route to begin shifting traffic away from
the first revision and toward the second. Edit `blue-green-demo-route.yaml`:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: blue-green-demo # Updating our existing route
  namespace: default
spec:
  traffic:
    - revisionName: blue-green-demo-00001
      percent: 50 # Updating the percentage from 100 to 50
    - revisionName: blue-green-demo-00002
      percent: 50 # Updating the percentage from 0 to 50
      name: v2
```

Save the file, then apply the updated route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

Refresh the original route
(http://blue-green-demo.default.YOUR_CUSTOM_DOMAIN.com) a few times to see that
some traffic now goes to version 2 of the app.

> Note: This sample shows a 50/50 split to assure you don't have to refresh too
> much, but it's recommended to start with 1-2% of traffic in a production
> environment

## Rerouting all traffic to the new version

Lastly, we'll update our existing route to finally shift all traffic to the
second revision. Edit `blue-green-demo-route.yaml`:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: blue-green-demo # Updating our existing route
  namespace: default
spec:
  traffic:
    - revisionName: blue-green-demo-00001
      percent: 0
      name: v1 # Adding a new named route for v1
    - revisionName: blue-green-demo-00002
      percent: 100
      # Named route for v2 has been removed, since we don't need it anymore
```

Save the file, then apply the updated route to your cluster:

```bash
kubectl apply --filename blue-green-demo-route.yaml

route "blue-green-demo" configured
```

Refresh the original route
(http://blue-green-demo.default.YOUR_CUSTOM_DOMAIN.com) a few times to verify
that no traffic is being routed to v1 of the app.

We added a named route to v1 of the app, so you can now access it at
http://v1.blue-green-demo.default.YOUR_CUSTOM_DOMAIN.com.

With all inbound traffic being directed to the second revision of the
application, Knative will soon scale the first revision down to 0 running pods
and the blue/green deployment can be considered complete. Using the named `v1`
route will reactivate a pod to serve any occassional requests intended
specifically for the initial revision.

## Cleaning up

To delete the sample app, enter the following commands:

```
kubectl delete route blue-green-demo
kubectl delete configuration blue-green-demo
```

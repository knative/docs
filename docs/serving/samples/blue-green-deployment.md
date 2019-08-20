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

First, create a new file called `blue-green-demo.yaml` and copy this into
it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: demo
  namespace: default
spec:
  template:
    metadata:
      name: demo-blue
    spec:
      containers:
        - image: gcr.io/knative-samples/knative-route-demo:blue # The URL to the sample app docker image
          env:
            - name: T_VERSION
              value: "blue"
```

Save the file, then deploy the service to your cluster:

```bash
kubectl apply --filename blue-green-demo.yaml

service.serving.knative.dev/demo created
```

This will deploy the initial revision (`demo-blue`) of the sample application. 

You'll now be able to view the sample app at
http://demo.default.YOUR_CUSTOM_DOMAIN.com (replace
`YOUR_CUSTOM_DOMAIN`) with the [custom domain](../using-a-custom-domain.md) you
configured for use with Knative.

> Note: If you don't have a custom domain configured for use with Knative, you
> can interact with your app using cURL requests if you have the host URL and IP
> address:
> `curl -H "Host: demo.default.example.com" http://IP_ADDRESS`
> Knative creates the host URL by combining the name of your Route object, the
> namespace, and `example.com`, if you haven't configured a custom domain. For
> example, `[route-name].[namespace].example.com`. You can get the IP address by
> entering `kubectl get svc istio-ingressgateway --namespace istio-system` (or
> `kubectl get svc istio-ingressgateway --namespace istio-system` if using
> Knative 0.2.x or prior versions) and copying the `EXTERNAL-IP` returned by
> that command. See
> [Interacting with your app](../../install/getting-started-knative-app.md#interacting-with-your-app)
> for more information.

## Deploying Revision 2 (Green)

Revision 2 of the sample application will display the text "App v2" on a green
background. To create the new revision, we'll edit our existing service in
`blue-green-demo.yaml` with an updated image, environment variable and a traffic section:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: demo
  namespace: default
spec:
  template:
    metadata:
      name: demo-green
    spec:
      containers:
        - image: gcr.io/knative-samples/knative-route-demo:green # The URL to the sample app docker image
          env:
            - name: T_VERSION
              value: "green"
  traffic:
  - tag: current
    revisionName: demo-blue
    percent: 100
  - tag: candidate
    revisionName: demo-green
    percent: 0
  - tag: latest
    latestRevision: true
    percent: 0
```

Save the file, then apply the update to your cluster:

```bash
kubectl apply --filename blue-green-demo.yaml

service.serving.knative.dev/demo configured
```

At this point, the first revision (`demo-blue`) and the second
revision (`demo-green`) will both be deployed and running. 

Revision 2 of the app is staged at this point. That means:

- No traffic will be routed to revision 2 at the main URL,
  http://demo.default.YOUR_CUSTOM_DOMAIN.com
- Knative creates a new route for testing the newly deployed version.
  
You can refresh the app URL (http://demo.default.YOUR_CUSTOM_DOMAIN.com) to see 
that the v2 app takes no traffic, but you can navigate there directly 
http://candidate-demo.default.YOUR_CUSTOM_DOMAIN.com

This allows you to validate that the new version of the app is behaving as
expected before switching any traffic over to it.

## Migrating traffic to the new revision

We'll once again update our existing service to begin shifting traffic away from
the first revision and toward the second. Edit `blue-green-demo.yaml`:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: demo
  namespace: default
spec:
  template:
    metadata:
      name: demo-green
    spec:
      containers:
        - image: gcr.io/knative-samples/knative-route-demo:green # The URL to the sample app docker image
          env:
            - name: T_VERSION
              value: "green"
  traffic:
  - tag: current
    revisionName: demo-blue
    percent: 50
  - tag: candidate
    revisionName: demo-green
    percent: 50
  - tag: latest
    latestRevision: true
    percent: 0
```

Save the file, then apply the update to your cluster:

```bash
kubectl apply --filename blue-green-demo.yaml

service.serving.knative.dev/demo configured
```

Refresh the original route
(http://demo.default.YOUR_CUSTOM_DOMAIN.com) a few times to see that
some traffic now goes to version 2 of the app.

> Note: This sample shows a 50/50 split to assure you don't have to refresh too
> much, but it's recommended to start with 1-2% of traffic in a production
> environment

## Rerouting all traffic to the new version

Lastly, we'll update our existing service to finally shift all traffic to the
second revision. Edit `blue-green-demo.yaml`:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: demo
  namespace: default
spec:
  template:
    metadata:
      name: demo-green
    spec:
      containers:
        - image: gcr.io/knative-samples/knative-route-demo:green # The URL to the sample app docker image
          env:
            - name: T_VERSION
              value: "green"
  traffic:
  - tag: previous
    revisionName: demo-blue
    percent: 0
  - tag: current
    revisionName: demo-green
    percent: 100
  - tag: latest
    latestRevision: true
    percent: 0
```

Save the file, then apply the update to your cluster:

```bash
kubectl apply --filename blue-green-demo.yaml

service.serving.knative.dev/demo configured
```

Refresh the original route
(http://demo.default.YOUR_CUSTOM_DOMAIN.com) a few times to verify
that no traffic is being routed to v1 of the app.

With all inbound traffic being directed to the second revision of the
application, Knative will soon scale the first revision down to 0 running pods
and the blue/green deployment can be considered complete. Using the named `previous`
route (http://previous-demo.default.YOUR_CUSTOM_DOMAIN.com) will reactivate a pod 
to serve any occasional requests intended specifically for the initial revision.

## Cleaning up

To delete the sample app, enter the following commands:

```
kubectl delete ksvc demo
```

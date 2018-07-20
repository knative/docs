# Routing and managing traffic with blue/green deployment

This sample demonstrates updating an application to a new version using a
blue/green traffic routing pattern. With Knative, you can safely reroute traffic
from a live version of an application to a new version by changing the routing
configuration.

## Before you begin

You need:
* A Kubernetes cluster with [Knative installed](../install/README.md).
* (Optional) [A custom domain configured](../serving/using-a-custom-domain.md) for use with Knative.

## Deploying Version 1 (Blue)

We'll be deploying an image of a sample application that displays the text
"App v1" on a blue background.

First, create a new file called `stage1.yaml`and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: route-demo # The name of our route; appears in the URL to access the app
  namespace: default # The namespace we're working in; also appears in the URL to access the app
spec:
  traffic:
  - configurationName: route-demo-config-v1
    percent: 100 # All traffic goes to this configutation
---
apiVersion: serving.knative.dev/v1alpha1
kind: Configuration
metadata:
  name: route-demo-config-v1
  namespace: default
spec:
  revisionTemplate:
    metadata:
      labels:
        knative.dev/type: container
    spec:
      container:
        image: gcr.io/knative-samples/knative-route-demo:blue # The URL to the sample app
        imagePullPolicy: Always
        env:
          - name: T_VERSION
            value: "blue"
```

Save the file, then deploy the application to your cluster:
```bash
kubectl apply -f stage1.yaml

route "route-demo" configured
configuration "route-demo-config-v1" configured
```

You'll now be able to view the sample app at 
http://route-demo.default.YOUR_CUSTOM_DOMAIN.com (replace `YOUR_CUSTOM_DOMAIN`)
with the [custom domain](../serving/using-a-custom-domain.md) you configured for
use with Knative.

> Note: If you don't have a custom domain configured for use with Knative, you can interact
  with your app using cURL requests if you have the host URL and IP address:
  `curl -H "Host: route-demo.default.example.com" http://IP_ADDRESS`  
   Knative creates the host URL by combining the name of your Route object,
   the namespace, and `example.com`, if you haven't configured a custom domain.
   For example, `[route-name].[namespace].example.com`.
   You can get the IP address by entering `kubectl get svc knative-ingressgateway -n istio-system`
   and copying the `EXTERNAL-IP` returned by that command.
   See [Interacting with your app](../install/getting-started-knative-app.md#interacting-with-your-app)
   for more information.

## Deploying Version 2 (Green)

Version 2 of the sample application displays the text "App v2" on a green background.

Create a new file called `stage2.yaml` and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: route-demo # Route name is unchanged, since we're updating an existing Route
  namespace: default
spec:
  traffic:
  - configurationName: route-demo-config-v1
    percent: 100 # All traffic still going to the first version
  - configurationName: route-demo-config-v2
    percent: 0
    name: v2
---
apiVersion: serving.knative.dev/v1alpha1
kind: Configuration # Adding a new Configuration for the second app version
metadata:
  name: route-demo-config-v2
  namespace: default
spec:
  revisionTemplate:
    metadata:
      labels:
        knative.dev/type: container
    spec:
      container:
        image: gcr.io/knative-samples/knative-route-demo:green # URL to the second version of the app
        imagePullPolicy: Always
        env:
          - name: T_VERSION
            value: "green"
```

This updates the existing Route's configuration to add the second configuration,
and adds the Configuration for the second version of the app. We start with zero
percent of traffic routed to Version 2.

Save the file, then deploy the application to your cluster:
```bash
kubectl apply -f stage2.yaml

route "route-demo" configured
configuration "route-demo-config-v2" configured
```

Version 2 of the app is staged at this point. That means:

* No traffic will be routed to version 2 at the main URL, http://route-demo.default.YOUR_CUSTOM_DOMAIN.com
* Knative creates a new route named v2 for testing the newly deployed version at http://v2.route-demo.default.YOUR_CUSTOM_DOMAIN.com

This allows you to validate that the new version of the app is behaving as expected before switching
any traffic over to it.


## Migrating traffic to the new version

Create a new file called `stage3.yaml` and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: route-demo # Updating our existing route
  namespace: default
spec:
  traffic:
  - configurationName: route-demo-config-v1
    percent: 50 # Updating the percentage from 100 to 50
  - configurationName: route-demo-config-v2
    percent: 50 # Updating the percentage from 0 to 50
    name: v2
```

Save the file, then deploy the updated routing configuration to your cluster:

```bash
kubectl apply -f stage3.yaml

route "route-demo" configured
```

Refresh the original route (http://route-demo.default.YOUR_CUSTOM_DOMAIN.com) a
few times to see that some traffic now goes to version 2 of the app.

> Note: This sample shows a 50/50 split to assure you don't have to refresh too much,
  but it's recommended to start with 1-2% of traffic in a production environment


## Rerouting all traffic to the new version

Create a new file called `stage4.yaml` and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: route-demo # Updating our existing route
  namespace: default
spec:
  traffic:
  - configurationName: route-demo-config-v1
    percent: 0
    name: v1 # Adding a new named route for v1
  - configurationName: route-demo-config-v2
    percent: 100
    # Named route for v2 has been removed, since we don't need it anymore
```

Save the file, then deploy the updated routing configuration to your cluster:

```bash
kubectl apply -f stage4.yaml

route "route-demo" configured
```

Refresh the original route (http://route-demo.default.YOUR_CUSTOM_DOMAIN.com) a
few times to verify that no traffic is being routed to v1 of the app.

We added a named route to v1 of the app, so you can now access it at 
http://v1.route-demo.default.YOUR_CUSTOM_DOMAIN.com.

## Cleaning up

To delete the sample app, enter the following commands:

```
kubectl delete -f stage4.yaml --ignore-not-found=true
kubectl delete -f stage3.yaml --ignore-not-found=true
kubectl delete -f stage2.yaml --ignore-not-found=true
kubectl delete -f stage1.yaml --ignore-not-found=true
```

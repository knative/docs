# Updating an Existing App

This guide demonstrates how to update an application that is serving
traffic to a new version. With Knative, it's easy to reroute traffic
from one version of an application to another by changing the routing
configuration. 

A sample app is used to demonstrate the flow of updating an
application, but the same principles can be applied to your own Knative
application.

## Before you begin

We assume you have:

* [Installed Knative](../install/README.md) on a Kubernetes cluster
* [Configured a custom domain](../serving/using-a-custom-domain.md) for use with Knative

## Deploying the first version

We'll be deploying an image of a demo application that displays the text
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
```

You'll now be able to view the sample app at 
http://route-demo.default.YOUR_CUSTOM_DOMAIN.com (replace `YOUR_CUSTOM_DOMAIN`)
with the [custom domain](../serving/using-a-custom-domain.md) you configured for
use with Knative.

## Deploying the second version

Create a new file called `stage2.yaml` and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: route-demo
  namespace: default
spec:
  traffic:
  - configurationName: route-demo-config-v1
    percent: 100
  - configurationName: route-demo-config-v2
    percent: 0
    name: v2
---
apiVersion: serving.knative.dev/v1alpha1
kind: Configuration
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
        image: gcr.io/knative-samples/knative-route-demo:green
        imagePullPolicy: Always
        env:
          - name: T_VERSION
            value: "green"
```

Save the file, then deploy the application to your cluster:
```bash
kubectl apply -f stage2.yaml
```

This deploys an image of a demo application that displays the text
"App v2" on a green background.

This will only stage v2. That means:

* No traffic will be routed to the v2 of the app at http://route-demo.default.YOUR_CUSTOM_DOMAIN.com
* Knative creates a new route named v2 for testing the newly deployed version at http://v2.route-demo.default.YOUR_CUSTOM_DOMAIN.com


## Migrating traffic to the new version

Create a new file called `stage3.yaml` and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: route-demo
  namespace: default
spec:
  traffic:
  - configurationName: route-demo-config-v1
    percent: 50
  - configurationName: route-demo-config-v2
    percent: 50
    name: v2
```

Save the file, then deploy the updated routing configuration to your cluster:

```bash
kubectl apply -f stage3.yaml
```

Refresh the original route (http://route-demo.default.YOUR_CUSTOM_DOMAIN.com) a
few times to show that some traffic now goes to v2 of the app.

> Note, this sample shows a 50/50 split to assure you don't have to refresh too much,
  but it's recommended to start with 1-2% in a production environment


## Reouting all traffic to the new version

Create a new file called `stage4.yaml` and copy this into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Route
metadata:
  name: route-demo
  namespace: default
spec:
  traffic:
  - configurationName: route-demo-config-v1
    percent: 0
    name: v1
  - configurationName: route-demo-config-v2
    percent: 100
```

Save the file, then deploy the updated routing configuration to your cluster:

```bash
kubectl apply -f stage4.yaml
```

Refresh the original route (http://route-demo.default.YOUR_CUSTOM_DOMAIN.com) a
few times to verify that no traffic is being routed to v1 of the app.

We added a named route to v1 of the app, so you can now access it at 
http://v1.route-demo.default.YOUR_CUSTOM_DOMAIN.com.

# Advanced deploy (aka blue/green)

Simple blue/green-like application deployment pattern illustrating process of updating live application without dropping any traffic. 

> Note, this demo assumes you mapped domain to your cluster. For purposes of this demo we will use `project-serverless.com`. Substitude with your own domain. 

## Deploy app (blue)

First the initial version of the applicaiton (blue). Save the beloow manifest as `stage1.yaml`

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
        image: gcr.io/knative-samples/knative-route-demo:blue
        imagePullPolicy: Always
        env:
          - name: T_VERSION
            value: "blue"
 ```

And then apply that manifest. 

`kubectl apply -f stage1.yaml`

When route created and IP assigned, navigate to http://route-demo.default.project-serverless.com to show deployed app. Let's call this blue (aka v1) version of the app.

## Deploy new (green) version of the app

Again, save the following manifest representing application update to `stage2.yaml`

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

And then apply that file to your cluster

`kubectl apply -f stage2.yaml`

This will only stage v2. That means:

* Won't route any of v1 (blue) traffic to that new (green) version, and
* Create new named route (`v2`) for testing of new the newlly deployed version

Refresh v1 (http://route-demo.default.project-serverless.com) to show our v2 takes no traffic,
and navigate to http://v2.route-demo.default.project-serverless.com to show the new `v2` named route.

## Migrate portion of v1 (blew) traffic to v2 (green)

Now we are going to migrate traffic. Save this manofest to `stage3.yaml`

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

And then apply it

`kubectl apply -f stage3.yaml`

Refresh (a few times) the original route http://route-demo.default.project-serverless.com to show part of traffic going to v2

> Note, demo uses 50/50 split to assure you don't have to refresh too much, normally you would start with 1-2% maybe

## Re-route 100% of traffic to v2 (green)

Finally, we will migeate all traffic to the green version. Save the following manofest to `stage4.yaml`

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

`kubectl apply -f stage4.yaml`

This will complete the deployment by sending all traffic to the new (green) version.

Refresh original route http://route-demo.default.project-serverless.com bunch of times to show that all traffic goes to v2 (green) and v1 (blue) no longer takes traffic.

Optionally, I like to pointing out that:

* I kept v1 (blue) entry with 0% traffic for speed of reverting, if ever necessary
* I added named route `v1` to the old (blue) version of the app to allow access for comp reasons

Navigate to http://v1.route-demo.default.project-serverless.com to show the old version accessible by `v1` named route


## Cleanup

```
kubectl delete -f stage4.yaml --ignore-not-found=true
kubectl delete -f stage3.yaml --ignore-not-found=true
kubectl delete -f stage2.yaml --ignore-not-found=true
kubectl delete -f stage1.yaml --ignore-not-found=true
```

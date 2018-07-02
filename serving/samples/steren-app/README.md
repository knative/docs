# Sample App

A web application that accepts names, storing them in Google Cloud Datastore, and
lists all of the names it has seen.

This is based on the source code available from: github.com/steren/sample-app

## Prerequisites

1. [Install Knative Serving](https://github.com/knative/install/blob/master/README.md)
1. Enable the Google Cloud Datastore API.

## Running

You can deploy this to Knative Serving from the root directory via:
```shell
# Replace the token string with a suitable registry
REPO="gcr.io/<your-project-here>"
perl -pi -e "s@DOCKER_REPO_OVERRIDE@$REPO@g" sample/steren-app/sample.yaml

# Create the Kubernetes resources
kubectl apply -f sample/templates/node-app.yaml -f sample/steren-app/sample.yaml
```

Once deployed, you will see that it first builds:

```shell
kubectl get revision -o yaml
apiVersion: v1
items:
- apiVersion: serving.knative.dev/v1alpha1
  kind: Revision
  ...
  status:
    conditions:
    - reason: Building
      status: "False"
      type: BuildComplete
...
```

Once the `BuildComplete` status becomes `True` the resources will start getting created.


To access this service via `curl`, we first need to determine its ingress address:
```shell
$ watch kubectl get svc knative-ingressgateway -n istio-system
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

Once the `EXTERNAL-IP` gets assigned to the cluster, you can run:

```shell
# Put the Host name into an environment variable.
export SERVICE_HOST=`kubectl get route steren-sample-app -o jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

If your cluster is running outside a cloud provider (for example on Minikube),
your services will never get an external IP address. In that case, use the istio `hostIP` and `nodePort` as the service IP:

```shell
export SERVICE_IP=$(kubectl get po -l knative=ingressgateway -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc knative-ingressgateway -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

Now curl the service IP as if DNS were properly configured:

```shell
$ curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/
<!DOCTYPE html><html><head><title>Demo</title><link rel="stylesheet" href="/stylesheets/style.css"></head><body><h1>Demo</h1><form action="/messages" method="POST"><input type="text" name="text"><input type="submit"></form><ol></ol></body></html>
```

## Cleaning up

To clean up the sample service:

```shell
kubectl delete -f sample/templates/node-app.yaml -f sample/steren-app/sample.yaml
```

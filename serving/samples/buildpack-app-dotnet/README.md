# Buildpack Sample App

A sample app that demonstrates usage of Cloud Foundry buildpacks on Knative Serving,
using the [packs Docker images](https://github.com/sclevine/packs).

This deploys the [.NET Core Hello World](https://github.com/cloudfoundry-samples/dotnet-core-hello-world)
sample app for Cloud Foundry.

## Prerequisites

[Install Knative Serving](https://github.com/knative/docs/blob/master/install/README.md)

## Running

This sample uses the [Buildpack build
template](https://github.com/knative/build-templates/blob/master/buildpack/buildpack.yaml)
in the [build-templates](https://github.com/knative/build-templates/) repo.

First, install the Buildpack build template from that repo:

```shell
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/buildpack/buildpack.yaml
```

Then you can deploy this to Knative Serving from the root directory via:

```shell
# Replace the token string with a suitable registry
REPO="gcr.io/<your-project-here>"
perl -pi -e "s@DOCKER_REPO_OVERRIDE@$REPO@g" serving/samples/buildpack-app-dotnet/sample.yaml

# Create the Kubernetes resources
kubectl apply -f serving/samples/buildpack-app-dotnet/sample.yaml
```

Once deployed, you will see that it first builds:

```shell
$ kubectl get revision -o yaml
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

Once the `ADDRESS` gets assigned to the cluster, you can run:

```shell
# Put the Host name into an environment variable.
export SERVICE_HOST=`kubectl get route buildpack-sample-app -o jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`

# Curl the ingress IP "as-if" DNS were properly configured.
curl --header "Host: $SERVICE_HOST" http://${SERVICE_IP}/
[response]
```

## Cleaning up

To clean up the sample service:

```shell
# Clean up the serving resources
kubectl delete -f serving/samples/buildpack-app-dotnet/sample.yaml
# Clean up the build template
kubectl delete buildtemplate buildpack
```

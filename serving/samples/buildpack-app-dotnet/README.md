# Buildpack Sample App

A sample app that demonstrates using
[Cloud Foundry](https://www.cloudfoundry.org/) buildpacks on Knative Serving,
using the [packs Docker images](https://github.com/sclevine/packs).

This deploys the
[.NET Core Hello World](https://github.com/cloudfoundry-samples/dotnet-core-hello-world)
sample app for Cloud Foundry.

## Prerequisites

- [Install Knative Serving](../../../install/README.md)

## Running

This sample uses the
[Buildpack build template](https://github.com/knative/build-templates/blob/master/buildpack/buildpack.yaml)
in the [build-templates](https://github.com/knative/build-templates/) repo. Save
a copy of `buildpack.yaml`, then install it:

```shell
kubectl apply --filename https://raw.githubusercontent.com/knative/build-templates/master/buildpack/buildpack.yaml
```

Then you can deploy this to Knative Serving from the root directory by entering
the following commands:

```shell
# Replace <your-project-here> with your own registry
export REPO="gcr.io/<your-project-here>"

perl -pi -e "s@DOCKER_REPO_OVERRIDE@$REPO@g" sample.yaml

# Create the Kubernetes resources
kubectl apply --filename sample.yaml
```

Once deployed, you will see that it first builds:

```shell
$ kubectl get revision --output yaml
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

Once the `BuildComplete` status is `True`, resource creation begins.

To access this service using `curl`, we first need to determine its ingress
address:

```shell
$ watch kubectl get svc knative-ingressgateway --namespace istio-system
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

Once the `EXTERNAL-IP` gets assigned to the cluster, enter the follow commands
to capture the host URL and the IP of the ingress endpoint in environment
variables:

```shell
# Put the Host name into an environment variable.
export SERVICE_HOST=`kubectl get route buildpack-sample-app --output jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc knative-ingressgateway --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

Now curl the service IP to make sure the deployment succeeded:

```shell
# Curl the ingress IP as if DNS were properly configured
curl --header "Host: $SERVICE_HOST" http://${SERVICE_IP}/
[response]
```

## Cleaning up

To clean up the sample service:

```shell
# Clean up the serving resources
kubectl delete --filename serving/samples/buildpack-app-dotnet/sample.yaml
# Clean up the build template
kubectl delete buildtemplate buildpack
```

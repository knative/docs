
A sample function that demonstrates using
[Cloud Foundry](https://www.cloudfoundry.org/) buildpacks on Knative Serving,
using the [packs Docker images](https://github.com/sclevine/packs).

This deploys the [riff square](https://github.com/scothis/riff-square-buildpack)
sample function for riff.

## Prerequisites

- [Install Knative Serving](../../../../install/)

## Running

This sample uses the
[Buildpack build template](https://github.com/knative/build-templates/blob/master/buildpack/buildpack.yaml)
from the [build-templates](https://github.com/knative/build-templates/) repo.

Save a copy of `buildpack.yaml`, then install it:

```shell
kubectl apply --filename https://raw.githubusercontent.com/knative/build-templates/master/buildpack/buildpack.yaml
```

Then you can deploy this to Knative Serving from the root directory via:

```shell
# Replace <your-project-here> with your own registry
export REPO="gcr.io/<your-project-here>"

perl -pi -e "s@DOCKER_REPO_OVERRIDE@$REPO@g" sample.yaml

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
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

watch kubectl get svc $INGRESSGATEWAY --namespace istio-system
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

Once the `EXTERNAL-IP` gets assigned to the cluster, enter the follow commands
to capture the host URL and the IP of the ingress endpoint in environment
variables:

```shell
# Put the Host name into an environment variable.
$ export SERVICE_HOST=`kubectl get route buildpack-function --output jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
$ export SERVICE_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

Now curl the service IP to make sure the deployment succeeded:

```shell
# Curl the ingress IP as if DNS were properly configured
$ curl http://${SERVICE_IP}/ -H "Host: $SERVICE_HOST" -H "Content-Type: application/json" -d "33"
[response]
```

## Cleaning up

To clean up the sample service:

```shell
# Clean up the serving resources
kubectl delete --filename serving/samples/buildpack-function-nodejs/sample.yaml
# Clean up the build template
kubectl delete buildtemplate buildpack
```

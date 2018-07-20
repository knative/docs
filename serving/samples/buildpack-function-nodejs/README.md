# Buildpack Sample Function

A sample function that demonstrates using Cloud Foundry buildpacks on
Knative Serving, using the [packs Docker images](https://github.com/sclevine/packs).

This deploys the [riff square](https://github.com/scothis/riff-square-buildpack)
sample function for riff.

## Prerequisites

* [Install Knative Serving](../../../install/README.md)

## Running

This sample uses the [Buildpack build
template](https://github.com/knative/build-templates/blob/master/buildpack/buildpack.yaml)
from the [build-templates](https://github.com/knative/build-templates/) repo.

First, install the Buildpack build template from that repo:

```shell
kubectl apply -f buildpack.yaml
```

Then you can deploy this to Knative Serving from the root directory via:

```shell
# Replace the token string with a suitable registry
REPO="gcr.io/<your-project-here>"
perl -pi -e "s@DOCKER_REPO_OVERRIDE@$REPO@g" serving/samples/buildpack-function-nodejs/sample.yaml

kubectl apply -f serving/samples/buildpack-function-nodejs/sample.yaml
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

Once the `BuildComplete` status is `True`, resource creation begins.

To access this service using `curl`, we first need to determine its ingress address:
```shell
watch kubectl get svc knative-ingressgateway -n istio-system
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

Once the `EXTERNAL-IP` gets assigned to the cluster, enter the follow commands to capture
the host URL and the IP of the ingress endpoint in environment variables:

```shell
# Put the Host name into an environment variable.
$ export SERVICE_HOST=`kubectl get route buildpack-function -o jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
$ export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

Now curl the service IP to make sure the deployment succeeded:

```
# Curl the ingress IP "as-if" DNS were properly configured.
$ curl http://${SERVICE_IP}/ -H "Host: $SERVICE_HOST" -H "Content-Type: application/json" -d "33"
[response]
```

## Cleaning up

To clean up the sample service:

```shell
kubectl delete -f serving/samples/buildpack-function-nodejs/sample.yaml
```

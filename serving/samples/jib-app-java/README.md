# Jib Sample App

A sample app that demonstrates using
[Jib](https://github.com/GoogleContainerTools/jib) to build Java applications
and running with Knative Serving.

Jib can package any Java application without needing a Dockerfile nor Docker
installed.

This builds the
[Helloworld Java](https://github.com/knative/docs/tree/master/serving/samples/helloworld-java)
sample app, creates a container image, and deploys it into Knative using the
[Knative Jib Build Template](https://github.com/knative/build-templates/tree/master/jib).

## Prerequisites

- [Install Knative Serving](../../../install/README.md)
- [Configure Image Push Credentials](../../../build/auth.md#basic-authentication-docker)

## Running

This sample uses the
[Jib build template](https://github.com/knative/build-templates/tree/master/jib)
in the [build-templates](https://github.com/knative/build-templates/) repo.

Install the Jib Maven build template:

```shell
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/jib/jib-maven.yaml
```

Then you can deploy this to Knative Serving from the root directory by entering
the following commands:

```shell
export REPO="your/registry"

# For example, with Google Container Registry:
# export REPO="gcr.io/YOUR_PROJECT_ID"

perl -pi -e "s@DOCKER_REPO_OVERRIDE@$REPO@g" sample.yaml

# Create the Kubernetes resources
kubectl apply -f sample.yaml
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

To access this service using `curl`, we first need to determine its ingress
address:

```shell
$ watch kubectl get svc knative-ingressgateway -n istio-system
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

Once the `EXTERNAL-IP` gets assigned to the cluster, enter the follow commands
to capture the host URL and the IP of the ingress endpoint in environment
variables:

```shell
# Put the Host name into an environment variable.
export SERVICE_HOST=`kubectl get route jib-sample-app -o jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
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
kubectl delete -f sample.yaml
# Clean up the build template
kubectl delete buildtemplate jib-maven
```

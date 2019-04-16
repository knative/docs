# Jib Sample App

A sample app that demonstrates using
[Jib](https://github.com/GoogleContainerTools/jib) to build Java applications
and running with Knative Serving.

Jib can package any Java application without needing a Dockerfile nor Docker
installed.

This builds the
[Spring Boot Webflux](https://github.com/spring-projects/spring-boot/tree/v2.1.2.RELEASE/spring-boot-samples/spring-boot-sample-webflux)
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

First, in `sample.yaml`, replace `DOCKER_REPO_OVERRIDE` with your Docker repository prefix.
For example, `gcr.io/<your-project-id>`.

Then you can deploy this to Knative Serving from the root directory by entering
the following commands:

```shell
# Create the Kubernetes resources
kubectl apply -f sample.yaml
```

Once deployed, you will see that it first build and revision. See the revision status.

```shell
kubectl describe revisions jib-sample-app-00001
```

Once the `BuildSucceed` status is `True`, then the build container image will be deployed.

To access this service using `curl`, we first need to determine its ingress
address:

```shell
kubectl get svc istio-ingressgateway --namespace istio-system
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

Confirm that the `EXTERNAL-IP` gets assigned to the cluster, enter the follow commands
to capture the host URL and the IP of the ingress endpoint in environment
variables:

```shell
# Put the Host name into an environment variable.
export SERVICE_HOST=`kubectl get route jib-sample-app --output jsonpath="{.status.domain}"`

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
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

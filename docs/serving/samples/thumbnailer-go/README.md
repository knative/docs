
This is a walk-through example that demonstrates deploying a dockerized
application that accesses external dependencies to Knative Serving. In this demo
we will use a sample `golang` application that takes a video URL as an input and
generates its thumbnail image using the `ffmpeg` framework.

## Before you begin

- [Install Knative Serving](../../../../install/)

If you want to test and run the app locally:

- [Install Go](https://golang.org/doc/install)
- [Download `ffmpeg`](https://www.ffmpeg.org/download.html)

## Sample code

In this demo we are going to use a simple `golang` REST app called
[rester-tester](https://github.com/mchmarny/rester-tester). It's important to
point out that this application doesn't use any special Knative Serving
components, nor does it have any Knative Serving SDK dependencies.

### Cloning the sample code

Let's start by cloning the public `rester-tester` repository:

```
git clone git@github.com:mchmarny/rester-tester.git
cd rester-tester
```

The `rester-tester` application uses [godep](https://github.com/tools/godep) to
manage its own dependencies. Download `godep` and restore the app dependencies:

```
go get github.com/tools/godep
godep restore
```

### Run tests

To make sure the application is ready, run the integrated tests:

```
go test ./...
```

### Run the app

You can now run the `rester-tester` application locally in `go` or using Docker.

**Local**

To run the app:

```
go build
./rester-tester
```

**Docker**

When running the application locally using Docker, you do not need to install
`ffmpeg`; Docker will install it for you 'inside' of the Docker image.

To run the app:

```
docker build -t rester-tester:latest .
docker run -p 8080:8080 rester-tester:latest
```

### Test

To test the thumbnailing service, use `curl` to submit the `src`, a video URL:

```
curl -X POST -H "Content-Type: application/json" http://localhost:8080/image \
     -d '{"src":"https://www.youtube.com/watch?v=DjByja9ejTQ"}'
```

## Deploying the app to Knative

From this point, you can either deploy a prebuilt image of the app, or build the
app locally and then deploy it.

### Deploying a prebuilt image

You can deploy a prebuilt image of the `rester-tester` app to Knative Serving
using `kubectl` and the included `sample-prebuilt.yaml` file:

```
# From inside the thumbnailer-go directory
kubectl apply --filename sample-prebuilt.yaml
```

### Building and deploying a version of the app

If you want to build the image yourself, follow these instructions. This sample
uses the
[Kaniko build template](https://github.com/knative/build-templates/blob/master/kaniko/kaniko.yaml)
from the [build-templates](https://github.com/knative/build-templates/) repo.

```shell
# Replace the token string with a suitable registry
REPO="gcr.io/<your-project-here>"
perl -pi -e "s@DOCKER_REPO_OVERRIDE@$REPO@g" sample.yaml

# Install the Kaniko build template used to build this sample (in the
# build-templates repo).
kubectl apply --filename https://raw.githubusercontent.com/knative/build-templates/master/kaniko/kaniko.yaml

# Create the Knative route and configuration for the application
kubectl apply --filename sample.yaml
```

Now, if you look at the `status` of the revision, you will see that a build is
in progress:

```shell
$ kubectl get revisions --output yaml
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

Once `BuildComplete` has a `status: "True"`, the revision will be deployed.

## Using the app

To confirm that the app deployed, you can check for the Knative Serving service
using `kubectl`. First, is there an ingress service, and does it have an
`EXTERNAL-IP`:

```
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

kubectl get svc $INGRESSGATEWAY --namespace istio-system
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

> Note: It can take a few seconds for the service to show an `EXTERNAL-IP`.

The newly deployed app may take few seconds to initialize. You can check its
status by entering the following command:

```
kubectl --namespace default get pods
```

The Knative Serving ingress service will automatically be assigned an external
IP, so let's capture the IP and Host URL in variables so that we can use them in
`curl` commands:

```
# Put the Host URL into an environment variable.
export SERVICE_HOST=`kubectl get route thumb --output jsonpath="{.status.domain}"`

# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway
INGRESSGATEWAY_LABEL=knative

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
    INGRESSGATEWAY_LABEL=istio
fi

# Put the ingress IP into an environment variable.
export SERVICE_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

If your cluster is running outside a cloud provider (for example on Minikube),
your services will never get an external IP address. In that case, use the istio
`hostIP` and `nodePort` as the service IP:

```shell
export SERVICE_IP=$(kubectl get po --selector $INGRESSGATEWAY_LABEL=ingressgateway --namespace istio-system --output 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

### Ping

Let's start with a simple `ping` to make sure the app is deployed:

```
curl -H "Content-Type: application/json" -H "Host: $SERVICE_HOST" \
  http://$SERVICE_IP/ping
```

### Video Thumbnail

Now, supply the video URL and generate a video thumbnail:

```
curl -X POST -H "Content-Type: application/json" -H "Host: $SERVICE_HOST" \
  http://$SERVICE_IP/image -d '{"src":"https://www.youtube.com/watch?v=DjByja9ejTQ"}'
```

You can then download the newly created thumbnail. Make sure to replace the
image file name with the one returned by the previous curl request:

```
curl -H "Host: $SERVICE_HOST" \
  http://$SERVICE_IP/thumb/img_b43ffcc2-0c80-4862-8423-60ec1b4c4926.png > demo.png
```

## Final Thoughts

Although this demo uses an external application, the Knative Serving deployment
steps would be similar for any 'dockerized' app you may already have. Just copy
the `sample.yaml` and change a few variables.

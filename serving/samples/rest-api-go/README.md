# Creating a RESTful Service

This sample demonstrates creating and running a simple RESTful service on
Knative Serving. The exposed endpoint takes a stock ticker (i.e. stock symbol),
then outputs the stock price.

## Prerequisites

1. A Kubernetes cluster with
   [Knative Serving](https://github.com/knative/docs/blob/master/install/README.md)
   v0.3 or higher installed.
1. [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment)
   installed locally.
1. [Outbound network access](https://github.com/knative/docs/blob/master/serving/outbound-network-access.md)
   enabled for this Service to amke external API requests.
1. The code checked out locally.

```
go get -d github.com/knative/docs/serving/samples/rest-api-go
```

## Setup

In order to run an application on Knative Serving a container image must be
available to fetch from a container registry. Building and pushing a container
image can be accomplished locally using
[Docker](https://docs.docker.com/get-started) or
[ko](https://github.com/google/go-containerregistry/tree/master/cmd/ko) as well
as remotely using
[Knative Build](https://github.com/knative/docs/tree/master/build).

This sample uses Docker for both building and pushing.

To build and push to a container registry using Docker:

1. Move into the sample directory:

```
cd $GOPATH/src/github.com/knative/docs
```

2. Set your preferred container registry endpoint as an environment variable.
   This sample uses
   [Google Container Registry (GCR)](https://cloud.google.com/container-registry/):

```
export REPO="gcr.io/<YOUR_PROJECT_ID>"
```

3. Set up your container registry to make sure you are ready to push.

To push to GCR, you need to:

- Create a
  [Google Cloud Platform project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project).
- Enable the
  [Google Container Registry API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com).
- Setup an
  [auth helper](https://cloud.google.com/container-registry/docs/advanced-authentication#gcloud_as_a_docker_credential_helper)
  to give the Docker client the permissions it needs to push.

If you are using a different container registry, you will want to follow the
registry specific instructions for both setup and authorizing the image push.

4. Use Docker to build your application container:

```
docker build \
  --tag "${REPO}/serving/samples/rest-api-go" \
  --file serving/samples/rest-api-go/Dockerfile .
```

5. Push your container to a container registry:

```
docker push "${REPO}/serving/samples/rest-api-go"
```

6. Replace the image reference path with our published image path in the
   configuration files (`serving/samples/rest-api-go/sample.yaml`:

   - Manually replace:
     `image: github.com/knative/docs/serving/samples/rest-api-go` with
     `image: <YOUR_CONTAINER_REGISTRY>/serving/samples/rest-api-go`

   Or

   - Use run this command:

   ```
   perl -pi -e "s@github.com/knative/docs@${REPO}@g" serving/samples/rest-api-go/sample.yaml
   ```

## Deploy the Service

Now that our image is available from the container registry, we can deploy the
Knative Serving sample:

```
kubectl apply --filename serving/samples/rest-api-go/sample.yaml
```

The above command creates a Knative Service within your Kubernetes cluster in
the default namespace.

## Explore the Service

The Knative Service creates the following child resources:

- Knative Route
- Knative Configuration
- Knative Revision
- Kubernetes Deployment
- Kuberentes Service

You can inspect the created resources with the following `kubectl` commands:

- View the created Service resource:

```
kubectl get ksvc stock-service-example -o yaml
```

- View the created Route resource:

```
kubectl get route -l
"serving.knative.dev/service=stock-service-example" -o yaml
```

- View the Kubernetes Service created by the Route

```
kubectl get service -l
"serving.knative.dev/service=stock-service-example" -o yaml
```

- View the created Configuration resource:

```
kubectl get configuration -l
"serving.knative.dev/service=stock-service-example" -o yaml
```

- View the Revision that was created by our Configuration:

```
kubectl get revision -l
"serving.knative.dev/service=stock-service-example" -o yaml
```

- View the Deployment created by our Revision

```
kubectl get deployment -l
"serving.knative.dev/service=stock-service-example" -o yaml
```

## Access the Service

To access this service via `curl`, you need to determine its ingress address.
This example assumes you are using the default Ingress Gateway setup for
Knative. If you customized your gateway, you will want to adjust the enviornment
variables below.

1. To get the IP address of your Ingress Gateway:

```
INGRESSGATEWAY=istio-ingressgateway
INGRESSGATEWAY_LABEL=istio

export INGRESS_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
--output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
echo $INGRESS_IP
```

- If your cluster is running outside a cloud provider (for example on Minikube),
  your services will never get an external IP address, and your INGRESS_IP will
  be empty. In that case, use the istio `hostIP` and `nodePort` as the ingress
  IP:

```
export INGRESS_IP=$(kubectl get po --selector $INGRESSGATEWAY_LABEL=ingressgateway --namespace istio-system \
  --output 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system \
  --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
echo $INGRESS_IP
```

2. To get the hostname of the Service:

```
export SERVICE_HOSTNAME=`kubectl get ksvc stock-service-example --output jsonpath="{.status.domain}"`
echo $SERVICE_HOSTNAME
```

3. Now use `curl` to make a request to the Service:

- Make a request to the index endpoint:

The `curl` command below makes a request to the Ingress Gateway IP. The Ingress
Gateway uses the host header to route the request to the Service. This example
passes the host header to skip DNS configuration. If your cluster has DNS
configured, you can simply curl the DNS name instead of the ingress gateway IP.

```
curl --header "Host:$SERVICE_HOSTNAME" http://${INGRESS_IP}
```

Response body: `Welcome to the stock app!`

- Make a request to the `/stock` endpoint:

```
curl --header "Host:$SERVICE_HOSTNAME" http://${INGRESS_IP}/stock
```

Response body: `stock ticker not found!, require /stock/{ticker}`

- Make a request to the `/stock` endpoint with a `ticker` parameter:

```
curl --header "Host:$SERVICE_HOSTNAME" http://${INGRESS_IP}/stock/<ticker>
```

Response body: `stock price for ticker <ticker> is <price>`

## Next Steps

The
[traffic splitting example](https://github.com/knative/docs/tree/master/serving/samples/traffic-splitting)
continues from here to walk through creating new Revisions and splitting traffic
between multiple Revisions.

## Clean Up

To clean up the sample Service:

```
kubectl delete --filename serving/samples/rest-api-go/sample.yaml
```

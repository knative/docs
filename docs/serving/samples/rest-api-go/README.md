
This sample demonstrates creating a simple RESTful service. The exposed endpoint
takes a stock ticker (i.e. stock symbol), then outputs the stock price. The
endpoint resource name is defined by an environment variable set in the
configuration file.

## Prerequisites

1. A Kubernetes cluster with
   [Knative Serving](../../../../install/)
   installed.
2. Install
   [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment).
3. You need to
   [configure outbound network access](../../outbound-network-access/)
   because this application makes an external API request.
4. Check out the code:

```
go get -d github.com/knative/docs/docs/serving/samples/rest-api-go
```

## Setup

Build the application container and publish it to a container registry:

1. Move into the sample directory:

```
cd $GOPATH/src/github.com/knative/docs
```

2. Set your preferred container registry:

```
export REPO="gcr.io/<YOUR_PROJECT_ID>"
```

To run the sample, you need to have a Google Cloud Platform project, and you
also need to enable the
[Google Container Registry API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com).

3. Use Docker to build your application container:

```
docker build \
  --tag "${REPO}/serving/samples/rest-api-go" \
  --file serving/samples/rest-api-go/Dockerfile .
```

4. Push your container to a container registry:

```
docker push "${REPO}/serving/samples/rest-api-go"
```

5. Replace the image reference path with our published image path in the
   configuration files (`serving/samples/rest-api-go/sample.yaml`:

   - Manually replace:
     `image: github.com/knative/docs/docs/serving/samples/rest-api-go` with
     `image: <YOUR_CONTAINER_REGISTRY>/serving/samples/rest-api-go`

   Or

   - Use run this command:

   ```
   perl -pi -e "s@github.com/knative/docs@${REPO}@g" serving/samples/rest-api-go/sample.yaml
   ```

## Deploy the Configuration

Deploy the Knative Serving sample:

```
kubectl apply --filename serving/samples/rest-api-go/sample.yaml
```

## Explore the Configuration

Inspect the created resources with the `kubectl` commands:

- View the created Route resource:

```
kubectl get route --output yaml
```

- View the created Configuration resource:

```
kubectl get configurations --output yaml
```

- View the Revision that was created by our Configuration:

```
kubectl get revisions --output yaml
```

## Access the Service

To access this service via `curl`, you need to determine its ingress address.

1. To determine if your service is ready:

```
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

kubectl get svc $INGRESSGATEWAY --namespace istio-system --watch
```

When the service is ready, you'll see an IP address in the `EXTERNAL-IP` field:

```
NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
```

2. When the service is ready, export the ingress hostname and IP as environment
   variables:

```
export SERVICE_HOST=`kubectl get route stock-route-example --output jsonpath="{.status.domain}"`
export SERVICE_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
--output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

- If your cluster is running outside a cloud provider (for example on Minikube),
  your services will never get an external IP address. In that case, use the
  istio `hostIP` and `nodePort` as the service IP:

```
export SERVICE_IP=$(kubectl get po --selector $INGRESSGATEWAY_LABEL=ingressgateway --namespace istio-system \
  --output 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system \
  --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

3. Now use `curl` to make a request to the service:

- Make a request to the index endpoint:

```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}
```

Response body: `Welcome to the stock app!`

- Make a request to the `/stock` endpoint:

```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/stock
```

Response body: `stock ticker not found!, require /stock/{ticker}`

- Make a request to the `/stock` endpoint with a `ticker` parameter:

```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/stock/<ticker>
```

Response body: `stock price for ticker <ticker> is <price>`

## Clean Up

To clean up the sample service:

```
kubectl delete --filename serving/samples/rest-api-go/sample.yaml
```

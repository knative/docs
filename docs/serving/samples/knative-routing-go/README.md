
This example shows how to map multiple Knative services to different paths under
a single domain name using the Istio VirtualService concept. Istio is a
general-purpose reverse proxy, therefore these directions can also be used to
configure routing based on other request data such as headers, or even to map
Knative and external resources under the same domain name.

In this sample, we set up two web services: `Search` service and `Login`
service, which simply read in an env variable `SERVICE_NAME` and prints
`"${SERVICE_NAME} is called"`. We'll then create a VirtualService with host
`example.com`, and define routing rules in the VirtualService so that
`example.com/search` maps to the Search service, and `example.com/login` maps to
the Login service.

## Prerequisites

1. A Kubernetes cluster with
   [Knative Serving](../../../../install/)
   installed.
2. Install
   [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment).
3. Acquire a domain name.
   - In this example, we use `example.com`. If you don't have a domain name, you
     can modify your hosts file (on Mac or Linux) to map `example.com` to your
     cluster's ingress IP.
4. Check out the code:

```
go get -d github.com/knative/docs/docs/serving/samples/knative-routing-go
```

## Setup

Build the application container and publish it to a container registry:

1. Move into the sample directory:

```shell
cd $GOPATH/src/github.com/knative/docs
```

2. Set your preferred container registry:

```shell
export REPO="gcr.io/<YOUR_PROJECT_ID>"
```

This example shows how to use Google Container Registry (GCR). You will need a
Google Cloud Project and to enable the
[Google Container Registry API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com).

3. Use Docker to build your application container:

```
docker build \
  --tag "${REPO}/serving/samples/knative-routing-go" \
  --file=serving/samples/knative-routing-go/Dockerfile .
```

4. Push your container to a container registry:

```
docker push "${REPO}/serving/samples/knative-routing-go"
```

5. Replace the image reference path with our published image path in the
   configuration file `serving/samples/knative-routing-go/sample.yaml`:

   - Manually replace:
     `image: github.com/knative/docs/docs/serving/samples/knative-routing-go` with
     `image: <YOUR_CONTAINER_REGISTRY>/serving/samples/knative-routing-go`

   Or

   - Run this command:

   ```
   perl -pi -e "s@github.com/knative/docs@${REPO}@g" serving/samples/knative-routing-go/sample.yaml
   ```

## Deploy the Service

Deploy the Knative Serving sample:

```
kubectl apply --filename serving/samples/knative-routing-go/sample.yaml
```

## Exploring the Routes

A shared Gateway `knative-ingress-gateway` is used within Knative service mesh
for serving all incoming traffic. You can inspect it and its corresponding
Kubernetes service with:

- Check the shared Gateway:

```
kubectl get Gateway --namespace knative-serving --output yaml
```

- Check the corresponding Kubernetes service for the shared Gateway:

```
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

kubectl get svc $INGRESSGATEWAY --namespace istio-system --output yaml
```

- Inspect the deployed Knative services with:

```
kubectl get ksvc
```

You should see 2 Knative services: `search-service` and `login-service`.

### Access the Services

1. Find the shared Gateway IP and export as an environment variable:

```shell
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

export GATEWAY_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
    --output jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`
```

2. Find the `Search` service route and export as an environment variable:

```shell
export SERVICE_HOST=`kubectl get route search-service --output jsonpath="{.status.domain}"`
```

3. Make a curl request to the service:

```shell
curl http://${GATEWAY_IP} --header "Host:${SERVICE_HOST}"
```

You should see: `Search Service is called !`

4. Similarly, you can also directly access "Login" service with:

```shell
export SERVICE_HOST=`kubectl get route login-service --output jsonpath="{.status.domain}"`
```

```shell
curl http://${GATEWAY_IP} --header "Host:${SERVICE_HOST}"
```

You should see: `Login Service is called !`

## Apply Custom Routing Rule

1. Apply the custom routing rules defined in `routing.yaml` file with:

```
kubectl apply --filename serving/samples/knative-routing-go/routing.yaml
```

2. The `routing.yaml` file will generate a new VirtualService `entry-route` for
   domain `example.com`. View the VirtualService:

```
kubectl get VirtualService entry-route --output yaml
```

3.  Send a request to the `Search` service and the `Login` service by using
    corresponding URIs. You should get the same results as directly accessing
    these services.
     \_ Get the ingress IP:

    ```shell
    # In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
    INGRESSGATEWAY=knative-ingressgateway

    # The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
    # Use `istio-ingressgateway` instead, since `knative-ingressgateway`
    # will be removed in Knative v0.4.
    if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
        INGRESSGATEWAY=istio-ingressgateway
    fi

    export GATEWAY_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
        --output jsonpath="{.status.loadBalancer.ingress[_]['ip']}"`
    ```

        * Send a request to the Search service:
        ```shell
        curl http://${GATEWAY_IP}/search --header "Host:example.com"
        ```

        * Send a request to the Login service:
        ```shell
        curl http://${GATEWAY_IP}/login --header "Host:example.com"
        ```

## How It Works

When an external request with host `example.com` reaches
`knative-ingress-gateway` Gateway, the `entry-route` VirtualService will check if
it has `/search` or `/login` URI. If the URI matches, then the host of request
will be rewritten into the host of `Search` service or `Login` service
correspondingly. This resets the final destination of the request. The request
with updated host will be forwarded to `knative-ingress-gateway` Gateway again.
The Gateway proxy checks the updated host, and forwards it to `Search` or
`Login` service according to its host setting.

![Object model](images/knative-routing-sample-flow.png)

## Clean Up

To clean up the sample resources:

```
kubectl delete --filename serving/samples/knative-routing-go/sample.yaml
kubectl delete --filename serving/samples/knative-routing-go/routing.yaml
```

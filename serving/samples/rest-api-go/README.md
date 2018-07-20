# Creating a RESTful service

A simple RESTful service for testing purposes. It exposes an endpoint, which takes
a stock ticker (stock symbol), then outputs the stock price. It uses the the REST resource
name from environment defined in configuration.

## Prerequisites

1. A Kubernetes cluster with [Knative Serving](https://github.com/knative/docs/blob/master/install/README.md) installed.
2. Install [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment).
3. This application makes an external API request, therefore you will need to
[configuring outbound network access](https://github.com/knative/docs/blob/master/serving/outbound-network-access.md).
4. Check out the code:
```
go get -d github.com/knative/docs/serving/samples/rest-api-go
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
   This example shows how to use Google Container Registry (GCR). You will need a Google Cloud Project and to enable the [Google Container Registry
API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com).  

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

5. Replace the image reference path with our published image path in the configuration files (`serving/samples/rest-api-go/sample.yaml` and `serving/samples/rest-api-go/updated_configuration.yaml`):  
   * Manually replace:  
    `image: github.com/knative/docs/serving/samples/rest-api-go` with `image: <YOUR_CONTAINER_REGISTRY>/serving/samples/rest-api-go`  

    Or

   * Use run this command:  
    ```
    perl -pi -e "s@github.com/knative/docs@${REPO}@g" serving/samples/rest-api-go/*.yaml
    ```

## Deploy the Configuration

Deploy the Knative Serving sample:
```
kubectl apply -f serving/samples/rest-api-go/sample.yaml
```

## Explore the Configuration

Inspect the created resources with the `kubectl` commands:

* View the created Route resource:
```
kubectl get route -o yaml
```

* View the created Configuration resource:
```
kubectl get configurations -o yaml
```

* View the Revision that was created by our Configuration:
```
kubectl get revisions -o yaml
```

## Access the Service

To access this service via `curl`, you need to determine its ingress address.

1. To determine if your service is ready:
  ```
  kubectl get svc knative-ingressgateway -n istio-system --watch
  ```

  When the service is ready, you'll see an IP address in the `EXTERNAL-IP` field:

  ```
  NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
  knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
  ```

2. When the service is ready, export the ingress hostname and IP as environment variables:
  ```
  export SERVICE_HOST=`kubectl get route stock-route-example -o jsonpath="{.status.domain}"`
  export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system \
  -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
  ```

  * If your cluster is running outside a cloud provider (for example on Minikube),
  your services will never get an external IP address. In that case, use the istio `hostIP` and `nodePort` as the service IP:
  ```
  export SERVICE_IP=$(kubectl get po -l knative=ingressgateway -n istio-system \
    -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc knative-ingressgateway -n istio-system \
    -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
  ```

3. Now use `curl` to make a request to the service:
  * Make a request to the index endpoint:
  ```
  curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}
  ```
  Response body: `Welcome to the stock app!`

  * Make a request to the `/stock` endpoint:
  ```
  curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/stock
  ```
  Response body: `stock ticker not found!, require /stock/{ticker}`

  * Make a request to the `/stock` endpoint with a `ticker` parameter:
  ```
  curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/stock/<ticker>
  ```
  Response body: `stock price for ticker <ticker>  is  <price>`

## Updating the Service

This section describes how to update your service using an additional configuration file.

1. Deploy the new configuration to update the `RESOURCE` environment variable
from `stock` to `share`:
```
kubectl apply -f serving/samples/rest-api-go/updated_configuration.yaml
```

2. Once deployed, traffic will shift to the new revision automatically. Verify the deployment by checking the route status:
```
kubectl get route -o yaml
```

3. When the new route is ready, you can access the new endpoints:
  * Make a request to the index endpoint:
  ```
  curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}
  ```
  Response body: `Welcome to the share app!`

  * Make a request to the `/share` endpoint:
  ```
  curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/share
  ```
  Response body: `share ticker not found!, require /share/{ticker}`

  * Make a request to the `/share` endpoint with a `ticker` parameter:
  ```
  curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/share/<ticker>
  ```
  Response body: `share price for ticker <ticker>  is  <price>`

## Manual Traffic Splitting

This section describes how to manually split traffic to specific revisions.

1. Get your revisions names via:
```
kubectl get revisions
```
```
NAME                                AGE
stock-configuration-example-00001   11m
stock-configuration-example-00002   4m
```

2. Update the `traffic` list in `serving/samples/rest-api-go/sample.yaml` as:
```yaml
traffic:
  - revisionName: <YOUR_FIRST_REVISION_NAME>
    percent: 50
  - revisionName: <YOUR_SECOND_REVISION_NAME>
    percent: 50
```

3. Deploy your traffic revision:
```
kubectl apply -f serving/samples/rest-api-go/sample.yaml
```

4. Verify the deployment by checking the route status:
```
kubectl get route -o yaml
```
Once updated, you can make `curl` requests to the API endpoints as before.

## Clean Up

To clean up the sample service:

```
kubectl delete -f serving/samples/rest-api-go/sample.yaml
```

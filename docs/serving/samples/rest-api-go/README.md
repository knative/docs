---
title: "Creating a RESTful Service - Go"
linkTitle: "RESTful service - Go"
weight: 1
type: "docs"
---

This "stock ticker" sample demonstrates how to create and run a simple RESTful
service on Knative Serving. The exposed endpoint outputs the stock price for a
given "[stock symbol](https://www.marketwatch.com/tools/quotes/lookup.asp)",
like `AAPL`,`AMZN`, `GOOG`, `MSFT`, etc.

## Prerequisites

1. A Kubernetes cluster with [Knative Serving](../../../install/README.md) v0.3
   or higher installed.
1. [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment)
   installed locally.
1. [Outbound network access](../../outbound-network-access.md) enabled for this
   Service to make external API requests.
1. `envsubst` installed locally. This is installed by the `gettext` package. If
   not installed it can be installed by a Linux package manager, or by
   [Homebrew](https://brew.sh/) on OS X.
1. Download a copy of the code:

   ```shell
   git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
   cd knative-docs/serving/samples/rest-api-go
   ```

## Setup

In order to run an application on Knative Serving a container image must be
available to fetch from a container registry. Building and pushing a container
image can be accomplished locally using
[Docker](https://docs.docker.com/get-started) or
[ko](https://github.com/google/go-containerregistry/tree/master/cmd/ko) as well
as remotely using [Knative Build](../../../build).

This sample uses Docker for both building and pushing.

To build and push to a container registry using Docker:

1. Move into the sample directory:

   ```shell
   cd $GOPATH/src/github.com/knative/docs
   ```

2. Set your preferred container registry endpoint as an environment variable.
   This sample uses
   [Google Container Registry (GCR)](https://cloud.google.com/container-registry/):


    ```shell
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

   ```shell
   docker build \
     --tag "${REPO}/rest-api-go" \
     --file docs/serving/samples/rest-api-go/Dockerfile .
   ```

5. Push your container to a container registry:

   ```shell
   docker push "${REPO}/rest-api-go"
   ```

6. Substitute the image reference path in the template with our published image
   path. The command below substitutes using the \${REPO} variable into a new
   file called `docs/serving/samples/rest-api-go/sample.yaml`.

   ```shell
   envsubst < docs/serving/samples/rest-api-go/sample-template.yaml > \
   docs/serving/samples/rest-api-go/sample.yaml
   ```

## Deploy the Service

Now that our image is available from the container registry, we can deploy the
Knative Serving sample:

```shell
kubectl apply --filename docs/serving/samples/rest-api-go/sample.yaml
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

  ```shell
  kubectl get ksvc stock-service-example --output yaml
  ```

- View the created Route resource:

  ```shell
  kubectl get route -l \
  "serving.knative.dev/service=stock-service-example" --output yaml
  ```

- View the Kubernetes Service created by the Route

  ```shell
  kubectl get service -l \
  "serving.knative.dev/service=stock-service-example" --output yaml
  ```

- View the created Configuration resource:

  ```shell
  kubectl get configuration -l \
  "serving.knative.dev/service=stock-service-example" --output yaml
  ```

- View the Revision that was created by our Configuration:

  ```shell
  kubectl get revision -l \
  "serving.knative.dev/service=stock-service-example" --output yaml
  ```

- View the Deployment created by our Revision

  ```shell
  kubectl get deployment -l \
  "serving.knative.dev/service=stock-service-example" --output yaml
  ```

## Access the Service

To access this service and run the stock ticker, you first obtain the ingress
address and service hostname, and then you run `curl` commands to send request
with your stock symbol.

**Note**: This sample assumes that you are using Knative's default Ingress
Gateway. If you customized your gateway, you need to adjust the enviornment
variables in the following steps.

1. Find the IP address of the ingress gateway:

   - **Cloud Provider**: To get the IP address of your ingress gateway:

     ```shell
     INGRESSGATEWAY=istio-ingressgateway
     INGRESSGATEWAY_LABEL=istio

     export INGRESS_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
     --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
     echo $INGRESS_IP
     ```

   - **Minikube**: If your cluster is running outside a cloud provider (for
     example on Minikube), your services will never get an external IP address,
     and `INGRESS_IP` won't contain a value. In that case, use the Istio
     `hostIP` and `nodePort` as the ingress IP:

     ```shell
     export INGRESS_IP=$(kubectl get po --selector $INGRESSGATEWAY_LABEL=ingressgateway --namespace istio-system \
       --output 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system \
       --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
     echo $INGRESS_IP
     ```

2. Get the URL of the service:

   ```shell
   kubectl get ksvc stock-service-example  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                    URL
   stock-service-example   http://stock-service-example.default.example.com
   ```

3. Send requests to the service using `curl`:

   1. Send a request to the index endpoint:

      The `curl` command below makes a request to the Ingress Gateway IP. The
      Ingress Gateway uses the host header to route the request to the Service.
      This example passes the host header to skip DNS configuration. If your
      cluster has DNS configured, you can simply curl the DNS name instead of
      the ingress gateway IP.

      ```shell
      curl --header "Host:stock-service-example.default.example.com" http://${INGRESS_IP}
      ```

      Response body: `Welcome to the stock app!`

   2. Send a request to the `/stock` endpoint:

      ```shell
      curl --header "Host:stock-service-example.default.example.com" http://${INGRESS_IP}/stock
      ```

      Response body: `stock ticker not found!, require /stock/{ticker}`

   3. Send a request to the `/stock` endpoint with your
      "[stock symbol](https://www.marketwatch.com/tools/quotes/lookup.asp)":

      ```shell
      curl --header "Host:stock-service-example.default.example.com" http://${INGRESS_IP}/stock/<SYMBOL>
      ```

      where `<SYMBOL>` is your "stock symbol".

      Response body: `stock price for ticker <SYMBOL> is <PRICE>`

      **Example**

      Request:

      ```shell
      curl --header "Host:stock-service-example.default.example.com" http://${INGRESS_IP}/stock/FAKE
      ```

      Response: `stock price for ticker FAKE is 0.00`

## Next Steps

The [traffic splitting example](../traffic-splitting/README.md) continues from
here to walk you through how to create new Revisions and then use traffic
splitting between those Revisions.

## Clean Up

To clean up the sample Service:

```shell
kubectl delete --filename docs/serving/samples/rest-api-go/sample.yaml
```

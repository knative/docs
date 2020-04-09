This "stock ticker" sample demonstrates how to create and run a simple RESTful
service on Knative Serving. The exposed endpoint outputs the stock price for a
given "[stock symbol](https://www.marketwatch.com/tools/quotes/lookup.asp)",
like `AAPL`,`AMZN`, `GOOG`, `MSFT`, etc.

## Prerequisites

1. A Kubernetes cluster with [Knative Serving](../../../install/README.md) installed
   and DNS configured.
1. [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment)
   installed locally.
1. `envsubst` installed locally. This is installed by the `gettext` package. If
   not installed it can be installed by a Linux package manager, or by
   [Homebrew](https://brew.sh/) on OS X.
1. Download a copy of the code:

   ```shell
   git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
   cd knative-docs
   ```

## Setup

In order to run an application on Knative Serving a container image must be
available to fetch from a container registry.

This sample uses Docker for both building and pushing.

To build and push to a container registry using Docker:

1. From the `knative-docs` directory, run the following command to set your 
   container registry endpoint as an environment variable.
   
   This sample uses
   [Google Container Registry (GCR)](https://cloud.google.com/container-registry/):
   
    ```shell
    export REPO="gcr.io/<YOUR_PROJECT_ID>"
    ```

1. Set up your container registry to make sure you are ready to push.

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

1. Use Docker to build your application container:

   ```shell
   docker build \
     --tag "${REPO}/rest-api-go" \
     --file docs/serving/samples/rest-api-go/Dockerfile .
   ```

1. Push your container to a container registry:

   ```shell
   docker push "${REPO}/rest-api-go"
   ```

1. Substitute the image reference path in the template with our published image
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

To access this service and run the stock ticker, you first obtain the service URL,
and then you run `curl` commands to send request with your stock symbol.

1. Get the URL of the service:

   ```shell
   kubectl get ksvc stock-service-example  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                    URL
   stock-service-example   http://stock-service-example.default.1.2.3.4.xip.io
   ```

2. Send requests to the service using `curl`:

   1. Send a request to the index endpoint:

      ```shell
      curl http://stock-service-example.default.1.2.3.4.xip.io
      ```

      Response body: `Welcome to the stock app!`

   2. Send a request to the `/stock` endpoint:

      ```shell
      curl http://stock-service-example.default.1.2.3.4.xip.io/stock
      ```

      Response body: `stock ticker not found!, require /stock/{ticker}`

   3. Send a request to the `/stock` endpoint with your
      "[stock symbol](https://www.marketwatch.com/tools/quotes/lookup.asp)":

      ```shell
      curl http://stock-service-example.default.1.2.3.4.xip.io/stock/<SYMBOL>
      ```

      where `<SYMBOL>` is your "stock symbol".

      Response body: `stock price for ticker <SYMBOL> is <PRICE>`

      **Example**

      Request:

      ```shell
      curl http://stock-service-example.default.1.2.3.4.xip.io/stock/FAKE
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

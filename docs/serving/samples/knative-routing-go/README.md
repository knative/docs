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

1. A Kubernetes cluster with [Knative Serving](../../../install/README.md)
   installed.
2. Install
   [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment).
3. Acquire a domain name.
   - In this example, we use `example.com`. If you don't have a domain name, you
     can modify your hosts file (on Mac or Linux) to map `example.com` to your
     cluster's ingress IP.
   - If you have configured a custom domain for your Knative installation, we
     will refer to it as <YOUR_DOMAIN_NAME> in the rest of this document
4. Check out the code:

```
go get -d github.com/knative/docs/docs/serving/samples/knative-routing-go
```

## Setup

To check the domain name, run the following command:

```
kubectl get cm  -n knative-serving config-domain -o yaml
```

Then, check the value for `data`. The domain name should be in the format of
`<YOUR_DOMAIN_NAME>: ""`, if it is available.

Build the application container and publish it to a container registry:

1. Move into the sample directory:

```shell
cd $GOPATH/src/github.com/knative/docs
```

2. Set your preferred container registry:

If you use Google Container Registry (GCR), you will need to enable the
[GCR API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com)
in your GCP project.

```shell
export REPO="gcr.io/<YOUR_PROJECT_ID>"
```

If you use Docker Hub as your docker image registry, replace <username> with
your dockerhub username and run the following command:

```shell
export REPO="docker.io/<username>"
```

3. Use Docker to build your application container:

```
docker build \
  --tag "${REPO}/knative-routing-go" \
  --file=docs/serving/samples/knative-routing-go/Dockerfile .
```

4. Push your container to a container registry:

```
docker push "${REPO}/knative-routing-go"
```

5. Replace the image reference path with our published image path in the
   configuration file `docs/serving/samples/knative-routing-go/sample.yaml`:

   - Manually replace:
     `image: github.com/knative/docs/docs/serving/samples/knative-routing-go`
     with `image: ${REPO}/knative-routing-go` If you manually changed the .yaml
     file, you must replace \${REPO} with the correct path on your local
     machine.

   Or

   - Run this command:

   ```
   perl -pi -e "s@github.com/knative/docs/docs/serving/samples@${REPO}@g" docs/serving/samples/knative-routing-go/sample.yaml
   ```

## Deploy the Service

Deploy the Knative Serving sample:

```
kubectl apply --filename docs/serving/samples/knative-routing-go/sample.yaml
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
INGRESSGATEWAY=istio-ingressgateway

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
INGRESSGATEWAY=istio-ingressgateway

export GATEWAY_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
    --output jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`
```

2. Find the `Search` service URL with:

```shell
# kubectl get route search-service  --output=custom-columns=NAME:.metadata.name,URL:.status.url
NAME              URL
search-service    http://search-service.default.example.com
```

3. Make a curl request to the service:

```shell
curl http://${GATEWAY_IP} --header "Host:search-service.default.example.com"
```

You should see: `Search Service is called !`

4. Similarly, you can also directly access "Login" service with:

```shell
curl http://${GATEWAY_IP} --header "Host:login-service.default.example.com"
```

You should see: `Login Service is called !`

## Apply Custom Routing Rule

1. Apply the custom routing rules defined in `routing.yaml` file with:

```
kubectl apply --filename docs/serving/samples/knative-routing-go/routing.yaml
```

If you have configured a custom domain name for your service, please replace all
mentions of "example.com" in `routing.yaml` with "<YOUR_DOMAIN_NAME>" for
spec.hosts and spec.http.rewrite.authority.

In addition, you need to verify how your domain template is defined. By default,
we use the format of {{.Name}}.{{.Namespace}}, like search-service.default and
login-service.default. However, some Knative environments may use other format
like {{.Name}}-{{.Namespace}}. You can find out the format by running the
command:

```
kubectl get cm  -n knative-serving config-network -o yaml
```

Then look for the value for `domainTemplate`. If it is
`{{.Name}}-{{.Namespace}}.{{.Domain}}`, you need to change
`search-service.default` into `search-service-default` and
`login-service.default` into `login-service-default` as well in `routing.yaml`.

2. The `routing.yaml` file will generate a new VirtualService `entry-route` for
   domain `example.com` or your own domain name. View the VirtualService:

```
kubectl get VirtualService entry-route --output yaml
```

3.  Send a request to the `Search` service and the `Login` service by using
    corresponding URIs. You should get the same results as directly accessing
    these services. Get the ingress IP:

    ```shell
    INGRESSGATEWAY=istio-ingressgateway

    export GATEWAY_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
        --output jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`
    ```

* Send a request to the Search service:

    ```shell
    curl http://${GATEWAY_IP}/search --header "Host: example.com"
    ```

    or

    ```shell
    curl http://${GATEWAY_IP}/search --header "Host: <YOUR_DOMAIN_NAME>"
    ```

    for the case using your own domain.

* Send a request to the Login service:

    ```shell
    curl http://${GATEWAY_IP}/login --header "Host: example.com"
    ```

    or

    ```shell
    curl http://${GATEWAY_IP}/login --header "Host: <YOUR_DOMAIN_NAME>"
    ```

    for the case using your own domain.

## How It Works

When an external request with host `example.com` or your own domain name reaches
`knative-ingress-gateway` Gateway, the `entry-route` VirtualService will check
if it has `/search` or `/login` URI. If the URI matches, then the host of
request will be rewritten into the host of `Search` service or `Login` service
correspondingly. This resets the final destination of the request. The request
with updated host will be forwarded to `knative-ingress-gateway` Gateway again.
The Gateway proxy checks the updated host, and forwards it to `Search` or
`Login` service according to its host setting.

![Object model](./images/knative-routing-sample-flow.png)

## Clean Up

To clean up the sample resources:

```shell
kubectl delete --filename docs/serving/samples/knative-routing-go/sample.yaml
kubectl delete --filename docs/serving/samples/knative-routing-go/routing.yaml
```


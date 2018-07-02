# Routing across Knative Services

This example shows how to map multiple Knative services to different paths 
under a single domain name using the Istio VirtualSerivce concept. 
Since Istio is a general-purpose reverse proxy, these directions can also be 
used to configure routing based on other request data such as headers, or even 
to map Knative and external resources under the same domain name.

In this sample, we set up two web services: "Search" service and "Login" 
service, which simply read in an env variable 'SERVICE_NAME' and prints 
"${SERVICE_NAME} is called". We'll then create a VirtualSerivce with host 
"example.com", and define routing rules in the VirtualService so that example.com/search maps to the Search service, and example.com/login maps to the Login service.

## Prerequisites

1. [Install Knative](https://github.com/knative/install/blob/master/README.md)
1. Install [docker](https://www.docker.com/)
1. Acquire a domain name. In this example, we use example.com. If you don't 
have a domain name, you can modify your hosts file (on Mac or Linux) to map 
example.com to your cluster's ingress IP.

## Setup

Build the app container and publish it to your registry of choice:

```shell
REPO="gcr.io/<your-project-here>"

# Build and publish the container, run from the root directory.
docker build \
  --build-arg SAMPLE=knative-routing \
  --tag "${REPO}/sample/knative-routing" \
  --file=sample/Dockerfile.golang .

docker push "${REPO}/sample/knative-routing"

# Replace the image reference with our published image.
perl -pi -e "s@github.com/knative/serving/sample/knative-routing@${REPO}/sample/knative-routing@g" sample/knative-routing/*.yaml

# Deploy the "Search" and "Login" services.
kubectl apply -f sample/knative-routing/sample.yaml
```

## Exploring

A shared Gateway "knative-shared-gateway" is used within Knative service mesh for serving all incoming traffic. You can inspect it and its corresponding k8s service with
```shell
# Check shared Gateway
kubectl get Gateway -n knative-serving -oyaml

# Check the corresponding k8s service for the shared gateway
kubectl get svc knative-ingressgateway -n istio-system -oyaml
```

And you can inspect the deployed Knative services with
```shell
kubectl get service.serving.knative.dev
```
You should see 2 Knative services: search-service and login-service.

You can directly access "Search" service by running
```shell
# Get the ingress IP.
export GATEWAY_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`

export SERVICE_HOST=`kubectl get route search-service -o jsonpath="{.status.domain}"`

curl http://${GATEWAY_IP} --header "Host:${SERVICE_HOST}"
```
You should see
```
Search Service is called !
```
Similarly, you can also directly access "Login" service with
```shell
# Get the ingress IP.
export GATEWAY_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`

export SERVICE_HOST=`kubectl get route login-service -o jsonpath="{.status.domain}"`

curl http://${GATEWAY_IP} --header "Host:${SERVICE_HOST}"
```

## Apply Custom Routing Rule

You can apply the custom routing rule defined in "routing.yaml" file with
```shell
kubectl apply -f sample/knative-routing/routing.yaml
```
The routing.yaml file will generate a new VirtualService "entry-route" for 
domain "example.com". You can see it by running
```shell
kubectl get VirtualService entry-route -o yaml
```

Now you can send request to "Search" service and "Login" service by using 
different URI.

```shell
# Get the ingress IP.
export GATEWAY_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`

# send request to Search service
curl http://${GATEWAY_IP}/search --header "Host:example.com"

# send request to Login service
curl http://${GATEWAY_IP}/login --header "Host:example.com"
```
You should get the same results as you directly access these services.


## How It Works

This is the traffic flow of this sample:
![Object model](images/knative-routing-sample-flow.png)


When an external request with host "example.com" reaches 
"knative-shared-gateway" Gateway, the "entry-route" VirtualService will check 
if it has "/search" or "/login" URI. If it has, then the host of 
request will be rewritten into the host of "Search" service or "Login" service 
correspondingly, which actually resets the final destination of the request. 
The request with updated host will be forwarded to "knative-shared-gateway" 
Gateway again. The Gateway proxy checks the updated host, and forwards it to 
"Search" or "Login" service according to its host setting.

## Cleaning up

To clean up the sample resources:

```shell
kubectl delete -f sample/knative-routing/sample.yaml

kubectl delete -f sample/knative-routing/routing.yaml
```

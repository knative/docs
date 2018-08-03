# Telemetry Sample

This sample runs a simple web server that makes calls to other in-cluster services
and responds to requests with "Hello World!".
The purpose of this sample is to show generating [metrics](../../accessing-metrics.md),
[logs](../../accessing-logs.md) and distributed [traces](../../accessing-traces.md).
This sample also shows how to create a dedicated Prometheus instance rather than
using the default installation.

## Prerequisites

1. A Kubernetes cluster with [Knative Serving](https://github.com/knative/docs/blob/master/install/README.md)
installed.
2. Check if Knative monitoring components are installed:
```
kubectl get pods -n monitoring
```
  * If pods aren't found, install [Knative monitoring component](../../installing-logging-metrics-traces.md).
3. Install [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment).
4. Check out the code:
```
go get -d github.com/knative/docs/serving/samples/telemetry-go
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
   This example shows how to use Google Container Registry (GCR). You will need
   a Google Cloud Project and to enable the [Google Container Registry
API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com).  

3. Use Docker to build your application container:  
```
docker build \
  --tag "${REPO}/serving/samples/telemetry-go" \
  --file=serving/samples/telemetry-go/Dockerfile .
```

4. Push your container to a container registry:  
```  
docker push "${REPO}/serving/samples/telemetry-go"
```

5. Replace the image reference path with our published image path in the
configuration file (`serving/samples/telemetry-go/sample.yaml`):  
   * Manually replace:  
    `image: github.com/knative/docs/serving/samples/telemetry-go` with
    `image: <YOUR_CONTAINER_REGISTRY>/serving/samples/telemetry-go`  

    Or

   * Use run this command:  
    ```
    perl -pi -e "s@github.com/knative/docs@${REPO}@g" serving/samples/telemetry-go/sample.yaml
    ```

## Deploy the Service

Deploy this application to Knative Serving:
```
kubectl apply -f serving/samples/telemetry-go/
```

## Explore the Service

Inspect the created resources with the `kubectl` commands:

 * View the created Route resource:
 ```
 kubectl get route -o yaml
 ```

 * View the created Configuration resource:
 ```
 kubectl get configurations -o yaml
 ```

 * View the Revision that was created by the Configuration:
 ```
 kubectl get revisions -o yaml
 ```

## Access the Service

To access this service via `curl`, you need to determine its ingress address.

1. To determine if your service is ready:  
  Check the status of your Knative gateway:
  ```
  kubectl get svc knative-ingressgateway -n istio-system --watch
  ```

  When the service is ready, you'll see an IP address in the `EXTERNAL-IP` field:
  ```
  NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
  knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
  ```
  CTRL+C to end watch.

  Check the status of your route:
  ```
  kubectl get route -o yaml
  ```
  When the route is ready, you'll see the following fields reported as:
  ```YAML
  status:
    conditions:
      ...
      status: "True"
      type: Ready
      domain: telemetrysample-route.default.example.com
  ```

2. Export the ingress hostname and IP as environment
variables:
```
export SERVICE_HOST=`kubectl get route telemetrysample-route -o jsonpath="{.status.domain}"`
export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

3. Make a request to the service to see the `Hello World!` message:
```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}
```

4. Make a request to the `/log` endpoint to generate logs to the `stdout` file
and generate files under `/var/log` in both `JSON` and plain text formats:
```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/log
```

## Access Logs
You can access to the logs from Kibana UI - see [Logs](../../accessing-logs.md)
for more information.

## Access per Request Traces
You can access to per request traces from Zipkin UI - see [Traces](../../accessing-traces.md)
for more information.

## Accessing Custom Metrics
You can see published metrics using Prometheus UI. To access to the UI, forward
the Prometheus server to your machine:
```
kubectl port-forward $(kubectl get pods --selector=app=prometheus,prometheus=test --output=jsonpath="{.items[0].metadata.name}") 9090
```

Then browse to http://localhost:9090.

## Clean up

To clean up the sample service:
```
kubectl delete -f serving/samples/telemetry-go/
```

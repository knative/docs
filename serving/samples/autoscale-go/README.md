# Autoscale Sample

A demonstration of the autoscaling capabilities of an Knative Serving Revision.

## Prerequisites

1. A Kubernetes cluster with [Knative Serving](https://github.com/knative/docs/blob/master/install/README.md) installed.
1. Install [Docker](https://docs.docker.com/get-started/#prepare-your-docker-environment).
1. Check out the code:
```
go get -d github.com/knative/docs/serving/samples/autoscale-go
```

## Setup

Build the application container and publish it to a container registry:

1. Move into the sample directory:
   ```
   cd $GOPATH/src/github.com/knative/docs
   ```

1. Set your preferred container registry:
   ```
   export REPO="gcr.io/<YOUR_PROJECT_ID>"
   ```
   * This example shows how to use Google Container Registry (GCR). You will need a
   Google Cloud Project and to enable the
   [Google Container Registry API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com).  

1. Use Docker to build your application container:
   ```
   docker build \
     --tag "${REPO}/serving/samples/autoscale-go" \
     --file=serving/samples/autoscale-go/Dockerfile .
   ```

1. Push your container to a container registry:
   ```  
   docker push "${REPO}/serving/samples/autoscale-go"
   ```

1. Replace the image reference with our published image:
   ```
   perl -pi -e \
   "s@github.com/knative/docs/serving/samples/autoscale-go@${REPO}/serving/samples/autoscale-go@g" \
   serving/samples/autoscale-go/sample.yaml
   ```

## Deploy the Service

1. Deploy the Knative Serving sample:
   ```
   kubectl apply -f serving/samples/autoscale-go/service.yaml
   ```

1. Find the ingress hostname and IP and export as an environment variable:
   ```
   export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
   ```

## View the Autoscaling Capabilities

1. Make a request to the autoscale app to see it consume some resources.
   ```
   curl --header "Host: autoscale-go.default.example.com" "http://${IP_ADDRESS?}?sleep=100&prime=1000000&bloat=50"
   ```
   ```
   Allocated 50 Mb of memory.
   The largest prime less than 1000000 is 999983.
   Slept for 100.13 milliseconds.
   ```

1. Ramp up traffic to maintain 10 in-flight requests.

   ```
   go run serving/samples/autoscale-go/test/test.go -sleep 100 -prime 1000000 -bloat 50 -qps 9999 -concurrency 10
   ```
   ```
   REQUEST STATS:
   Total: 34       Inflight: 10    Done: 34        Success Rate: 100.00%   Avg Latency: 0.2584 sec
   Total: 69       Inflight: 10    Done: 35        Success Rate: 100.00%   Avg Latency: 0.2750 sec
   Total: 108      Inflight: 10    Done: 39        Success Rate: 100.00%   Avg Latency: 0.2598 sec
   Total: 148      Inflight: 10    Done: 40        Success Rate: 100.00%   Avg Latency: 0.2565 sec
   Total: 185      Inflight: 10    Done: 37        Success Rate: 100.00%   Avg Latency: 0.2624 sec
   ```

1. Watch the Knative Serving deployment pod count increase.
   ```
   kubectl get deploy --watch
   ```
   > Note: Use CTRL+C to exit watch mode.

## Analysis

You can view the autoscaler debugging dashboard at ... DASHBOARD LINK GOES HERE WITH SCREENSHOT

### Algorithm

Knative Serving autoscaling is based on the average number of in-flight requests per pod (concurrency). The system has a default target concurency of 1.0. For example, if there are 100 clients making requests at any given time, each of which takes 100 ms to complete, the system will determine that at least 10 pods are required to serve the request load.

### Other Experiments

1. Maintain 100 concurrent requests.
   ```
   go run serving/samples/autoscale-go/test/test.go -qps 9999 -concurrency 100
   ```

1. Maintain 100 qps with fast requests.
   ```
   go run serving/samples/autoscale-go/test/test.go -qps 100 -concurrency 9999
   ```


1. Maintain 100 qps with slow requests.
   ```
   go run serving/samples/autoscale-go/test/test.go -qps 100 -concurrency 9999 -sleep 500
   ```


## Cleanup

```
kubectl delete -f serving/samples/autoscale-go/sample.yaml
```

## Further reading

1. [Autoscaling Developer Documentation](https://github.com/knative/serving/blob/master/docs/scaling/DEVELOPMENT.md)

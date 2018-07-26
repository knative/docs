# Autoscale Sample

A demonstration of the autoscaling capabilities of a Knative Serving Revision.

## Prerequisites

1. A Kubernetes cluster with [Knative Serving](https://github.com/knative/docs/blob/master/install/README.md) installed.
1. A [metrics installation](https://github.com/knative/docs/blob/master/serving/installing-logging-metrics-traces.md) for viewing scaling graphs (optional).
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
   serving/samples/autoscale-go/service.yaml
   ```

## Deploy the Service

1. Deploy the Knative Serving sample:
   ```
   kubectl apply -f serving/samples/autoscale-go/service.yaml
   ```

1. Find the ingress hostname and IP and export as an environment variable:
   ```
   export IP_ADDRESS=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
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
   ...
   ```
   > Note: Use CTRL+C to exit the load test.

1. Watch the Knative Serving deployment pod count increase.
   ```
   kubectl get deploy --watch
   ```
   > Note: Use CTRL+C to exit watch mode.

## Analysis

### Algorithm

Knative Serving autoscaling is based on the average number of in-flight requests per pod (concurrency). The system has a default [target concurency of 1.0](https://github.com/knative/serving/blob/5441a18b360805d261528b2ac8ac13124e826946/config/config-autoscaler.yaml#L27).

For example, if a Revision is receiving 35 requests per second, each of which takes about about .25 seconds, Knative Serving will determine the Revision needs about 9 pods

```
35 * .25 = 8.75
ceil(8.75) = 9
```

### Dashboards

View the Knative Serving Scaling and Request dashboards (if configured).

```
kubectl port-forward -n monitoring $(kubectl get pods -n monitoring --selector=app=grafana --output=jsonpath="{.items..metadata.name}") 3000
```

![scale dashboard](scale-dashboard.png)

![request dashboard](request-dashboard.png)

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

1. Heavy CPU usage.
   ```
   go run serving/samples/autoscale-go/test/test.go -qps 9999 -concurrency 10 -prime 40000000
   ```

1. Heavy memory usage.
   ```
   go run serving/samples/autoscale-go/test/test.go -qps 9999 -concurrency 5 -bloat 1000
   ```

## Cleanup

```
kubectl delete -f serving/samples/autoscale-go/service.yaml
```

## Further reading

1. [Autoscaling Developer Documentation](https://github.com/knative/serving/blob/master/docs/scaling/DEVELOPMENT.md)

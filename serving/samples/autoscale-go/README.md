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
  * This example shows how to use Google Container Registry (GCR). You will need a Google Cloud Project and to enable the [Google Container Registry API](https://console.cloud.google.com/apis/library/containerregistry.googleapis.com).  


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
kubectl apply -f serving/samples/autoscale-go/sample.yaml
```

1. Find the ingress hostname and IP and export as an environment variable:
```
export SERVICE_HOST=`kubectl get route autoscale-route -o jsonpath="{.status.domain}"`
export SERVICE_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

## View the Autoscaling Capabilities

1. Request the largest prime less than 40,000,000 from the autoscale app.  Note that it consumes about 1 cpu/sec.
```
time curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP?}/primes/40000000
```

1. Ramp up traffic on the autoscale app (about 300 QPS).
```
kubectl delete namespace hey --ignore-not-found && kubectl create namespace hey
```
```
for i in `seq 2 2 60`; do
    kubectl -n hey run hey-$i --image josephburnett/hey --restart Never -- \
      -n 999999 -c $i -z 2m -host $SERVICE_HOST \
      "http://${SERVICE_IP?}/primes/40000000"
    sleep 1
done
```

1. Watch the Knative Serving deployment pod count increase.
```
kubectl get deploy --watch
```

1. Watch the pod traffic ramp up.
```
kubectl get pods -n hey --show-all --watch
```

1. Look at the latency, requests/sec and success rate of each pod.
```
for i in `seq 2 2 60`; do kubectl -n hey logs hey-$i ; done
```

## Cleanup

```
kubectl delete namespace hey
kubectl delete -f serving/samples/autoscale-go/sample.yaml
```

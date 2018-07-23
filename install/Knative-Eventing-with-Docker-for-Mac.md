# Getting Started with Eventing on Docker for Mac
This guide walks you through the installation of
[Knative Serving](https://github.com/knative/serving) and [Knative Eventing](https://github.com/knative/eventing) from source on Docker for Mac.

It demonstrates sending messages to sample "hello world" app via a Channel backed by a topic on a Kafka Bus.

### Install Docker for Mac
- Download and install [Docker CE for Mac](https://store.docker.com/editions/community/docker-ce-desktop-mac#get-docker) (Edge release).
- Configure memory 8GB
- Enable k8s

### Configure docker credential helper for gcr
Only needed once for a new install of docker, see [setting-up-a-docker-registry](https://github.com/knative/serving/blob/master/docs/setting-up-a-docker-registry.md).
```
gcloud components install docker-credential-gcr
docker-credential-gcr configure-docker
```

## Knative Serving install
Follow the [Getting started instructions](https://github.com/knative/serving/blob/master/DEVELOPMENT.md#getting-started) to clone the [knative/serving](https://github.com/knative/serving/) repo from GitHub and set up a Knative Serving development environment.

### Install Istio from knative/serving 
```
cd ~/go/src/github.com/knative/serving
sed -e s/LoadBalancer/NodePort/ ./third_party/istio-0.8.0/istio.yaml | kubectl apply -f -
kubectl label namespace default istio-injection=enabled --overwrite
```
wait until the istio pilot pod is running 2/2 

### Install build
```
kubectl apply -f ./third_party/config/build/release.yaml
```

### Edit the knative-ingressgateway yaml
replace `Loadbalancer` with `NodePort` in `knative/serving/config/202-gateway.yaml`.
```
spec:
  type: NodePort
```

### Build and install Knative from source
Using `ko apply -L` builds the images locally in docker. After this step you should see 3 new pods in the knative-serving namespace 
and a pod for the knative-ingressgateway.
```
ko apply -L -f config/
```

### Build and deploy helloworld
NOTE: the `cd` is required, ko apply will not work properly if run from the root of knative/serving 
```
cd ~/go/src/github.com/knative/docs/serving/samples/helloworld-go
ko apply -L -f service.yaml

# after the helloworld-go pod starts up, this should respond with Hello World
curl -H "Host:helloworld-go.default.example.com" http://localhost:32380
```

### Troubleshooting helloworld
If curl hangs, the gateway is not accessible from curl. This often happens when you delete all the k8s resources and reinstall. We believe that this is a bug which manifests for the knative-ingregessgateway only on Docker for Mac.

Try deleting (and restarting) the pod for the knative-ingressgateway
```
kubectl delete pod -l knative=ingressgateway -n istio-system
```
A new pod should appear, and usually curl will be able to hit that

If deleting the pod doesn't work
  1. restart docker for mac, wait for all the pods to come up
  2. delete the knative-ingressgateway pod

If curl returns `curl: (52) Empty reply from server` try installing the primer test app (see steps below).
This sometimes helps to get traffic through the ingressgateway working properly.


### Deploy the primer test app (optional)
This doesn't depend on ko, so it's a nice way to test a cluster
```
kubectl apply -f https://storage.googleapis.com/knative-samples/primer.yaml
curl -H "Host:primer.default.example.com" http://localhost:32380/5000000
```

FYI: to lookup the Knative app hostname e.g. for primer:
```
kubectl get route primer -o jsonpath="{.status.domain}"
```

### Install the Kubernetes dashboard
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard.yaml
```

Forward the dashboard port 9090 using kubectl (in a new terminal window)
``` 
kubectl port-forward $(kubectl get pod -n kube-system -l k8s-app=kubernetes-dashboard --output=jsonpath={.items..metadata.name}) 9090:9090 --namespace=kube-system
```

To open the dashboard in a browser
```
open http://localhost:9090
```

## Knative Eventing install
```
cd ~/go/src/github.com/knative/eventing
ko apply -f config/
```
Alternatively, to install from released yaml do
```
kubectl apply -f https://storage.googleapis.com/knative-releases/latest/release-eventing.yaml`
```

### Kafka install
This creates a single node kafka cluster in the `kafka` namespace.
```
kubectl create namespace kafka
kubectl apply -n kafka -f config/buses/kafka/kafka-broker.yaml
```

### Kafka bus install
```
ko apply -f config/buses/kafka/kafka-bus.yaml
```
NOTE: don't use the ClusterBus - it currently crashes on startup because of
[#187](https://github.com/knative/eventing/issues/187)

### Edit hello-channel.yaml
The sample defaults to using the `stub` bus. Switch to using Kafka in `/knative/eventing/sample/hello/hello-channel.yaml`.
```
spec:
  bus: kafka
```

### Build and deploy the eventing hello sample
```
cd ~/go/src/github.com/knative/eventing
ko apply -f sample/hello/
```

### Test the hello app
As soon as the pod for the hello app is running you should be able to test it with curl.
```
curl -H "Host:hello.default.example.com" http://localhost:32380/ -d 'world' 
```

### Edit the aloha-channel to expose it for external access
```
kc edit virtualservice aloha-channel
```

```
spec:
  gateways:
  - knative-shared-gateway.knative-serving.svc.cluster.local
  - mesh
  hosts:
  - '*.aloha-channel.default.example.com'
  - aloha-channel.default.example.com
  - aloha-channel.default.svc.cluster.local
  - aloha.default.channels.cluster.local
  http:
  ...
 ```
After saving and closing the file in your editor, you should see `virtualservice.networking.istio.io "aloha-channel" edited`.

 ### Tail the hello log
 Since channels don't reply (yet) it helps to tail the log for the hello app, before sending a message across the bus. Use kail in a new terminal window. 
```
kail -d hello-00001-deployment -c user-container
```

### Tail the kafka bus dispatcher log
```
kail -d kafka-bus -c dispatcher
```

### Post a message to the aloha-channel
```
curl -d "world via channel" -H "Host:aloha-channel.default.example.com" http://localhost:32380/ -w "\n" 
```
the result should appear in the log of the hello app, and you should see the events flowing through the channel by looking for kafka bus dispatcher log messages.
```
[...dispatcher.go:278] Received request for aloha.default.channels.cluster.local
[...dispatcher.go:194] Dispatching a message for subscription default/aloha2hello: aloha -> hello-00001-service
```
### FYI: subscription currently points to a revision
See eventing/sample/hello/hello-subscription.yaml - the spec is.
```
spec:
  channel: aloha
  subscriber: hello-00001-service
```
When [#185](https://github.com/knative/eventing/issues/185) is fixed this will be changed to point to an in-cluster route so that the app can be updated without breaking the subscription.
```
spec:
  channel: aloha
  subscriber: hello.default.svc.cluster.local
```

### Cleanup
```
cd ~/go/src/github.com/knative/serving

ko delete --ignore-not-found=true \
  -f ../eventing/sample/hello \
  -f ../eventing/config/ \
  -f ../eventing/config/buses/kafka \
  -f ./config/monitoring/100-common \
  -f ./config/ \
  -f ./third_party/config/build/release.yaml \
  -f ./third_party/istio-0.8.0/istio.yaml \
  -f ~/go/src/github.com/knative/docs/serving/samples/helloworld-go/service.yaml \
  -f https://storage.googleapis.com/knative-samples/primer.yaml

ko delete --ignore-not-found=true -n kafka -f config/buses/kafka/kafka-broker.yaml
```
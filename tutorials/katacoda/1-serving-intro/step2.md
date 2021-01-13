## Deploy and autoscale application

We are going to deploy the [Hello world sample web application](https://knative.dev/docs/serving/samples/hello-world/helloworld-go/). This basic web application reads in an env variable TARGET and prints `Hello ${TARGET}!`. If TARGET is not specified, it will use `World` as the TARGET.

We will now deploy the application by specifying the image location and the `TARGET` env variable.

Knative defines a `service.serving.knative.dev` CRD to control the lifecycle of the application (not to be confused with kubernetes service). We will use the `kn` cli to create the Knative service:

```
kn service create demo --image gcr.io/knative-samples/helloworld-go --env TARGET=blue
```{{execute}}

We can now invoke the application using `curl`. We first need to figure out the IP address of minikube and ingress port.
```
MINIKUBE_IP=$(minikube ip)
INGRESS_PORT=$(kubectl get svc envoy --namespace contour-external --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```{{execute}}
Then invoke the application using curl:
```
curl http://$MINIKUBE_IP:$INGRESS_PORT/ -H 'Host: demo.default.example.com'
```{{execute T1}}

### Scale down to zero
You can run `watch kubectl get pods`{{execute T2}} in a new Terminal tab to see a pod created to serve the requests. Knative will scale this pod down to zero if there are no incoming requests for 60 seconds by default.

You can wait for the pods to scale down to zero and then issue the above `curl` again to see the pod spin up and serve the request.

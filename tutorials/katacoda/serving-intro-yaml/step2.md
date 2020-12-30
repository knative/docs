## Deploy and autoscale application

We are going to deploy the [Hello world sample application](https://knative.dev/docs/serving/samples/hello-world/helloworld-go/). This application reads in an env variable TARGET and prints `Hello ${TARGET}!`. If TARGET is not specified, it will use `World` as the TARGET.

We will now deploy the application by specfying the image location and the `TARGET` env variable.

Knative defines a `service.serving.knative.dev` CRD to control the lifecycle of the application (not to be confused with kubernetes service). We will create the Knative service using the yaml below:

```
cat <<EOF | kubectl apply -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
spec:
  template:
    metadata:
      name: helloworld-go-blue
    spec:
      containers:
      - env:
        - name: TARGET
          value: blue
        image: gcr.io/knative-samples/helloworld-go

EOF
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

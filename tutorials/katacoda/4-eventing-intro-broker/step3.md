## Publishing Events
Finally, let's publish some events. The broker can only be accessed from within the cluster where Knative Eventing is installed. We will create a pod within that cluster to
act as an event producer that will execute the curl commands.

```
kubectl apply -f - << EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: post-event
  name: post-event
spec:
  containers:
    # This could be any image that we can SSH into and has curl.
  - image: radial/busyboxplus:curl
    imagePullPolicy: IfNotPresent
    name: post-event
    resources: {}
    stdin: true
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    tty: true
EOF
```{{execute}}

Publish red events using the command:

```
kubectl exec post-event -- curl -v "http://broker-ingress.knative-eventing.svc.cluster.local/default/default" \
  -X POST \
  -H "Ce-Id: test" \
  -H "Ce-Specversion: 1.0" \
  -H "Ce-Type: red" \
  -H "Ce-Source: kata-tutorial" \
  -H "Content-Type: application/json" \
  -d '{"msg":"The event is red!"}'
```{{execute}}

Publish blue events using the command:

```
kubectl exec post-event -- curl -v "http://broker-ingress.knative-eventing.svc.cluster.local/default/default" \
  -X POST \
  -H "Ce-Id: test" \
  -H "Ce-Specversion: 1.0" \
  -H "Ce-Type: blue" \
  -H "Ce-Source: kata-tutorial" \
  -H "Content-Type: application/json" \
  -d '{"msg":"The event is blue!"}'
```{{execute}}

Publish orange events using the command:

```
kubectl exec post-event -- curl -v "http://broker-ingress.knative-eventing.svc.cluster.local/default/default" \
  -X POST \
  -H "Ce-Id: test" \
  -H "Ce-Specversion: 1.0" \
  -H "Ce-Type: orange" \
  -H "Ce-Source: kata-tutorial" \
  -H "Content-Type: application/json" \
  -d '{"msg":"The event is orange!"}'
```{{execute}}

Verify that the correct events are delivered using the command:

```
kubectl logs -l serving.knative.dev/service=consumer1 -c user-container --since=10m
kubectl logs -l serving.knative.dev/service=consumer2 -c user-container --since=10m
```{{execute}}

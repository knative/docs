## Blue/Green deploy
The Knative `service` resource creates additional resources "route, configuration and revision" to manage the lifecycle of the application.
- revision: just like a git revision, any change to the Service's `spec.template` results in a new revision
- route: control traffic to several revisions

You can list those resources by running ```kubectl get ksvc,configuration,route,revision```{{execute T1}} or by using the `kn` cli

We will now update the service to change the `TARGET` env variable to `green`.

```
cat <<EOF | kubectl apply -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
spec:
  template:
    metadata:
      name: helloworld-go-green
    spec:
      containers:
      - env:
        - name: TARGET
          value: green
        image: gcr.io/knative-samples/helloworld-go

EOF
```{{execute T1}}

This will result in a new `revision` being created. verify this by running `kubectl get revisions`{{execute T1}}.
Both these revisions are capable of serving requests. By default all traffic will be routed to the latest revision. You can test that by running the `curl` command again.
We will now split our traffic between the two revisions by using the `traffic` block in the Service definition.
```
cat <<EOF | kubectl apply -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
spec:
  template:
    metadata:
      name: helloworld-go-green
    spec:
      containers:
      - env:
        - name: TARGET
          value: green
        image: gcr.io/knative-samples/helloworld-go
  traffic:
  - tag: current
    revisionName: helloworld-go-green
    percent: 50
  - tag: candidate
    revisionName: helloworld-go-blue
    percent: 50
  - tag: latest
    latestRevision: true
    percent: 0

EOF

```{{execute T1}}
Then proceed by issuing the curl command multiple times
```
curl http://$MINIKUBE_IP:$INGRESS_PORT/ -H 'Host: helloworld-go.default.example.com'
```{{execute T1}}
to see that the traffic is split between the two revisions.

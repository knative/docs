## Blue/Green deploy
The Knative `service` resource creates additional resources "route, configuration and revision" to manage the lifecycle of the application.
- revision: just like a git revision, any change to the Service's `spec.template` results in a new revision
- route: control traffic to several revisions

You can list those resources by running `kubectl get ksvc,configuration,route,revision` or by using the `kn` cli

We will now update the service to change the `TARGET` env variable to `green`.

But, before we do that, let us add a `blue` tag to our existing revision.
```
kn service update demo --tag $(kn revision list -o 'jsonpath={.items[0].metadata.name}')=blue
```{{execute T1}}
Now, update the env variable to `green`:
```
kn service update demo --env TARGET=green
```{{execute T1}}

This will result in a new `revision` being created. Verify this by running `kn revision list`{{execute T1}}.
Both these revisions are capable of serving requests, we now need to split our traffic between the two revisions.
```
kn service update demo --traffic blue=50,@latest=50
```{{execute T1}}
Then proceed by issuing the curl command multiple times
```
curl http://$MINIKUBE_IP:$INGRESS_PORT/ -H 'Host: demo.default.example.com'
```{{execute T1}}
to see that the traffic is split between the two revisions.

## Blue/Green deploy
The Knative `service` resource creates additional resources "route, configuration and revision" to manage the lifecycle of the application.
- revision: just like a git revision, any change to the Service's `spec.template` results in a new revision
- route: control traffic to several revisions

You can list those resources by running `kubectl get ksvc,configuration,route,revision` or by using the `kn` cli

We will now update the service to change the `TARGET` env variable to `green`.

But, before we do that, let us update the revision name to "hello-v1", so that we can direct traffic to it.
```
kn service update demo --revision-name="demo-v1"```{{execute T1}}

Now, let's update the env variable to `green`, but let's do it as a dark launch i.e. zero traffic will go to this new revision:
```
kn service update demo --env TARGET=green --revision-name="demo-v2" --traffic demo-v1=100,demo-v2=0
```{{execute T1}}

This will result in a new `revision` being created. Verify this by running `kn revision list`{{execute T1}}.

All these revisions are capable of serving requests. Let's tag the `green` revision, so as to get a custom hostname to be able to access the revision.
```
kn service update demo --tag demo-v2=v2
```{{execute T1}}

You can now test the `green` revision like so: (This hostname can  be listed with `kn route describe demo` command).
```
curl http://$MINIKUBE_IP:$INGRESS_PORT/ -H 'Host: v2-demo.default.example.com'
```{{execute T1}}

We now need to split our traffic between the two revisions.
```
kn service update demo --traffic demo-v1=50,@latest=50
```{{execute T1}}
Then proceed by issuing the curl command multiple times to see that the traffic is split between the two revisions.
```
curl http://$MINIKUBE_IP:$INGRESS_PORT/ -H 'Host: demo.default.example.com'
```{{execute T1}}

We can now make all traffic go to the `green` revision:
```
kn service update demo --traffic @latest=100
```{{execute T1}}
Then proceed by issuing the curl command multiple times to see that all traffic is routed to `green` revision.
```
curl http://$MINIKUBE_IP:$INGRESS_PORT/ -H 'Host: demo.default.example.com'
```{{execute T1}}

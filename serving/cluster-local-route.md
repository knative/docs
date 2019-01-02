# Making your Routes local to the cluster.

In Knative 0.3.x or later, all Routes with a domain suffix of
`svc.cluster.local` will only be visible inside the cluster.

This can be done by changing the `config-domain` config map as instructed
[here](./using-a-custom-domain.md).

In addition to that, you can set the label
`serving.knative.dev/visibility=cluster-local` on your Route or KService to
achieve the same effect.  For example, to make the Route `helloworld-go` in
`default` namespace cluster local, run

```shell
kubectl label route helloworld-go serving.knative.dev/visibility=cluster-local
```

if such label was not already set when creating the Route.

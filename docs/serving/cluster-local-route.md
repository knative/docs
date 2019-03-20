# Making your Routes local to the cluster

In Knative 0.3.x or later, all Routes with a domain suffix of
`svc.cluster.local` will only be visible inside the cluster.

This can be done by changing the `config-domain` config map as instructed
[here](./using-a-custom-domain.md).

You can also set the label `serving.knative.dev/visibility=cluster-local` on
your Route or KService to achieve the same effect.

For example, if you didn't set a label when you created the Route
`helloworld-go` and you want to make it local to the cluster, run:

```shell
kubectl label route helloworld-go serving.knative.dev/visibility=cluster-local
```

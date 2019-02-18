<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Making your Routes local to the cluster](#making-your-routes-local-to-the-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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

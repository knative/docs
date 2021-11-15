# Autoscaling

Knative Serving provides automatic scaling, or _autoscaling_, for applications to match incoming demand. This is provided by default, by using the Knative Pod Autoscaler (KPA).

For example, if an application is receiving no traffic, and scale to zero is enabled, Knative Serving scales the application down to zero pods. If scaling to zero is disabled, the application is scaled down to the minimum number of pods specified for applications on the cluster. Pods can also be scaled up to meet demand if traffic to the application increases.

You can enable and disable scale to zero functionality for your cluster if you have cluster administrator permissions. See ([global configuration](scale-to-zero.md)).
<!--TODO: How can you check if you have it enabled if you're not a cluster admin?-->
To use autoscaling for your application if it is enabled on your cluster, you must configure concurrency and scale bounds.
<!--TODO: Include this in the basic config before other settings-->

## Additional resources

<!--TODO: Move KPA details, metrics to admin / advanced section; too in depth for intro)-->
* Try out the [Go Autoscale Sample App](autoscale-go/README.md).
* Configure your Knative deployment to use the Kubernetes Horizontal Pod Autoscaler (HPA) instead of the default KPA. For how to install HPA, see [Install optional Serving extensions](../../install/serving/install-serving-with-yaml.md#install-optional-serving-extensions).
* Configure the [type of metrics](autoscaling-metrics.md) your Autoscaler consumes.

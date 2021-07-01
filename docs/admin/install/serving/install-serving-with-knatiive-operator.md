# Installing Knative Serving with the Knative Operator


### Knative Operator networking requirements

In addition to the basic prerequisites for installing Knative Serving, if you want to install Knative Serving by using the Knative Operator, you must also install an ingress (networking layer) on your cluster. By default, the Knative Operator uses Istio if an ingress is not specified.

The Knative Operator provides `net-*` plugins for the following ingress types:

- [Istio](https://github.com/knative-sandbox/net-istio)
- [Kourier](https://github.com/knative-sandbox/net-kourier)
- [Contour](https://github.com/knative-sandbox/net-contour)

This means that once you have a working installation of these ingress types, they can be easily configured for use with Knative Serving by modifying the `ingress` spec in the `KnativeServing` CRD.

You can also use Ambassador as your ingress, however this requires additional configuration, since there is currently no Ambassador Knative plugin available.

#### Using Istio as the networking layer

If you already have Istio installed, you can simply [install Knative Serving by using the Knative Operator](). Istio is used as the networking layer by default.

If you do not yet have Istio installed, but would like to use it as the default networking layer, you can follow the [Istio Getting Started documentation](https://istio.io/latest/docs/setup/getting-started/) to install it before you install the Knative Operator.

#### Using Kourier as the networking layer

If you have Kourier installed and want to use it as the networking layer, ensure that your `KnativeServing` CRD contains the following spec:

```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  ingress:
    kourier:
      enabled: true
  config:
    network:
      ingress.class: "kourier.ingress.networking.knative.dev"
```

<!---TODO: Add this step to the DNS docs instead, it's not necessary here

Fetch the External IP or CNAME:

    kubectl --namespace knative-serving get service kourier

Save this for configuring DNS below.
--->

#### Using Contour as the networking layer

#### Using Ambassador as the networking layer

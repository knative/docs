# Configuring Services custom ingress class

When a Knative Service is created an ingress class (`ingress-class`) is automatically assigned to it, based on the value in the `config-network` ConfigMap located inside the `knative-serving` namespace. This ConfigMap is part of Knative Serving installation. If the ingress class is not specified, this defaults to `istio.ingress.networking.knative.dev`. Once configured the `ingress-class` is used for all Knative Services unless it is overridden with an `ingress-class` annotation.

!!! warning
    Changing the ingress class in `config-network` ConfigMap will only affect newly created Services

## Using the ingress class annotation

Generally it is recommended for Knative Services to use the default `ingress-class`. However, in scenarios where there are multiple networking implementations, you might want to specify different ingress class annotations for each Service.

You can configure each Service to use a different ingress class by specifying the `networking.knative.dev/ingress-class` annotation.

To add an ingress class annotation to a Service, run the following command:
```bash
kubectl annotate kservice <service-name> networking.knative.dev/ingress-class=<ingress-type>
```
Where:

- `<service-name>` is the name of the Service that you are applying the annotation to.
- `<ingress-type>` is the type of ingress that is used as the ingress class for the Service.

!!! note
    This annotation overrides the `ingress-class` value specified in the `config-network` ConfigMap.

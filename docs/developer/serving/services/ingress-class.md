# Configuring Services custom Ingress Class

By default, when a Knative Service is created an Ingress Class (`ingress.class`) is automatically chosen for it based on the content of the `networking-config` ConfigMap located inside the `knative-serving` namespace. 

The `networking-config` ConfigMap is configured when Knative Serving is installed, and if no other ingress class is specified, this defaults to `"istio.ingress.networking.knative.dev"`. 

After it is configured in the `networking-config` ConfigMap, the `ingress.class` is used for all Knative Services that do not specify an `ingress.class` annotation.

!!! warning
    The ingress class value should only be modified during Knative Serving installation to avoid issues in your deployment.

## Using the ingress class annotation

Generally it is recommended for Knative Services to use the default `ingress.class`. However, in scenarios where there are multiple networking implementations, you might want to specify different ingress class annotations for each Service.

You can configure each Service to use a different ingress class by specifying the `network.knative.dev/ingress.class` annotation.

To add an ingress class annotation to a Service, run the following command:
    ```bash
    kubectl annotate kservice <service-name> network.knative.dev/ingress.class=<ingress-type>
    ```
    Where:
    - `<service-name>` is the name of the Service that you are applying the annotation to.
    - `<ingress-type` is the type of ingress that is used as the ingress class for the Service.

!!! note
    This annotation overrides the configuration specified in the `networking-config` ConfigMap.

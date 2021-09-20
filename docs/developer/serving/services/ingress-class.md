# Configuring Services custom Ingress Class

By default, when a Knative Service is created an Ingress Class (`ingress.class`) is automatically chosen for it based on the content of the `networking-config` ConfigMap located inside the `knative-serving` namespace. 

The `networking-config` ConfigMap is configured at installation time and by default if no other implementation is provided this is defaulted to `"istio.ingress.networking.knative.dev"`. Note that it is best to only update this value during the setup of Knative, to avoid getting undefined behavior.

Once configuraded in the `networking-config` ConfigMap, the `ingress.class` will be used for all Knative Services which doesn't specify the `ingress.class` annotation.


## Using the `ingress-class` annotation 

Most of the times, you want your Knative Services to use the default and same `ingress.class`, but for scenarios where there are multiple networking implementations you might want to specify different `ingress.class`es per service. 

You can configure each Service to use a different Ingress Class by specifying the 
`network.knative.dev/ingress.class` label.

- To label a Knative Service:

    ```bash
    kubectl annotate kservice ${KSVC_NAME} network.knative.dev/ingress.class=<Implementation>
    ```

This annotation overrides the configuration specified in the `networking-config` ConfigMap.


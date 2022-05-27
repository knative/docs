# Configuring domain names

You can customize the domain of an individual Knative Service, or set a global default domain for all Services created on a cluster. The fully qualified domain name for a route by default is `{route}.{namespace}.example.com`.

## Configuring a domain for a single Knative Service

If you want to customize the domain of an individual Service, see the documentation about [`DomainMapping`](services/custom-domains.md).

## Configuring the default domain for all Knative Services on a cluster

You can change the default domain for all Knative Services on a cluster by modifying the [`config-domain` ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/domain.yaml).

### Procedure

1. Open the `config-domain` ConfigMap in your default text editor:

    ```bash
    kubectl edit configmap config-domain -n knative-serving
    ```

1. Edit the file to replace `example.com` with the domain you want to use, then remove the `_example` key and save your changes. In this example, `knative.dev` is configured as the domain for all routes:

    ```yaml
    apiVersion: v1
    data:
      knative.dev: ""
    kind: ConfigMap
    [...]
    ```

If you have an existing deployment, Knative reconciles the change made to the ConfigMap, and automatically updates the host name for all of the deployed Services and Routes.

## Verification steps

1. Deploy an app to your cluster.
1. Retrieve the URL for the Route:

    ```bash
    kubectl get route <route-name> --output jsonpath="{.status.url}"
    ```

    Where `<route-name>` is the name of the Route.

1. Observe the customized domain that you have configured.

## Publish your Domain

To make your domain publicly accessible, you must update your DNS provider to point to the IP address for your service ingress.

1. Create a [wildcard record](https://support.google.com/domains/answer/4633759)
  for the namespace and custom domain to the ingress IP Address, which would
  enable hostnames for multiple services in the same namespace to work without
  creating additional DNS entries.

    ```dns
    *.default.knative.dev                   59     IN     A   35.237.28.44
    ```

1. Create an A record to point from the fully qualified domain name to the IP
  address of your Knative gateway. This step needs to be done for each Knative
  Service or Route created.

    ```dns
    helloworld-go.default.knative.dev       59     IN     A   35.237.28.44
    ```

1. After the domain update has propagated, you can access your app by using the fully qualified domain name of the deployed route.

# Configuring custom domains

Each Knative Service is automatically assigned a default domain name when it is created. However, you can map any custom domain name that you own to a Knative Service, by using _domain mapping_.

You can create a `DomainMapping` object to map a single, non-wildcard domain to a specific Knative Service.

For example, if you own the domain name `example.org`, and you configure the domain DNS to reference your Knative cluster, you can use domain mapping to
serve a Knative Service at this domain.

## Prerequisites

- You must have access to a Kubernetes cluster, with Knative Serving and an Ingress implementation installed. For more information, see the [Installation documentation](../../../../admin/install/).
- You must have the domain mapping feature enabled on your cluster.
- You must have access to [a Knative service](../../../serving/services/creating-services) that you can map a domain to.
- You must own or have access to a domain name to map, and be able to change the domain DNS to point to your Knative cluster by using the tools provided by your domain registrar.

## Procedure

1. Create a `DomainMapping` object by entering the following command:

    ```yaml
    kubectl apply -f - <<EOF
    apiVersion: serving.knative.dev/v1alpha1
    kind: DomainMapping
    metadata:
      name: <domain-name>
      namespace: <namespace>
    spec:
      ref:
        name: <service-name>
        kind: Service
        apiVersion: serving.knative.dev/v1
    EOF
    ```
    Where:

    - `<domain-name>` is the domain name that you want to map a Service to.
    - `<namespace>` is the namespace that contains both the `DomainMapping` and `Service` objects.
    - `<service-name>` is the name of the service that will be mapped to the domain.

        !!! note

        You can also map to other targets as long as they conform to the Addressable contract and their resolved URL is of the form `{name}.{namespace}.{clusterdomain}`, where `{name}` and `{namespace}` are the name and namespace of a Kubernetes service, and `{clusterdomain}`is the cluster domain. Examples of objects that conform to this contract include Knative Services, Routes, and Kubernetes services.

1. Point the domain name to the IP address of your Knative cluster. Details of this step differ depending on your domain registrar.

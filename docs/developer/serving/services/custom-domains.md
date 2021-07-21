# Configuring custom domains

{{ feature(beta="0.24") }}

Each Knative Service is automatically assigned a default domain name when it is created. However, you can map any custom domain name that you own to a Knative Service, by using _domain mapping_.

You can create a `DomainMapping` object to map a single, non-wildcard domain to a specific Knative Service.

For example, if you own the domain name `example.org`, and you configure the domain DNS to reference your Knative cluster, you can use domain mapping to
serve a Knative Service at this domain.

!!! note
    If you create a domain mapping to map to a [private Knative Service](./private-services.md),
    the private Knative Service will be accessible from public internet with the custom domain of the domain mapping.

## Prerequisites

- You must have access to a Kubernetes cluster, with Knative Serving and an Ingress implementation installed. For more information, see the [Installation documentation](../../../../admin/install/).
- You must have the domain mapping feature enabled on your cluster.
- You must have access to [a Knative service](../../../serving/services/creating-services) that you can map a domain to.
- You must own or have access to a domain name to map, and be able to change the domain DNS to point to your Knative cluster by using the tools provided by your domain registrar.

## Procedure

1. By default, in order to create a DomainMapping you, or a cluster
   administrator, must first delegate the domain name to the namespace you wish
   to create the DomainMapping in by creating a ClusterDomainClaim.
   ClusterDomainClaims delegate a domain name to a namespace, so that
   DomainMappings in that namespace can use the domain name.

    Create a ClusterDomainClaim by entering the following command:
      ```yaml
      kubectl apply -f - <<EOF
      apiVersion: networking.internal.knative.dev/v1alpha1
      kind: ClusterDomainClaim
      metadata:
        name: <domain-name>
      spec:
        namespace: <namespace>
      EOF
      ```

    !!! tip
        You can avoid this step by setting the `autocreateClusterDomainClaims`
        property to "true" in the `config-network` config map, in the
        `knative-serving` namespace. This allows any user, in any namespace, to
        map any domain name, even ones in other namespaces or for domain names
        that they do not own.

1. Create a DomainMapping object by entering the following command:
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

    !!! tip
        You can also map to other targets as long as they conform to the Addressable contract and their resolved URL is of the form `{name}.{namespace}.{clusterdomain}`, where `{name}` and `{namespace}` are the name and namespace of a Kubernetes service, and `{clusterdomain}`is the cluster domain. Examples of objects that conform to this contract include Knative Services, Routes, and Kubernetes services.

1. Point the domain name to the IP address of your Knative cluster. Details of this step differ depending on your domain registrar.

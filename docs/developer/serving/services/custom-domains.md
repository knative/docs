# Configuring custom domains

{{ feature(beta="0.24") }}

Each Knative Service is automatically assigned a default domain name when it is created. However, you can map any custom domain name that you own to a Knative Service, by using _domain mapping_.

You can create a `DomainMapping` object to map a single, non-wildcard domain to a specific Knative Service.

For example, if you own the domain name `example.org`, and you configure the domain DNS to reference your Knative cluster, you can use domain mapping to
serve a Knative Service at this domain.

!!! note
    If you create a domain mapping to map to a [private Knative Service](private-services.md),
    the private Knative Service is accessible from public internet with the custom domain of the domain mapping.

## Prerequisites

- You must have access to a Kubernetes cluster, with Knative Serving and an Ingress implementation installed. For more information, see the [Installation documentation](../../../../admin/install/).
- You must have the domain mapping feature enabled on your cluster.
- You must have access to [a Knative service](../../../serving/services/creating-services) that you can map a domain to.
- You must own or have access to a domain name to map, and be able to change the domain DNS to point to your Knative cluster by using the tools provided by your domain registrar.

## Procedure

To create a DomainMapping, you must first have a ClusterDomainClaim. This ClusterDomainClaim
delegates the domain name to the namespace you want to create the DomainMapping in, which enables
DomainMappings in that namespace to use the domain name.

1. Create a ClusterDomainClaim manually or configure automatic creation of ClusterDomainClaims:

    * To create a ClusterDomainClaim manually:

        1. Create a YAML file using the following template:

            ```yaml
            apiVersion: networking.internal.knative.dev/v1alpha1
            kind: ClusterDomainClaim
            metadata:
              name: <domain-name>
            spec:
              namespace: <namespace>
            ```

        1. Apply the YAML file by running the command:

            ```bash
            kubectl apply -f <filename>.yaml
            ```
            Where `<filename>` is the name of the file you created in the previous step.

    * To create ClusterDomainClaims automatically, set the `autocreateClusterDomainClaims` property
    to `true` in the `config-network` ConfigMap in the `knative-serving` namespace.
    This allows any user, in any namespace, to map any domain name, including ones in other
    namespaces or for domain names that they do not own.
    <!-- insert example snippet -->

1. Create a DomainMapping object:

    1. Create a YAML file using the following template:

        ```yaml
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
        ```
        Where:
        - `<domain-name>` is the domain name that you want to map a Service to.
        - `<namespace>` is the namespace that contains both the `DomainMapping` and `Service` objects.
        - `<service-name>` is the name of the Service that is mapped to the domain.

        !!! tip
            You can also map to other targets as long as they conform to the Addressable contract and their resolved URL is of the form `<name>.<namespace>.<clusterdomain>`, where `<name>` and `<namespace>` are the name and namespace of a Kubernetes Service, and `<clusterdomain>`is the cluster domain.
            Examples of objects that conform to this contract include Knative Services, Routes, and Kubernetes Services.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Point the domain name to the IP address of your Knative cluster. Details of this step differ
depending on your domain registrar.

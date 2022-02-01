# Configuring custom domains

{{ feature(beta="0.24") }}

Each Knative Service is automatically assigned a default domain name when it is created. However, you can map any custom domain name that you own to a Knative Service, by using _domain mapping_.

You can create a `DomainMapping` object to map a single, non-wildcard domain to a specific Knative Service.

For example, if you own the domain name `example.org`, and you configure the domain DNS to reference your Knative cluster, you can use DomainMapping to
serve a Knative Service at this domain.

!!! note
    If you create a domain mapping to map to a [private Knative Service](private-services.md),
    the private Knative Service is accessible from public internet with the custom domain of the domain mapping.

!!! tip
    This topic instructs how to customize the domain of each service, regardless of the default domain.
    If you want to customize the domain template to assign the default domain name,
    see [Changing the default domain](../using-a-custom-domain.md).

## Prerequisites

- You must have access to a Kubernetes cluster, with Knative Serving and an Ingress implementation installed. For more information, see the [Serving Installation documentation](../../install/yaml-install/serving/install-serving-with-yaml.md).
- You must have the domain mapping feature enabled on your cluster.
- You must have access to [a Knative service](creating-services.md) that you can map a domain to.
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

    * To create ClusterDomainClaims automatically: set the `autocreate-cluster-domain-claims` property
    to `true` in the `config-network` ConfigMap in the `knative-serving` namespace.
    This allows any user, in any namespace, to map any domain name, including ones in other
    namespaces or for domain names that they do not own.
    <!-- insert example snippet -->

1. Create a DomainMapping object:

    === "YAML"

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
              tls:
                secretName: <cert-secret>
            ```
            Where:

            - `<domain-name>` is the domain name that you want to map a Service to.
            - `<namespace>` is the namespace that contains both the `DomainMapping` and `Service` objects.
            - `<service-name>` is the name of the Service that is mapped to the domain.
            - `<cert-secret>` is the name of a Secret that holds the server certificate for TLS communication. If this optional `tls:` section is provided, the protocol is switched from HTTP to HTTPS.

            !!! tip
                You can also map to other targets as long as they conform to the Addressable contract and their resolved URL is of the form `<name>.<namespace>.<clusterdomain>`, where `<name>` and `<namespace>` are the name and namespace of a Kubernetes Service, and `<clusterdomain>`is the cluster domain.
                Examples of objects that conform to this contract include Knative Services, Routes, and Kubernetes Services.

        1. Apply the YAML file by running the command:

            ```bash
            kubectl apply -f <filename>.yaml
            ```
            Where `<filename>` is the name of the file you created in the previous step.

    === "kn"
        Run the command:

        ```bash
        kn domain create <domain-name> --ref <target> --tls <tls-secret> --namespace <namespace>
        ```

        Where:

        - `<domain-name>` is the domain name that you want to map a Service or Route to.
        - `<target>` is the name of the Service or Route that is mapped to the domain.
        You can use the prefix `ksvc:` or `kroute:` to specify whether to map the domain to a Knative Service or Route.
        If no prefix is given, `ksvc:` is assumed.
        Additionally, you can use a `:namespace` suffix to point to a Service or Route in a different namespace.
        Examples:
            - `mysvc` maps to a Service `mysvc` in the same namespace as this mapping.
            - `kroute:myroute:othernamespace` maps to a Route `myroute` in namespace `othernamespace`.
        - `<tls-secret>` is optional and if provided enables the TLS protocol. The value specifies the secret that holds the server certificate.
        - `<namespace>` is the namespace where you want to create the DomainMapping. By default the DomainMapping is created in the current namespace.

        !!! note
            In addition to creating DomainMappings, you can use the `kn domain`
            command to list, describe, update, and delete existing DomainMappings.
            For more information about the command, run `kn domain --help`.

1. Point the domain name to the IP address of your Knative cluster. Details of this step differ
depending on your domain registrar.

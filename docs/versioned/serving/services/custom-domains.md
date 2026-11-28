---
audience: developer
components:
  - serving
function: how-to
---

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
- The DomainMapping API and controller must be installed. They are included in
  the standard Serving core installation.
- You need permission to create a ClusterDomainClaim, or an administrator must
  delegate the chosen domain to your namespace.
- You must have access to [a Knative service](creating-services.md) that you can map a domain to.
- For public access, you control the domain and its DNS, and your Serving networking
  gateway has an address reachable by your callers. Use the **networking gateway's**
  public IP or hostname, not the Kubernetes API endpoint, a pod IP, or an arbitrary
  cluster address. See [networking gateway checks](../troubleshooting/debugging-application-issues.md#check-ingress-status)
  for the installed adapter.

For a standard installation, check the API and controller:

```bash
kubectl get crd domainmappings.serving.knative.dev
kubectl rollout status deployment/controller -n knative-serving
```

If either is missing, follow the Serving installation guide or ask your platform
administrator; do not guess at a feature flag. Controller and namespace names may
differ in a customized installation.

The default kind Quickstart is local-only: its gateway is exposed on your machine,
not at a public cloud address. For a local test you can use the reserved domain
`example.test` and the explicit localhost request below; no public DNS change is
needed. Do not publish a DNS record pointing your real domain to `127.0.0.1`.

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
            apiVersion: serving.knative.dev/v1beta1
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
            This basic example uses HTTP. To add HTTPS with a certificate Secret,
            follow [Using a custom TLS certificate for DomainMapping](custom-tls-certificate-domain-mapping.md).

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
        kn domain create <domain-name> --ref <target> --namespace <namespace>
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
        - To enable HTTPS, add `--tls <tls-secret>` with an existing certificate
          Secret and follow the [TLS guide](custom-tls-certificate-domain-mapping.md).
          It is not required for the HTTP example.
        - `<namespace>` is the namespace where you want to create the DomainMapping. By default the DomainMapping is created in the current namespace.

        !!! note
            In addition to creating DomainMappings, you can use the `kn domain`
            command to list, describe, update, and delete existing DomainMappings.
            For more information about the command, run `kn domain --help`.

1. Choose how callers will reach the domain:

    - **Public access:** create a DNS record for the **exact hostname** used as the
      DomainMapping name. Use an A record for your gateway's public IPv4 address
      or an AAAA record for its public IPv6 address. If your provider gives the
      gateway a hostname instead, follow your DNS provider's CNAME/alias rules.
      This is a single-domain record, not a wildcard for the cluster's default
      domain suffix. You do **not** need to patch `config-domain` just to use
      this DomainMapping. DNS may take time to propagate.
    - **Local kind Quickstart:** do not change public DNS. Create the mapping using
      `example.test` (or your chosen test domain) and use the localhost request below.

## Verify { #verify-the-mapping-and-request }

Substitute the same domain name and namespace used when creating the DomainMapping:

```bash
kubectl wait domainmapping/<domain-name> \
  --namespace <namespace> --for=condition=Ready --timeout=120s
```

If it is not ready, inspect `kubectl describe domainmapping <domain-name> --namespace <namespace>`
and check the reported claim, target-Service, and ingress conditions.

For a public HTTP mapping, request `http://<domain-name>` from an environment that
can reach the gateway; use `https://` if you configured TLS. Confirm your
application's expected response, not just that the resource exists.

For the default local kind Quickstart with a mapping named `example.test`, use:

```bash
curl --resolve example.test:80:127.0.0.1 http://example.test
```

Substitute your test domain in both places if different. This sends the domain's
HTTP Host header to the gateway on your machine without requiring DNS resolution.
It verifies a local route only, not public reachability or production TLS.

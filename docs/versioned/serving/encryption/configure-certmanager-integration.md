---
audience: administrator
components:
  - serving
function: how-to
---

# Configuring Knative cert-manager integration

Knative Serving relies on a bridging component to use cert-manager for automated certificate provisioning. 
If you intend to use that feature, you need to enable the Knative cert-manager integration.

## Prerequisites

The following must be installed on your Knative cluster:

- [Knative Serving](../../install/yaml-install/serving/install-serving-with-yaml.md).
- [`cert-manager`](../../install/installing-cert-manager.md) version `1.0.0` or higher.

!!! warning
    Make sure you have installed cert-manager. Otherwise, the Serving controller will not start up correctly.


## Issuer configuration

The Knative cert-manager integration defines three references to [cert-manager issuers](https://cert-manager.io/docs/configuration/issuers/) to configure different CAs
for the [three Knative Serving encryption features](./encryption-overview.md):

* `issuerRef`: issuer for external-domain certificates used for ingress.
* `clusterLocalIssuerRef`: issuer for cluster-local-domain certificates used for ingress.
* `systemInternalIssuerRef`: issuer for certificates for system-internal-tls certificates used by Knative internal components.

The following example uses a self-signed `ClusterIssuer` and the Knative cert-manager integration references that `ClusterIssuer` for all three configurations.
As this **should not be used in production** (and does not support rotating the CA without downtime),
you should think about which CA should be used for each use case and how trust will be distributed to the clients calling the encrypted services. 
For the Knative system components, Knative provides a way to specify a bundle of CAs that should be trusted (more on this below).

There is no general answer on how to structure this, here an example on how it could look like:

| Feature                  | Certificate Authority                      | Trusted via                                                                                                                                                                          |
|--------------------------|--------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| external-domain-tls      | Let's encrypt                              | Browser clients have the Let's encrypt chain already, all the root CAs will be added in company-wide Docker base image by DevOps team.                                               |
| cluster-local-domain-tls | CA provided by cluster operator            | The CA is managed by the DevOps team and will be added in company-wide Docker base image.                                                                                            |
| system-internal-tls      | Self-signed Cert-Manager `ClusterIssuer`   | The CA will be populated by cert-manager. DevOps team will use [trust-manager](https://cert-manager.io/docs/trust/trust-manager/) to distribute the CA to Knative system components. |


### Issuer selection

In general, you can refer to the [cert-manager documentation](https://cert-manager.io/docs/configuration/acme/#creating-a-basic-acme-issuer). There are examples available for:

* [CA based on a K8s secret](https://cert-manager.io/docs/configuration/ca/)
* [HTTP-01 challenges, e.g. Let's encrypt](https://cert-manager.io/docs/configuration/acme/#creating-a-basic-acme-issuer)
* [DNS-01 challenges](https://cert-manager.io/docs/configuration/acme/dns01/)
* [Self-signed issuers](https://cert-manager.io/docs/configuration/selfsigned/)

!!! important
    Please note, that not all issuer types work for each Knative feature.

`cluster-local-domain-tls` needs to be able to sign certificates for cluster-local domains like `myapp.<namespace>`, `myapp.<namespace>.svc` and `myapp.<namespace>.svc.cluster.local`.
The CA is usually outside the cluster, so verification via ACME protocol (DNS01/HTTP01) is impossible. You can use an issuer that allows the creation of these certificates (e.g., a CA issuer). 

`system-internal-tls` needs to be able to sign specific SANs that Knative validates for. The defined set of SANs is:

* `kn-routing`
* `kn-user-<namespace>` (<namespace> is each namespace where Knative Services are/will be created)
* `data-plane.knative.dev`

As this is also not possible via ACME protocol (DNS01/HTTP01), you need to configure an issuer that allows creating the these certificates (e.g. CA issuer).


### Configuring issuers

!!! warning
    The self-signed cluster issuer should not be used in production, please see [Issuer configuration](#issuer-configuration) above for more information.

1. Create and apply the following self-signed `ClusterIssuer` to your cluster:

    ```yaml
    # this issuer is used by cert-manager to sign all certificates
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: cluster-selfsigned-issuer
    spec:
      selfSigned: {}
    ---
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer # this issuer is specifically for Knative, it will use the CA stored in the secret created by the Certificate below
    metadata:
      name: knative-selfsigned-issuer
    spec:
      ca:
        secretName: knative-selfsigned-ca
    ---
    apiVersion: cert-manager.io/v1
    kind: Certificate # this creates a CA certificate, signed by cluster-selfsigned-issuer and stored in the secret knative-selfsigned-ca
    metadata:
      name: knative-selfsigned-ca
      namespace: cert-manager #  If you want to use it as a ClusterIssuer the secret must be in the cert-manager namespace.
    spec:
      secretName: knative-selfsigned-ca
      commonName: knative.dev
      usages:
        - server auth
      isCA: true
      issuerRef:
        kind: ClusterIssuer
        name: cluster-selfsigned-issuer
    ```

1. Ensure that the `ClusterIssuer` is ready:

    ```bash
    kubectl get clusterissuer cluster-selfsigned-issuer -o yaml
    kubectl get clusterissuer knative-selfsigned-issuer -o yaml
    ```
    Result: The `Status.Conditions` should include `Ready=True`.

1. Then reference the `ClusterIssuer` in the `config-certmanager` ConfigMap:

    ```bash
    kubectl edit configmap config-certmanager -n knative-serving
    ```

    Add the fields within the `data` section:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-certmanager
      namespace: knative-serving
      labels:
        networking.knative.dev/certificate-provider: cert-manager
    data:
      issuerRef: |
        kind: ClusterIssuer
        name: knative-selfsigned-issuer
      clusterLocalIssuerRef: |
        kind: ClusterIssuer
        name: knative-selfsigned-issuer
      systemInternalIssuerRef: |
        kind: ClusterIssuer
        name: knative-selfsigned-issuer
    ```

    Ensure that the file was updated successfully:

    ```bash
    kubectl get configmap config-certmanager -n knative-serving -o yaml
    ```


## Managing trust and rotation without downtime

As pointed out above, each client that calls a Knative Service using HTTPS needs to trust the CA and/or intermediate chain.
If you take a look at the [encryption overview](./encryption-overview.md), you can see that there are multiple places where 
trust needs to be distributed:

* **Cluster external client (Browser and/or other application)**: this is considered out of scope of Knative.
* **Cluster internal client (e.g. Knative or Vanilla K8s workload)**: see below.
* **Knative system components (e.g. Activator, Queue-Proxy, Ingress-Controller)**: see below.


### Trusting for cluster internal clients (e.g. Knative or Vanilla K8s workload)

As Knative does not control all workload and the settings are highly dependent on your runtime and/or language, this is out of scope of Knative.
But here a few points to consider, as there are several ways on how to provide CAs to your application:

* Adding the CA bundle to a Container image on build-time (be aware that this complicates CA rotation, you basically need to rebuild every application)
* Mounting a CA bundle to the filesystem (e.g. from a `Secret` or `ConfigMap`)
* Reading it from environment variable
* Accessing it from a `Secret`/`ConfigMap` via K8s API

If reloading certificates without downtime is important for your client, the workload must either watch changes on the K8s resource (Secret/ConfigMap) or watch the filesystem.
If the workload is watching the filesystem, it is important to note that using `ionotify` to catch changing Secrets/ConfigMaps is not very reliable on K8s. Tests have shown that it is more reliable to regularly poll and check the certificate on the filesystem for changes.

Here are a few examples for golang:

* Saving the bundle as a file to a defined path: [https://go.dev/src/crypto/x509/root_linux.go](https://go.dev/src/crypto/x509/root_linux.go) (note does not reload without restart)
* Reloading dynamically via K8s API: [https://github.com/knative/serving/blob/main/pkg/activator/certificate/cache.go](https://github.com/knative/serving/blob/main/pkg/activator/certificate/cache.go#L95)
* Reloading from filesystem with a watcher process: [https://github.com/knative/serving/blob/main/pkg/queue/certificate/watcher.go](https://github.com/knative/serving/blob/main/pkg/queue/certificate/watcher.go#L32)


### Trusting for Knative system components

Knative system components can be configured to trust one or many CA bundles from `ConfigMaps`. The cluster operator needs to ensure,
to configure them accordingly to avoid any downtimes [during a rotation](#trust-during-rotation). Knative components look for a `ConfigMap`
in the namespace where the component runs, e.g:

* knative-serving
* istio-system (when using net-istio)
* kourier-system (when using net-kourier)
* Each namespace where a Knative Service runs

Knative looks for a `ConfigMap` with the label `networking.knative.dev/trust-bundle: "true"` and will read all `data` keys (regardless of the name). 
One key can contain one or multiple CAs/Intermediates. If they are valid, they will be added to the trust store of the Knative components.

Here is an example of how `ConfigMap` could look like:

```yaml
apiVersion: v1
data:
  cacerts.pem: |
    -----BEGIN CERTIFICATE-----
    MIIDDTCCAfWgAwIBAgIQMQuip05h7NLQq2TB+j9ZmTANBgkqhkiG9w0BAQsFADAW
    MRQwEgYDVQQDEwtrbmF0aXZlLmRldjAeFw0yMzExMjIwOTAwNDhaFw0yNDAyMjAw
    OTAwNDhaMBYxFDASBgNVBAMTC2tuYXRpdmUuZGV2MIIBIjANBgkqhkiG9w0BAQEF
    AAOCAQ8AMIIBCgKCAQEA3clC3CV7sy0TpUKNuTku6QmP9z8JUCbLCPCLACCUc1zG
    FEokqOva6TakgvAntXLkB3TEsbdCJlNm6qFbbko6DBfX6rEggqZs40x3/T+KH66u
    4PvMT3fzEtaMJDK/KQOBIvVHrKmPkvccUYK/qWY7rgBjVjjLVSJrCn4dKaEZ2JNr
    Fd0KNnaaW/dP9/FvviLqVJvHnTMHH5qyRRr1kUGTrc8njRKwpHcnUdauiDoWRKxo
    Zlyy+MhQfdbbyapX984WsDjCvrDXzkdGgbRNAf+erl6yUm6pHpQhyFFo/zndx6Uq
    QXA7jYvM2M3qCnXmaFowidoLDsDyhwoxD7WT8zur/QIDAQABo1cwVTAOBgNVHQ8B
    Af8EBAMCAgQwEwYDVR0lBAwwCgYIKwYBBQUHAwEwDwYDVR0TAQH/BAUwAwEB/zAd
    BgNVHQ4EFgQU7p4VuECNOcnrP9ulOjc4J37Q2VUwDQYJKoZIhvcNAQELBQADggEB
    AAv26Vnk+ptQrppouF7yHV8fZbfnehpm07HIZkmnXO2vAP+MZJDNrHjy8JAVzXjt
    +OlzqAL0cRQLsUptB0btoJuw23eq8RXgJo05OLOPQ2iGNbAATQh2kLwBWd/CMg+V
    KJ4EIEpF4dmwOohsNR6xa/JoArIYH0D7gh2CwjrdGZr/tq1eMSL+uZcuX5OiE44A
    2oXF9/jsqerOcH7QUMejSnB8N7X0LmUvH4jAesQgr7jo1JTOBs7GF6wb+U76NzFa
    8ms2iAWhoplQ+EHR52wffWb0k6trXspq4O6v/J+nq9Ky3vC36so+G1ZFkMhCdTVJ
    ZmrBsSMWeT2l07qeei2UFRU=
    -----END CERTIFICATE-----
kind: ConfigMap
metadata:
  labels:
    networking.knative.dev/trust-bundle: "true"
  name: knative-bundle
  namespace: knative-serving
```

### Using trust-manager to distribute the bundle

As it can be a cumbersome task to distribute the CA bundle to all the namespaces, you can use [trust-manager](https://cert-manager.io/docs/trust/trust-manager/) 
to automatically distribute the CA bundles. Please refer to their documentation for more information on how to do this.


### Trust during rotation

During a rotation of a CA and/or Intermediate certificates your clients will need to trust the old and the new CA/chain until the
rotation is done. Using the [trust approach](#managing-trust-and-rotation-without-downtime) from above, you can do a full
chain rotation without downtime:

1. Make sure your existing setup is up and running.
2. Make sure all Knative Services have the relevant certificates and are not expired.
3. Make sure your CA (and full chain) is not expired.
4. Add the existing **and** the new CA (and the full chain) to the trust bundle (either manually or via trust-manager).
5. Reconfigure your cert-manager `ClusterIssuers` or `Issuers` to use the new CA.
6. Wait until all certificates are expired and are renewed by cert-manager.
7. All certificates are now signed by the new CA.
8. Add some grace period to make sure all components did pick up all the changes.
9. Remove the old CA from the trust bundle.



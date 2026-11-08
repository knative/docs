---
audience: administrator
components:
  - eventing
function: how-to
---

# Transport Encryption for Knative Eventing

**Flag name**: `transport-encryption`

**Stage**: Beta, disabled by default

**Tracking issue**: [#5957](https://github.com/knative/eventing/issues/5957)

**v1.24 source scope:** the flag name, Beta/disabled release configuration,
and `strict`/`permissive` values were rechecked in the
[v1.24 feature configuration](https://github.com/knative/eventing/blob/knative-v1.24.0/config/core/configmaps/features.yaml)
and [flag parser](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/apis/feature/features.go).
The shared server behavior below is implementation-scoped, not a revalidated
Broker/Channel capability matrix. Earlier v1.23 runtime results are historical
only; the certificate/producer examples have not been executed here on v1.24.

## Overview

By default, event delivery within the cluster is unencrypted. This limits the types of events which
can be transmitted to those of low compliance value (or a relaxed compliance posture)
or, alternatively, forces administrators to use a service mesh or encrypted CNI to encrypt the
traffic, which poses many challenges to Knative Eventing adopters.

Knative Brokers and Channels provides HTTPS endpoints to receive events. Given that these
endpoints typically do not have public DNS names (e.g. svc.cluster.local or the like), these need to
be signed by a non-public CA (cluster or organization specific CA).

Event producers are be able to connect to HTTPS endpoints with cluster-internal CA certificates.

## Prerequisites

- Identify the approved cluster/context, Eventing component namespace, and
  configuration authority before installing certificates or changing feature
  settings. You need the responsible platform owner's approval and permissions,
  plus an authoritative manifest and recoverable record of the previous flag
  value or absence. The installation examples use specific namespaces; check
  them against your deployment before running their commands.
- If the Knative Operator manages Eventing, use the existing `KnativeEventing`
  resource for feature configuration rather than editing its generated
  `config-features` ConfigMap. If GitOps manages that resource or a YAML-managed
  ConfigMap, change the authoritative source through that workflow. Unknown
  authority or read-only access is a handoff to the platform owner, not a reason
  to edit a live ConfigMap. See [Apply through the configuration authority](#apply-through-the-configuration-authority).
- In order to enable the transport encryption feature, you will need to install cert-manager
  operator by
  following [the cert-manager operator installation instructions](https://cert-manager.io/docs/installation/).
- [Eventing installation](../../install/README.md)

## Installation

### Setup `SelfSigned` `ClusterIssuer`

!!! note
    ClusterIssuers, are Kubernetes resources that represent certificate authorities (CAs) that are able
    to generate signed certificates by honoring certificate signing requests. All cert-manager
    certificates require a referenced issuer that is in a ready condition to attempt to honor the
    request.
    Reference: cert-manager.io/docs/concepts/issuer/

!!! important
    For the simplicity of this guide, we will use a `SelfSigned` issuer as root certificate, however, be
    aware of the implications and limitations as documented at
    cert-manager.io/docs/configuration/selfsigned/ of this method.
    If you’re running your company specific Private Key Infrastructure (PKI), we recommend the CA
    issuer. Refer to the cert-manager documentation for more details:
    cert-manager.io/docs/configuration/ca/, however, you can use any other issuer that is usable for
    cluster-local services.

1. Create a `SelfSigned` `ClusterIssuer`:
    ```yaml
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: knative-eventing-selfsigned-issuer
    spec:
      selfSigned: {}
    ```
2. Apply the `ClusterIssuer` resource:
    ```shell
    $ kubectl apply -f <filename>
    ```
3. Create a root certificate using the previously created `SelfSigned` `ClusterIssuer`:
    ```yaml
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: knative-eventing-selfsigned-ca
      namespace: cert-manager # the cert-manager operator namespace
    spec:
       # Secret name later used for the ClusterIssuer for Eventing
      secretName: knative-eventing-ca

      isCA: true
      commonName: selfsigned-ca
      privateKey:
        algorithm: ECDSA
        size: 256

      issuerRef:
        name: knative-eventing-selfsigned-issuer
        kind: ClusterIssuer
        group: cert-manager.io
    ```
4. Apply the `Certificate` resource:
    ```yaml
    $ kubectl apply -f <filename>
    ```

### Setup `ClusterIssuer` for Eventing

1. Create the `knative-eventing-ca-issuer` `ClusterIssuer` for Eventing:
    ```yaml
    # This is the issuer that every Eventing component use to issue their server's certs.
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: knative-eventing-ca-issuer
    spec:
      ca:
        # Secret name in the Cert-Manager Operator namespace (cert-manager by default) containing
        # the certificate that can then be used by Knative Eventing components for new certificates.
        secretName: knative-eventing-ca 
    ```
   !!! important
        The name of the `ClusterIssuer` must be `knative-eventing-ca-issuer`.

2. Apply the `ClusterIssuer` resource:
    ```yaml
    $ kubectl apply -f <filename>
    ```

### Install the certificates for Eventing components

Eventing components use cert-manager issuers and certificates to provision TLS certificates and in
the release assets, we release the certificates for Eventing servers that can be customized as
necessary.

1. Install certificates, run the following command:
    ```shell
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-tls-networking.yaml")}}
    ```
2. [Optional] If you're using Eventing Kafka components, install certificates for Kafka components
   by running the following command:
    ```shell
    kubectl apply -f {{ artifact(org="knative-extensions",repo="eventing-kafka-broker",file="eventing-kafka-tls-networking.yaml")}}
    ```
3. Verify issuers and certificates are ready
    ```shell
    kubectl get certificates.cert-manager.io -n knative-eventing
    ```
   Example output:
    ```shell
    NAME                           READY   SECRET                         AGE
    imc-dispatcher-server-tls      True    imc-dispatcher-server-tls      14s
    mt-broker-filter-server-tls    True    mt-broker-filter-server-tls    14s
    mt-broker-ingress-server-tls   True    mt-broker-ingress-server-tls   14s
    selfsigned-ca                  True    eventing-ca                    14s
    ...
    ```

## Transport Encryption configuration

The `transport-encryption` feature flag is an enum configuration that configures how Addressables (
Broker, Channel, Sink) should accept events.

The possible values for `transport-encryption` are:

- `disabled`
    - For v1.24 components using the shared `ServerManager`, HTTP requests reach
      the handler while HTTPS requests receive 404. This is a source-scoped
      receiver behavior, not a claim about every implementation.
    - Producers may send events to separately configured HTTPS destinations.
- `permissive`
    - Addressables should accept events on both HTTP and HTTPS endpoints
    - Addressables should advertise both HTTP and HTTPS endpoints
    - Producers should prefer sending events to HTTPS endpoints, if available
- `strict`
    - Addressables must not accept events to non-HTTPS endpoints
    - Addressables must only advertise HTTPS endpoints

!!! important
    The `strict` is only enforced on the Broker and Channel receiver/ingress. 
    When a broker or channel sends events to a subscriber, if that subscriber only has an HTTP
    address, the broker or channel can still send events over HTTP instead of HTTPS

The rechecked v1.24 [shared server manager](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/eventingtls/servermanager.go)
returns 404 on HTTP in strict mode and on HTTPS in disabled mode; permissive
mode allows both handlers. This receiver gating does not require an HTTP-only
subscriber to become an HTTPS endpoint. The release's
[Broker certificate manifest](https://github.com/knative/eventing/blob/knative-v1.24.0/config/brokers/mt-channel-broker-tls/broker-ingress-tls-certificate.yaml)
references `knative-eventing-ca-issuer`; the
[trust-bundle code](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/eventingtls/trust_bundle.go)
defines `networking.knative.dev/trust-bundle=true` and `/knative-custom-certs`.
These source checks do not establish certificate readiness or end-to-end trust.

For example, the resulting `config-features` data for `strict` transport
encryption is shown below. This illustrates the intended ConfigMap value,
**not** permission to replace an existing ConfigMap or directly edit an
Operator-managed one. Preserve unrelated feature settings and follow the
[configuration-authority branch](#apply-through-the-configuration-authority).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
data:
  transport-encryption: "strict"
```

### Apply through the configuration authority

Choose one authority path for the `transport-encryption` flag after satisfying
the certificate/trust prerequisites and reviewing the receiver-only `strict`
constraint above. Use the actual resource names/namespaces and the explicitly
approved `--context` when adapting the linked apply/verify commands; do not run
their examples against an unrelated default context.

- **Knative Operator-managed:** inspect `spec.config` in both the live
  `KnativeEventing` resource and its authoritative manifest. The rechecked
  [v1.24 Operator `ConfigMapTransform`](https://github.com/knative/operator/blob/knative-v1.24.0/pkg/reconciler/common/config_maps.go)
  and [mapping reference](../../install/operator/configuration-reference.md#configmap-mapping)
  define `config-features` as the full-name entry and `features` as its shortened
  form. A present `config-features` entry wins, including an empty entry or one
  without `transport-encryption`; its data is not merged with `features`.
  Update the winning existing entry rather than adding a shadow entry. If neither
  exists, have the owner choose one naming form through that mapping guidance.
  Change only the intended flag, preserving other settings, and follow
  [Apply and verify an Eventing configuration change](../../install/operator/configuring-eventing-cr.md#apply-and-verify-a-configuration-change)
  through the authoritative workflow. Do not apply the ConfigMap example above
  or the linked collection's unrelated example fields over your installation.
- **YAML-managed:** update `data.transport-encryption` in the authoritative
  `config-features` manifest, retaining the existing namespace and other data,
  then apply through its approved workflow. Direct live editing is appropriate
  only if the platform owner identifies it as the configuration authority;
  do not use it for Operator- or GitOps-managed configuration.
- **Unknown authority or insufficient permissions:** request the change and
  redacted resulting configuration from the platform owner. Do not create a
  competing ConfigMap or custom resource.

After reconciliation, inspect the actual component namespace in the approved
context, replacing the placeholders:

```bash
kubectl --context <approved-context-name> -n <eventing-component-namespace> get configmap config-features -o jsonpath='{.data.transport-encryption}{"\n"}'
```

For the illustrated change, the active key should print `strict`. A blank result
means the key is absent, not proof of the effective encryption mode. For an
Operator-managed installation, also inspect `KnativeEventing` readiness and
conditions using the linked procedure. If the flag does not persist, resolve the
winning entry and configuration authority rather than repeatedly patching the
managed ConfigMap.

These checks establish configuration propagation, not TLS trust, rejection of
plaintext ingress, or subscriber receipt. Retain the feature-stage and
receiver-only enforcement caveats above. The [verification example](#verifying-that-the-feature-is-working)
illustrates a separate test path; validate its commands, certificates, addresses,
and release artifacts before execution in an approved disposable environment.
This authority handoff does not revalidate implementation capabilities or claim
runtime verification. To recover, restore the recorded flag value or absence
through the same authoritative workflow, repeat the configuration checks, and
have the platform owner recheck the affected event path.

## Configure additional CA trust bundles

By default, Eventing clients trusts the system root CA (public CA).

If you need to add additional CA bundles for Eventing, you can do so by creating ConfigMaps in the
`knative-eventing` namespace with label `networking.knative.dev/trust-bundle: true`:

!!! important
    Whenever CA bundles `ConfigMaps` are updated, the Eventing clients will automatically add them to
    their trusted CA bundles when a new connection is established.

1. Create a CA bundle for Eventing:
    ```yaml
    kind: ConfigMap
    metadata:
      name: my-org-eventing-bundle
      namespace: knative-eventing
      labels:
        networking.knative.dev/trust-bundle: "true"
    # All data keys containing valid PEM-encoded CA bundles will be trusted by Eventing clients.
    data:
      ca.crt: ...
      ca1.crt: ...
      tls.crt: ...
    ```

!!! important
    Use a name that is unlikely to conflict with existing or future Eventing-provided `ConfigMap` name.

For distributing CA trust bundles, you can leverage [trust-manager](https://cert-manager.io/docs/trust/trust-manager/),
however, it is not required.

### Trusting CA for a specific event sender

Event sources, triggers or subscriptions are considered event senders, and they can be configured to
trust specific CA certificates.

!!! important
    The CA certs must be PEM formatted certificates. Since it's a multi-line YAML string make sure that
    the `CACerts` value is indented correctly, otherwise when creating the resource it will be rejected.

Triggers and subscriptions can be configured as follows:

```yaml
spec:
  # ...

  subscriber:
    uri: https://mycorp-internal-example.com/v1/api
    CACerts: |-
      -----BEGIN CERTIFICATE-----
      MIIFWjCCA0KgAwIBAgIQT9Irj/VkyDOeTzRYZiNwYDANBgkqhkiG9w0BAQsFADBH
      MQswCQYDVQQGEwJDTjERMA8GA1UECgwIVW5pVHJ1c3QxJTAjBgNVBAMMHFVDQSBF
      eHRlbmRlZCBWYWxpZGF0aW9uIFJvb3QwHhcNMTUwMzEzMDAwMDAwWhcNMzgxMjMx
      MDAwMDAwWjBHMQswCQYDVQQGEwJDTjERMA8GA1UECgwIVW5pVHJ1c3QxJTAjBgNV
      BAMMHFVDQSBFeHRlbmRlZCBWYWxpZGF0aW9uIFJvb3QwggIiMA0GCSqGSIb3DQEB
      AQUAA4ICDwAwggIKAoICAQCpCQcoEwKwmeBkqh5DFnpzsZGgdT6o+uM4AHrsiWog
      D4vFsJszA1qGxliG1cGFu0/GnEBNyr7uaZa4rYEwmnySBesFK5pI0Lh2PpbIILvS
      sPGP2KxFRv+qZ2C0d35qHzwaUnoEPQc8hQ2E0B92CvdqFN9y4zR8V05WAT558aop
      O2z6+I9tTcg1367r3CTueUWnhbYFiN6IXSV8l2RnCdm/WhUFhvMJHuxYMjMR83dk
      sHYf5BA1FxvyDrFspCqjc/wJHx4yGVMR59mzLC52LqGj3n5qiAno8geK+LLNEOfi
      c0CTuwjRP+H8C5SzJe98ptfRr5//lpr1kXuYC3fUfugH0mK1lTnj8/FtDw5lhIpj
      VMWAtuCeS31HJqcBCF3RiJ7XwzJE+oJKCmhUfzhTA8ykADNkUVkLo4KRel7sFsLz
      KuZi2irbWWIQJUoqgQtHB0MGcIfS+pMRKXpITeuUx3BNr2fVUbGAIAEBtHoIppB/
      TuDvB0GHr2qlXov7z1CymlSvw4m6WC31MJixNnI5fkkE/SmnTHnkBVfblLkWU41G
      sx2VYVdWf6/wFlthWG82UBEL2KwrlRYaDh8IzTY0ZRBiZtWAXxQgXy0MoHgKaNYs
      1+lvK9JKBZP8nm9rZ/+I8U6laUpSNwXqxhaN0sSZ0YIrO7o1dfdRUVjzyAfd5LQD
      fwIDAQABo0IwQDAdBgNVHQ4EFgQU2XQ65DA9DfcS3H5aBZ8eNJr34RQwDwYDVR0T
      AQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggIBADaN
      l8xCFWQpN5smLNb7rhVpLGsaGvdftvkHTFnq88nIua7Mui563MD1sC3AO6+fcAUR
      ap8lTwEpcOPlDOHqWnzcSbvBHiqB9RZLcpHIojG5qtr8nR/zXUACE/xOHAbKsxSQ
      VBcZEhrxH9cMaVr2cXj0lH2RC47skFSOvG+hTKv8dGT9cZr4QQehzZHkPJrgmzI5
      c6sq1WnIeJEmMX3ixzDx/BR4dxIOE/TdFpS/S2d7cFOFyrC78zhNLJA5wA3CXWvp
      4uXViI3WLL+rG761KIcSF3Ru/H38j9CHJrAb+7lsq+KePRXBOy5nAliRn+/4Qh8s
      t2j1da3Ptfb/EX3C8CSlrdP6oDyp+l3cpaDvRKS+1ujl5BOWF3sGPjLtx7dCvHaj
      2GU4Kzg1USEODm8uNBNA4StnDG1KQTAYI1oyVZnJF+A83vbsea0rWBmirSwiGpWO
      vpaQXUJXxPkUAzUrHC1RVwinOt4/5Mi0A3PCwSaAuwtCH60NryZy2sy+s6ODWA2C
      xR9GUeOcGMyNm43sSet1UNWMKFnKdDTajAshqx7qG+XH/RU+wBeq+yNuJkbL+vmx
      cmtpzyKEC2IPrNkZAJSidjzULZrtBJ4tBmIQN1IchXIbJ+XMxjHsN+xjWZsLHXbM
      fjKaiJUINlK73nZfdklJrX+9ZSCyycErdhh2n1ax
      -----END CERTIFICATE-----
```

Similarly, sources can be configured as follows:

```yaml
spec:
  # ...

  sink:
    uri: https://mycorp-internal-example.com/v1/api
    CACerts: |-
      -----BEGIN CERTIFICATE-----
      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
      -----END CERTIFICATE-----
```

### Configure custom event sources to trust the Eventing CA

The recommended way of creating custom event sources is using a SinkBinding, SinkBinding will inject
the configured CA trust bundles as projected volume into each container using the directory
`/knative-custom-certs`.

!!! note
    Some organizations might inject company specific CA trust bundles into base container images and
    automatically configure runtimes (openjdk, node, etc) to trust that CA bundle.
    In that case, you might not need to configure your clients.

Using the previous example of the my-org-eventing-bundle ConfigMap with data keys being ca.crt,
ca1.crt and tls.crt, you will have a `/knative-custom-certs` directory that will have the following
layout:

```bash
/knative-custom-certs/ca.crt
/knative-custom-certs/ca1.crt
/knative-custom-certs/tls.crt
```

Those files can then be used to add CA trust bundles to HTTP clients sending events to Eventing.

!!!note
    Depending on the runtime, programming language or library that you’re using, there are different
    ways of configuring custom CA certs files using command line flags, environment variables, or by
    reading the content of those files.
    Refer to their documentation for more details.

### Adding `SelfSigned` `ClusterIssuer` to CA trust bundles

In case you are using a SelfSigned ClusterIssuer as described in the [Setup SelfSigned
ClusterIssuer section](#setup-selfsigned-clusterissuer), you can add the CA to the Eventing CA trust
bundles by running the following commands:

1. Export the CA from the knative-eventing-ca secret in the OpenShift Cert-Manager Operator namespace, cert-manager by default:
    ```shell
    $ kubectl get secret -n cert-manager knative-eventing-ca -o=jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
    ```
2. Create a CA trust bundle in the `knative-eventing` namespace:
    ```shell
    $ kubectl create configmap -n knative-eventing my-org-selfsigned-ca-bundle --from-file=ca.crt
    ```
3. Label the ConfigMap with networking.knative.dev/trust-bundle: "true" label:
    ```shell
    $ kubectl label configmap -n knative-eventing my-org-selfsigned-ca-bundle networking.knative.dev/trust-bundle=true
    ```

## Verifying that the feature is working

Save the following YAML into a file called `default-broker-example.yaml`

```yaml
# default-broker-example.yaml

apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: br

---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: tr
spec:
  broker: br
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: event-display
---
apiVersion: v1
kind: Service
metadata:
  name: event-display
spec:
  selector:
    app: event-display
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: event-display
  labels:
    app: event-display
spec:
  containers:
    - name: event-display
      image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
      imagePullPolicy: Always
      ports:
        - containerPort: 8080
```

Apply the `default-broker-example.yaml` file into a test namespace  `transport-encryption-test`:

```shell
kubectl create namespace transport-encryption-test

kubectl apply -n transport-encryption-test -f defautl-broker-example.yaml
```

Verify that addresses are all `HTTPS`:

```shell
kubectl get brokers.eventing.knative.dev -n transport-encryption-test br -oyaml
```

Example output:

```shell
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  # ...
  name: br
  namespace: transport-encryption-test
# ...
status:
  address:
    CACerts: |
      -----BEGIN CERTIFICATE-----
      MIIBbzCCARagAwIBAgIQAur7vdEcreEWSEQatCYlNjAKBggqhkjOPQQDAjAYMRYw
      FAYDVQQDEw1zZWxmc2lnbmVkLWNhMB4XDTIzMDgwMzA4MzA1N1oXDTIzMTEwMTA4
      MzA1N1owGDEWMBQGA1UEAxMNc2VsZnNpZ25lZC1jYTBZMBMGByqGSM49AgEGCCqG
      SM49AwEHA0IABBqkD9lAwrnXCo/OOdpKzJROSbzCeC73FE/Np+/j8n862Ox5xYwJ
      tAp/o3RDpDa3omhzqZoYumqdtneozGFY/zGjQjBAMA4GA1UdDwEB/wQEAwICpDAP
      BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSHoKjXzfxfudt3mVGU3VudSi6TrTAK
      BggqhkjOPQQDAgNHADBEAiA5z0/TpD7T6vRpN9VQisQMtum/Zg3tThnYA5nFnAW7
      KAIgKR/EzW7f8BPcnlcgXt5kp3Fdqye1SAkjxZzr2a0Zik8=
      -----END CERTIFICATE-----
    name: https
    url: https://broker-ingress.knative-eventing.svc.cluster.local/transport-encryption-test/br
  addresses:
  - CACerts: |
      -----BEGIN CERTIFICATE-----
      MIIBbzCCARagAwIBAgIQAur7vdEcreEWSEQatCYlNjAKBggqhkjOPQQDAjAYMRYw
      FAYDVQQDEw1zZWxmc2lnbmVkLWNhMB4XDTIzMDgwMzA4MzA1N1oXDTIzMTEwMTA4
      MzA1N1owGDEWMBQGA1UEAxMNc2VsZnNpZ25lZC1jYTBZMBMGByqGSM49AgEGCCqG
      SM49AwEHA0IABBqkD9lAwrnXCo/OOdpKzJROSbzCeC73FE/Np+/j8n862Ox5xYwJ
      tAp/o3RDpDa3omhzqZoYumqdtneozGFY/zGjQjBAMA4GA1UdDwEB/wQEAwICpDAP
      BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSHoKjXzfxfudt3mVGU3VudSi6TrTAK
      BggqhkjOPQQDAgNHADBEAiA5z0/TpD7T6vRpN9VQisQMtum/Zg3tThnYA5nFnAW7
      KAIgKR/EzW7f8BPcnlcgXt5kp3Fdqye1SAkjxZzr2a0Zik8=
      -----END CERTIFICATE-----
    name: https
    url: https://broker-ingress.knative-eventing.svc.cluster.local/transport-encryption-test/br
  annotations:
    knative.dev/channelAPIVersion: messaging.knative.dev/v1
    knative.dev/channelAddress: https://imc-dispatcher.knative-eventing.svc.cluster.local/transport-encryption-test/br-kne-trigger
    knative.dev/channelCACerts: |
      -----BEGIN CERTIFICATE-----
      MIIBbzCCARagAwIBAgIQAur7vdEcreEWSEQatCYlNjAKBggqhkjOPQQDAjAYMRYw
      FAYDVQQDEw1zZWxmc2lnbmVkLWNhMB4XDTIzMDgwMzA4MzA1N1oXDTIzMTEwMTA4
      MzA1N1owGDEWMBQGA1UEAxMNc2VsZnNpZ25lZC1jYTBZMBMGByqGSM49AgEGCCqG
      SM49AwEHA0IABBqkD9lAwrnXCo/OOdpKzJROSbzCeC73FE/Np+/j8n862Ox5xYwJ
      tAp/o3RDpDa3omhzqZoYumqdtneozGFY/zGjQjBAMA4GA1UdDwEB/wQEAwICpDAP
      BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSHoKjXzfxfudt3mVGU3VudSi6TrTAK
      BggqhkjOPQQDAgNHADBEAiA5z0/TpD7T6vRpN9VQisQMtum/Zg3tThnYA5nFnAW7
      KAIgKR/EzW7f8BPcnlcgXt5kp3Fdqye1SAkjxZzr2a0Zik8=
      -----END CERTIFICATE-----
    knative.dev/channelKind: InMemoryChannel
    knative.dev/channelName: br-kne-trigger
  conditions:
  # ...
```

Sending events to the Broker using HTTPS endpoints:

```shell
kubectl run curl -n transport-encryption-test --image=curlimages/curl -i --tty -- sh

```

Save the CA certs from the Broker's `.status.address.CACerts` field into `/tmp/cacerts.pem`

```shell
cat <<EOF >> /tmp/cacerts.pem
-----BEGIN CERTIFICATE-----
MIIBbzCCARagAwIBAgIQAur7vdEcreEWSEQatCYlNjAKBggqhkjOPQQDAjAYMRYw
FAYDVQQDEw1zZWxmc2lnbmVkLWNhMB4XDTIzMDgwMzA4MzA1N1oXDTIzMTEwMTA4
MzA1N1owGDEWMBQGA1UEAxMNc2VsZnNpZ25lZC1jYTBZMBMGByqGSM49AgEGCCqG
SM49AwEHA0IABBqkD9lAwrnXCo/OOdpKzJROSbzCeC73FE/Np+/j8n862Ox5xYwJ
tAp/o3RDpDa3omhzqZoYumqdtneozGFY/zGjQjBAMA4GA1UdDwEB/wQEAwICpDAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSHoKjXzfxfudt3mVGU3VudSi6TrTAK
BggqhkjOPQQDAgNHADBEAiA5z0/TpD7T6vRpN9VQisQMtum/Zg3tThnYA5nFnAW7
KAIgKR/EzW7f8BPcnlcgXt5kp3Fdqye1SAkjxZzr2a0Zik8=
-----END CERTIFICATE-----
EOF
```

Send the event by running the following command:

```shell
curl -v -X POST -H "content-type: application/json" -H "ce-specversion: 1.0" -H "ce-source: my/curl/command" -H "ce-type: my.demo.event" -H "ce-id: 6cf17c7b-30b1-45a6-80b0-4cf58c92b947" -d '{"name":"Knative Demo"}' --cacert /tmp/cacert
s.pem https://broker-ingress.knative-eventing.svc.cluster.local/transport-encryption-test/br
```

Example output:

```shell
* processing: https://broker-ingress.knative-eventing.svc.cluster.local/transport-encryption-test/br
*   Trying 10.96.174.249:443...
* Connected to broker-ingress.knative-eventing.svc.cluster.local (10.96.174.249) port 443
* ALPN: offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
*  CAfile: /tmp/cacerts.pem
*  CApath: none
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
* ALPN: server accepted h2
* Server certificate:
*  subject: O=local
*  start date: Aug  3 08:31:02 2023 GMT
*  expire date: Nov  1 08:31:02 2023 GMT
*  subjectAltName: host "broker-ingress.knative-eventing.svc.cluster.local" matched cert's "broker-ingress.knative-eventing.svc.cluster.local"
*  issuer: CN=selfsigned-ca
*  SSL certificate verify ok.
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* using HTTP/2
* h2 [:method: POST]
* h2 [:scheme: https]
* h2 [:authority: broker-ingress.knative-eventing.svc.cluster.local]
* h2 [:path: /transport-encryption-test/br]
* h2 [user-agent: curl/8.2.1]
* h2 [accept: */*]
* h2 [content-type: application/json]
* h2 [ce-specversion: 1.0]
* h2 [ce-source: my/curl/command]
* h2 [ce-type: my.demo.event]
* h2 [ce-id: 6cf17c7b-30b1-45a6-80b0-4cf58c92b947]
* h2 [content-length: 23]
* Using Stream ID: 1
> POST /transport-encryption-test/br HTTP/2
> Host: broker-ingress.knative-eventing.svc.cluster.local
> User-Agent: curl/8.2.1
> Accept: */*
> content-type: application/json
> ce-specversion: 1.0
> ce-source: my/curl/command
> ce-type: my.demo.event
> ce-id: 6cf17c7b-30b1-45a6-80b0-4cf58c92b947
> Content-Length: 23
> 
< HTTP/2 202 
< allow: POST, OPTIONS
< content-length: 0
< date: Thu, 03 Aug 2023 10:08:22 GMT
< 
* Connection #0 to host broker-ingress.knative-eventing.svc.cluster.local left intact
```

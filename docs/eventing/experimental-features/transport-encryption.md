# Transport Encryption for Knative Eventing

**Flag name**: `transport-encryption`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5957](https://github.com/knative/eventing/issues/5957)

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

- In order to enable the transport encryption feature, you will need to install cert-manager
  operator by
  following [the cert-manager operator installation instructions](https://cert-manager.io/docs/installation/).
- [Eventing installation](./../../install)

## Installation

Eventing components use cert-manager issuers and certificates to provision TLS certificates and in
the release assets, we release such default issuers and certificates that can be customized as
necessary.

1. Install issuers and certificates, run the following command:
    ```shell
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-tls-networking.yaml")}}
    ```
2. Verify issuers and certificates are ready
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
    ```

## Transport Encryption configuration

The `transport-encryption` feature flag is an enum configuration that configures how Addressables (
Broker, Channel, Sink) should accept events.

The possible values for `transport-encryption` are:

- `disabled` (this is equivalent to the current behavior)
    - Addressables may accept events to HTTPS endpoints
    - Producers may send events to HTTPS endpoints
- `permissive`
    - Addressables should accept events on both HTTP and HTTPS endpoints
    - Addressables should advertise both HTTP and HTTPS endpoints
    - Producers should prefer sending events to HTTPS endpoints, if available
- `strict`
    - Addressables must not accept events to non-HTTPS endpoints
    - Addressables must only advertise HTTPS endpoints

For example, to enable `strict` transport encryption, the `config-features` ConfigMap will look like
the following:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
data:
  transport-encryption: "strict"
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
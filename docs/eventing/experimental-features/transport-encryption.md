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

In order to enable the transport encryption feature, you will need to install cert-manager operator
by
following [the cert-manager operator installation instructions](https://cert-manager.io/docs/installation/).

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

// TODO


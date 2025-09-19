---
audience: administrator
components:
  - eventing
function: how-to
---

# Sender Identity for Knative Eventing

**Flag name**: `authentication-oidc`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#6806](https://github.com/knative/eventing/issues/6806)

## Overview

Currently, event delivery within the cluster is unauthenticated, and an addressable event consumer cannot determine the identity of any sender.

Knative Eventing Addressables expose their OIDC Audience in their status as part of their address (e.g. `.status.address.audience`) and require requests containing an OIDC access token issued for this audience.

Knative Eventing Souces request an OIDC access token for the targets audience and add them to the request. A per-source dedicated Service Account is used as the identity for the request.

## Prerequisites

- [Eventing installation](./../../../install)

!!! note
    To not provide the access token in cleartext over the wire, transport-encryption should be enabled as well. Take a look at [Transport-Encryption](./transport-encryption.md), which explains how to enable the transport encryption feature flag.

## Compatibility

OIDC authentication is currently supported for the following components:

- Brokers:
    - [MTChannelBasedBroker](./../../brokers/broker-types/channel-based-broker/)
    - [Knative Broker for Apache Kafka](./../../brokers/broker-types/kafka-broker/)
- Channels:
    - [InMemoryChannel](./../../channels/channels-crds/)
    - [KafkaChannel](./../../channels/channels-crds/)
- Sources:
    - [ApiServerSource](./../../sources/apiserversource/)
    - [PingSource](./../../sources/ping-source/)
    - [KafkaSource](./../../sources/kafka-source/)

## Sender Identity Configuration

The possible values for `authentication-oidc` are:

- `disabled`
    - No change in behaviour
- `enabled`
    - Addressables announce their audience in their status
    - Sources add an Authorization Header to their request containing an access token for their target

For example, to enable sender identity, the `config-features` ConfigMap will look like
the following:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
data:
  authentication-oidc: "enabled"
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

Apply the `default-broker-example.yaml` file into a test namespace `authentication-oidc-test`:

```shell
kubectl create namespace authentication-oidc-test

kubectl apply -n authentication-oidc-test -f default-broker-example.yaml
```

Verify that the Broker announces its audience:
```shell
kubectl -n authentication-oidc-test get broker br -o yaml
```

Example output:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: br
  namespace: authentication-oidc-test
spec:
  config:
    # ...
  delivery:
    # ...
status:
  address:
    audience: eventing.knative.dev/broker/authentication-oidc-test/br
    name: http
    url: http://broker-ingress.knative-eventing.svc.cluster.local/authentication-oidc-test/br
  annotations:
  # ...
```

Send events to the Broker using OIDC authentication:

1. Create an OIDC token (access token):
    ```shell
    kubectl -n authentication-oidc-test create serviceaccount oidc-test-user; kubectl -n authentication-oidc-test create token oidc-test-user --audience eventing.knative.dev/broker/authentication-oidc-test/br
    ```

    Example output:
    ```shell
    serviceaccount/oidc-test-user created
    eyJhbGciOiJSUzI1NiIsImtpZCI6IlZBWmppNEVJZkVSVDZoYTA4dU1xTWJxSHFYQTgtbE00VU1tMmpFZUNuakUifQ.eyJhdWQiOlsiZXZlbnRpbmcua25hdGl2ZS5kZXYvYnJva2VyL2F1dGhlbnRpY2F0aW9uLW9pZGMtdGVzdC9iciJdLCJleHAiOjE3MDU5MzQyMTQsImlhdCI6MTcwNTkzMDYxNCwiaXNzIjoiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJhdXRoZW50aWNhdGlvbi1vaWRjLXRlc3QiLCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoib2lkYy10ZXN0LXVzZXIiLCJ1aWQiOiJkNGM5MjkzMy1kZThlLTRhNDYtYjkxYS04NjRjNTZkZDU4YzIifX0sIm5iZiI6MTcwNTkzMDYxNCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmF1dGhlbnRpY2F0aW9uLW9pZGMtdGVzdDpvaWRjLXRlc3QtdXNlciJ9.Taqk11LRC7FKMbt_1VvmRjMolJL54CFGbRT85ZgNdG8YT6MXiw_S2rMHxLyC9RyX0hb720szHhiVIPj15jbz597egSBbcuk-f_MCsUFMyK1Nb95blo6UNDFKIQxC5_aleoT-qaGtXlt4OEE6RjA28mFeeSCjcJUCRdLGLuSiQT47lxLqNK5OfKjd4wGMiUsbBzOcXor9ouJc1lr4gFlCzzIMJNLfXU0O_AB8J--yh6wP07Q-2AWwwv7J1CtZCrIqaPBFjWnplLqtBgo33ZNbqomXyYVdO_0HlEN9XtlK_y_2veEvKOkINzpic_ipf5ZhTxEpXWaztZzdkWd-e2mHMg
    ```

2. Send a curl request to the Broker
    ```shell
    kubectl -n authentication-oidc-test run curl --image=curlimages/curl -i --tty -- sh

    # Send unauthenticated request (should result in a 401)
    curl -v http://broker-ingress.knative-eventing.svc.cluster.local/authentication-oidc-test/br -H "Content-Type:application/json" -H "Ce-Id:1" -H "Ce-Source:cloud-event-example" -H "Ce-Type:myCloudEventGreeting" -H "Ce-Specversion:1.0" -d "{\"name\": \"unauthenticated\"}"

    # Send authenticated request (should request in 202)
    curl -v http://broker-ingress.knative-eventing.svc.cluster.local/authentication-oidc-test/br -H "Content-Type:application/json" -H "Ce-Id:1" -H "Ce-Source:cloud-event-example" -H "Ce-Type:myCloudEventGreeting" -H "Ce-Specversion:1.0" -H "Authorization: Bearer <YOUR-TOKEN-FROM-STEP-1>" -d "{\"name\": \"authenticated\"}"
    ```

    Example output: 
    ```shell
    $ curl -v http://broker-ingress.knative-eventing.svc.cluster.local/authentication-oidc-test/br -H "Content-Type:application/json" -H "Ce-Id:1" -H "Ce-Source:cloud-event-example" -H "Ce-Type:myCloudEventGreeting" -H "Ce-Specversion:1.0" -d "{\"name\": \"unauthenticated\"}"

    * Host broker-ingress.knative-eventing.svc.cluster.local:80 was resolved.
    * IPv6: (none)
    * IPv4: 10.96.110.167
    *   Trying 10.96.110.167:80...
    * Connected to broker-ingress.knative-eventing.svc.cluster.local (10.96.110.167) port 80
    > POST /authentication-oidc-test/br HTTP/1.1
    > Host: broker-ingress.knative-eventing.svc.cluster.local
    > User-Agent: curl/8.5.0
    > Accept: */*
    > Content-Type:application/json
    > Ce-Id:1
    > Ce-Source:cloud-event-example
    > Ce-Type:myCloudEventGreeting
    > Ce-Specversion:1.0
    > Content-Length: 27
    > 
    < HTTP/1.1 401 Unauthorized
    < Allow: POST, OPTIONS
    < Date: Mon, 22 Jan 2024 13:33:57 GMT
    < Content-Length: 0
    < 
    * Connection #0 to host broker-ingress.knative-eventing.svc.cluster.local left intact

    ~ $ curl -v http://broker-ingress.knative-eventing.svc.cluster.local/authentication-oidc-test/br -H "Content-Type:application/json" -H "Ce-Id:1" -H "Ce-Source:cloud-event-example" -H "Ce-Type:myCloudEventGreeting" -H "Ce-Specversion:1.0" -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IlZBWmppNEVJZkVSV
    DZoYTA4dU1xTWJxSHFYQTgtbE00VU1tMmpFZUNuakUifQ.eyJhdWQiOlsiZXZlbnRpbmcua25hdGl2ZS5kZXYvYnJva2VyL2F1dGhlbnRpY2F0aW9uLW9pZGMtdGVzdC9iciJdLCJleHAiOjE3MDU5MzQwMDgsImlhdCI6MTcwNTkzMDQwOCwiaXNzIjoiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJhdXRoZW50aWNhdGlvbi1vaWRjLXRlc3QiLCJ
    zZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoib2lkYy10ZXN0LXVzZXIiLCJ1aWQiOiI3MTlkMWI3ZC1hZjBkLTQzMDAtOGUxNy1lNTk4YmZmN2VmYTIifX0sIm5iZiI6MTcwNTkzMDQwOCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmF1dGhlbnRpY2F0aW9uLW9pZGMtdGVzdDpvaWRjLXRlc3QtdXNlciJ9.UrleSi54mxgThesyrC4kzG7rO3-Fic1B3kPOY8k1l-oslhvw3dbT0n24bvP96m7Ke4ZGoXE3Efo
    966LZM_61-bfntFbw8kTRe_w6wGXVGpadrBSZsIChVgFYqsPNX_7r1LSNTy5tFXze9phVz6EpO7XeUct_PXyYLASNw0LNXWyqbcEqBNtgWmDKHaS_1pIscFP6MaoGVj968hpVqli8O6okQUQitIoPwFEGAIbaBlIX6Z5ZqlGwL9eqbIiNEMEgjlduv9dyZVmpDc0hsF6GHk2RnAhLeOniUNdUo4VO3z27TJY5JYK7xIMBD6Z5dUAhud9ofA8VWEl7Mziw4fsdCw" -d "{\"name\": \"authenticated\"}"
    * Host broker-ingress.knative-eventing.svc.cluster.local:80 was resolved.
    * IPv6: (none)
    * IPv4: 10.96.110.167
    *   Trying 10.96.110.167:80...
    * Connected to broker-ingress.knative-eventing.svc.cluster.local (10.96.110.167) port 80
    > POST /authentication-oidc-test/br HTTP/1.1
    > Host: broker-ingress.knative-eventing.svc.cluster.local
    > User-Agent: curl/8.5.0
    > Accept: */*
    > Content-Type:application/json
    > Ce-Id:1
    > Ce-Source:cloud-event-example
    > Ce-Type:myCloudEventGreeting
    > Ce-Specversion:1.0
    > Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IlZBWmppNEVJZkVSVDZoYTA4dU1xTWJxSHFYQTgtbE00VU1tMmpFZUNuakUifQ.eyJhdWQiOlsiZXZlbnRpbmcua25hdGl2ZS5kZXYvYnJva2VyL2F1dGhlbnRpY2F0aW9uLW9pZGMtdGVzdC9iciJdLCJleHAiOjE3MDU5MzQwMDgsImlhdCI6MTcwNTkzMDQwOCwiaXNzIjoiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJhdXRoZW50aWNhdGlvbi1vaWRjLXRlc3QiLCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoib2lkYy10ZXN0LXVzZXIiLCJ1aWQiOiI3MTlkMWI3ZC1hZjBkLTQzMDAtOGUxNy1lNTk4YmZmN2VmYTIifX0sIm5iZiI6MTcwNTkzMDQwOCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmF1dGhlbnRpY2F0aW9uLW9pZGMtdGVzdDpvaWRjLXRlc3QtdXNlciJ9.UrleSi54mxgThesyrC4kzG7rO3-Fic1B3kPOY8k1l-oslhvw3dbT0n24bvP96m7Ke4ZGoXE3Efo966LZM_61-bfntFbw8kTRe_w6wGXVGpadrBSZsIChVgFYqsPNX_7r1LSNTy5tFXze9phVz6EpO7XeUct_PXyYLASNw0LNXWyqbcEqBNtgWmDKHaS_1pIscFP6MaoGVj968hpVqli8O6okQUQitIoPwFEGAIbaBlIX6Z5ZqlGwL9eqbIiNEMEgjlduv9dyZVmpDc0hsF6GHk2RnAhLeOniUNdUo4VO3z27TJY5JYK7xIMBD6Z5dUAhud9ofA8VWEl7Mziw4fsdCw
    > Content-Length: 25
    > 
    < HTTP/1.1 202 Accepted
    < Allow: POST, OPTIONS
    < Date: Mon, 22 Jan 2024 13:34:27 GMT
    < Content-Length: 0
    < 
    * Connection #0 to host broker-ingress.knative-eventing.svc.cluster.local left intact
    ~ $
    ```
3. Verify the 2nd event reached the event-display pod
    ```shell
    kubectl -n authentication-oidc-test logs event-display
    ```

    Example output:
    ```shell
    ☁️  cloudevents.Event
    Context Attributes,
      specversion: 1.0
      type: myCloudEventGreeting
      source: cloud-event-example
      id: 1
      datacontenttype: application/json
    Extensions,
      knativearrivaltime: 2024-01-22T13:34:26.032199371Z
    Data,
      {
        "name": "authenticated"
      }
    ```

## Limitations with Istio

You might experience issues with the [eventing integration with Istio](https://github.com/knative-extensions/eventing-istio) and having the `authentication-oidc` feature flag enabeled, when the JWKS URI is represented via an IP. E.g. like in the following case:

```
$ kubectl get --raw /.well-known/openid-configuration | jq
{
  "issuer": "https://kubernetes.default.svc",
  "jwks_uri": "https://172.18.0.3:6443/openid/v1/jwks",
  ...
}
```

In this case you need to add the [`traffic.sidecar.istio.io/excludeOutboundIPRanges: <JWKS IP>/32`](https://istio.io/latest/docs/reference/config/annotations/#SidecarTrafficExcludeOutboundIPRanges) annotation to the pod templates of the following deployments:

- `imc-dispatcher`
- `mt-broker-ingress`
- `mt-broker-filter`

For example:

```
$ kubectl -n knative-eventing patch deploy imc-dispatcher --patch '{"spec":{"template":{"metadata":{"annotations":{"traffic.sidecar.istio.io/excludeOutboundIPRanges":"172.18.0.3/32"}}}}}'
deployment.apps/imc-dispatcher patched
```

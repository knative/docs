---
audience: administrator
components:
  - serving
  - eventing
function: how-to
---

# Troubleshooting a Knative Installation

This page describes how you can troubleshoot a Knative installation. Please try these instructions before filing a bug report.

## Check if all containers are running, ready and healthy

!!! note
    The outputs below are just examples. The containers may vary depending on the installation and configuration. Please make sure all containers are running, ready and healthy (look for the `1/1` in the following examples) or are `Complete` (in case of jobs).

**Knative Serving Components**

```bash
kubectl get pods -n knative-serving

NAME                                      READY   STATUS    RESTARTS   AGE
activator-6b9dc4c9db-cl56b                1/1     Running   0          2m
autoscaler-77f9b75856-f88qw               1/1     Running   0          2m
controller-7dcb56fdb6-dbzrp               1/1     Running   0          2m
webhook-78dc6ddddb-6868n                  1/1     Running   0          2m
```

**Knative Serving Networking Layer**

=== "Kourier"
    ```bash
    kubectl get pods -n knative-serving

    NAME                                      READY   STATUS    RESTARTS   AGE
    net-kourier-controller-5fcbb6d996-fprpd   1/1     Running   0          103s
    ```

    ```bash
    kubectl get pods -n kourier-system
    NAME                                      READY   STATUS    RESTARTS   AGE
    3scale-kourier-gateway-86b9f6dc44-xpn6h   1/1     Running   0          2m22s
    ```

=== "Istio"
    ```bash
    kubectl get pods -n knative-serving

    NAME                                    READY   STATUS    RESTARTS   AGE
    net-istio-controller-ccc455b58-f98ld    1/1     Running   0          19s
    net-istio-webhook-7558dbfc64-5jmt6      1/1     Running   0          19s
    ```
    ```bash
    kubectl get pods -n istio-system

    NAME                                   READY   STATUS    RESTARTS   AGE
    istio-ingressgateway-c7b9f6477-bgr6q   1/1     Running   0          44s
    istiod-79d65bf5f4-5zvtj                1/1     Running   0          29s
    ```

=== "Contour"
    ```bash
    kubectl get pods -n knative-serving

    NAME                                      READY   STATUS        RESTARTS   AGE
    net-contour-controller-68547b797c-dl8pf   1/1     Running       0          14s
    ```
    ```bash
    kubectl get pods -n contour-external

    NAME                            READY   STATUS      RESTARTS   AGE
    contour-7b995cdb68-jg5s8        1/1     Running     0          41s
    contour-certgen-v1.24.2-zmr9r   0/1     Completed   0          41s
    envoy-xkzck                     2/2     Running     0          41s
    ```
    ```bash
    kubectl get pods -n contour-internal

    NAME                            READY   STATUS      RESTARTS   AGE
    contour-57fcf576fd-wb57c        1/1     Running     0          55s
    contour-certgen-v1.24.2-gqgrx   0/1     Completed   0          55s
    envoy-rht69                     2/2     Running     0          55s
    ```

**Knative Eventing**

```bash
kubectl get pods -n knative-eventing

NAME                                  READY   STATUS    RESTARTS   AGE
eventing-controller-bb8b689c4-lk6pq   1/1     Running   0          41s
eventing-webhook-577bb88ccd-hcz5p     1/1     Running   0          41s
```

## Check if there are any errors logged in the Knative components

```bash
kubectl logs -n knative-serving <pod-name>
kubectl logs -n knative-eventing <pod-name>
kubectl logs -n <ingress-namespaces> <pod-namespaces> # see above for the relevant namespaces

# For example
kubectl logs -n knative-serving activator-6b9dc4c9db-cl56b
2023/05/01 11:52:51 Registering 3 clients
2023/05/01 11:52:51 Registering 3 informer factories
2023/05/01 11:52:51 Registering 4 informers
```

## Check the status of the Knative Resources

**Knative Serving**
```bash
kubectl describe -n <namespace> kservice
kubectl describe -n <namespace> config
kubectl describe -n <namespace> revision
kubectl describe -n <namespace> sks # Serverless Service
kubectl describe -n <namespace> kingress # Knative Ingress
kubectl describe -n <namespace> rt # Knative Route
kubectl describe -n <namespace> dm # Domain-Mapping

# Check the status at the end. For example
kubectl describe -n default kservice

... omitted ...
Status:
  Address:
    URL:  http://hello.default.svc.cluster.local
  Conditions:
    Last Transition Time:        2023-05-01T12:08:18Z
    Status:                      True
    Type:                        ConfigurationsReady
    Last Transition Time:        2023-05-01T12:08:18Z
    Status:                      True
    Type:                        Ready
    Last Transition Time:        2023-05-01T12:08:18Z
    Status:                      True
    Type:                        RoutesReady
  Latest Created Revision Name:  hello-00001
  Latest Ready Revision Name:    hello-00001
  Observed Generation:           1
  Traffic:
    Latest Revision:  true
    Percent:          100
    Revision Name:    hello-00001
  URL:                http://hello.default.10.89.0.200.sslip.io
Events:
  Type    Reason   Age   From                Message
  ----    ------   ----  ----                -------
  Normal  Created  45s   service-controller  Created Configuration "hello"
  Normal  Created  45s   service-controller  Created Route "hello"
```

**Knative Eventing**

```bash
kubectl describe -n <namespace> brokers
kubectl describe -n <namespace> eventtypes
kubectl describe -n <namespace> triggers
kubectl describe -n <namespace> channels
kubectl describe -n <namespace> subscriptions
kubectl describe -n <namespace> apiserversources
kubectl describe -n <namespace> containersources
kubectl describe -n <namespace> pingsources
kubectl describe -n <namespace> sinkbindings


# Check the status at the end. For example
kubectl describe -n default brokers

... omitted ...
Status:
  Annotations:
    bootstrap.servers:                 my-cluster-kafka-bootstrap.kafka:9092
    default.topic.partitions:          10
    default.topic.replication.factor:  3
```

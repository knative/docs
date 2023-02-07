# Knative Apache Kafka Broker with Isolated Data Plane

**Author: Ali Ok, Principal Software Engineer @ Red Hat**

**Date: 2023-02-03**

_In this blog post, you will learn how to configure Knative's Apache Kafka Broker in isolated data plane mode._

The [Knative Broker implementation for Apache Kafka](https://knative.dev/docs/eventing/brokers/broker-types/kafka-broker/) is a Kafka-native implementation of the [Knative Broker APIs](https://knative.dev/docs/eventing/brokers/), offering improvements over the usage of the Channel-based Knative Broker implementation, such as reduced network hops, support of any Kafka version and a better integration with Apache Kafka for the Broker and Trigger model.

Furthermore, this broker class supports 2 data plane modes: shared and isolated.

## What is a data plane?

To give a better overview, it is important to understand what a _data plane_ is.

Knative's Apache Kafka Broker has 2 planes, similar to many other Knative and Kubernetes components.

The control plane is the collection of components that are controllers. These controllers manage the data plane, based on the custom objects created by the users. The custom objects managed by the control plane in this case are [`Broker`](https://knative.dev/docs/eventing/reference/eventing-api/#eventing.knative.dev/v1.Broker) and [`Trigger`](https://knative.dev/docs/eventing/reference/eventing-api/#eventing.knative.dev/v1.Trigger).

The data plane is the collection of components that talk to Apache Kafka and to the subscribers (targets of triggers), based on the configuration given by the control plane. There are 2 components in Knative Kafka Broker data plane:

- Ingress is the component that listens for the events by opening an HTTP endpoint. It then forwards events to an Apache Kafka topic for persistence and for synchronization of the pace of consuming and producing events.
- Dispatcher is the component that receives events from the Apache Kafka topic and dispatches them to the subscribers that are subscribed using the `Trigger` API.

## Shared data plane

When using a broker class of `Kafka`, control plane doesn't create a new data plane. Instead, it configures the existing data plane to fulfill the ingress and dispatch duties of the created broker.

Knative Kafka Broker in shared data plane mode is demonstrated in [this](https://knative.dev/blog/articles/single-node-kafka-development/) blog post.

If you follow that article, you will see the data plane of the Kafka Broker is created in the `knative-eventing` namespace:

```yaml
kubectl get pods -n knative-eventing
NAME                                       READY   STATUS    RESTARTS   AGE
eventing-controller-7b95f495bf-dkqtl       1/1     Running   0          2h4m
eventing-webhook-8db49d6cc-4f847           1/1     Running   0          2h4m
kafka-broker-dispatcher-859d684d7d-frw6p   1/1     Running   0          2h4m  **<-- Dispatcher**
kafka-broker-receiver-67b7ff757-rk9b6      1/1     Running   0          2h4m  **<-- Ingress**
kafka-controller-7cd9bd8649-d62dh          1/1     Running   0          2h4m
kafka-webhook-eventing-f8c975b99-vc969     1/1     Running   0          2h4m
```

Specifically, Knative Kafka Broker data plane consists of `kafka-broker-dispatcher` and `kafka-broker-receiver` pods, and they are shared among all broker custom objects. When another `Broker` is created, control plane will not create any new deployments.

If you `kubectl get` the `Broker` objects, you will see their _addresses_ are using the Kubernetes `Service` named `kafka-broker-ingress` in the `knative-eventing` namespace. Addresses of both brokers are with hostname `kafka-broker-ingress.knative-eventing.svc.cluster.local`.

```bash
kubectl get brokers.eventing.knative.dev -A

NAMESPACE  NAME                    URL                                                                                           AGE     READY   REASON
default    my-demo-kafka-broker    http://kafka-broker-ingress.knative-eventing.svc.cluster.local/default/my-demo-kafka-broker   2h6m    True
other      other-kafka-broker      http://kafka-broker-ingress.knative-eventing.svc.cluster.local/other/other-kafka-broker       2h6m    True
```

Since the same ingress service and the same ingress deployment is used, the URL path is used to identify the target broker for any events posted to the service. For `my-demo-kafka-broker` broker in `default` namespace, `/default/my-demo-kafka-broker` is used. For `other-kafka-broker` broker in `other` namespace, `/other/other-kafka-broker` is used.

## Isolated data plane

After creating a development environment Apache Kafka and Knative Kafka Broker as explained in [this](https://knative.dev/blog/articles/single-node-kafka-development/) blog post, you are already good to go and try Knative Kafka Broker in isolated data plane mode as this mode is supported out of the box.

To start with, you need to create a configmap that contains the configuration for the broker. In this case, we cannot rely on the cluster-wide configmap in the `knative-eventing` namespace, that was created in the previous blog post.

Similar to the global `kafka-broker-config` configmap created in that tutorial, we will create a configmap but in user namespace `default`. In isolated data plane mode, we need to have the configuration for the broker in the same namespace as the broker.

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-broker-config
  namespace: default
data:
  default.topic.partitions: "10"
  default.topic.replication.factor: "1"
  bootstrap.servers: "my-cluster-kafka-bootstrap.kafka:9092"
EOF
```

Now we create the broker, that uses the class `KafkaNamespaced` and also uses the configuration we just created above:

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: KafkaNamespaced
  name: broker-isolated-data-plane
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: kafka-broker-config
    namespace: default
EOF
```

When we check the user namespace where the `Broker` object is created in, we will see the data plane pods created:

```bash
kubectl get pods -n default

NAME                                       READY   STATUS    RESTARTS   AGE
kafka-broker-dispatcher-8497dd6fb6-h8kdg   1/1     Running   0          15s
kafka-broker-receiver-84ff47fcd9-cv8j8     1/1     Running   0          15s
```

Similar to the data plane deployments, we will also see different services used for the `Broker` objects. Thus, the addresses of the brokers will be using a different service than the `kafka-broker-ingress` service in the `knative-eventing` namespace.

```bash
kubectl get brokers.eventing.knative.dev broker-isolated-data-plane -n default

NAME                         URL                                                                                        AGE   READY   REASON
broker-isolated-data-plane   http://kafka-broker-ingress.default.svc.cluster.local/default/broker-isolated-data-plane   37s   True
```

In isolated data plane mode, a new data plane is created per namespace and not per `Broker` object. If we create another `Broker` object in the same namespace, it will use the same data plane:

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: KafkaNamespaced
  name: other-broker-isolated-data-plane
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: kafka-broker-config
    namespace: default
EOF
```

No new data plane pods are created:

```bash
kubectl get pods -n default

NAME                                       READY   STATUS    RESTARTS   AGE
kafka-broker-dispatcher-8497dd6fb6-h8kdg   1/1     Running   0          72s
kafka-broker-receiver-84ff47fcd9-cv8j8     1/1     Running   0          72s
```

Finally, when **all** of the `Broker` objects with class `KafkaNamespaced` in the namespace are deleted, the data plane will be removed:

```bash
kubectl delete brokers.eventing.knative.dev -n default --all

kubectl get pods -n default

No resources found in default namespace.
```

## Use cases

While the shared data plane approach is good for most of the cases, there might be some cases where you would like to have the data plane not shared.

One use case is when you would not like the dispatcher living in the `knative-eventing` namespace to talk to the subscribers in other namespaces or, similarly, if you would not like a single ingress deployment to talk to multiple Apache Kafka systems. Obviously, isolated data plane mode creates dispatchers and receivers in the user namespaces and thus, the communication is restricted to the namespace.

Another case is when you see the potential of a [noisy neighbors problem](https://en.wikipedia.org/wiki/Cloud_computing_issues#Performance_interference_and_noisy_neighbors). There might be broker instances which receive tremendous amount of load and this might reduce the performance of other brokers. As the data plane is created per namespace, you can create multiple namespaces and deploy brokers in each namespace. This way, you can isolate the load of each broker instance.

Finally, one other use case is when you would like to restrict traffic in a self-service manner using Istio. As documented in [Protect a Knative Broker by using JSON Web Token (JWT) and Istio](https://knative.dev/docs/eventing/brokers/broker-admin-config-options/#protect-a-knative-broker-by-using-json-web-token-jwt-and-istio), you can use Istio to restrict traffic based on the URL paths of the broker addresses. However, for the shared data plane approach, the Istio injection label `istio-injection=enabled` needs to be added to the `knative-eventing` namespace. Similarly, the `AuthorizationPolicy` object needs to be created in the `knative-eventing` namespace as the Broker service is created there. Users might not have access to modify the `knative-eventing` namespace. In isolated data plane mode though, users can do the necessary labeling and object creation in their own namespaces in a self service manner.

## Conclusion

In this blog post, we have seen how to use the new `KafkaNamespaced` broker class that makes Knative's Apache Kafka Broker create isolated data planes per namespace. We have seen some use cases where the isolated data plane mode might be useful.

It is also important to understand that although the isolated data plane approach is useful in some cases, it is more resource intensive. Thus, it is recommended to use the shared data plane approach unless you have a good reason to use the isolated data plane approach.

More information about the `KafkaNamespaced` broker class, its limitations and its configuration options can be found in the [documentation](https://knative.dev/docs/eventing/brokers/broker-types/kafka-broker/#data-plane-isolation-vs-shared-data-plane).

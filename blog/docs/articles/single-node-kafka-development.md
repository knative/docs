# Using Apache Kafka for Local Knative Development

**Author: Matthias Weßendorf, Principal Software Engineer @ Red Hat**

**Date: 2023-01-12**

_In this blog post you will learn how to use a production-like environment for your local development with Knative Broker and Apache Kafka._

The [Knative Broker implementation for Apache Kafka](https://knative.dev/docs/eventing/brokers/broker-types/kafka-broker/) is a Kafka-native implementation of the [Knative Broker APIs](https://knative.dev/docs/eventing/brokers/), offering improvements over the usage of the Channel-based Knative Broker implementation, such as reduced network hops, support of any Kafka version and a better integration with Apache Kafka for the Broker and Trigger model.

### Picking the local development environment

At the beginning of every project one important aspect is always to keep the development process as simple and also realistic as possible.

When going with the _Knative Broker APIs_ one first thought for the development environment could be the usage of the `MTChannelBasedBroker` reference broker (backed by the `InMemoryChannel`) as the main tools for development, because there are no extra systems needed for it to function.

However, while the APIs for the Knative Broker are generic and of course the same for any broker implementation, there are still some behavioural differences with the different broker implementations. For sure a system like Apache Kafka is way different compared to an "In Memory" storage.


### From start to end with Apache Kafka

When targeting Apache Kafka you should also use it directly for the development environment, while there is some little overhead with Apache Kafka to operate it, there is good news that with [Strimzi operator](https://strimzi.io/) and Apache Kafka in version 3+ it is very easy to use just a single node Kafka cluster for the development, yet being close to a realistic environment.

#### No Apache Zookeeper is needed!

This all is possible due to the `KRaft` feature of Kafka. It has been developed over the past years and was recently announced a [production feature](https://www.infoq.com/news/2022/10/apache-kafka-kraft/) of [Apache Kafka 3.3.1](https://archive.apache.org/dist/kafka/3.3.0/RELEASE_NOTES.html).

The Strimzi operator is offering a [FeatureGate](https://strimzi.io/docs/operators/in-development/configuring.html#ref-operator-use-kraft-feature-gate-str) to make use of it, since its version 0.29. `KRaft` itself is an implementation of the [Raft Consensus Algorithm](https://raft.github.io/) residing directly in [Apache Kafka](https://kafka.apache.org/documentation/#kraft), removing the need for a 3rd-party tool like Zookeeper.


### Setting up Apache Kafka with Strimzi on Kubernetes

In order to create an Apache Kafka cluster on your development environment, such as [kind](https://kind.sigs.k8s.io/) or [minikube](https://minikube.sigs.k8s.io/), you need to install the Strimzi operator first:

```bash
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
```

Once that happened you need to `patch` the `Deployment` of the Operator to enable the required FeatureGates:

```bash
kubectl -n kafka set env deployment/strimzi-cluster-operator STRIMZI_FEATURE_GATES=+UseStrimziPodSets,+UseKRaft
```

Once the pod for the operator is up and running you can define a single node Apache Kafka cluster with a YAML snippet like below:

```bash
cat <<-EOF | kubectl -n kafka apply -f -
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 3.3.1
    replicas: 1
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
      default.replication.factor: 1
      min.insync.replicas: 1
      inter.broker.protocol.version: "3.3"
    storage:
      type: jbod
      volumes:
      - id: 0
        type: persistent-claim
        size: 100Gi
        deleteClaim: false
# With KRaft not relevant:
  zookeeper:
    replicas: 1
    storage:
      type: persistent-claim
      size: 100Gi
      deleteClaim: false
EOF
```

> NOTE: The `Kafkas.kafka.strimzi.io` CR currently does require you describe the `zookeeper` field, but it is ignored when the `UseKRaft` FeatureGate is enabled. To learn more about the `UseKRaft`, you can watch [this presentation](https://www.youtube.com/watch?v=mT7dbLNCGtQ).

The above configures a single-node Apache Kafka, which does not require a Zookeeper instance at all:

```bash
kubectl get pods -n kafka
NAME                                        READY   STATUS    RESTARTS        AGE
my-cluster-kafka-0                          1/1     Running   0               2h1m
strimzi-cluster-operator-6d94c67fd8-wfmvl   1/1     Running   1 (1h46m ago)   2h1m
```

### Installing Knative Eventing and the Knative Broker for Apache Kafka

With Apache Kafka up and running on our development instance, we install Knative Eventing and the Knative Broker implementation for Apache Kafka.

#### Eventing Core

When using the Knative Kafka broker, we only need a bare minimum setup of Knative Eventing, its `eventing-core` manifest, since it provides all the APIs, as well the `controller` and `webhook` pods:

```bash
kubectl apply --filename https://github.com/knative/eventing/releases/download/knative-v1.8.4/eventing-core.yaml
```

Once finished there will be exactly two pods running for Knative Eventing:

```bash
kubectl get pods -n knative-eventing
NAME                                       READY   STATUS    RESTARTS   AGE
eventing-controller-7b95f495bf-dkqtl       1/1     Running   0          2h1m
eventing-webhook-8db49d6cc-4f847           1/1     Running   0          2h1m
```

#### The Knative Kafka Broker installation

As the next step we need to install the control- and data-plane for the Knative Kafka broker:

```bash
kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.4/eventing-kafka-controller.yaml
kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.4/eventing-kafka-broker.yaml
```

Afterwards we have four new pods in our `knative-eventing` namespace, for our Knative Kafka Broker:

```bash
kubectl get pods -n knative-eventing
NAME                                       READY   STATUS    RESTARTS   AGE
eventing-controller-7b95f495bf-dkqtl       1/1     Running   0          2h4m
eventing-webhook-8db49d6cc-4f847           1/1     Running   0          2h4m
kafka-broker-dispatcher-859d684d7d-frw6p   1/1     Running   0          2h4m
kafka-broker-receiver-67b7ff757-rk9b6      1/1     Running   0          2h4m
kafka-controller-7cd9bd8649-d62dh          1/1     Running   0          2h4m
kafka-webhook-eventing-f8c975b99-vc969     1/1     Running   0          2h4m
```

#### Setting the Kafka broker class as default

To make the usage of the Knative Kafka broker straightforward, we are configuring it as our default broker. First we specify a global configuration, pointing to our single-node Apache Kafka cluster:

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-broker-config
  namespace: knative-eventing
data:
  default.topic.partitions: "10"
  default.topic.replication.factor: "1"
  bootstrap.servers: "my-cluster-kafka-bootstrap.kafka:9092"
EOF
```

It is important to note, that the replication factor is tied to the number of Kafka pods on the system. We are using `1`, since we operate a single-node cluster for Apache Kafka.

Finally we update  Knative Eventing's `config-br-defaults` ConfigMap to reflect that the Knative Kafka broker should be the default broker for the system:

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: Kafka
      apiVersion: v1
      kind: ConfigMap
      name: kafka-broker-config
      namespace: knative-eventing
EOF
```

Besides setting the `brokerClass` to `Kafka` we also reference our `kafka-broker-config` configuration from above, so that all new broker objects rely on this setup. At this point we are done with the installation and configuration related tasks, and we can simply create a new Knative Broker object, leveraging our Knative Kafka Broker implementation:

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: my-demo-kafka-broker
spec: {}
EOF
```

A minimum resource was created on the cluster, representing a Knative Kafka broker object:

```bash
kubectl get brokers.eventing.knative.dev

NAME                   URL                                                                                           AGE     READY   REASON
my-demo-kafka-broker   http://kafka-broker-ingress.knative-eventing.svc.cluster.local/default/my-demo-kafka-broker   2h6m   True
```


### Conclusion

With the help of the `KRaft` feature on Apache Kafka and the Strimzi operator we can easily operate a single-node Apache Kafka cluster on Kubernetes, allowing our local development process to start early with a real persistence system instead of an in-memory storage. KRaft does reduce the footprint for Apache Kafka and allows user a smooth develop against a real, but yet small, Apache Kafka cluster.

Installation script for the described setup can be found [here](https://github.com/matzew/knative-broker-box).

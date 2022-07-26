# Announcing Eventing RabbitMQ moving to GA

**Author: Gab Satchi, Senior Software Engineer @ VMware**

**Date: 2022-07-26**

We’re excited to announce that [Eventing RabbitMQ](https://github.com/knative-sandbox/eventing-rabbitmq) is now GA (General Availability). With this milestone, the APIs provided will remain stable in future iterations.
A quick start can be found [here](https://knative.dev/docs/eventing/broker/rabbitmq-broker/).

# Key Features

### Use any RabbitMQ instance

Eventing RabbitMQ works well with RabbitMQ clusters provisioned using the [cluster operator](https://github.com/rabbitmq/cluster-operator) but can also be configured to use RabbitMQ instances provisioned by other means.
Both broker and source have a `rabbitmqClusterReference` which can either reference a `RabbitMQCluster` created using the cluster operator or a `Secret` containing the credentials to a RabbitMQ instance.
A full guide can be found [here](https://github.com/knative-sandbox/eventing-rabbitmq/tree/49787466f88b21fe022216a13c8321b334f92dc4/samples/external-cluster).

### FIFO vs Throughput

Eventing RabbitMQ, by default, operates in a first-in-first-out (FIFO) mode for events. However, there can be use cases where ordering isn't required and higher throughput may be preferred.
Bother broker and source have a `parallelism` annotation (default 1) that can be configured to process more than 1 message in parallel. An example outlining both FIFO and high throughput modes can be found [here](https://github.com/knative-sandbox/eventing-rabbitmq/tree/49787466f88b21fe022216a13c8321b334f92dc4/samples/trigger-customizations).

### Queue Type

Quorum queues are a fault tolerant replicated queue type to be used in multi-node setups. The performance between quorum queues and classic queues are very close and Eventing RabbitMQ has opted to using quorum queues by default.
The queue type remains configurable at the broker level and any triggers subscribed to a broker will inherit the queue type. Queue type can be configured using the `RabbitMQBrokerConfig` object:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: RabbitmqBrokerConfig
...
spec:
  queueType: "classic" #'classic | quorum'
...
```

### Metrics

Eventing RabbitMQ mirrors a subset of the eventing metrics found [here](https://knative.dev/docs/eventing/observability/metrics/eventing-metrics/). Due to the single-tenant nature, `Broker - Filter` metrics aren't applicable.

### Architecture

Eventing RabbitMQ follows a single tenant model where dedicated resources (pods) are created per Broker, Trigger and Source objects. While there is some overhead to this approach, there are also benefits:
- Pods can be autoscaled to handle the expected traffic for a given Broker/Trigger/Source.
- User's existing policies and roles can be used for role based access control (RBAC).
- Increased transparency into what's being run on the cluster.

<img src="/blog/articles/images/eventing-rabbitmq-architecture-broker.png" alt="Eventing RabbitMQ broker architecture" width="960"/>

Creating a broker will create an ingress pod that can receive CloudEvents and RabbitMQ resources needed to plumb the event through the RabbitMQ system. A trigger will create a dispatcher pod that will consume messages from RabbitMQ and send the event to an addressable resource.

<img src="/blog/articles/images/eventing-rabbitmq-architecture-source.png" alt="Eventing RabbitMQ source architecture" width="841"/>

A RabbitMQSource object can retrieve messages from a queue, convert it to a cloud event and send it to an addressable consumer.


### Performance

A suite of performance tests are run with each release to ensure adequate throughput and acceptable latency. The results of the latest run can be found [here](https://github.com/knative-sandbox/eventing-rabbitmq/tree/49787466f88b21fe022216a13c8321b334f92dc4/test/performance/results/release-v1.6).

### Adopters and Feedback
Knative Eventing RabbitMQ is currently in use by VMware Event Broker Appliance ([VEBA](https://flings.vmware.com/vmware-event-broker-appliance)), Cloud Native Runtimes ([CNR](https://docs.vmware.com/en/Cloud-Native-Runtimes-for-VMware-Tanzu/1.3/tanzu-cloud-native-runtimes/GUID-cnr-overview.html)) and others. We will appreciate community feedback on trying this new release and reporting back any issues or queries that you might have.
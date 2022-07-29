# Announcing Eventing RabbitMQ moving to GA

**Author: Gab Satchi, Senior Software Engineer @ VMware**

**Date: 2022-07-26**

We’re excited to announce that [Eventing RabbitMQ](https://github.com/knative-sandbox/eventing-rabbitmq) is now Generally Available (GA). With this milestone, the APIs provided will remain stable in future iterations.
A quick start can be found [here](https://knative.dev/docs/eventing/broker/rabbitmq-broker/).

# Key Features

### Use any RabbitMQ instance

Eventing RabbitMQ works well with RabbitMQ clusters that have been provisioned by using the [RabbitMQ Cluster Kubernetes Operator](https://github.com/rabbitmq/cluster-operator), but can also be configured to use RabbitMQ instances provisioned by other means.
The RabbitMQ Broker and Source both contain a `rabbitmqClusterReference` field, which can either reference a RabbitMQ cluster that was created by using the Operator, or a `Secret` containing the credentials for a RabbitMQ instance.
Full documentation can be found [here](https://github.com/knative-sandbox/eventing-rabbitmq/tree/49787466f88b21fe022216a13c8321b334f92dc4/samples/external-cluster).

### Parallelism and event ordering

RabbitMQ by default uses a first-in-first-out (FIFO) ordering mode for events. However, there can be use cases where ordering isn't required and higher throughput may be preferred.
Both the RabbitMQ Broker and Source contain a `parallelism` annotation that can be configured to process more than one message in parallel.
An example outlining both FIFO and high throughput modes can be found [here](https://github.com/knative-sandbox/eventing-rabbitmq/tree/49787466f88b21fe022216a13c8321b334f92dc4/samples/trigger-customizations).

### Quorum queues

Quorum queues are a fault tolerant, replicated queue type that are used in multi-node setups. RabbitMQ uses quorum queues by default.
The queue type can be configured for RabbitMQ Brokers, and any Triggers subscribed to a Broker will inherit the queue type.
Full documentation can be found [here](https://github.com/knative-sandbox/eventing-rabbitmq/tree/e6b6312a660698edf8daffa6b1c7274c1e3951a4/samples/quick-setup)

### Metrics

Eventing RabbitMQ mirrors a subset of the eventing metrics found [here](https://knative.dev/docs/eventing/observability/metrics/eventing-metrics/). Due to the single-tenant nature, `Broker - Filter` metrics aren't applicable.

### Architecture

Eventing RabbitMQ follows a single tenant model where dedicated resources are created for each Broker, Trigger, and Source object. While there is some overhead to this approach, there are also benefits:
- Pods can be autoscaled to handle the expected traffic for a given Broker, Trigger, or Source.
- User's existing policies and roles can be used for role based access control (RBAC).
- Increased transparency into what is running on the cluster.

<img src="/blog/articles/images/eventing-rabbitmq-architecture-broker.png" alt="Eventing RabbitMQ broker architecture" width="960"/>

Creating a Broker automatically creates an ingress pod that can receive CloudEvents, and the RabbitMQ resources needed to route CloudEvents through the RabbitMQ system. Triggers create dispatcher pods that consume messages from RabbitMQ, and send CloudEvents to an addressable resource.

<img src="/blog/articles/images/eventing-rabbitmq-architecture-source.png" alt="Eventing RabbitMQ source architecture" width="841"/>

RabbitMQSource objects can retrieve messages from a queue, convert them to CloudEvents, and send these CloudEvents to addressable consumers.


### Performance

A suite of performance tests are run with each release to ensure adequate throughput and acceptable latency. The results of the latest run can be found [here](https://github.com/knative-sandbox/eventing-rabbitmq/tree/49787466f88b21fe022216a13c8321b334f92dc4/test/performance/results/release-v1.6).

### Adopters

Eventing RabbitMQ is currently in use by VMware Event Broker Appliance ([VEBA](https://flings.vmware.com/vmware-event-broker-appliance)), Cloud Native Runtimes ([CNR](https://docs.vmware.com/en/Cloud-Native-Runtimes-for-VMware-Tanzu/1.3/tanzu-cloud-native-runtimes/GUID-cnr-overview.html)).

### Feedback

We will appreciate community feedback on trying this new release and reporting back any issues or queries that you might have. New issues can be created [here](https://github.com/knative-sandbox/eventing-rabbitmq/issues/new/choose).

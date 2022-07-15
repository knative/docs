# What is a broker?

A broker is middleware that is used to manage event delivery between event producers and consumers.

Knative brokers manage CloudEvents, and use a traditional publish-subscribe pattern. If non-CloudEvent spec events are sent to a Knative broker, the event is transformed to use the correct schema automatically before it is routed to an event consumer.

## Why use Knative brokers?

In a Knative deployment, brokers provide the following benefits over having to configure sending and managing events directly between each producer and consumer:

- You can use triggers to filter which events are sent to which consumers from the broker's common event pool.

- You can configure event delivery options for each event consumer, including specifications about what to do if an event is not able to be delivered.

- You can configure the order in which events are sent from the broker to a consumer.

- You can use the Knative event registry to discover event types that brokers can consume, and create triggers for these event types.

- You can view metrics to understand how efficiency your event-driven applications are working, and troubleshoot any event delivery performance issues.

<!--
- Security at various levels of authentication, authorization and topic/channel access control.

- Optimization of scaling to support the varying traffic density of certain event types through intelligent clustering.
-->

## Next concepts

- [Choosing a broker type](choosing-a-broker.md)
- Good links about (advanced) event brokers
- Event producer
- Event consumer
- Publish-subscribe pattern
- Triggers and filtering
- Event ordering
- [CloudEvents](https://cloudevents.io/)
- Event registry
- Broker security
- High availability and autoscaling
- Event delivery and delivery failure
- Observability and metrics

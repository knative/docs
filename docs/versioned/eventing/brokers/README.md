# About Brokers

--8<-- "about-brokers.md"

## Event delivery

Event delivery mechanics are an implementation detail that depend on the configured Broker class. Using Brokers and Triggers abstracts the details of event routing from the event producer and event consumer.

## Advanced use cases

For most use cases, a single Broker per namespace is sufficient, but
there are several use cases where multiple Brokers can simplify
architecture. For example, separate Brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

## Next steps

- Create a [Broker](create-broker.md).
- Configure [default Broker ConfigMap settings](../configuration/broker-configuration.md).

## Additional resources

- [Broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/overview.md#broker){target=_blank}

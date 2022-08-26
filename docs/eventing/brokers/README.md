# About Brokers

--8<-- "about-brokers.md"

## Event delivery

Event delivery mechanics are an implementation detail that depend on the configured
[broker class](../configuration/broker-configuration.md#broker-class-options).
Using brokers and triggers abstracts the details of event routing from the event producer and event consumer.

## Advanced use cases

For most use cases, a single broker per namespace is sufficient, but
there are several use cases where multiple brokers can simplify
architecture. For example, separate brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

## Additional resources

- [Brokers concept documentation](../../concepts/eventing-resources/brokers.md){target=_blank}

## Next steps

- Create an [MT channel-based broker](create-mtbroker.md).
- Configure [default broker ConfigMap settings](../configuration/broker-configuration.md).
- View the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/overview.md#broker).

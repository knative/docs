# Secure Event processing and improved Event discoverability

**Authors: Pierangelo Di Pilato, Senior Software Engineer @ Red Hat, Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

**Date: 2023-07-27**

## What is next in Knative Eventing?

Knative Eventing has come a long way and has established itself as the goto platform on Kubernetes for event-driven applications. However we are not done with the project and we continue to evolve it. We are improving existing APIs and adding new features to Knative Eventing as well. Below is a high level overview of what we are currently doing for the next couple of months.

Please keep in mind that we need your feedback as well! If there are missing features or needed improvements, please speak up and tell.

## Secure Event Processing

Secure event processing refers to the practice of processing and analyzing events or data streams in a secure and trusted manner. Events can include various types of data, such as user interactions, system logs, sensor readings, network traffic, or any other form of real-time or near-real-time data.

The primary goal of secure event processing is to ensure the confidentiality, integrity, and availability of the processed events while maintaining the privacy and security of the underlying data.

### Transport encryption

Currently, event delivery within the cluster is unencrypted. This limits the types of events which can be transmitted to those of low compliance value (or a relaxed compliance posture) or, alternatively, forces administrators to use a service mesh or encrypted CNI to encrypt the traffic, which poses many challenges to Knative Eventing adopters.

Knative Brokers and Channels will provide HTTPS endpoints to receive events. Given that these endpoints typically do not have public DNS names (e.g. svc.cluster.local or the like), these need to be signed by a non-public CA (cluster or organization specific CA).

Event producers will be able to determine the CA root used to sign the Broker or Channel certificate from the Knative resource’s metadata.

For more information, please refer to the [feature track document](https://docs.google.com/document/d/1H-x_oji8LqkCyd7tlsSyclmUe7FAmEJPgRxOU_0pkn8/edit).

### Sender identity

Currently, event delivery within the cluster is unauthenticated, and an event consumer cannot determine the identity of any sender.

By sending the identity of the event sender along with the events, event receivers can start implementing access control features.

For more information, please refer to the [feature track document](https://docs.google.com/document/d/1e7UgNTkL0Br5Da09Rg2ieVmhKJo4VXuBj-mHT9NCujY/edit).

### Authorization and admission policies

Event-driven architecture is meant to lower organizations' silos and barriers, make systems more resilient and ultimately increase business agility, however, this is not possible without event admission policies and safeguards for security and data quality.

Event admission policies will address the need to have authorization policies regarding who is allowed to send events to a given event hub, like a Knative Broker or Channel, as well as what they accept as valid content for events sent to them (schemas, etc).

Authorization and admission policies will be the feature that will bridge the secure event processing topic to the event discovery topic, below.

## Improved Event discovery

Event discovery helps developers to understand which events they can consume and how the events look like, without having to dig through various levels of service documentation.

Knative defines an EventType API which allows for discovery of the types of events that are available in the Knative Eventing system. This helps developers understand what kinds of events can be listened to and processed, which can be particularly helpful in systems with a large number of events being produced.

However currently the EventType is unfortunately underused and is limited to Source-Duck compliant sources, in combination with the Knative Broker API. 

In order to improve the developer experience of Knative Eventing we are enhancing the event discovery in a couple of ways!

* Automatic event type creation
* Usage beyond the broker API
* Event Type definitions

### Automatic Event Type creation

Today the EventType API is limited to Source-Duck compliant sources, and only usable in combination with the Knative Broker API. 

However when using the Broker with a 3rd party integration, such as regular deployments or even CLI tools like `kn event send` the EventType is not created automatically! We do not see any EvenType information for these common usage patterns.
To address this problem we introduce an optional feature flag which can be _enabled_ in order to have support for an automatic creation of EventTypes.

Details can be found in the matching [feature track document](https://docs.google.com/document/d/1H8-mkMs5HWd3U7TT6KAWgU9ltDxqZv25Wls-6c4lneA/edit).

### Support for more than just Brokers

The EventType API will deprecate the `.spec.broker` field and replace it with a `.spec.reference`, which can be any Knative Resource, such a Channel, a Sink, or even a Database.

The good news is: This breaks the limitation to use the event type metadata with the Broker API only. Even when there is no filter on Channel/Subscription APIs, it is still important to know what event types are emitted to components like Channels or Sinks!

### CRD for Event Type Definitions

The above limitations show that event types are only discoverable when there are running workloads, such as a PingSource sending events to a broker. Without this connection it is not possible to tell what categories of event types are generally available in Knative Eventing installation.

To address this problem, Knative Eventing will have a new EventTypeDefinition metadata CRD that captures this information independently of running applications.

Details can be found in the matching [feature track document](https://docs.google.com/document/d/1vwEWtAm28g_QY9j0b63h8sRpGhvyB1K5ViNr8X3vIiM/edit).

## Conclusion

As you can see we are committed to move the Knative Eventing project forward. The above shows that topics like secure event processing or improved event discoverability are addressed to improve the developer experience for all Knative Eventing users.

However, we are not done! We are passionate about improving Knative Eventing and also continue to innovate in the area of event driven architectures for Kubernetes. But we can not just do this alone: We also need your help!

If you are curious, please check out the [Github Projects](https://github.com/orgs/knative/projects) we have or swing by in our several [Slack channels](https://knative.dev/docs/community/#communication-channels).

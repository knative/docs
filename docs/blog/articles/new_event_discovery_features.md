# Better Developer experience with improved event discovery in Knative

**Authors: David Simansky, Senior Software Engineer @ Red Hat, Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In this blog post you will learn about the new enhancements in Knative Eventing around event discovery._

Event discovery is an important part of event-driven applications, since it allows developers to better understand system dynamics and what events to consume. It does enable a more efficient and robust application design.

### Knative Event Type API enhancements

With the latest 1.11 release of Knative Eventing there were a few improvements related to improved Event discovery:

* `EventType` API bumped to `v1beta2`
* Making use of `reference`s to point to any Resource like Channels or Sinks, not just brokers
* Enhance build-in Sources to create eventypes for any binding, not just brokers.
* Automatic EvenType creation for Brokers and Channels

#### EventType API changes and version bump

After a couple of years being on version `v1beta1` the `EventType` API in Knative has changed and was bumped to `v1beta2`. The version bump did not come alone, it was combined with an overhaul for improved developer experience. It is now possible to point to any resource from an Event type object, instead of being only restricted to broker objects.

### Referencing other resources

The new version is marking the `broker` field as deprecated and it will be removed in a future release, instead we now have the `reference` field which takes any `KReference` API type, being able to point to any sink, channel or the broker as well. Let's take a look at the new `EventType` object:

```yaml
apiVersion: eventing.knative.dev/v1beta2
kind: EventType
metadata:
  name: dev.knative.source.github.push-sss34cnb
  namespace: default
spec:
  type: dev.knative.source.github.push
  source: https://github.com/knative/eventing
  reference:
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
    name: testchannel
```

The status was also changed, since we do just require the reference to be existing, instead of being also ready itself.

#### Duck Sources 

The above enhancement did allow an additional change for the build-in sources, or any source that is compliant to the Sources Duck type. For instance until previous releases `EventType` objects where only created automatically when the source was pointing to a broker, because of the above restriction. Now those are created for any referenced sink, on the source, like:

```yaml
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: ping-source-broker2
spec:
  schedule: "*/1 * * * *"
  data: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: v1
      kind: Service
      name: log-receiver
```

This results in an auto-created event type, like:

```bash
k get eventtypes.eventing.knative.dev -A 
NAMESPACE   NAME                               TYPE                       SOURCE                                                        SCHEMA   REFERENCE NAME   REFERENCE KIND   DESCRIPTION   READY   REASON
default     93774a924a741245a94313745d78e69f   dev.knative.sources.ping   /apis/v1/namespaces/default/pingsources/ping-source-broker2            log-receiver     Service                        True    
```
#### Auto Event Type creation

Furthermore to improve the experience with consumption and creation of `EventTypes`, there's a new experimental feature to automatically create `EventTypes` objects based on processed events on the broker ingress and in-memory channels. Instead of manually creating them as yaml manifests along the application code that talks to the Broker or Channel API. This behaviour can be enabled by feature flag `eventtype-auto-creation` in `config-features` ConfigMap. For further details and examples please refer to [the documentation](https://knative.dev/docs/eventing/experimental-features/eventtype-auto-creation/).



### Conclusion

This blog post introduced new features and improvements to `EventType` discoverability. The main motivation is to harden the position of developer's insight into the event-driven applications to ease up the discovery and speed up development. 

We look forward from the community to further enhance `EventType` API and discoverability. Please reach out on the CNCF Slack's [#knative-eventing](https://cloud-native.slack.com/archives/C04LMU33V1S) or GitHub [issues](https://github.com/knative/eventing/issues).

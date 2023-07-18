# EventType auto creation for Brokers

**Flag name**: `eventtype-auto-creation`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#7044](https://github.com/knative/eventing/issues/7044)

**Persona**: Developer


## Overview

With the `eventtype-auto-creation` feature, we have possibliy to _auto create_ EventTypes that are received and ingressed by the Knative Broker implementations.

For making use of this _opt-in_ feature, we must turn it on in the `config-features`, by setting the `eventtype-auto-creation` flag to `enabled`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
data:
  eventtype-auto-creation: "enabled"
...
```

With this experiemental feature enabled, we get `EventType`s on the broker ingress for free. Instead of manually creating them as yaml manifests along the application code that talks to the `Broker` API. 

## Example

To check the feature is working, create a simple broker:

```bash
kn broker create my-broker
```

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  namespace: default
  name: my-broker
```

## Produce Events to the Broker

Once events are send to the broker the feature kicks in.

### Using `kn event`

Below is an example that sends an event with the `kn` CLI, for improved developer productivity. The kn-event-plugin can be installed with Homebrew, for more details refer to plugin (instalation steps)[https://knative.dev/docs/client/kn-plugins/#install-a-plugin-by-using-homebrew].

```bash
brew install knative-sandbox/kn-plugins/event
```

```bash
kn event send \
  --to Broker:eventing.knative.dev/v1:my-broker\
  --type com.corp.integration.warning \
  -f message="There might be a problem"
```

### Using curl container

An event can be also send via `curl`

```bash
kubectl run curl  --image=docker.io/curlimages/curl --rm=true --restart=Never -ti \
  -- -X POST -v \
  -H "content-type: application/json" \
  -H "ce-specversion: 1.0" \
  -H "ce-source: my/curl/command" \
  -H "ce-type: my.demo.event" \
  -H "ce-id: 6cf17c7b-30b1-45a6-80b0-4cf58c92b947" \
  -d '{"name":"Knative Demo"}' \
  http://broker-ingress.knative-eventing.svc.cluster.local/default/my-broker
```
This is more complex, as we have to _craft_ the event as part of the `curl` HTTP POST request... 

## Event Discovery

After the two produced events, we should be able to have discoverable events in the system, based on the `auto-eventtype-creation` feature:

```
k get eventtypes.eventing.knative.dev -A 
NAMESPACE   NAME     TYPE                           SOURCE            SCHEMA   BROKER      DESCRIPTION   READY   REASON
default     <...>    com.corp.integration.warning   kn-event/v1.9.0            my-broker                 True    
default     <...>    my.demo.event                  my/curl/command            my-broker                 True    
```

# Conclusion and Recommendation

With out this feature we would not see the two `EventType`s in the system, so we have improved the discoverablilty of events, for consumption. However while this **opt-in** feature is handy for automatic event creation, we **strongly** recommend to create the actual `EventType` manifests for all events that your application `deployments` produce, as part of your Gitops pipeline, rather than relying on this auto-create feature.

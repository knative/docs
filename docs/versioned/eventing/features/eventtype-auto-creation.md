# EventType auto creation for improved discoverability

**Flag name**: `eventtype-auto-create`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#7044](https://github.com/knative/eventing/issues/7044)

**Persona**: Developer


## Overview

With the `eventtype-auto-creation` feature, we have possibliy to _auto create_ EventTypes that are received and ingressed by the Knative Broker and Channel implementations.

For making use of this _opt-in_ feature, we must turn it on in the `config-features`, by setting the `eventtype-auto-create` flag to `enabled`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
data:
  eventtype-auto-create: "enabled"
...
```

With this feature enabled, we get `EventType`s on the broker/channel ingress for free, instead of manually creating them as yaml manifests along the application code that talks to the `Broker` or `Channel` API. 

## Example

### Create a Broker

To check the feature is working, create a simple broker:


=== "kn CLI"
  
    ```bash
    kn broker create my-broker
    ```

=== "Apply YAML"

    1. Create a YAML file using the following example:

        ```yaml
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        metadata:
          namespace: default
          name: my-broker
        ```
    
    1. Apply the YAML file by running the command:

          ```bash
          kubectl apply -f <filename>.yaml
          ```
          Where `<filename>` is the name of the file you created in the previous step.


### Produce Events to the Broker

The auto-creation feature is triggered by processed events. Therefore to verify the functionality we need to send a sample event with desired type. This can be achieved in a severals ways, below are two examples using `kn-plugin-event` and `cURL`
container in a cluster.

=== "kn event"

    Below is an example that sends an event with the `kn` CLI, for improved developer productivity. The `kn-plugin-event` plugin can be installed with Homebrew or downloaded directly from GitHub releases, for more details please refer to plugin [instalation steps](https://knative.dev/docs/client/kn-plugins/).

    1. Setup `kn event` plugin
        ```bash
        brew install knative-extensions/kn-plugins/event
        ```

    1. Send event
        ```bash
        kn event send \
          --to Broker:eventing.knative.dev/v1:my-broker\
          --type com.corp.integration.warning \
          -f message="There might be a problem"
        ```

=== "cURL container"

    An event can be send via `curl` in a cluster:

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
    This is more complex, as we have to _craft_ the event as part of the `curl` HTTP POST request.

### Event Discovery

After the two produced events, we should be able to have discoverable events in the system, based on the `eventtype-auto-creation` feature:

```
k get eventtypes.eventing.knative.dev -A 
NAMESPACE   NAME     TYPE                           SOURCE            SCHEMA   BROKER      DESCRIPTION   READY   REASON
default     <...>    com.corp.integration.warning   kn-event/v1.9.0            my-broker                 True    
default     <...>    my.demo.event                  my/curl/command            my-broker                 True    
```

## Conclusion and Recommendation

With out this feature we would not see the two `EventType` instances in the system, so we have improved the discoverablilty of events, for consumption. However while this _opt-in_ feature is handy for automatic event creation, we **strongly** recommend to create the actual `EventType` manifests for all events that your application `deployments` produce, as part of your Gitops pipeline, rather than relying on this auto-create feature.

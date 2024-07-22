# Introducing MQTT Source with ContainerSource CRD

**Author: Phuong Cao...**

Knative Eventing is taking a step forward in IoT integration with the introduction of an MQTT Source. This new feature contributes to addressing a growing need in the IoT space, allowing developers to seamlessly transform MQTT messages into CloudEvents and ingest them into the Knative Eventing system.

## Why MQTT Source?

With the proliferation of IoT devices and edge computing, there's an increasing number of devices emitting MQTT messages to brokers. Until now, processing these messages within Knative Eventing required additional steps. The new MQTT Source bridges this gap, enabling direct ingestion and processing of MQTT messages in a cloud-native event-driven architecture.

## Feature Description:

Instead of developing a full-fledged controller from scratch, we've taken a simpler and more efficient approach. The MQTT Source is implemented as a container image that can be used with the existing ContainerSource CRD. This approach is similar to what we've done for the WebSocket protocol, allowing us to transform MQTT messages received into CloudEvents and send them to specified brokers.

## Installations:

This feature uses mqtt_paho to receive and send MQTT messages as CloudEvents. The Mosquitto Eclipse package is used to send test MQTT messages, so it can be disregarded when the feature is complete and MQTT messages are sent from another source.

```shell
go get github.com/eclipse/paho.golang/paho
go get github.com/cloudevents/sdk-go/v2
go get github.com/cloudevents/sdk-go/protocol/mqtt_paho/v2
```

## Using the feature:

1. Set up an MQTT broker (for testing, you can use Mosquitto):

```shell
docker run -it --rm --name mosquitto -p 1883:1883 eclipse-mosquitto:2.0 mosquitto -c /mosquitto-no-auth.conf
```

2. Set up sink:
   The MQTT Source needs a sink to receive the CloudEvent message it sends. For testing purposes, we can use an event display service to receive and display those messages. Add this event_display.yaml file.

```
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
 name: event-display
 namespace: default
spec:
 template:
   spec:
     containers:
       - # This corresponds to
         # https://github.com/knative/eventing/tree/main/cmd/event_display/main.go
         image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
```

Then keep this event_display running:

```shell
kubectl apply event-display.yaml
```

## Deploy the MQTT Source

We will first need to build the Container Source using command:

```shell
ko build cmd/mqttsource/main.go
```

Then, use the following yaml file in config/tools/mqtt_source. Here, you can specify a different topic and event source by adding args. The default source would be localhost:1883, assuming you have started the mosquitto MQTT broker, and the default topic would be mqtt-topic

```
apiVersion: sources.knative.dev/v1
kind: ContainerSource
metadata:
 name: mqttsource
spec:
 template:
   spec:
     containers:
       - image: ko://knative.dev/eventing/cmd/mqttsource
         securityContext:
           allowPrivilegeEscalation: false
           readOnlyRootFilesystem: true
           runAsNonRoot: true
           capabilities:
             drop:
               - ALL
           seccompProfile:
             type: RuntimeDefault


 sink:
   ref:
     apiVersion: serving.knative.dev/v1
     kind: Service
     name: event-display
```

```shell
ko apply -f config/tools/mqttsource/mqttsource.yaml
```

4. Send testing messages:
   Use this command to trigger the mosquitto broker to send a MQTT message to the MQTT Source.

```shell
mosquitto_pub -t '<topic-name>' -m '{"specversion" : "1.0","type" :"com.example.someevent", "id" : "1234-1234-1234","source" : "/mycontext/subcontext","data":{"msg":<message>"}}' -D PUBLISH user-property Content-Type application/cloudevents+json; charset=utf-8
```

The MQTT Source will receive this message, transform it into a CloudEvent, and send it to the specified sink in your Knative Eventing system. The event received will also be logged to the console. You can view the message if it is successfully sent by viewing the logs of event_display.

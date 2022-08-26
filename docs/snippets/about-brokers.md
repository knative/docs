<!-- Snippet used in the following topics:
- /docs/concepts/eventing-resources/brokers.md
- /docs/eventing/broker/README.md
-->

Brokers are Kubernetes custom resources that define an event mesh for collecting a pool of events. Brokers provide a discoverable endpoint for event ingress, and use Triggers for event delivery. Event producers can send events to a broker by POSTing the event.

![Source 1 and Source 2 are transmitting some data -- ones and twos -- to the Broker, which then gets filtered by Triggers to the desired Sink.](https://user-images.githubusercontent.com/16281246/116248768-1fe56080-a73a-11eb-9a85-8bdccb82d16c.png){draggable=false}

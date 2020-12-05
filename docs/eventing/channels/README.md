Channels are Kubernetes [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) which define a single event forwarding
and persistence layer. Messaging implementations may provide implementations of
Channels via a Kubernetes Custom Resource, supporting different technologies, such as Apache Kafka or NATS
Streaming.

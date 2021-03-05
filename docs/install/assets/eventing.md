# Knative Serving installation files (0.21 releases)

| File name | Description | Dependencies|
| --- | --- | --- |
| eventing-core.yaml | Knative Eventing core components. | eventing-crds.yaml |
| eventing-crds.yaml | Knative Serving core CRDs. | none |
| eventing-post-install.yaml | Optional jobs after installing eventing-core.yaml. | eventing-core.yaml |
| eventing-sugar-controller.yaml | Optional reconciler that watches for labels and annotations on certain resources to inject eventing components. | eventing-core.yaml |
| in-memory-channel.yaml | Components to configure In-Memory Channels. | eventing-core.yaml |
| mt-channel-broker.yaml | Components to configure MT Channel Broker. | eventing-core.yaml |
| eventing.yaml | Combines `eventing-core.yaml`, `mt-channel-broker.yaml`, and `in-memory-channel.yaml`. | none |

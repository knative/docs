# Knative Eventing installation files

| File name | Description | Dependencies|
| --- | --- | --- |
| eventing-core.yaml | Knative Eventing core components. | eventing-crds.yaml |
| eventing-crds.yaml | Knative Eventing core CRDs. | none |
| eventing-post-install.yaml | Required jobs for upgrading to a new minor version. | eventing-core.yaml, eventing-crds.yaml |
| eventing-sugar-controller.yaml | Optional reconciler that watches for labels and annotations on certain resources to inject eventing components. | eventing-core.yaml |
| eventing.yaml | Combines `eventing-core.yaml`, `mt-channel-broker.yaml`, and `in-memory-channel.yaml`. | none |
| in-memory-channel.yaml | Components to configure In-Memory Channels. | eventing-core.yaml |
| mt-channel-broker.yaml | Components to configure Multi-Tenant (MT) Channel Broker. | eventing-core.yaml |

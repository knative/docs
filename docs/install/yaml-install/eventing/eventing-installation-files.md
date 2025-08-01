---
audience: administrator
components:
  - eventing
function: reference
---

# Knative Eventing installation files

This guide provides reference information about the core Knative Eventing YAML files, including:

- The custom resource definitions (CRDs) and core components required to install Knative Eventing.
- Optional components that you can apply to customize your installation.

For information about installing these files, see
[Installing Knative Eventing using YAML files](install-eventing-with-yaml.md).

The following table describes the installation files included in Knative Eventing:

| File name | Description | Dependencies|
| --- | --- | --- |
| [eventing-core.yaml]({{ artifact(repo="eventing",file="eventing-core.yaml")}}) | Required: Knative Eventing core components. |  [eventing-crds.yaml]({{ artifact(repo="eventing",file="eventing-crds.yaml")}}) |
| [eventing-crds.yaml]({{ artifact(repo="eventing",file="eventing-crds.yaml")}}) | Required: Knative Eventing core CRDs. |  none |
| [eventing-post-install.yaml]({{ artifact(repo="eventing",file="eventing-post-install.yaml")}}) | Jobs required for upgrading to a new minor version. | [eventing-core.yaml]({{ artifact(repo="eventing",file="eventing-core.yaml")}}), [eventing-crds.yaml]({{ artifact(repo="eventing",file="eventing-crds.yaml")}}) |
| [eventing.yaml]({{ artifact(repo="eventing",file="eventing.yaml")}}) | Combines `eventing-core.yaml`, `mt-channel-broker.yaml`, and `in-memory-channel.yaml`. | none |
| [in-memory-channel.yaml]({{ artifact(repo="eventing",file="in-memory-channel.yaml")}}) | Components to configure In-Memory Channels. | [eventing-core.yaml]({{ artifact(repo="eventing",file="eventing-core.yaml")}}) |
| [mt-channel-broker.yaml]({{ artifact(repo="eventing",file="mt-channel-broker.yaml")}}) | Components to configure Multi-Tenant (MT) Channel Broker. | [eventing-core.yaml]({{ artifact(repo="eventing",file="eventing-core.yaml")}}) |

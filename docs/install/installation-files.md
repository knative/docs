---
title: "Installation files"
weight: 20
type: "docs"
---

This guide provides reference information about the YAML files in the Knative
Serving and Eventing releases.

The YAML files in the releases include:

- The custom resource definitions (CRDs) and core components required to install Knative.
- Optional components that you can apply to customize your installation.

For information about installing these files, see [Installing Serving using YAML files](./install-serving-with-yaml)
and [Installing Eventing using YAML files](./install-eventing-with-yaml).

## Knative Serving installation files

The table below describes the installation files in the Knative Serving release:

| File name | Description | Dependencies|
| --- | --- | --- |
| serving-core.yaml | Required: Knative Serving core components. | serving-crds.yaml |
| serving-crds.yaml | Required: Knative Serving core CRDs. | none |
| serving-default-domain.yaml | Configures Knative Serving to use [http://xip.io](http://xip.io) as the default DNS suffix. | serving-core.yaml |
| serving-domainmapping-crds.yaml | CRDs used by the Domain Mapping feature. | none |
| serving-domainmapping.yaml | Components used by the Domain Mapping feature. | serving-domainmapping-crds.yaml |
| serving-hpa.yaml | Components to autoscale Knative revisions through the Kubernetes Horizontal Pod Autoscaler. | serving-core.yaml |
  serving-nscert.yaml | Components to provision TLS wildcard certificates. | serving-core.yaml |
| serving-post-install-jobs.yaml | Additional jobs after installing `serving-core.yaml`. Currently it is the same as `serving-storage-version-migration.yaml`. | serving-core.yaml |
| serving-storage-version-migration.yaml | Migrates the storage version of Knative resources, including Service, Route, Revision, and Configuration, from `v1alpha1` and `v1beta1` to `v1`. Required by upgrade from version 0.18 to 0.19. | serving-core.yaml |


## Knative Eventing installation files

The table below describes the installation files in the Knative Eventing release:

| File name | Description | Dependencies|
| --- | --- | --- |
| eventing-core.yaml | Required: Knative Eventing core components. |  eventing-crds.yaml |
| eventing-crds.yaml | Required: Knative Eventing core CRDs. |  none |
| eventing-post-install.yaml | Jobs required for upgrading to a new minor version. | eventing-core.yaml, eventing-crds.yaml |
| eventing-sugar-controller.yaml | Reconciler that watches for labels and annotations on certain resources to inject eventing components. | eventing-core.yaml |
| eventing.yaml | Combines `eventing-core.yaml`, `mt-channel-broker.yaml`, and `in-memory-channel.yaml`. | none |
| in-memory-channel.yaml | Components to configure In-Memory Channels. | eventing-core.yaml |
| mt-channel-broker.yaml | Components to configure Multi-Tenant (MT) Channel Broker. | eventing-core.yaml |

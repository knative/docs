---
title: "Experimental features"
weight: 99
type: "docs"
---

# Experimental features

In Knative Eventing we want to keep the innovation alive, experimenting and delivering new features without affecting the stability of the project.

In order to achieve that goal, we have a process to include new features.
This allows users like you to try out new features and provide feedback back to the project.

This document explains how to enable experimental features and which ones are available today.

For more details about the process, the feature phases, quality requirements and guarantees, check out the [Experimental features process documentation](https://github.com/knative/eventing/blob/main/docs/experimental-features.md).

## Before you begin

You must have a Knative cluster running with the Eventing component installed. [Learn more](../install/)

## Experimental features configuration

When installing Eventing, the `config-experimental-features` ConfigMap is added to your cluster in the `knative-eventing` namespace.
In order to enable a feature, you just need to add it to the config map and set its value to `"true"`.
For example, to enable `new-cool-feature`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-experimental-features
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
    knative.dev/config-propagation: original
    knative.dev/config-category: eventing
data:
  new-cool-feature: "true"
```

In order to disable it, you can either remove the flag or set it to `"false"`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-experimental-features
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
    knative.dev/config-propagation: original
    knative.dev/config-category: eventing
data:
  new-cool-feature: "false"
```

## Features list

<!-- TODO there are no experimental features at the moment -->

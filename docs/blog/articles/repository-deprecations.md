---
title: "Deprecation of inactive Knative repositories"
linkTitle: "Repository deprecations"
author: "[Dave Protasowski](https://github.com/dprotaso)"
author handle: https://github.com/dprotaso
date: 2026-11-01
description: "Deprecation and archival of inactive Knative repositories"
type: "blog"
---

# Deprecation of inactive Knative repositories

The repositories listed below are deprecated and will be archived as part of Knative's repository cleanup. These projects will no longer receive maintenance or new releases.

Archiving makes the repositories read-only while preserving their source history and existing release assets. We will also remove them from release and maintenance automation and update the relevant documentation.

## Knative Extensions

- [`.allstar`](https://github.com/knative-extensions/.allstar)
- [`autoscaler-keda`](https://github.com/knative-extensions/autoscaler-keda)
- [`backstage-plugins`](https://github.com/knative-extensions/backstage-plugins)
- [`discovery`](https://github.com/knative-extensions/discovery)
- [`eventing-autoscaler-keda`](https://github.com/knative-extensions/eventing-autoscaler-keda)
- [`func-tastic`](https://github.com/knative-extensions/func-tastic)
- [`kn-plugin-sample`](https://github.com/knative-extensions/kn-plugin-sample)
- [`kn-plugin-service-log`](https://github.com/knative-extensions/kn-plugin-service-log)
- [`kn-plugin-source-kamelet`](https://github.com/knative-extensions/kn-plugin-source-kamelet)
- [`security-guard`](https://github.com/knative-extensions/security-guard)
- [`wg-repository`](https://github.com/knative-extensions/wg-repository)

## Knative

- [`.artifacthub`](https://github.com/knative/.artifacthub)
- [`test-infra`](https://github.com/knative/test-infra)

This retirement applies to the listed repositories, not to Knative Serving, Eventing, Functions, or the maintained plugins. In particular, Kafka's built-in KEDA integration is separate from the two retiring KEDA repositories.

The implementation work and archival status are tracked in [knative/community#1802](https://github.com/knative/community/issues/1802).

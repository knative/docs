---
title: "Feature/Extension Flags"
weight: 50
type: "docs"
---

Knative is deliberate about the concepts it incorporates into its core API. The API aims to be portable and abstracts away the specificities of each users' implementation. That being said, the Knative API should empower users to surface extra features and extensions possible within their platform of choice.

This document introduces two concepts:
* Feature: a way to stage the introduction of features to the Knative API.
* Extension: a way to extend Knative beyond the portable concepts of the Knative API.

## Control
Features and extensions are controlled by flags defined in the `config-features` ConfigMap in the `knative-serving` namespace.
Flags can have the following values:
* Enabled: the feature is enabled.
* Allowed: the feature may be enabled (e.g. using an annotation or looser validation).
* Disabled: the feature cannot be enabled.

These three states don't make sense for all features.
Let's consider two types of features: `multi-container` and `kubernetes/podspec-dryrun`.

`multi-container` allows the user to specify more than one container in the Knative Service spec. In this case, `Enabled` and `Allowed` are equivalent because using this feature requires to actually use it in the Knative Service spec. If a single container is specified, whether the feature is enabled or not doesn't change anything.

`kubernetes/podspec-dryrun` changes the behavior of the Kubernetes implementation of the Knative API, but it has nothing to do with the Knative API itself. In this case, `Enabled` means the feature will be enabled unconditionally, `Allowed` means that the feature will be enabled only when specified with an annotation, and `Disabled` means that the feature cannot be used at all.

## Lifecyle
Features and extensions go through 3 similar phases (Alpha, Beta, GA) but with important differences.

Alpha means:
* Might be buggy. Enabling the feature may expose bugs.
* Support for feature may be dropped at any time without notice.
* The API may change in incompatible ways in a later software release without notice.
* Recommended for use only in short-lived testing clusters, due to increased risk of bugs and lack of long-term support.

Beta means:
* The feature is well tested. Enabling the feature is considered safe.
* Support for the overall feature will not be dropped, though details may change.
* The schema and/or semantics of objects may change in incompatible ways in a subsequent beta or stable release. When this happens, we will provide instructions for migrating to the next version. This may require deleting, editing, or re-creating API objects. The editing process may require some thought. This may require downtime for applications that rely on the feature.
* Recommended for only non-business-critical uses because of potential for incompatible changes in subsequent releases. If you have multiple clusters that can be upgraded independently, you may be able to relax this restriction.

General Availability (GA) means:
* Stable versions of features/extensions will appear in released software for many subsequent versions.

# Feature
Features use flags to safely introduce new changes to the Knative API. Eventually, each feature will graduate to become fully part of the Knative API, and the flag guard will be removed.

## Alpha
* Disabled by default.

## Beta
* Enabled by default.

## GA
* The feature is always enabled; you cannot disable it.
* The corresponding feature flag is no longer needed.

# Extension
An extension may surface details of a specific Knative implementation or features of the underlying environment. It is never intended for inclusion in the core Knative API due to its lack of portability. Each extension will always be controlled by a flag and never enabled by default.

## Alpha
* Disabled by default.

## Beta
* Allowed by default.

## GA
* Allowed by default.

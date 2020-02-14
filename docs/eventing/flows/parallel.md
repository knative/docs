---
title: "Parallel"
weight: 20
type: "docs"
aliases:
   - /docs/eventing/parallel.md
---

Parallel CRD provides a way to easily define a list of branches, each receiving
the same CloudEvent sent to the Parallel ingress channel. Typically, each branch
consists of a filter function guarding the execution of the branch.

Parallel creates `Channel`s and `Subscription`s under the hood.

## Usage

### Parallel Spec

Parallel has three parts for the Spec:

1. `branches` defines the list of `filter` and `subscriber` pairs, one per branch,
   and optionally a `reply` object. For each branch:
   1. (optional) the `filter` is evaluated and when it returns an event the `subscriber` is
      executed. Both `filter` and `subscriber` must be `Addressable`.
   1. the event returned by the `subscriber` is sent to the branch `reply`
      object. When the `reply` is empty, the event is sent to the `spec.reply`
      object (see below).
1. (optional) `channelTemplate` defines the Template which will be used to
   create `Channel`s.
1. (optional) `reply` defines where the result of each branch is sent to when
   the branch does not have its own `reply` object.

### Parallel Status

Parallel has three parts for the Status:

1. `conditions` which details the overall status of the Parallel object
1. `ingressChannelStatus` and `branchesStatuses` which convey the status of
   underlying `Channel` and `Subscription` resource that are created as part of
   this Parallel.
1. `address` which is exposed so that Parallel can be used where Addressable can
   be used. Sending to this address will target the `Channel` which is fronting
   this Parallel (same as `ingressChannelStatus`).

## Examples

Learn how to use Parallel by following the [examples](../samples/parallel/README.md)

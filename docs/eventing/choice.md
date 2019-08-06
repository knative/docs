---
title: "Choice"
weight: 20
type: "docs"
---

Choice CRD provides a way to easily define a list of branches, each
receiving the same Cloud Event sent to the Choice ingress channel.
Typically, each branch consists of a filter function guarding the execution
of the branch.

Choice creates `Channel`s and `Subscription`s under the hood.

## Usage

### Choice Spec

Choice has three parts for the Spec:

1. `cases` defines the list of `filter` and `subscriber` pairs, one per branch,
   and optionally a `reply` object. For each branch:
   1. the `filter` is evaluated and when it returns an event the `subscriber` is
      executed. Both `filter` and `subscriber` must be `Callable`.
   1. the event returned by the `subscriber` is sent to the branch `reply`
      object. When the `reply` is empty, the event is sent to the `spec.reply`
      object (see below).
1. (optional) `channelTemplate` defines the Template which will be used to
   create `Channel`s.
1. (optional) `reply` defines where the result of each branch is sent to when
   the branch does not have its own `reply` object.

### Choice Status

Choice has three parts for the Status:

1. `conditions` which details the overall status of the Choice object
1. `ingressChannelStatus` and `caseStatuses` which convey the status of underlying
   `Channel` and `Subscription` resource that are created as part of this
   Choice.
1. `address` which is exposed so that Choice can be used where Addressable
   can be used. Sending to this address will target the `Channel` which is
   fronting this Choice (same as `ingressChannelStatus`).

## Examples

Learn how to use Choice by following the [examples](./samples/choice/README.md)

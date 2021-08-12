# Parallel Example

The following examples will help you understand how to use Parallel to describe
various flows.

## Prerequisites

All examples require:

- A Kubernetes cluster with
  - Knative Eventing
  - Knative Serving

All examples are using the
[default channel template](../../channels/create-default-channel).

## Examples

Each of the following examples use
[`PingSource`](../../sources/ping-source/) as the source of events.

We also use simple
[functions](https://github.com/lionelvillard/knative-functions) to perform
trivial filtering, transformation and routing of the incoming events.

The examples are:

- [Parallel with multiple branches and global reply](multiple-branches/)
- [Parallel with mutually exclusive cases](mutual-exclusivity/)

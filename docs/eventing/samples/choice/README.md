The following examples will help you understand how to use Choice
to describe various flows.

## Prerequisites

All examples require:
- A Kubernetes cluster with
    - Knative Eventing v0.8+
    - Knative Service v0.8+

All examples are using the [default channel template](../../channels/default-channels.md).

## Examples

For each of these examples below, we'll use
[`CronJobSource`](../cronjob-source/README.md) as the source of events.

We also use simple
[functions](https://github.com/lionelvillard/knative-functions) to perform trivial filtering, transformation and routing of the incoming events.

The examples are:

- [Choice with multiple cases and global reply](./multiple-cases/README.md)
- [Choice with mutually exclusive cases](./mutual-exclusivity/README.md)


---
audience: contributor
components:
  - serving
function: how-to
---

!!! note

    This integration is current [Alpha](https://github.com/knative/community/blob/main/mechanics/MATURITY-LEVELS.md#alpha-stage).
    We're trying to guage usage of this so if you're using or interested please reach out to us in
    [#knative-serving](https://cloud-native.slack.com/archives/C04LMU0AX60) slack.

# Extending Queue Proxy image with QPOptions

!!! warning "Deprecated"
    QPOptions and the Security Guard extension shown here are deprecated. See [knative/community#1802](https://github.com/knative/community/issues/1802).

Knative service pods include two containers:

- The user main service container, which is named `user-container`
- The Queue Proxy - a sidecar named `queue-proxy` that serves as a reverse proxy in front of the `user-container`

You can extend Queue Proxy to offer additional features. The QPOptions feature of Queue Proxy allows additional runtime packages to extend Queue Proxy capabilities.

The runtime features available are determined when the Queue Proxy image is built. Queue Proxy defines an orderly manner to activate and to configure extensions.

## Additional information

- [Enabling Queue Proxy Pod Info](./configuration/feature-flags.md#queue-proxy-pod-info) - discussing a necessary step to enable the use of extensions.

## Adding extensions

You can add extensions by replacing the `cmd/queue/main.go` file before the Queue Proxy image is built. Implement your extension as a [`sharedmain.Option`](https://pkg.go.dev/knative.dev/serving/pkg/queue/sharedmain#Option) and pass it to `sharedmain.Main`.

An option receives the Queue Proxy's [`sharedmain.Defaults`](https://pkg.go.dev/knative.dev/serving/pkg/queue/sharedmain#Defaults), which provides access to its context, transport, and proxy handler. Consult that API documentation when implementing your extension. Configuration and activation depend on the extension's implementation.

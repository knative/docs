# Extending Queue Proxy image with QPOptions

Knative service pods include two containers:

- The user main service container, which is named `user-container`
- The Queue Proxy - a sidecar named `queue-proxy` that serves as a reverse proxy in front of the `user-container`

You can extend Queue Proxy to offer additional features. The QPOptions feature of Queue Proxy allows additional runtime packages to extend Queue Proxy capabilities.

For example, the [security-guard](https://knative.dev/security-guard#section-readme) repository provides an extension that uses the QPOptions feature. The [QPOption](https://knative.dev/security-guard/pkg/qpoption#section-readme) package enables users to add additional security features to Queue Proxy.

The runtime features available are determined when the Queue Proxy image is built. Queue Proxy defines an orderly manner to activate and to configure extensions.

## Additional information

- [Enabling Queue Proxy Pod Info](./configuration/feature-flags.md#queue-proxy-pod-info) - discussing a necessary step to enable the use of extensions.
- [Using extensions enabled by QPOptions](./services/using-queue-extensions.md) - discussing how to configure a service to use features implemented in extensions.

## Adding extensions

You can add extensions by replacing the `cmd/queue/main.go` file before the Queue Proxy image is built. The following example shows a `cmd/queue/main.go` file that adds the `test-gate` extension:

```go
  package main

  import "os"

  import "knative.dev/serving/pkg/queue/sharedmain"
  import "knative.dev/security-guard/pkg/qpoption"
  import _ "knative.dev/security-guard/pkg/test-gate"

  func main() {
      qOpt := qpoption.NewQPSecurityPlugs()
      defer qOpt.Shutdown()

        if sharedmain.Main(qOpt.Setup) != nil {
          os.Exit(1)
      }
  }
```

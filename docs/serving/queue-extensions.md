# Queue Proxy Runtime Extensions

Queue Proxy can be built with additional runtime extensions. Such extensions add optional features to Queue Proxy. While Knative core upstream introduce core features available on any knative deployment, Queue Proxy Extensions allow adding additional runtime features. It is up to Downstream to decide which such extensions will be available on what package.

For example, the [security-guard](https://knative.dev/security-guard) repository includes a Queue Proxy Extension [qpoption](https://knative.dev/security-guard/pkg/qpoption) that offers the ability to add security plus to Queue Proxy. Other extensions may be developed to add other features.

The runtime features available are determined when the Queue Proxy image is built. Queue Proxy defines an orderly manner to activate and to configure extensions - See:

- [Enabling Queue Proxy Pod Info](./configuration/feature-flags.md#queue-proxy-pod-info) - discussing a necessary step to enable the use of Extensions.
- [Using Queue Proxy Extensions](./services/using-queue-extensions.md) - discussing how to configure a service to use features implemented in extensions.

In order to add extensions, `cmd/queue/main.go` need to be replaced before queue proxy image is built. Here is an example `cmd/queue/main.go` that adds the `test-gate` extension.

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

# Queue Proxy Runtime Extensions

Queue proxy can be build with additional runtime extensions. Enabling such extensions by upstream enables adding features 
such as runtime security and other runtime features during the build stage of the queue proxy. Queue proxy further defines 
an orderly manner to activate and to configure extensions - See [Controlling Extensions with Annotations](./services/queue-proxy-extensions.md) 
and [Extensions Default Configuration](./configuration/deployment.md).

When using extensions queue proxy is provided with additional options (features). 
Each option is implemented as a function call that receives a queue proxy `sharedmain.Defaults` object. 
The called extension may update the object to mutate the behaviour of queue proxy. 
This allows adding a [RoundTripper](https://pkg.go.dev/net/http#RoundTripper) to the queue proxy and so extending its functionality.

In order to add options, `cmd/queue/main.go` need to be replaced before queue proxy image is built.
Here is an example `cmd/queue/main.go` that adds the testgate extension when building a queue proxy image. 

```
  package main

  import "os"

  import "knative.dev/serving/pkg/queue/sharedmain"
  import "github.com/IBM/go-security-plugs/qpsecurity"
  import _ "github.com/IBM/go-security-plugs/plugs/testgate"

  func main() {
      qOpt := qpsecurity.NewQPSecurityPlugs()
      defer qOpt.Shutdown()

      if sharedmain.Main(qOpt.Setup) != nil {
		      os.Exit(1)
	    }
  }
```

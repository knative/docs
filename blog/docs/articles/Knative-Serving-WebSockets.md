# Building WebSocket Applications with Knative using Golang

**Author: Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

Knative Serving supports multiple protocols for running serverless workloads, such as `HTTP`, `HTTP/2`, `gRPC` or `WebSocket`. The [WebSocket protocol](https://datatracker.ietf.org/doc/html/rfc6455) allows a full-duplex communication over one single TCP connection between client applications and servers. The WebSocket protocol starts as an HTTP "Upgrade" request and then switchs the connection from HTTP over to the WebSocket protocol, allowing real-time and bidirectional communication between the peers. In this article we show how to build a scalable WebSocket server with Knative.

!!! note

    A sample application can be found in the [Knative docs repository](https://github.com/knative/docs/tree/main/code-samples/serving/websockets-go).

## HTTP Upgrade

Since every WebSocket application starts with an HTTP Upgrade request, we need to define a Golang-based Webserver that handles classic HTTP requests. For the WebSocket implementation the [`gorilla/websocket`](https://github.com/gorilla/websocket) package is used, which offers a fast, well-tested and widely used WebSocket implementation for Golang. Below is HTTP part of our sample application:

```go
package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
	"github.com/knative/docs/code-samples/serving/websockets-go/pkg/handlers"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Error upgrading to websocket: %v", err)
		return
	}
	handlers.OnOpen(conn)

	go func() {
		defer handlers.OnClose(conn)
		for {
			messageType, message, err := conn.ReadMessage()
			if err != nil {
				handlers.OnError(conn, err)
				break
			}
			handlers.OnMessage(conn, messageType, message)
		}
	}()
}

func main() {
	http.HandleFunc("/ws", handleWebSocket)
	fmt.Println("Starting server on :8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server error: %v", err)
	}
}
```

The `main` function starts the web server on the `/ws` context and registers a `handleWebSocket` handle function:

```go
func main() {
    http.HandleFunc("/ws", handleWebSocket)
    fmt.Println("Starting server on :8080...")
    if err := http.ListenAndServe(":8080", nil); err != nil {
        log.Fatalf("Server error: %v", err)
    }
}
```

The `handleWebSocket` performs the protocol upgrade and assigns various websocket handler functions, such as `OnOpen` or `OnMessage`:

```go
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        log.Printf("Error upgrading to websocket: %v", err)
        return
    }
    handlers.OnOpen(conn)

    go func() {
        defer handlers.OnClose(conn)
        for {
            messageType, message, err := conn.ReadMessage()
            if err != nil {
                handlers.OnError(conn, err)
                break
            }
            handlers.OnMessage(conn, messageType, message)
        }
    }()
}
```

!!! note

    For a cleaner separation of concerns the different `On...` handlers are located in separate `handlers` package.

## WebSocket handlers

The WebSocket application logic is located in the `pkg/handlers/handlers.go` file and contains callbacks for each WebSocket event:

```go
func OnOpen(conn *websocket.Conn) {
    log.Printf("WebSocket connection opened: %v", conn.RemoteAddr())
}

func OnMessage(conn *websocket.Conn, messageType int, message []byte) {
    log.Printf("Received message from %v: %s", conn.RemoteAddr(), string(message))

    if err := conn.WriteMessage(messageType, message); err != nil {
        log.Printf("Error sending message: %v", err)
    }
}

func OnClose(conn *websocket.Conn) {
    log.Printf("WebSocket connection closed: %v", conn.RemoteAddr())
    conn.Close()
}

func OnError(conn *websocket.Conn, err error) {
    log.Printf("WebSocket error from %v: %v", conn.RemoteAddr(), err)
}
```

In each of the handlers we log the remote address of the connected peer and of any incomming message through the `OnMessage` handler we echo it back to the sender.

## Testing the WebSocket server

!!! note

    The easiest way to build and deploy Golang applications is using [ko](https://github.com/ko-build/ko), as described on the actual [sample application](https://github.com/knative/docs/tree/main/code-samples/serving/websockets-go).

Once the Knative Serving application was deployed the the Kubernetes cluster, you can test it. For that you need to receive the actual URL for the service of the WebSocket application:

```bash
kubectl get ksvc
NAME               URL                                                 LATESTCREATED            LATESTREADY              READY   REASON
websocket-server   http://websocket-server.default.svc.cluster.local   websocket-server-00001   websocket-server-00001   True
```

Now we need a client to connect against our service. For that we launch a Linux container inside Kubernetes and run the [wscat](https://github.com/websockets/wscat) to connect against our WebSocket server application:

```bash
kubectl run --rm -i --tty wscat --image=monotykamary/wscat --restart=Never -- -c ws://websocket-server.default.svc.cluster.local/ws
```

Afterward you can chat with the WebSocket server like:

```bash
```If you don't see a command prompt, try pressing enter.
```connected (press CTRL+C to quit)
```> Hello
```< Hello
```>
```

The above is scaling to exactly one pod, since only one client was connected. Since Knative Serving allows you a dynamic scalling, a certain number of concurrent connections lead to a number of pods.

Below is an example of a scaled out application when running a larger number of concurrent requests against it:

```bash
k get pods 
NAME                                                READY   STATUS    RESTARTS   AGE
websocket-server-00001-deployment-f785cbd65-42mrn   2/2     Running   0          16s
websocket-server-00001-deployment-f785cbd65-76bjr   2/2     Running   0          14s
websocket-server-00001-deployment-f785cbd65-98cwb   2/2     Running   0          18s
websocket-server-00001-deployment-f785cbd65-9fdbl   2/2     Running   0          18s
websocket-server-00001-deployment-f785cbd65-bpvjj   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-c6f47   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-fl6kk   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-gnffw   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-hqpfx   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-j4v9d   2/2     Running   0          18s
websocket-server-00001-deployment-f785cbd65-j72vk   2/2     Running   0          18s
websocket-server-00001-deployment-f785cbd65-k856w   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-kmmng   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-l4f2v   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-lpfr9   2/2     Running   0          14s
websocket-server-00001-deployment-f785cbd65-mn26w   2/2     Running   0          16s
websocket-server-00001-deployment-f785cbd65-mr98h   2/2     Running   0          18s
websocket-server-00001-deployment-f785cbd65-prjmj   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-v696v   2/2     Running   0          18s
websocket-server-00001-deployment-f785cbd65-ws5k9   2/2     Running   0          20s
websocket-server-00001-deployment-f785cbd65-xmszx   2/2     Running   0          18s
websocket-server-00001-deployment-f785cbd65-znhrr   2/2     Running   0          20s
```

!!! note

    Depending on the target annotation you have ([`autoscaling.knative.dev/target`](https://knative.dev/docs/serving/autoscaling/autoscaling-targets/)) you can scale based on num of connections.

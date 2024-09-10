# WebSocket - Go

A simple [WebSocket](https://datatracker.ietf.org/doc/html/rfc6455) server that performs the HTTP upgrade and prints log messages on all standardized WebSocket events, such as `open`, `message`, `close` and `error`. The server is written in Golang and uses the [Gorilla WebSocket](github.com/gorilla/websocket) library.


## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [ko](https://github.com/ko-build/ko) or [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## The sample code.

1. If you look in `cmd/server/main.go`, you will the `main` function setting a `handleWebSocket` function and starting the web server on the `/ws` context:

   ```go
    func main() {
        http.HandleFunc("/ws", handleWebSocket)
        fmt.Println("Starting server on :8080...")
        if err := http.ListenAndServe(":8080", nil); err != nil {
            log.Fatalf("Server error: %v", err)
        }
    }
   ```

2. The `handleWebSocket` performs the protocol upgrade and assigns various websocket handler functions, such as `OnOpen` or `OnMessage`:

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

3. The WebSocket application logic is located in the `pkg/handlers/handlers.go` file and contains callbacks for each WebSocket event:

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

## Build the application

 ### Dockerfile

 * If you look in `Dockerfile`, you will see a method for pulling in the dependencies and building a small Go container based on Alpine. You can build and push this to your registry of choice via:
```bash
# Build and push the container on your local machine.
docker buildx build --platform linux/arm64,linux/amd64 -t "<image>" --push .
```

 ### ko

 * You can use `ko` to build and push just the image with:
```bash
ko publish github.com/knative/docs/code-samples/serving/websockets-go
```
 However, if you use `ko` for the next step, this is not necessary.

## Deploy the application

 ### yaml (with Dockerfile)
 * If you look in `service.yaml`, take the `<image>` name you used earlier and insert it into the `image:` field, then run:
```bash
kubectl apply -f config/service.yaml
```

 ### yaml (with ko)
 * If using `ko` to build and push:
```bash
ko apply -f config/service.yaml
```

## Testing the WebSocket server

Get the URL for your Service with:

   ```bash
   kubectl get ksvc
   NAME               URL                                                 LATESTCREATED            LATESTREADY              READY   REASON
   websocket-server   http://websocket-server.default.svc.cluster.local   websocket-server-00001   websocket-server-00001   True
   ```

Now run a container with the [wscat](https://github.com/websockets/wscat) CLI and point it to the WebSocket application `ws://websocket-server.default.svc.cluster.local/ws`, like:


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

>> **NOTE:** Depending on the target annotation you have ([`autoscaling.knative.dev/target`](https://knative.dev/docs/serving/autoscaling/autoscaling-targets/)) you can scale based on num of connections.

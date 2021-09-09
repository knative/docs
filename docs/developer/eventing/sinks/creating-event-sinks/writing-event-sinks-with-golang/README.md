# Writing an event sink using Golang

This tutorial provides instructions to build an event sink in Golang and implement it as a Knative Service.

## A quick overview of building and deploying a simple event sink with Golang

In the following procedure, you can create a simple sink that receives CloudEvents and performs an example operation on them.

1. From within the `$GOPATH`, create a folder named `demosink`, that contains a new file named `main.go`:

	```go
	package main

	import (
		"context"
		"log"
		"math/rand"
		"time"

		cloudevents "github.com/cloudevents/sdk-go/v2"
		"github.com/sethvargo/go-signalcontext"
	)

	func main() {
		cli, err := cloudevents.NewDefaultClient()
		if err != nil {
			log.Panicf("Unable to create CloudEvents client: %s", err)
		}

		h := NewHandler(cli)

		log.Print("Running CloudEvents handler")

		ctx, cancel := signalcontext.OnInterrupt()
		defer cancel()

		if err := h.Run(ctx); err != nil {
			log.Panicf("Failure during runtime of CloudEvents handler: %s", err)
		}
	}

	const (
		eventTypeAck = "com.example.target.ack"

		eventSrcName = "io.demo.targets.go-sample"

		ceExtProcessedType   = "processedtype"

	)

	// Handler runs a CloudEvents receiver.
	type Handler struct {
		cli cloudevents.Client
	}

	// NewHandler returns a new Handler for the given CloudEvents client.
	func NewHandler(c cloudevents.Client) *Handler {
		rand.Seed(time.Now().UnixNano())

		return &Handler{
			cli: c,
		}
	}

	// Run starts the handler and blocks until it returns.
	func (h *Handler) Run(ctx context.Context) error {
		return h.cli.StartReceiver(ctx, h.receive)
	}

	// ACKResponse represents the data of a CloudEvent payload returned to
	// acknowledge the processing of an event.
	type ACKResponse struct {
		Code   ACKCode     `json:"code"`
		Detail interface{} `json:"detail"`
	}

	// ACKCode defines the outcome of the processing of an event.
	type ACKCode int

	// Enum of supported ACK codes.
	const (
		CodeSuccess ACKCode = iota
		CodeFailure
	)

	// receive implements the handler's receive logic.
	func (h *Handler) receive(e cloudevents.Event) (*cloudevents.Event, cloudevents.Result) {
		code := CodeSuccess
		ceResult := cloudevents.ResultACK

		result, err := processEvent(e)
		// this error handling is for demo purposes only, since processEvent()
		// always succeeds
		if err != nil {
			code = CodeFailure
			ceResult = cloudevents.ResultNACK
		}

		return newAckEvent(e, code, result), ceResult
	}

	// processEvent processes the event and returns the result of the processing.
	func processEvent(e cloudevents.Event) (interface{} /*result*/, error) {
		tBegin := time.Now()

		// simulate processing time
		randomDelay()

		res := &exampleResult{
			Message:        "event processed successfully",
			ProcessingTime: time.Since(tBegin).Milliseconds(),
		}

		return res, nil
	}

	// exampleResult represents a fictional structured result of some event
	// processing.
	type exampleResult struct {
		Message        string `json:"message"`
		ProcessingTime int64  `json:"processing_time_ms"`
	}

	// newAckEvent returns a CloudEvent that acknowledges the processing of an
	// event.
	func newAckEvent(e cloudevents.Event, code ACKCode, detail interface{}) *cloudevents.Event {
		resp := cloudevents.NewEvent()
		resp.SetType(eventTypeAck)
		resp.SetSource(eventSrcName)
		resp.SetExtension(ceExtProcessedType, e.Type())

		data := &ACKResponse{
			Code:   code,
			Detail: detail,
		}

		if err := resp.SetData(cloudevents.ApplicationJSON, data); err != nil {
			log.Panicf("Error serializing CloudEvent data: %s", err)
		}

		return &resp
	}

	// randomDelay sleeps for a random amount of time.
	func randomDelay() {
		const maxDelay = 100 * time.Millisecond

		randomDelay := time.Duration(rand.Int63n(int64(maxDelay)))
		time.Sleep(randomDelay)
	}

	```

1. Create the `go.mod` file, then run the following commands:

	```
	go mod init
	go mod tidy
	```

1. Create a new file `Dockerfile` in the same folder:

    ```dockerfile
    FROM golang:1.15-buster AS builder
    ENV CGO_ENABLED 0
    WORKDIR /project
    COPY . ./
    RUN go build
    FROM gcr.io/distroless/static:nonroot
    COPY --from=builder /project/demosink /
    ENTRYPOINT ["/demosink"]
    ```

1. Run the application locally to debug:

	```sh
	go run .
	```

1. Send it an event and verify the expected results:

	```sh
	curl -v "http://localhost:8080" \
	       -X POST \
	       -H "Ce-Id: 536808d3-88be-4077-9d7a-a3f162705f79" \
	       -H "Ce-Specversion: 1.0" \
	       -H "Ce-Type: io.demo.email.send" \
	       -H "Ce-Source: dev.knative.samples/demo" \
	       -H "Content-Type: application/json" \
	       -d '{"fromName":"richard","toName":"bob","message":"hello"}'
	* upload completely sent off: 55 out of 55 bytes
	< HTTP/1.1 200 OK
	< Ce-Id: 70eb24d9-3678-4c08-9332-315cbae7fe1e
	< Ce-Processedid: 536808d3-88be-4077-9d7a-a3f162705f79
	< Ce-Processedsource: dev.knative.samples/demo
	< Ce-Processedtype: io.demo.email.send
	< Ce-Source: io.demo.targets.go-sample
	< Ce-Specversion: 1.0
	< Ce-Time: 2021-09-08T19:40:37.1619Z
	< Ce-Type: com.example.target.ack
	< Content-Length: 98
	< Content-Type: application/json
	< Date: Wed, 08 Sep 2021 19:40:37 GMT
	<
	* Connection #0 to host localhost left intact
	{"code":0,"detail":{"message":"Hello richard! Thank you for the message!","processing_time_ms":0}}* Closing connection 0
	```


1. When you are ready to deploy, build and publish the container image:

	```sh
	docker build -t <user-name>/<image-name> .
	docker push <user-name>/<image-name>
	```

1. Create a manifest.yaml file:

	```yaml
	apiVersion: serving.knative.dev/v1
	kind: Service
	metadata:
	 name: demo-service
	spec:
	 template:
	  spec:
	   containers:
	    - image: <image-name>
	```

1. Apply this manifest:

	```sh
	kubectl apply -f manifest.yaml
	```

1. Verify that the service is running:

	```sh
	kubectl get ksvc
	NAME          URL                                            LATESTCREATED         LATESTREADY            READY   REASON
	demo-service  http://demo-service.dmo.10.64.140.43.xip.io    demo-service-00001     demo-service-00001     True
	```

1. Send it a Cloudevent to trigger the service and verify the expected results:

	```sh
	curl -v "http://demo-service.dmo.10.64.140.43.xip.io " \
	       -X POST \
	       -H "Ce-Id: 536808d3-88be-4077-9d7a-a3f162705f79" \
	       -H "Ce-Specversion: 1.0" \
	       -H "Ce-Type: io.demo.test.event" \
	       -H "Ce-Source: dev.knative.samples/demo" \
	       -H "Content-Type: application/json" \
	       -d '{"test":"data"}'
	* upload completely sent off: 15 out of 15 bytes
	< HTTP/1.1 200 OK
	< Ce-Id: 0086d811-c609-4619-beb3-66965f9a1e64
	< Ce-Processedid: 536808d3-88be-4077-9d7a-a3f162705f79
	< Ce-Processedsource: dev.knative.samples/demo
	< Ce-Processedtype: io.demo.test.event
	< Ce-Source: io.demo.targets.go-sample
	< Ce-Specversion: 1.0
	< Ce-Time: 2021-09-08T19:00:16.291182Z
	< Ce-Type: com.example.target.ack
	< Content-Length: 86
	< Content-Type: application/json
	< Date: Wed, 08 Sep 2021 19:00:16 GMT
	<
	* Connection #0 to host localhost left intact
	{"code":0,"detail":{"message":"event processed successfully","processing_time_ms":32}}* Closing connection 0
	```


## Processing an event containing a structured payload

Consider this example Cloudevent for the purpose of this demo:

```sh
curl -v "https://dce.demo-sink.dev.demo.io" \
       -X POST \
       -H "Ce-Id: 536808d3-88be-4077-9d7a-a3f162705f79" \
       -H "Ce-Specversion: 1.0" \
       -H "Ce-Type: io.demo.email.send" \
       -H "Ce-Source: dev.knative.samples/demo" \
       -H "Content-Type: application/json" \
       -d '{"fromName":"richard","toName":"bob","message":"hello"}'
```

1. Update the main.go file to include this struct. The `EventData` struct
will be used to unmarshal the Cloudevent payload specified in the Cloudevent above.

	```go
	type EventData struct {
		Fromname string `json:"fromName"`
		Toname   string `json:"toName"`
		Message  string `json:"message"`
	}
	```

1. Update the `processEvent()` function found in the `main.go` file.

	```go
	// processEvent processes the event and returns the result of the processing.
	func processEvent(e cloudevents.Event) (interface{} /*result*/, error) {
		tBegin := time.Now()
		// Create our new struct to hold the event data.
		ed := &EventData{}
		// Unmarshal the event data into our struct.
		if err := e.DataAs(ed); err != nil {
			return nil, err
		}

		// Do something with the event data.
		log.Printf("Received event with message of : %+v\n", ed.Message)
		newMessage := "Hello " + ed.Fromname + "! Thank you for the message!"

		res := &exampleResult{
			Message:        newMessage,
			ProcessingTime: time.Since(tBegin).Milliseconds(),
		}
		return res, nil
	}
	```

1. Remove the `randomDelay()` function as it is no longer needed.

1. Run the application locally or build an image and deploy, as described above.

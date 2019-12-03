package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	cloudevents "github.com/cloudevents/sdk-go"
	"github.com/kelseyhightower/envconfig"
)

type Receiver struct {
	client cloudevents.Client

	// If the K_SINK environment variable is set, then events are sent there,
	// otherwise we simply reply to the inbound request.
	Target string `envconfig:"K_SINK"`
}

func main() {
	client, err := cloudevents.NewDefaultClient()
	if err != nil {
		log.Fatal(err.Error())
	}

	r := Receiver{client: client}
	if err := envconfig.Process("", &r); err != nil {
		log.Fatal(err.Error())
	}

	// Depending on whether targeting data has been supplied,
	// we will either reply with our response or send it on to
	// an event sink.
	var receiver interface{} // the SDK reflects on the signature.
	if r.Target == "" {
		receiver = r.ReceiveAndReply
	} else {
		receiver = r.ReceiveAndSend
	}

	if err := client.StartReceiver(context.Background(), receiver); err != nil {
		log.Fatal(err)
	}
}

// Request is the structure of the event we expect to receive.
type Request struct {
	Name string `json:"name"`
}

// Response is the structure of the event we send in response to requests.
type Response struct {
	Message string `json:"message,omitempty"`
}

// handle shared the logic for producing the Response event from the Request.
func handle(req Request) (resp Response) {
	resp.Message = fmt.Sprintf("Hello, %s", req.Name)
	return
}

// ReceiveAndSend is invoked whenever we receive an event.
func (recv *Receiver) ReceiveAndSend(ctx context.Context, event cloudevents.Event) error {
	req := Request{}
	if err := event.DataAs(&req); err != nil {
		return err
	}
	log.Printf("Got an event from: %q", req.Name)

	resp := handle(req)
	log.Printf("Sending event: %q", resp.Message)

	r := cloudevents.NewEvent(cloudevents.VersionV1)
	r.SetType("dev.knative.docs.sample")
	r.SetSource("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-go")
	r.SetDataContentType("application/json")
	r.SetData(resp)

	ctx = cloudevents.ContextWithTarget(ctx, recv.Target)
	_, _, err := recv.client.Send(ctx, r)
	return err
}

// ReceiveAndReply is invoked whenever we receive an event.
func (recv *Receiver) ReceiveAndReply(ctx context.Context, event cloudevents.Event, eventResp *cloudevents.EventResponse) error {
	req := Request{}
	if err := event.DataAs(&req); err != nil {
		return err
	}
	log.Printf("Got an event from: %q", req.Name)

	resp := handle(req)
	log.Printf("Replying with event: %q", resp.Message)

	r := cloudevents.NewEvent(cloudevents.VersionV1)
	r.SetType("dev.knative.docs.sample")
	r.SetSource("https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-go")
	r.SetDataContentType("application/json")
	r.SetData(resp)

	eventResp.RespondWith(http.StatusOK, &r)

	return nil
}

package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	cloudevents "github.com/cloudevents/sdk-go"
	"github.com/google/uuid"
)

type eventData struct {
	Message string `json:"message,omitempty,string"`
}

func receive(ctx context.Context, event cloudevents.Event, response *cloudevents.EventResponse) error {
	// Here is where your code to process the event will go.
	// In this example we will log the event msg
	log.Printf("Event received. Context: %v\n", event.Context)
	data := &HelloWorld{}
	if err := event.DataAs(data); err != nil {
		log.Printf("Error while extracting cloudevent Data: %s\n", err.Error())
		return err
	}
	log.Printf("Hello World Message from received event %q", data.Msg)

	// Respond with another event (optional)
	// This is optional and is intended to show how to respond back with another event after processing.
	// The response will go back into the knative eventing system just like any other event
	newEvent := cloudevents.NewEvent()
	newEvent.SetID(uuid.New().String())
	newEvent.SetSource("knative/eventing/samples/hello-world")
	newEvent.SetType("dev.knative.samples.hifromknative")
	newEvent.SetData(HiFromKnative{Msg: "Hi from helloworld-go app!"})
	response.RespondWith(200, &newEvent)

	log.Printf("Responded with event %v", newEvent)

	return nil
}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Print("Hello world received a request.")
	target := os.Getenv("TARGET")
	if target == "" {
		target = "World"
	}
	fmt.Fprintf(w, "Hello %s!\n", target)
}

func main() {
	log.Print("Hello world sample started.")
	c, err := cloudevents.NewDefaultClient()
	if err != nil {
		log.Fatalf("failed to create client, %v", err)
	}
	log.Fatal(c.StartReceiver(context.Background(), receive))
}

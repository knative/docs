/*
Copyright 2019 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"context"
	"log"
	"os"

	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/cloudevents/sdk-go/v2/event"
	"github.com/cloudevents/sdk-go/v2/protocol"
	"github.com/cloudevents/sdk-go/v2/protocol/http"
	"github.com/kelseyhightower/envconfig"
)

/*
Small function that demonstrates two concepts:

1. Deserializing / Serializing data
2. Using direct reply to modify incoming events (decorating in this example)

Incoming data is assumbed to be CloudEventBaseData with two fields
 Sequence int
 Message string

This function appends env[MESSAGE] to the Message portion of the data.
It is used by the samples in the Knative sequence section:
https://knative.dev/docs/eventing/sequence/
*/

type envConfig struct {
	Msg  string `envconfig:"MESSAGE" default:"boring default msg, change me with env[MESSAGE]"`
	Type string `envconfig:"TYPE"`
}

var (
	env envConfig
)

// Define a small struct representing the data for our expected data.
type payload struct {
	Sequence int    `json:"id"`
	Message  string `json:"message"`
}

func gotEvent(inputEvent event.Event) (*event.Event, protocol.Result) {
	data := &payload{}
	if err := inputEvent.DataAs(data); err != nil {
		log.Printf("Got error while unmarshalling data: %s", err.Error())
		return nil, http.NewResult(400, "got error while unmarshalling data: %w", err)
	}

	log.Println("Received a new event: ")
	log.Printf("[%v] %s %s: %+v", inputEvent.Time(), inputEvent.Source(), inputEvent.Type(), data)

	// append eventMsgAppender to message of the data
	data.Message = data.Message + env.Msg

	// Create output event
	outputEvent := inputEvent.Clone()

	if err := outputEvent.SetData(cloudevents.ApplicationJSON, data); err != nil {
		log.Printf("Got error while marshalling data: %s", err.Error())
		return nil, http.NewResult(500, "got error while marshalling data: %w", err)
	}

	// Resolve type
	if env.Type != "" {
		outputEvent.SetType(env.Type)
	}

	log.Println("Transform the event to: ")
	log.Printf("[%s] %s %s: %+v", outputEvent.Time(), outputEvent.Source(), outputEvent.Type(), data)

	return &outputEvent, nil
}

func main() {
	if err := envconfig.Process("", &env); err != nil {
		log.Printf("[ERROR] Failed to process env var: %s", err)
		os.Exit(1)
	}

	c, err := cloudevents.NewDefaultClient()
	if err != nil {
		log.Fatalf("failed to create client, %v", err)
	}

	log.Printf("listening on 8080, appending %q to events", env.Msg)
	log.Fatalf("failed to start receiver: %s", c.StartReceiver(context.Background(), gotEvent))
}

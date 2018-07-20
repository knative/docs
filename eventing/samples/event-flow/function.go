/*
Copyright 2018 The Knative Authors

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
	"encoding/base64"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

// Event represents PubSub payload
type Event struct {
	ID         string            `json:"ID"`
	Data       string            `json:"Data"`
	Attributes map[string]string `json:"Attributes"`
}

// EventPayload represents PubSub Data payload
type EventPayload struct {
	ID       string `json:"event_id"`
	SourceID string `json:"source_id"`
	SentOn   int    `json:"event_ts"`
	Metric   int    `json:"metric"`
}

func handlePost(rw http.ResponseWriter, req *http.Request) {

	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		panic(err)
	}
	//log.Println(string(body))

	// decode the pubsub message
	//	var event map[string]string
	var event Event
	if err := json.Unmarshal(body, &event); err != nil {
		log.Printf("Failed to unmarshal event: %s", err)
		return
	}

	// decode pubsub payload
	rawEvent, _ := base64.StdEncoding.DecodeString(event.Data)

	// decode iot data
	data, _ := base64.StdEncoding.DecodeString(string(rawEvent))

	// decode the pubsub message payload
	var payload EventPayload
	if err := json.Unmarshal(data, &payload); err != nil {
		log.Printf("Failed to unmarshal payload: %s", err)
		return
	}

	log.Printf("Data sent by device %q: [metric: %d, on: %v]",
		event.Attributes["deviceId"], payload.Metric, payload.SentOn)
}

func main() {
	http.HandleFunc("/", handlePost)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

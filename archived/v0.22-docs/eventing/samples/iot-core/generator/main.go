/*
Copyright 2018 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"time"

	MQTT "github.com/eclipse/paho.mqtt.golang"
	jwt "github.com/form3tech-oss/jwt-go"
	uuid "github.com/google/uuid"
)

const (
	host     = "mqtt.googleapis.com"
	port     = "8883"
	idPrefix = "eid"
)

var (
	deviceID   = flag.String("device", "", "Cloud IoT Core Device ID")
	projectID  = flag.String("project", "", "GCP Project ID")
	registryID = flag.String("registry", "", "Cloud IoT Registry ID (short form)")
	region     = flag.String("region", "us-central1", "GCP Region")
	numEvents  = flag.Int("events", 10, "Number of events to sent")
	eventSrc   = flag.String("src", "", "Event source")
	certsCA    = flag.String("ca", "root-ca.pem", "Download https://pki.google.com/roots.pem")
	privateKey = flag.String("key", "", "Path to private key file")
)

func main() {
	flag.Parse()

	log.Println("Loading Google's roots...")
	certpool := x509.NewCertPool()
	pemCerts, err := ioutil.ReadFile(*certsCA)
	if err == nil {
		certpool.AppendCertsFromPEM(pemCerts)
	}

	config := &tls.Config{
		RootCAs:            certpool,
		ClientAuth:         tls.NoClientCert,
		ClientCAs:          nil,
		InsecureSkipVerify: true,
		Certificates:       []tls.Certificate{},
		MinVersion:         tls.VersionTLS12,
	}

	clientID := fmt.Sprintf("projects/%v/locations/%v/registries/%v/devices/%v",
		*projectID,
		*region,
		*registryID,
		*deviceID,
	)

	log.Println("Creating MQTT client options...")
	opts := MQTT.NewClientOptions()

	broker := fmt.Sprintf("ssl://%v:%v", host, port)
	log.Printf("Broker '%v'", broker)

	opts.AddBroker(broker)
	opts.SetClientID(clientID).SetTLSConfig(config)
	opts.SetUsername("unused")

	token := jwt.New(jwt.SigningMethodRS256)
	token.Claims = jwt.StandardClaims{
		Audience:  []string{*projectID},
		IssuedAt:  time.Now().Unix(),
		ExpiresAt: time.Now().Add(24 * time.Hour).Unix(),
	}

	log.Println("Loading private key...")
	keyBytes, err := ioutil.ReadFile(*privateKey)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Parsing private key...")
	key, err := jwt.ParseRSAPrivateKeyFromPEM(keyBytes)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Signing token")
	tokenString, err := token.SignedString(key)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Setting password...")
	opts.SetPassword(tokenString)

	opts.SetDefaultPublishHandler(func(client MQTT.Client, msg MQTT.Message) {
		fmt.Printf("[handler] Topic: %v\n", msg.Topic())
		fmt.Printf("[handler] Payload: %v\n", msg.Payload())
	})

	log.Println("Connecting...")
	client := MQTT.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		log.Fatal(token.Error())
	}

	topic := fmt.Sprintf("/devices/%s/events", *deviceID)
	log.Println("Publishing messages...")
	for i := 0; i < *numEvents; i++ {
		data := makeEvent()
		log.Printf("Publishing to topic '%s': %v", topic, data)
		token := client.Publish(
			topic,
			0,
			false,
			data)
		token.WaitTimeout(5 * time.Second)
		if token.Error() != nil {
			log.Printf("Error publishing: %s", token.Error())
		}
	}

	log.Println("Disconnecting...")
	client.Disconnect(250)

	log.Println("Done")
}

func makeEvent() string {

	s1 := rand.NewSource(time.Now().UnixNano())
	r1 := rand.New(s1)

	event := struct {
		SourceID string  `json:"source_id"`
		EventID  string  `json:"event_id"`
		EventTs  int64   `json:"event_ts"`
		Metric   float32 `json:"metric"`
	}{
		SourceID: *eventSrc,
		EventID:  fmt.Sprintf("%s-%s", idPrefix, uuid.New().String()),
		EventTs:  time.Now().UTC().Unix(),
		Metric:   r1.Float32(),
	}

	data, _ := json.Marshal(event)

	return string(data)

}

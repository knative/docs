/*
Copyright 2020 The Knative Authors

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
	"fmt"
	"io"
	"log"
	"net/http"
	"time"
)

var sidecarClient = &http.Client{Timeout: 5 * time.Second}

func handler(w http.ResponseWriter, r *http.Request) {
	log.Println("serving container received a request.")
	res, err := sidecarClient.Get("http://127.0.0.1:8882")
	if err != nil {
		http.Error(w, "sidecar unavailable", http.StatusBadGateway)
		return
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		http.Error(w, "sidecar returned an error", http.StatusBadGateway)
		return
	}
	resp, err := io.ReadAll(res.Body)
	if err != nil {
		http.Error(w, "unable to read sidecar response", http.StatusBadGateway)
		return
	}
	fmt.Fprint(w, string(resp))
}

func main() {
	log.Print("serving container started...")
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(":8881", nil))
}

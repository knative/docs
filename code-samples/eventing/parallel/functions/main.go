// Copyright 2026 The Knative Authors
// SPDX-License-Identifier: Apache-2.0

// The Parallel sample helpers use explicit operations, not evaluated expressions.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/cloudevents/sdk-go/v2/binding"
	cehttp "github.com/cloudevents/sdk-go/v2/protocol/http"
)

const maxEventBytes = 1 << 20

// Match Math.round(Date.parse(time)/60000)%2: millisecond precision,
// ties toward +infinity, and signed remainder (including before 1970).
func roundedRemainder(timestamp time.Time) int64 {
	n := timestamp.UnixMilli() + 30000
	minutes := n / 60000
	if n < 0 && n%60000 != 0 {
		minutes-- // Go division truncates toward zero; Math.floor does not.
	}
	return minutes % 2
}

func newHandler(logger *log.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/healthz" {
			w.WriteHeader(http.StatusOK)
			return
		}
		operation := r.URL.Path
		switch operation {
		case "/filter/even", "/filter/odd", "/switch/0", "/switch/1", "/transform/even", "/transform/odd":
		default:
			http.NotFound(w, r)
			return
		}
		if r.Method != http.MethodPost {
			w.Header().Set("Allow", http.MethodPost)
			http.Error(w, "use POST", http.StatusMethodNotAllowed)
			return
		}

		r.Body = http.MaxBytesReader(w, r.Body, maxEventBytes)
		message := cehttp.NewMessageFromHttpRequest(r)
		defer message.Finish(nil)
		event, err := binding.ToEvent(r.Context(), message)
		if err != nil || event.SpecVersion() != "1.0" || event.Validate() != nil {
			http.Error(w, "invalid CloudEvents 1.0 event", http.StatusBadRequest)
			return
		}

		matched := true
		if strings.HasPrefix(operation, "/transform/") {
			text := "we are even!"
			if operation == "/transform/odd" {
				text = "this is odd!"
			}
			if err := event.SetData("application/json", map[string]string{"message": text}); err != nil {
				http.Error(w, "cannot encode transformed event", http.StatusInternalServerError)
				return
			}
		} else {
			if event.Context.AsV1().Time == nil {
				http.Error(w, "missing CloudEvent time", http.StatusBadRequest)
				return
			}
			parity := roundedRemainder(event.Time())
			switch operation {
			case "/filter/even", "/switch/0":
				matched = parity == 0
			case "/filter/odd":
				matched = parity != 0
			case "/switch/1":
				matched = parity == 1
			}
		}
		record, _ := json.Marshal(map[string]any{"path": operation, "id": event.ID(), "matched": matched})
		logger.Print(string(record))
		if !matched {
			// An empty successful response stops this branch, without a reply event.
			w.WriteHeader(http.StatusOK)
			return
		}

		ctx := binding.WithForceBinary(r.Context())
		if message.ReadEncoding() == binding.EncodingStructured {
			ctx = binding.WithForceStructured(r.Context())
		}
		if err := cehttp.WriteResponseWriter(ctx, binding.ToMessage(event), http.StatusOK, w); err != nil {
			logger.Printf("cannot write reply: %v", err)
		}
	})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	logger := log.New(os.Stdout, "", 0)
	server := &http.Server{Addr: ":" + port, Handler: newHandler(logger), ReadHeaderTimeout: 5 * time.Second}
	logger.Printf("listening on %s", server.Addr)
	logger.Fatal(server.ListenAndServe())
}

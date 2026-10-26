// This local test sink captures real sample output, never substitutes for the app.
package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		defer r.Body.Close()
		body, err := io.ReadAll(io.LimitReader(r.Body, 1<<20))
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		event := struct {
			Headers http.Header     `json:"headers"`
			Body    json.RawMessage `json:"body"`
		}{Headers: r.Header, Body: json.RawMessage(body)}
		if err := json.NewEncoder(log.Writer()).Encode(event); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		if r.URL.Path == "/fail" {
			w.WriteHeader(http.StatusServiceUnavailable)
		} else {
			w.WriteHeader(http.StatusNoContent)
		}
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}

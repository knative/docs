// Copyright 2026 The Knative Authors
// SPDX-License-Identifier: Apache-2.0

// A local GitHub API fixture for ci.sh; it never contacts github.com.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
)

type pullRequest struct {
	Title string `json:"title"`
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("PATCH /repos/{owner}/{repo}/pulls/{number}", func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer ci-token" {
			http.Error(w, "invalid token", http.StatusUnauthorized)
			return
		}

		number, err := strconv.ParseInt(r.PathValue("number"), 10, 64)
		if err != nil || number < 1 {
			http.Error(w, "invalid pull request number", http.StatusBadRequest)
			return
		}

		var body pullRequest
		r.Body = http.MaxBytesReader(w, r.Body, 1<<20)
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil || body.Title == "" {
			http.Error(w, "invalid pull request", http.StatusBadRequest)
			return
		}

		// Record the request so ci.sh can assert that the sample updated the title.
		record := struct {
			Path string      `json:"path"`
			Body pullRequest `json:"body"`
		}{Path: r.URL.Path, Body: body}
		if err := json.NewEncoder(os.Stdout).Encode(record); err != nil {
			http.Error(w, "cannot record request", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]any{"number": number, "title": body.Title})
	})

	server := &http.Server{Addr: ":8080", Handler: mux, ReadHeaderTimeout: 5 * time.Second}
	log.Fatal(server.ListenAndServe())
}

package main

import (
	"bytes"
	"fmt"
	"log"
	"net/http"
	"os"
)

func envOrDefault(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

func secretHandler(path string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Reopen the file on every request so projected Secret updates are seen.
		// Never include file contents, paths or underlying errors in the response.
		value, err := os.ReadFile(path)
		if err != nil {
			http.Error(w, "Secret file unavailable.", http.StatusServiceUnavailable)
			return
		}
		if len(bytes.TrimSpace(value)) == 0 {
			http.Error(w, "Secret file is empty.", http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		fmt.Fprintln(w, "Secret file loaded.")
	}
}

func main() {
	path := envOrDefault("SECRET_FILE", "/var/secret/message")
	port := envOrDefault("PORT", "8080")
	log.Print("Mounted Secret sample started.")
	log.Fatal(http.ListenAndServe(":"+port, secretHandler(path)))
}

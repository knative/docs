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
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/gomodule/redigo/redis"
)

const (
	redisPort = 6379
)

var (
	indexTemplate = template.Must(template.ParseFiles("template.html"))

	pool *redis.Pool
)

// handler displays a form for new posts and shows a list of current posts.
func handler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	ctx := r.Context()

	conn, err := pool.GetContext(ctx)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer conn.Close()

	// If name and message are non-empty, set name=message in Redis.
	if r.Method == "POST" {
		name := r.FormValue("name")
		message := r.FormValue("message")

		if name == "" || message == "" {
			http.Error(w, "name and message should both be non-empty", http.StatusBadRequest)
			return
		}

		if _, err := redis.String(conn.Do("SET", name, message)); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	}

	// Get all keys (names) from Redis.
	keys, err := redis.Strings(conn.Do("KEYS", "*"))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Get the message associated with each name.
	params := make(map[string]string)
	for _, key := range keys {
		value, err := redis.String(conn.Do("GET", key))
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		params[key] = value
	}

	indexTemplate.Execute(w, params)
}

func main() {
	redisHost := os.Getenv("REDIS_HOST")
	if redisHost == "" {
		log.Fatal("Environment variable REDIS_HOST is unset.")
	}

	addr := fmt.Sprintf("%s:%d", redisHost, redisPort)
	pool = &redis.Pool{
		Dial: func() (redis.Conn, error) {
			return redis.Dial("tcp", addr)
		},
	}

	log.Print("Guestbook sample started.")
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}

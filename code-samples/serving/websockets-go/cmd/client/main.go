// Copyright 2026 The Knative Authors
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/websocket"
)

func main() {
	url := flag.String("url", "ws://127.0.0.1:8080/ws", "WebSocket server URL")
	host := flag.String("host", "", "Optional Host header for Knative routing")
	flag.Parse()

	if err := checkEcho(*url, *host); err != nil {
		log.Fatal(err)
	}
	fmt.Println("WebSocket echo checks passed")
}

func checkEcho(url, host string) error {
	headers := http.Header{}
	if host != "" {
		headers.Set("Host", host)
	}
	dialer := websocket.Dialer{HandshakeTimeout: 30 * time.Second}
	connection, _, err := dialer.Dial(url, headers)
	if err != nil {
		return fmt.Errorf("connect: %w", err)
	}
	defer connection.Close()

	deadline := time.Now().Add(30 * time.Second)
	if err := connection.SetReadDeadline(deadline); err != nil {
		return err
	}
	if err := connection.SetWriteDeadline(deadline); err != nil {
		return err
	}

	for _, message := range []struct {
		kind int
		body string
	}{
		{websocket.TextMessage, "Hello through Knative WebSockets"},
		{websocket.BinaryMessage, "binary smoke test"},
	} {
		if err := connection.WriteMessage(message.kind, []byte(message.body)); err != nil {
			return fmt.Errorf("send: %w", err)
		}
		kind, body, err := connection.ReadMessage()
		if err != nil {
			return fmt.Errorf("receive: %w", err)
		}
		if kind != message.kind || string(body) != message.body {
			return fmt.Errorf("unexpected echo: type=%d body=%q", kind, body)
		}
	}
	return nil
}

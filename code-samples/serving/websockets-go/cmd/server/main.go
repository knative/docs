package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
	"github.com/knative/docs/code-samples/serving/websockets-go/pkg/handlers"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Error upgrading to websocket: %v", err)
		return
	}
	handlers.OnOpen(conn)

	go func() {
		defer handlers.OnClose(conn)
		for {
			messageType, message, err := conn.ReadMessage()
			if err != nil {
				handlers.OnError(conn, err)
				break
			}
			handlers.OnMessage(conn, messageType, message)
		}
	}()
}

func main() {
	http.HandleFunc("/ws", handleWebSocket)
	fmt.Println("Starting server on :8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server error: %v", err)
	}
}

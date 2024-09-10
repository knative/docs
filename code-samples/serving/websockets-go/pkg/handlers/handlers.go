package handlers

import (
	"log"

	"github.com/gorilla/websocket"
)

func OnOpen(conn *websocket.Conn) {
	log.Printf("WebSocket connection opened: %v", conn.RemoteAddr())
}

func OnMessage(conn *websocket.Conn, messageType int, message []byte) {
	log.Printf("Received message from %v: %s", conn.RemoteAddr(), string(message))

	if err := conn.WriteMessage(messageType, message); err != nil {
		log.Printf("Error sending message: %v", err)
	}
}

func OnClose(conn *websocket.Conn) {
	log.Printf("WebSocket connection closed: %v", conn.RemoteAddr())
	conn.Close()
}

func OnError(conn *websocket.Conn, err error) {
	log.Printf("WebSocket error from %v: %v", conn.RemoteAddr(), err)
}

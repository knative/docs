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

package event

import (
	"context"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"reflect"
	"time"
)

const (
	// CloudEventsVersion is the version of the CloudEvents spec targeted
	// by this library.
	CloudEventsVersion = "0.1"

	// ContentTypeStructuredJSON is the content-type for "Structured" encoding
	// where an event envelope is written in JSON and the body is arbitrary
	// data which might be an alternate encoding.
	ContentTypeStructuredJSON = "application/cloudevents+json"

	// ContentTypeBinaryJSON is the content-type for "Binary" encoding where
	// the event context is in HTTP headers and the body is a JSON event data.
	ContentTypeBinaryJSON = "application/json"

	// TODO(inlined) what about charset additions?
	contentTypeJSON = "application/json"
	contentTypeXML  = "application/xml"

	// HeaderContentType is the standard HTTP header "Content-Type"
	HeaderContentType = "Content-Type"

	fieldCloudEventsVersion = "CloudEventsVersion"
	fieldEventID            = "EventID"
	fieldEventType          = "EventType"
	fieldEventTime          = "EventTime"
	fieldSource             = "Source"
)

// EventContext holds standard metadata about an event. See
// https://github.com/cloudevents/spec/blob/v0.1/spec.md#context-attributes for
// details on these fields.
type EventContext struct {
	// The version of the CloudEvents specification used by the event.
	CloudEventsVersion string `json:"cloudEventsVersion,omitempty"`
	// ID of the event; must be non-empty and unique within the scope of the producer.
	EventID string `json:"eventID"`
	// Timestamp when the event happened.
	EventTime time.Time `json:"eventTime,omitempty"`
	// Type of occurrence which has happened.
	EventType string `json:"eventType"`
	// The version of the `eventType`; this is producer-specific.
	EventTypeVersion string `json:"eventTypeVersion,omitempty"`
	// A link to the schema that the `data` attribute adheres to.
	SchemaURL string `json:"schemaURL,omitempty"`
	// A MIME (RFC 2046) string describing the media type of `data`.
	// TODO: Should an empty string assume `application/json`, or auto-detect the content?
	ContentType string `json:"contentType,omitempty"`
	// A URI describing the event producer.
	Source string `json:"source"`
	// Additional metadata without a well-defined structure.
	Extensions map[string]interface{} `json:"extensions,omitempty"`
}

// HTTPMarshaller implements a scheme for decoding CloudEvents over HTTP.
// Implementations are Binary, Structured, and Any
type HTTPMarshaller interface {
	FromRequest(data interface{}, r *http.Request) (*EventContext, error)
	NewRequest(urlString string, data interface{}, context EventContext) (*http.Request, error)
}

func anyError(errs ...error) error {
	for _, err := range errs {
		if err != nil {
			return err
		}
	}
	return nil
}

func ensureRequiredFields(context EventContext) error {
	return anyError(
		require(fieldEventID, context.EventID),
		require(fieldEventType, context.EventType),
		require(fieldSource, context.Source))
}

func require(name string, value string) error {
	if len(value) == 0 {
		return fmt.Errorf("missing required field %q", name)
	}
	return nil
}

// The Cloud-Events spec allows two forms of JSON encoding:
// 1. The overall message (Structured JSON encoding)
// 2. Just the event data, where the context will be in HTTP headers instead
//
// Case #1 actually includes case #2. In structured binary encoding the JSON
// HTTP body itself allows for cross-encoding of the "data" field.
// This method is only intended for checking that inner JSON encoding type.
func isJSONEncoding(encoding string) bool {
	return encoding == contentTypeJSON || encoding == "text/json"
}

func isXMLEncoding(encoding string) bool {
	return encoding == contentTypeXML || encoding == "text/xml"
}

func unmarshalEventData(encoding string, reader io.Reader, data interface{}) error {
	// The Handler tools allow developers to not ask for event data;
	// in this case, just don't unmarshal anything
	if data == nil {
		return nil
	}

	// If someone tried to marshal an event into an io.Reader, just assign our existing reader.
	// (This is used by event.Mux to determine which type to unmarshal as)
	readerPtrType := reflect.TypeOf((*io.Reader)(nil))
	if reflect.TypeOf(data).ConvertibleTo(readerPtrType) {
		reflect.ValueOf(data).Elem().Set(reflect.ValueOf(reader))
		return nil
	}
	if isJSONEncoding(encoding) || encoding == "" {
		return json.NewDecoder(reader).Decode(&data)
	}

	if isXMLEncoding(encoding) {
		return xml.NewDecoder(reader).Decode(&data)
	}

	return fmt.Errorf("Cannot decode content type %q", encoding)
}

func marshalEventData(encoding string, data interface{}) ([]byte, error) {
	var b []byte
	var err error

	if isJSONEncoding(encoding) {
		b, err = json.Marshal(data)
	} else if isXMLEncoding(encoding) {
		b, err = xml.Marshal(data)
	} else {
		err = fmt.Errorf("Cannot encode content type %q", encoding)
	}

	if err != nil {
		return nil, err
	}
	return b, nil
}

// FromRequest parses a CloudEvent from any known encoding.
func FromRequest(data interface{}, r *http.Request) (*EventContext, error) {
	switch r.Header.Get(HeaderContentType) {
	case ContentTypeStructuredJSON:
		return Structured.FromRequest(data, r)
	case ContentTypeBinaryJSON:
		return Binary.FromRequest(data, r)
	default:
		// TODO: assume binary content mode
		// (https://github.com/cloudevents/spec/blob/v0.1/http-transport-binding.md#3-http-message-mapping)
		// and that data is ??? (io.Reader?, byte array?)
		return nil, fmt.Errorf("Cannot handle encoding %q", r.Header.Get("Content-Type"))
	}
}

// NewRequest craetes an HTTP request for Structured content encoding.
func NewRequest(urlString string, data interface{}, context EventContext) (*http.Request, error) {
	return Structured.NewRequest(urlString, data, context)
}

// Opaque key type used to store EventContexts in a context.Context
type contextKeyType struct{}

var contextKey = contextKeyType{}

// FromContext loads an EventContext from a normal context.Context
func FromContext(ctx context.Context) *EventContext {
	return ctx.Value(contextKey).(*EventContext)
}

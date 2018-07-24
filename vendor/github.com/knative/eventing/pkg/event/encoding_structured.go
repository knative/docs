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
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
)

const (
	// Structured implements the JSON structured encoding/decoding
	Structured structured = 0
)

type structured int

type structuredEnvelope struct {
	EventContext
	RawData json.RawMessage `json:"data"`
}

// FromRequest parses a CloudEvent from structured content encoding.
func (structured) FromRequest(data interface{}, r *http.Request) (*EventContext, error) {
	var e structuredEnvelope
	if err := json.NewDecoder(r.Body).Decode(&e); err != nil {
		return nil, err
	}

	contentType := e.EventContext.ContentType
	if contentType == "" {
		contentType = contentTypeJSON
	}
	var reader io.Reader
	if !isJSONEncoding(contentType) {
		var jsonDecoded string
		if err := json.Unmarshal(e.RawData, &jsonDecoded); err != nil {
			return nil, fmt.Errorf("Could not JSON decode %q value %q", contentType, string(e.RawData))
		}
		reader = strings.NewReader(jsonDecoded)
	} else {
		reader = bytes.NewReader(e.RawData)
	}
	if e.EventContext.Extensions == nil {
		e.EventContext.Extensions = make(map[string]interface{}, 0)
	}
	if err := unmarshalEventData(contentType, reader, data); err != nil {
		return nil, err
	}
	return &e.EventContext, nil
}

// NewRequest creates an HTTP request for Structured content encoding.
func (structured) NewRequest(urlString string, data interface{}, context EventContext) (*http.Request, error) {
	url, err := url.Parse(urlString)
	if err != nil {
		return nil, err
	}

	if err := ensureRequiredFields(context); err != nil {
		return nil, err
	}

	contentType := context.ContentType
	if contentType == "" {
		contentType = contentTypeJSON
	}
	e := structuredEnvelope{
		EventContext: context,
	}
	dataBytes, err := marshalEventData(contentType, data)
	if err != nil {
		return nil, err
	}
	if isJSONEncoding(contentType) {
		e.RawData = json.RawMessage(dataBytes)
	} else {
		e.RawData, err = json.Marshal(string(dataBytes))
		if err != nil {
			return nil, err
		}
	}

	b, err := json.Marshal(e)
	if err != nil {
		return nil, err
	}

	h := http.Header{}
	h.Set(HeaderContentType, ContentTypeStructuredJSON)
	return &http.Request{
		Method: http.MethodPost,
		URL:    url,
		Header: h,
		Body:   ioutil.NopCloser(bytes.NewReader(b)),
	}, nil
}

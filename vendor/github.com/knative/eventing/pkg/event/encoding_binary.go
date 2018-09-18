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

// TODO(inlined): must add header encoding/decoding

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/golang/glog"
)

const (
	// HeaderCloudEventsVersion is the header for the version of Cloud Events
	// used.
	HeaderCloudEventsVersion = "CE-CloudEventsVersion"

	// HeaderEventID is the header for the unique ID of this event.
	HeaderEventID = "CE-EventID"

	// HeaderEventTime is the OPTIONAL header for the time at which an event
	// occurred.
	HeaderEventTime = "CE-EventTime"

	// HeaderEventType is the header for type of event represented. Value SHOULD
	// be in reverse-dns form.
	HeaderEventType = "CE-EventType"

	// HeaderEventTypeVersion is the OPTIONAL header for the version of the
	// scheme for the event type.
	HeaderEventTypeVersion = "CE-EventTypeVersion"

	// HeaderSchemaURL is the OPTIONAL header for the schema of the event data.
	HeaderSchemaURL = "CE-SchemaURL"

	// HeaderSource is the header for the source which emitted this event.
	HeaderSource = "CE-Source"

	// HeaderExtensions is the OPTIONAL header prefix for CloudEvents extensions
	headerExtensionsPrefix = "CE-X-"

	// Binary implements Binary encoding/decoding
	Binary binary = 0
)

type binary int

// FromRequest parses event data and context from an HTTP request.
func (binary) FromRequest(data interface{}, r *http.Request) (*EventContext, error) {
	var ctx EventContext
	err := anyError(
		getRequiredHeader(r.Header, HeaderEventID, &ctx.EventID),
		getRequiredHeader(r.Header, HeaderEventType, &ctx.EventType),
		getRequiredHeader(r.Header, HeaderSource, &ctx.Source),
		getRequiredHeader(r.Header, HeaderContentType, &ctx.ContentType))
	if err != nil {
		return nil, err
	}

	ctx.CloudEventsVersion = r.Header.Get(HeaderCloudEventsVersion)
	if timeStr := r.Header.Get(HeaderEventTime); timeStr != "" {
		if ctx.EventTime, err = time.Parse(time.RFC3339Nano, timeStr); err != nil {
			return nil, err
		}
	}
	ctx.EventTypeVersion = r.Header.Get(HeaderEventTypeVersion)
	ctx.SchemaURL = r.Header.Get(HeaderSchemaURL)
	if ctx.CloudEventsVersion != CloudEventsVersion {
		glog.Warningf("Received CloudEvent version %q; parsing as version %q",
			ctx.CloudEventsVersion, CloudEventsVersion)
	}

	ctx.Extensions = make(map[string]interface{})
	for k, v := range r.Header {
		if strings.ToUpper(k)[:len(headerExtensionsPrefix)] != headerExtensionsPrefix {
			continue
		}
		name := k[len(headerExtensionsPrefix):]
		var val interface{}
		if err := json.Unmarshal([]byte(v[0]), &val); err != nil {
			// If this is not a JSON object, treat it as a string.
			// It's not clear when we would treat this as Bytes.
			ctx.Extensions[name] = v[0]
		} else {
			ctx.Extensions[name] = val
		}
	}

	if err := unmarshalEventData(ctx.ContentType, r.Body, data); err != nil {
		return nil, err
	}

	return &ctx, nil
}

// NewRequest creates an HTTP request for Binary content encoding.
func (binary) NewRequest(urlString string, data interface{}, context EventContext) (*http.Request, error) {
	url, err := url.Parse(urlString)
	if err != nil {
		return nil, err
	}

	if err := ensureRequiredFields(context); err != nil {
		return nil, err
	}
	// Defaultable values:
	ceVersion := context.CloudEventsVersion
	if ceVersion == "" {
		ceVersion = CloudEventsVersion
	}
	contentType := context.ContentType
	if contentType == "" {
		contentType = contentTypeJSON
	}

	// non-string values:
	eventTime := ""
	if !context.EventTime.IsZero() {
		eventTime = context.EventTime.Format(time.RFC3339Nano)
	}

	h := http.Header{}
	setHeader(h, HeaderCloudEventsVersion, ceVersion)
	setHeader(h, HeaderEventID, context.EventID)
	setHeader(h, HeaderEventTime, eventTime)
	setHeader(h, HeaderEventType, context.EventType)
	setHeader(h, HeaderEventTypeVersion, context.EventTypeVersion)
	setHeader(h, HeaderSchemaURL, context.SchemaURL)
	setHeader(h, HeaderContentType, contentType)
	setHeader(h, HeaderSource, context.Source)
	for name, value := range context.Extensions {
		encoded, err := json.Marshal(value)
		if err != nil {
			return nil, err
		}
		h[headerExtensionsPrefix+name] = []string{
			string(encoded),
		}
	}

	b, err := marshalEventData(contentType, data)
	if err != nil {
		return nil, err
	}

	return &http.Request{
		Method: http.MethodPost,
		URL:    url,
		Header: h,
		Body:   ioutil.NopCloser(bytes.NewReader(b)),
	}, nil
}

// TODO(inlined) URI encoding/decoding of headers
func getHeader(h http.Header, name string) string {
	return h.Get(name)
}

func setHeader(h http.Header, name string, value string) {
	if value != "" {
		h.Set(name, value)
	}
}
func getRequiredHeader(h http.Header, name string, value *string) error {
	if *value = getHeader(h, name); *value == "" {
		return fmt.Errorf("missing required header %q", name)
	}
	return nil
}

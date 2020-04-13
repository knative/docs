package event

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strings"
)

// Event represents the canonical representation of a CloudEvent.
type Event struct {
	Context     EventContext
	DataEncoded []byte
	// DataBase64 indicates if the event, when serialized, represents
	// the data field using the base64 encoding.
	// In v0.3, this field is superseded by DataContentEncoding
	DataBase64  bool
	FieldErrors map[string]error
}

const (
	defaultEventVersion = CloudEventsVersionV1
)

func (e *Event) fieldError(field string, err error) {
	if e.FieldErrors == nil {
		e.FieldErrors = make(map[string]error, 0)
	}
	e.FieldErrors[field] = err
}

func (e *Event) fieldOK(field string) {
	if e.FieldErrors != nil {
		delete(e.FieldErrors, field)
	}
}

// New returns a new Event, an optional version can be passed to change the
// default spec version from 1.0 to the provided version.
func New(version ...string) Event {
	specVersion := defaultEventVersion
	if len(version) >= 1 {
		specVersion = version[0]
	}
	e := &Event{}
	e.SetSpecVersion(specVersion)
	return *e
}

// DEPRECATED: Access extensions directly via the e.Extensions() map.
// Use functions in the types package to convert extension values.
// For example replace this:
//
//     var i int
//     err := e.ExtensionAs("foo", &i)
//
// With this:
//
//     i, err := types.ToInteger(e.Extensions["foo"])
//
func (e Event) ExtensionAs(name string, obj interface{}) error {
	return e.Context.ExtensionAs(name, obj)
}

// Validate performs a spec based validation on this event.
// Validation is dependent on the spec version specified in the event context.
func (e Event) Validate() error {
	if e.Context == nil {
		return fmt.Errorf("every event conforming to the CloudEvents specification MUST include a context")
	}

	if e.FieldErrors != nil {
		errs := make([]string, 0)
		for f, e := range e.FieldErrors {
			errs = append(errs, fmt.Sprintf("%q: %s,", f, e))
		}
		if len(errs) > 0 {
			return fmt.Errorf("previous field errors: [%s]", strings.Join(errs, "\n"))
		}
	}

	if err := e.Context.Validate(); err != nil {
		return err
	}

	return nil
}

// String returns a pretty-printed representation of the Event.
func (e Event) String() string {
	b := strings.Builder{}

	b.WriteString("Validation: ")

	valid := e.Validate()
	if valid == nil {
		b.WriteString("valid\n")
	} else {
		b.WriteString("invalid\n")
	}
	if valid != nil {
		b.WriteString(fmt.Sprintf("Validation Error: \n%s\n", valid.Error()))
	}

	b.WriteString(e.Context.String())

	if e.DataEncoded != nil {
		if e.DataBase64 {
			b.WriteString("Data (binary),\n  ")
		} else {
			b.WriteString("Data,\n  ")
		}
		switch e.DataMediaType() {
		case ApplicationJSON:
			var prettyJSON bytes.Buffer
			err := json.Indent(&prettyJSON, e.DataEncoded, "  ", "  ")
			if err != nil {
				b.Write(e.DataEncoded)
			} else {
				b.Write(prettyJSON.Bytes())
			}
		default:
			b.Write(e.DataEncoded)
		}
		b.WriteString("\n")
	}

	return b.String()
}

func (e Event) Clone() Event {
	out := Event{}
	out.Context = e.Context.Clone()
	out.DataEncoded = cloneBytes(e.DataEncoded)
	out.DataBase64 = e.DataBase64
	out.FieldErrors = e.cloneFieldErrors()
	return out
}

func cloneBytes(in []byte) []byte {
	if in == nil {
		return nil
	}
	out := make([]byte, len(in))
	copy(out, in)
	return out
}

func (e Event) cloneFieldErrors() map[string]error {
	if e.FieldErrors == nil {
		return nil
	}
	newFE := make(map[string]error, len(e.FieldErrors))
	for k, v := range e.FieldErrors {
		newFE[k] = v
	}
	return newFE
}

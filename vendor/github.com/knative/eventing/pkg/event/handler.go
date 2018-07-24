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
	"fmt"
	"io"
	"net/http"
	"reflect"

	"github.com/davecgh/go-spew/spew"
	"github.com/golang/glog"
)

type handler struct {
	numIn    int
	fnValue  reflect.Value
	dataType reflect.Type
}

type failedHandler struct {
	err error
}

type errAndHandler interface {
	http.Handler
	error
}

const (
	inParamUsage  = "Expected a function taking either no parameters, a context.Context, or (context.Context, any)"
	outParamUsage = "Expected a function returning either nothing, an error, or (any, error)"
)

var (
	// FYI: Getting the type of an interface is a bit hard in Go because of nil is special:
	// 1. Structs & pointers have concrete types, whereas interfaces are actually tuples of
	//    [imlpementation vtable, pointer].
	// 2. Literals (such as nil) can be cast to any relevant type.
	// Because TypeOf takes an interface{}, a nil interface reference would cast lossily when
	// it leaves this stack frame. The workaround is to pass a pointer to an interface and then
	// get the type of its reference.
	// For example, see: https://play.golang.org/p/_dxLvdkvqvg
	contextType = reflect.TypeOf((*context.Context)(nil)).Elem()
	errorType   = reflect.TypeOf((*error)(nil)).Elem()
)

// Verifies that the inputs to a function have a valid signature; panics otherwise.
// Valid input signatures:
// (), (context.Context), (context.Context, any)
func validateInParamSignature(fnType reflect.Type) error {
	switch fnType.NumIn() {
	case 2:
		fallthrough
	case 1:
		if !fnType.In(0).ConvertibleTo(contextType) {
			return fmt.Errorf("%s; cannot convert parameter 0 from %s to context.Context", inParamUsage, fnType.In(0))
		}
		fallthrough
	case 0:
		return nil
	default:
		return fmt.Errorf("%s; function has too many parameters (%d)", inParamUsage, fnType.NumIn())
	}
}

// Verifies that the outputs of a function have a valid signature; panics otherwise.
// Valid output signatures:
// (), (error), (any, error)
func validateOutParamSignature(fnType reflect.Type) error {
	switch fnType.NumOut() {
	case 2:
		fallthrough
	case 1:
		paramNo := fnType.NumOut() - 1
		paramType := fnType.Out(paramNo)
		if !paramType.ConvertibleTo(errorType) {
			return fmt.Errorf("%s; cannot convert return type %d from %s to error", outParamUsage, paramNo, paramType)
		}
		fallthrough
	case 0:
		return nil
	default:
		return fmt.Errorf("%s; function has too many return types (%d)", outParamUsage, fnType.NumOut())
	}
}

// Verifies that a function has the right number of in and out params and that they are
// of allowed types. If successful, returns the expected in-param type, otherwise panics.
func validateFunction(fnType reflect.Type) errAndHandler {
	if fnType.Kind() != reflect.Func {
		return &failedHandler{err: fmt.Errorf("Must pass a function to handle events")}
	}
	err := anyError(
		validateInParamSignature(fnType),
		validateOutParamSignature(fnType))
	if err != nil {
		return &failedHandler{err: err}
	}
	return nil
}

// Alocates a new instance of type t and returns:
// asPtr is of type t if t is a pointer type and of type &t otherwise (used for unmarshalling)
// asValue is a Value of type t pointing to the same data as asPtr
func allocate(t reflect.Type) (asPtr interface{}, asValue reflect.Value) {
	if t == nil {
		return nil, reflect.Value{}
	}
	if t.Kind() == reflect.Ptr {
		reflectPtr := reflect.New(t.Elem())
		asPtr = reflectPtr.Interface()
		asValue = reflectPtr
	} else {
		reflectPtr := reflect.New(t)
		asPtr = reflectPtr.Interface()
		asValue = reflectPtr.Elem()
	}
	return
}

func unwrapReturnValues(res []reflect.Value) (interface{}, error) {
	switch len(res) {
	case 0:
		return nil, nil
	case 1:
		if res[0].IsNil() {
			return nil, nil
		}
		// Should be a safe cast due to assertEventHandler()
		return nil, res[0].Interface().(error)
	case 2:
		if res[1].IsNil() {
			return res[0].Interface(), nil
		}
		// Should be a safe cast due to assertEventHandler()
		return nil, res[1].Interface().(error)
	default:
		// Should never happen due to assertEventHandler()
		panic("Cannot unmarshal more than 2 return values")
	}
}

// Accepts the results from a handler functions and translates them to an HTTP response
func respondHTTP(outparams []reflect.Value, w http.ResponseWriter) {
	res, err := unwrapReturnValues(outparams)

	if err != nil {
		glog.Error("Failed to handle event: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`Internal server error`))
		return
	}

	if res != nil {
		json, err := json.Marshal(res)
		if err != nil {
			glog.Errorf("Failed to marshal return value %+v: %s", res, err)
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(`Internal server error`))
		} else {
			w.Write(json)
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// Handler creates an EventHandler that implements http.Handler
// If the fn parameter is not a valid type, will produce an http.Handler that also conforms
// to error and will respond to all HTTP requests with that error. Valid types of fn are:
//
// * func()
// * func() error
// * func() (anything, error)
// * func(context.Context)
// * func(context.Context) error
// * func(context.Context) (anything, error)
// * func(context.Context, anything)
// * func(context.Context, anything) error
// * func(context.Context, anything) (anything, error)
//
// CloudEvent contexts are available from the context.Context parameter
// CloudEvent data will be deserialized into the "anything" parameter.
// The library supports native decoding with both XML and JSON encoding.
// To accept another advanced type, pass an io.Reader as the input parameter.
//
// HTTP responses are generated based on the return value of fn:
// * any error return value will cause a StatusInternalServerError response
// * a function with no return type or a function returning nil will cause a StatusNoContent response
// * a function that returns a value will cause a StatusOK and render the response as JSON
func Handler(fn interface{}) http.Handler {
	fnType := reflect.TypeOf(fn)
	err := validateFunction(fnType)
	if err != nil {
		return err
	}
	var dataType reflect.Type
	if fnType.NumIn() == 2 {
		dataType = fnType.In(1)
	}

	return &handler{
		numIn:    fnType.NumIn(),
		dataType: dataType,
		fnValue:  reflect.ValueOf(fn),
	}
}

// ServeHTTP implements http.Handler
func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	args := make([]reflect.Value, 0, 2)

	if h.numIn > 0 {
		dataPtr, dataArg := allocate(h.dataType)
		eventContext, err := FromRequest(dataPtr, r)
		if err != nil {
			glog.Warningf("Failed to handle request %s; error %s", spew.Sdump(r), err)
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte(`Invalid request`))
			return
		}

		ctx := r.Context()
		ctx = context.WithValue(ctx, contextKey, eventContext)
		args = append(args, reflect.ValueOf(ctx))

		if h.numIn == 2 {
			args = append(args, dataArg)
		}
	}

	res := h.fnValue.Call(args)
	respondHTTP(res, w)
}

func (h failedHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	glog.Error("Failed to handle event: ", h.Error())
	w.WriteHeader(http.StatusNotImplemented)
	w.Write([]byte(`Internal server error`))
}

func (h failedHandler) Error() string {
	return h.err.Error()
}

// Mux allows developers to handle logically related groups of
// functionality multiplexed based on the event type.
// TOOD: Consider dropping Mux or figure out how to handle non-JSON encoding.
type Mux map[string]*handler

// NewMux creates a new Mux
func NewMux() Mux {
	return make(map[string]*handler)
}

// Handle adds a new handler for a specific event type
// If the fn parameter is not a valid type, the endpoint will respond to all HTTP requests
// with that error. Valid types of fn are:
//
// * func()
// * func() error
// * func() (anything, error)
// * func(context.Context)
// * func(context.Context) error
// * func(context.Context) (anything, error)
// * func(context.Context, anything)
// * func(context.Context, anything) error
// * func(context.Context, anything) (anything, error)
//
// CloudEvent contexts are available from the context.Context parameter
// CloudEvent data will be deserialized into the "anything" parameter.
// The library supports native decoding with both XML and JSON encoding.
// To accept another advanced type, pass an io.Reader as the input parameter.
//
// HTTP responses are generated based on the return value of fn:
// * any error return value will cause a StatusInternalServerError response
// * a function with no return type or a function returning nil will cause a StatusNoContent response
// * a function that returns a value will cause a StatusOK and render the response as JSON
func (m Mux) Handle(eventType string, fn interface{}) error {
	fnType := reflect.TypeOf(fn)
	err := validateFunction(fnType)
	if err != nil {
		return err
	}
	var dataType reflect.Type
	if fnType.NumIn() == 2 {
		dataType = fnType.In(1)
	}
	m[eventType] = &handler{
		numIn:    fnType.NumIn(),
		dataType: dataType,
		fnValue:  reflect.ValueOf(fn),
	}
	return nil
}

// ServeHTTP implements http.Handler
func (m Mux) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var rawData io.Reader
	eventContext, err := FromRequest(&rawData, r)
	if err != nil {
		glog.Warning("Failed to handle request", spew.Sdump(r))
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(`Invalid request`))
		return
	}

	h := m[eventContext.EventType]
	if h == nil {
		glog.Warning("Cloud not find handler for event type", eventContext.EventType)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(fmt.Sprintf("Event type %q is not supported", eventContext.EventType)))
		return
	}

	args := make([]reflect.Value, 0, 2)
	if h.numIn > 0 {
		ctx := r.Context()
		ctx = context.WithValue(ctx, contextKey, eventContext)
		args = append(args, reflect.ValueOf(ctx))
	}
	if h.numIn == 2 {
		dataPtr, dataArg := allocate(h.dataType)
		if err := unmarshalEventData(eventContext.ContentType, rawData, dataPtr); err != nil {
			glog.Warning("Failed to parse event data", err)
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte(`Invalid request`))
			return
		}
		args = append(args, dataArg)
	}

	res := h.fnValue.Call(args)
	respondHTTP(res, w)
}

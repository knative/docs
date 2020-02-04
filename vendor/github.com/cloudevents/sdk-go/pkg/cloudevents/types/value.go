package types

import (
	"encoding/base64"
	"fmt"
	"math"
	"net/url"
	"reflect"
	"strconv"
	"time"
)

// FormatBool returns canonical string format: "true" or "false"
func FormatBool(v bool) string { return strconv.FormatBool(v) }

// FormatInteger returns canonical string format: decimal notation.
func FormatInteger(v int32) string { return strconv.Itoa(int(v)) }

// FormatBinary returns canonical string format: standard base64 encoding
func FormatBinary(v []byte) string { return base64.StdEncoding.EncodeToString(v) }

// FormatTime returns canonical string format: RFC3339 with nanoseconds
func FormatTime(v time.Time) string { return v.UTC().Format(time.RFC3339Nano) }

// ParseBool parse canonical string format: "true" or "false"
func ParseBool(v string) (bool, error) { return strconv.ParseBool(v) }

// ParseInteger parse canonical string format: decimal notation.
func ParseInteger(v string) (int32, error) {
	// Accept floating-point but truncate to int32 as per CE spec.
	f, err := strconv.ParseFloat(v, 64)
	if err != nil {
		return 0, err
	}
	if f > math.MaxInt32 || f < math.MinInt32 {
		return 0, rangeErr(v)
	}
	return int32(f), nil
}

// ParseBinary parse canonical string format: standard base64 encoding
func ParseBinary(v string) ([]byte, error) { return base64.StdEncoding.DecodeString(v) }

// ParseTime parse canonical string format: RFC3339 with nanoseconds
func ParseTime(v string) (time.Time, error) {
	t, err := time.Parse(time.RFC3339Nano, v)
	if err != nil {
		err := convertErr(time.Time{}, v)
		err.extra = ": not in RFC3339 format"
		return time.Time{}, err
	}
	return t, nil
}

// Format returns the canonical string format of v, where v can be
// any type that is convertible to a CloudEvents type.
func Format(v interface{}) (string, error) {
	v, err := Validate(v)
	if err != nil {
		return "", err
	}
	switch v := v.(type) {
	case bool:
		return FormatBool(v), nil
	case int32:
		return FormatInteger(v), nil
	case string:
		return v, nil
	case []byte:
		return FormatBinary(v), nil
	case url.URL:
		return v.String(), nil
	case *url.URL:
		// url.URL is often passed by pointer so allow both
		return v.String(), nil
	case time.Time:
		return FormatTime(v), nil
	default:
		return "", fmt.Errorf("%T is not a CloudEvents type", v)
	}
}

// Validate v is a valid CloudEvents attribute value, convert it to one of:
//     bool, int32, string, []byte, *url.URL, time.Time
func Validate(v interface{}) (interface{}, error) {
	switch v := v.(type) {
	case bool, int32, string, []byte, time.Time:
		return v, nil // Already a CloudEvents type, no validation needed.

	case uint, uintptr, uint8, uint16, uint32, uint64:
		u := reflect.ValueOf(v).Uint()
		if u > math.MaxInt32 {
			return nil, rangeErr(v)
		}
		return int32(u), nil
	case int, int8, int16, int64:
		i := reflect.ValueOf(v).Int()
		if i > math.MaxInt32 || i < math.MinInt32 {
			return nil, rangeErr(v)
		}
		return int32(i), nil
	case float32, float64:
		f := reflect.ValueOf(v).Float()
		if f > math.MaxInt32 || f < math.MinInt32 {
			return nil, rangeErr(v)
		}
		return int32(f), nil

	case *url.URL:
		if v == nil {
			break
		}
		return v, nil
	case url.URL:
		return &v, nil
	case URIRef:
		return &v.URL, nil
	case URI:
		return &v.URL, nil
	case URLRef:
		return &v.URL, nil

	case Timestamp:
		return v.Time, nil
	}
	rx := reflect.ValueOf(v)
	if rx.Kind() == reflect.Ptr && !rx.IsNil() {
		// Allow pointers-to convertible types
		return Validate(rx.Elem().Interface())
	}
	return nil, fmt.Errorf("invalid CloudEvents value: %#v", v)
}

// ToBool accepts a bool value or canonical "true"/"false" string.
func ToBool(v interface{}) (bool, error) {
	v, err := Validate(v)
	if err != nil {
		return false, err
	}
	switch v := v.(type) {
	case bool:
		return v, nil
	case string:
		return ParseBool(v)
	default:
		return false, convertErr(true, v)
	}
}

// ToInteger accepts any numeric value in int32 range, or canonical string.
func ToInteger(v interface{}) (int32, error) {
	v, err := Validate(v)
	if err != nil {
		return 0, err
	}
	switch v := v.(type) {
	case int32:
		return v, nil
	case string:
		return ParseInteger(v)
	default:
		return 0, convertErr(int32(0), v)
	}
}

// ToString returns a string value unaltered.
//
// This function does not perform canonical string encoding, use one of the
// Format functions for that.
func ToString(v interface{}) (string, error) {
	v, err := Validate(v)
	if err != nil {
		return "", err
	}
	switch v := v.(type) {
	case string:
		return v, nil
	default:
		return "", convertErr("", v)
	}
}

// ToBinary returns a []byte value, decoding from base64 string if necessary.
func ToBinary(v interface{}) ([]byte, error) {
	v, err := Validate(v)
	if err != nil {
		return nil, err
	}
	switch v := v.(type) {
	case []byte:
		return v, nil
	case string:
		return base64.StdEncoding.DecodeString(v)
	default:
		return nil, convertErr([]byte(nil), v)
	}
}

// ToURL returns a *url.URL value, parsing from string if necessary.
func ToURL(v interface{}) (*url.URL, error) {
	v, err := Validate(v)
	if err != nil {
		return nil, err
	}
	switch v := v.(type) {
	case *url.URL:
		return v, nil
	case string:
		u, err := url.Parse(v)
		if err != nil {
			return nil, err
		}
		return u, nil
	default:
		return nil, convertErr((*url.URL)(nil), v)
	}
}

// ToTime returns a time.Time value, parsing from RFC3339 string if necessary.
func ToTime(v interface{}) (time.Time, error) {
	v, err := Validate(v)
	if err != nil {
		return time.Time{}, err
	}
	switch v := v.(type) {
	case time.Time:
		return v, nil
	case string:
		ts, err := time.Parse(time.RFC3339Nano, v)
		if err != nil {
			return time.Time{}, err
		}
		return ts, nil
	default:
		return time.Time{}, convertErr(time.Time{}, v)
	}
}

type ConvertErr struct {
	// Value being converted
	Value interface{}
	// Type of attempted conversion
	Type reflect.Type

	extra string
}

func (e *ConvertErr) Error() string {
	return fmt.Sprintf("cannot convert %#v to %s%s", e.Value, e.Type, e.extra)
}

func convertErr(target, v interface{}) *ConvertErr {
	return &ConvertErr{Value: v, Type: reflect.TypeOf(target)}
}

func rangeErr(v interface{}) error {
	e := convertErr(int32(0), v)
	e.extra = ": out of range"
	return e
}

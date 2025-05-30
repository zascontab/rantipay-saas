// Code generated by protoc-gen-validate. DO NOT EDIT.
// source: google/api/httpbody/httpbody.proto

package httpbody

import (
	"bytes"
	"errors"
	"fmt"
	"net"
	"net/mail"
	"net/url"
	"regexp"
	"sort"
	"strings"
	"time"
	"unicode/utf8"

	"google.golang.org/protobuf/types/known/anypb"
)

// ensure the imports are used
var (
	_ = bytes.MinRead
	_ = errors.New("")
	_ = fmt.Print
	_ = utf8.UTFMax
	_ = (*regexp.Regexp)(nil)
	_ = (*strings.Reader)(nil)
	_ = net.IPv4len
	_ = time.Duration(0)
	_ = (*url.URL)(nil)
	_ = (*mail.Address)(nil)
	_ = anypb.Any{}
	_ = sort.Sort
)

// Validate checks the field values on HttpBody with the rules defined in the
// proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *HttpBody) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on HttpBody with the rules defined in
// the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in HttpBodyMultiError, or nil
// if none found.
func (m *HttpBody) ValidateAll() error {
	return m.validate(true)
}

func (m *HttpBody) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for ContentType

	// no validation rules for Data

	for idx, item := range m.GetExtensions() {
		_, _ = idx, item

		if all {
			switch v := interface{}(item).(type) {
			case interface{ ValidateAll() error }:
				if err := v.ValidateAll(); err != nil {
					errors = append(errors, HttpBodyValidationError{
						field:  fmt.Sprintf("Extensions[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, HttpBodyValidationError{
						field:  fmt.Sprintf("Extensions[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(item).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return HttpBodyValidationError{
					field:  fmt.Sprintf("Extensions[%v]", idx),
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	}

	if len(errors) > 0 {
		return HttpBodyMultiError(errors)
	}

	return nil
}

// HttpBodyMultiError is an error wrapping multiple validation errors returned
// by HttpBody.ValidateAll() if the designated constraints aren't met.
type HttpBodyMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m HttpBodyMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m HttpBodyMultiError) AllErrors() []error { return m }

// HttpBodyValidationError is the validation error returned by
// HttpBody.Validate if the designated constraints aren't met.
type HttpBodyValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e HttpBodyValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e HttpBodyValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e HttpBodyValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e HttpBodyValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e HttpBodyValidationError) ErrorName() string { return "HttpBodyValidationError" }

// Error satisfies the builtin error interface
func (e HttpBodyValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sHttpBody.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = HttpBodyValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = HttpBodyValidationError{}

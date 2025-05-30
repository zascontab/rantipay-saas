// Code generated by protoc-gen-validate. DO NOT EDIT.
// source: google/api/expr/v1beta1/source.proto

package expr

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

// Validate checks the field values on SourceInfo with the rules defined in the
// proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *SourceInfo) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on SourceInfo with the rules defined in
// the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in SourceInfoMultiError, or
// nil if none found.
func (m *SourceInfo) ValidateAll() error {
	return m.validate(true)
}

func (m *SourceInfo) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Location

	// no validation rules for Positions

	if len(errors) > 0 {
		return SourceInfoMultiError(errors)
	}

	return nil
}

// SourceInfoMultiError is an error wrapping multiple validation errors
// returned by SourceInfo.ValidateAll() if the designated constraints aren't met.
type SourceInfoMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m SourceInfoMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m SourceInfoMultiError) AllErrors() []error { return m }

// SourceInfoValidationError is the validation error returned by
// SourceInfo.Validate if the designated constraints aren't met.
type SourceInfoValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e SourceInfoValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e SourceInfoValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e SourceInfoValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e SourceInfoValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e SourceInfoValidationError) ErrorName() string { return "SourceInfoValidationError" }

// Error satisfies the builtin error interface
func (e SourceInfoValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sSourceInfo.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = SourceInfoValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = SourceInfoValidationError{}

// Validate checks the field values on SourcePosition with the rules defined in
// the proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *SourcePosition) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on SourcePosition with the rules defined
// in the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in SourcePositionMultiError,
// or nil if none found.
func (m *SourcePosition) ValidateAll() error {
	return m.validate(true)
}

func (m *SourcePosition) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Location

	// no validation rules for Offset

	// no validation rules for Line

	// no validation rules for Column

	if len(errors) > 0 {
		return SourcePositionMultiError(errors)
	}

	return nil
}

// SourcePositionMultiError is an error wrapping multiple validation errors
// returned by SourcePosition.ValidateAll() if the designated constraints
// aren't met.
type SourcePositionMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m SourcePositionMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m SourcePositionMultiError) AllErrors() []error { return m }

// SourcePositionValidationError is the validation error returned by
// SourcePosition.Validate if the designated constraints aren't met.
type SourcePositionValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e SourcePositionValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e SourcePositionValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e SourcePositionValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e SourcePositionValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e SourcePositionValidationError) ErrorName() string { return "SourcePositionValidationError" }

// Error satisfies the builtin error interface
func (e SourcePositionValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sSourcePosition.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = SourcePositionValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = SourcePositionValidationError{}

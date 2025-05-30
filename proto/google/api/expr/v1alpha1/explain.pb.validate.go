// Code generated by protoc-gen-validate. DO NOT EDIT.
// source: google/api/expr/v1alpha1/explain.proto

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

// Validate checks the field values on Explain with the rules defined in the
// proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *Explain) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on Explain with the rules defined in the
// proto definition for this message. If any rules are violated, the result is
// a list of violation errors wrapped in ExplainMultiError, or nil if none found.
func (m *Explain) ValidateAll() error {
	return m.validate(true)
}

func (m *Explain) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	for idx, item := range m.GetValues() {
		_, _ = idx, item

		if all {
			switch v := interface{}(item).(type) {
			case interface{ ValidateAll() error }:
				if err := v.ValidateAll(); err != nil {
					errors = append(errors, ExplainValidationError{
						field:  fmt.Sprintf("Values[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, ExplainValidationError{
						field:  fmt.Sprintf("Values[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(item).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return ExplainValidationError{
					field:  fmt.Sprintf("Values[%v]", idx),
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	}

	for idx, item := range m.GetExprSteps() {
		_, _ = idx, item

		if all {
			switch v := interface{}(item).(type) {
			case interface{ ValidateAll() error }:
				if err := v.ValidateAll(); err != nil {
					errors = append(errors, ExplainValidationError{
						field:  fmt.Sprintf("ExprSteps[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, ExplainValidationError{
						field:  fmt.Sprintf("ExprSteps[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(item).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return ExplainValidationError{
					field:  fmt.Sprintf("ExprSteps[%v]", idx),
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	}

	if len(errors) > 0 {
		return ExplainMultiError(errors)
	}

	return nil
}

// ExplainMultiError is an error wrapping multiple validation errors returned
// by Explain.ValidateAll() if the designated constraints aren't met.
type ExplainMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m ExplainMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m ExplainMultiError) AllErrors() []error { return m }

// ExplainValidationError is the validation error returned by Explain.Validate
// if the designated constraints aren't met.
type ExplainValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e ExplainValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e ExplainValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e ExplainValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e ExplainValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e ExplainValidationError) ErrorName() string { return "ExplainValidationError" }

// Error satisfies the builtin error interface
func (e ExplainValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sExplain.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = ExplainValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = ExplainValidationError{}

// Validate checks the field values on Explain_ExprStep with the rules defined
// in the proto definition for this message. If any rules are violated, the
// first error encountered is returned, or nil if there are no violations.
func (m *Explain_ExprStep) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on Explain_ExprStep with the rules
// defined in the proto definition for this message. If any rules are
// violated, the result is a list of violation errors wrapped in
// Explain_ExprStepMultiError, or nil if none found.
func (m *Explain_ExprStep) ValidateAll() error {
	return m.validate(true)
}

func (m *Explain_ExprStep) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Id

	// no validation rules for ValueIndex

	if len(errors) > 0 {
		return Explain_ExprStepMultiError(errors)
	}

	return nil
}

// Explain_ExprStepMultiError is an error wrapping multiple validation errors
// returned by Explain_ExprStep.ValidateAll() if the designated constraints
// aren't met.
type Explain_ExprStepMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m Explain_ExprStepMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m Explain_ExprStepMultiError) AllErrors() []error { return m }

// Explain_ExprStepValidationError is the validation error returned by
// Explain_ExprStep.Validate if the designated constraints aren't met.
type Explain_ExprStepValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e Explain_ExprStepValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e Explain_ExprStepValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e Explain_ExprStepValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e Explain_ExprStepValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e Explain_ExprStepValidationError) ErrorName() string { return "Explain_ExprStepValidationError" }

// Error satisfies the builtin error interface
func (e Explain_ExprStepValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sExplain_ExprStep.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = Explain_ExprStepValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = Explain_ExprStepValidationError{}

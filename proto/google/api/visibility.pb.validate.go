// Code generated by protoc-gen-validate. DO NOT EDIT.
// source: google/api/visibility.proto

package visibility

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

// Validate checks the field values on Visibility with the rules defined in the
// proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *Visibility) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on Visibility with the rules defined in
// the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in VisibilityMultiError, or
// nil if none found.
func (m *Visibility) ValidateAll() error {
	return m.validate(true)
}

func (m *Visibility) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	for idx, item := range m.GetRules() {
		_, _ = idx, item

		if all {
			switch v := interface{}(item).(type) {
			case interface{ ValidateAll() error }:
				if err := v.ValidateAll(); err != nil {
					errors = append(errors, VisibilityValidationError{
						field:  fmt.Sprintf("Rules[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, VisibilityValidationError{
						field:  fmt.Sprintf("Rules[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(item).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return VisibilityValidationError{
					field:  fmt.Sprintf("Rules[%v]", idx),
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	}

	if len(errors) > 0 {
		return VisibilityMultiError(errors)
	}

	return nil
}

// VisibilityMultiError is an error wrapping multiple validation errors
// returned by Visibility.ValidateAll() if the designated constraints aren't met.
type VisibilityMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m VisibilityMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m VisibilityMultiError) AllErrors() []error { return m }

// VisibilityValidationError is the validation error returned by
// Visibility.Validate if the designated constraints aren't met.
type VisibilityValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e VisibilityValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e VisibilityValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e VisibilityValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e VisibilityValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e VisibilityValidationError) ErrorName() string { return "VisibilityValidationError" }

// Error satisfies the builtin error interface
func (e VisibilityValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sVisibility.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = VisibilityValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = VisibilityValidationError{}

// Validate checks the field values on VisibilityRule with the rules defined in
// the proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *VisibilityRule) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on VisibilityRule with the rules defined
// in the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in VisibilityRuleMultiError,
// or nil if none found.
func (m *VisibilityRule) ValidateAll() error {
	return m.validate(true)
}

func (m *VisibilityRule) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Selector

	// no validation rules for Restriction

	if len(errors) > 0 {
		return VisibilityRuleMultiError(errors)
	}

	return nil
}

// VisibilityRuleMultiError is an error wrapping multiple validation errors
// returned by VisibilityRule.ValidateAll() if the designated constraints
// aren't met.
type VisibilityRuleMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m VisibilityRuleMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m VisibilityRuleMultiError) AllErrors() []error { return m }

// VisibilityRuleValidationError is the validation error returned by
// VisibilityRule.Validate if the designated constraints aren't met.
type VisibilityRuleValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e VisibilityRuleValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e VisibilityRuleValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e VisibilityRuleValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e VisibilityRuleValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e VisibilityRuleValidationError) ErrorName() string { return "VisibilityRuleValidationError" }

// Error satisfies the builtin error interface
func (e VisibilityRuleValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sVisibilityRule.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = VisibilityRuleValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = VisibilityRuleValidationError{}

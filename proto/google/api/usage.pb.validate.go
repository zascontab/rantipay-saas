// Code generated by protoc-gen-validate. DO NOT EDIT.
// source: google/api/usage.proto

package serviceconfig

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

// Validate checks the field values on Usage with the rules defined in the
// proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *Usage) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on Usage with the rules defined in the
// proto definition for this message. If any rules are violated, the result is
// a list of violation errors wrapped in UsageMultiError, or nil if none found.
func (m *Usage) ValidateAll() error {
	return m.validate(true)
}

func (m *Usage) validate(all bool) error {
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
					errors = append(errors, UsageValidationError{
						field:  fmt.Sprintf("Rules[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, UsageValidationError{
						field:  fmt.Sprintf("Rules[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(item).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return UsageValidationError{
					field:  fmt.Sprintf("Rules[%v]", idx),
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	}

	// no validation rules for ProducerNotificationChannel

	if len(errors) > 0 {
		return UsageMultiError(errors)
	}

	return nil
}

// UsageMultiError is an error wrapping multiple validation errors returned by
// Usage.ValidateAll() if the designated constraints aren't met.
type UsageMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m UsageMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m UsageMultiError) AllErrors() []error { return m }

// UsageValidationError is the validation error returned by Usage.Validate if
// the designated constraints aren't met.
type UsageValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e UsageValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e UsageValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e UsageValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e UsageValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e UsageValidationError) ErrorName() string { return "UsageValidationError" }

// Error satisfies the builtin error interface
func (e UsageValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sUsage.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = UsageValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = UsageValidationError{}

// Validate checks the field values on UsageRule with the rules defined in the
// proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *UsageRule) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on UsageRule with the rules defined in
// the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in UsageRuleMultiError, or nil
// if none found.
func (m *UsageRule) ValidateAll() error {
	return m.validate(true)
}

func (m *UsageRule) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Selector

	// no validation rules for AllowUnregisteredCalls

	// no validation rules for SkipServiceControl

	if len(errors) > 0 {
		return UsageRuleMultiError(errors)
	}

	return nil
}

// UsageRuleMultiError is an error wrapping multiple validation errors returned
// by UsageRule.ValidateAll() if the designated constraints aren't met.
type UsageRuleMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m UsageRuleMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m UsageRuleMultiError) AllErrors() []error { return m }

// UsageRuleValidationError is the validation error returned by
// UsageRule.Validate if the designated constraints aren't met.
type UsageRuleValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e UsageRuleValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e UsageRuleValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e UsageRuleValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e UsageRuleValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e UsageRuleValidationError) ErrorName() string { return "UsageRuleValidationError" }

// Error satisfies the builtin error interface
func (e UsageRuleValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sUsageRule.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = UsageRuleValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = UsageRuleValidationError{}

// Code generated by protoc-gen-validate. DO NOT EDIT.
// source: google/longrunning/operations.proto

package longrunningpb

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

// Validate checks the field values on Operation with the rules defined in the
// proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *Operation) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on Operation with the rules defined in
// the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in OperationMultiError, or nil
// if none found.
func (m *Operation) ValidateAll() error {
	return m.validate(true)
}

func (m *Operation) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Name

	if all {
		switch v := interface{}(m.GetMetadata()).(type) {
		case interface{ ValidateAll() error }:
			if err := v.ValidateAll(); err != nil {
				errors = append(errors, OperationValidationError{
					field:  "Metadata",
					reason: "embedded message failed validation",
					cause:  err,
				})
			}
		case interface{ Validate() error }:
			if err := v.Validate(); err != nil {
				errors = append(errors, OperationValidationError{
					field:  "Metadata",
					reason: "embedded message failed validation",
					cause:  err,
				})
			}
		}
	} else if v, ok := interface{}(m.GetMetadata()).(interface{ Validate() error }); ok {
		if err := v.Validate(); err != nil {
			return OperationValidationError{
				field:  "Metadata",
				reason: "embedded message failed validation",
				cause:  err,
			}
		}
	}

	// no validation rules for Done

	switch v := m.Result.(type) {
	case *Operation_Error:
		if v == nil {
			err := OperationValidationError{
				field:  "Result",
				reason: "oneof value cannot be a typed-nil",
			}
			if !all {
				return err
			}
			errors = append(errors, err)
		}

		if all {
			switch v := interface{}(m.GetError()).(type) {
			case interface{ ValidateAll() error }:
				if err := v.ValidateAll(); err != nil {
					errors = append(errors, OperationValidationError{
						field:  "Error",
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, OperationValidationError{
						field:  "Error",
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(m.GetError()).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return OperationValidationError{
					field:  "Error",
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	case *Operation_Response:
		if v == nil {
			err := OperationValidationError{
				field:  "Result",
				reason: "oneof value cannot be a typed-nil",
			}
			if !all {
				return err
			}
			errors = append(errors, err)
		}

		if all {
			switch v := interface{}(m.GetResponse()).(type) {
			case interface{ ValidateAll() error }:
				if err := v.ValidateAll(); err != nil {
					errors = append(errors, OperationValidationError{
						field:  "Response",
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, OperationValidationError{
						field:  "Response",
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(m.GetResponse()).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return OperationValidationError{
					field:  "Response",
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	default:
		_ = v // ensures v is used
	}

	if len(errors) > 0 {
		return OperationMultiError(errors)
	}

	return nil
}

// OperationMultiError is an error wrapping multiple validation errors returned
// by Operation.ValidateAll() if the designated constraints aren't met.
type OperationMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m OperationMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m OperationMultiError) AllErrors() []error { return m }

// OperationValidationError is the validation error returned by
// Operation.Validate if the designated constraints aren't met.
type OperationValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e OperationValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e OperationValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e OperationValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e OperationValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e OperationValidationError) ErrorName() string { return "OperationValidationError" }

// Error satisfies the builtin error interface
func (e OperationValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sOperation.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = OperationValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = OperationValidationError{}

// Validate checks the field values on GetOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the first error encountered is returned, or nil if there are no violations.
func (m *GetOperationRequest) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on GetOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the result is a list of violation errors wrapped in
// GetOperationRequestMultiError, or nil if none found.
func (m *GetOperationRequest) ValidateAll() error {
	return m.validate(true)
}

func (m *GetOperationRequest) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Name

	if len(errors) > 0 {
		return GetOperationRequestMultiError(errors)
	}

	return nil
}

// GetOperationRequestMultiError is an error wrapping multiple validation
// errors returned by GetOperationRequest.ValidateAll() if the designated
// constraints aren't met.
type GetOperationRequestMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m GetOperationRequestMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m GetOperationRequestMultiError) AllErrors() []error { return m }

// GetOperationRequestValidationError is the validation error returned by
// GetOperationRequest.Validate if the designated constraints aren't met.
type GetOperationRequestValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e GetOperationRequestValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e GetOperationRequestValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e GetOperationRequestValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e GetOperationRequestValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e GetOperationRequestValidationError) ErrorName() string {
	return "GetOperationRequestValidationError"
}

// Error satisfies the builtin error interface
func (e GetOperationRequestValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sGetOperationRequest.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = GetOperationRequestValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = GetOperationRequestValidationError{}

// Validate checks the field values on ListOperationsRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the first error encountered is returned, or nil if there are no violations.
func (m *ListOperationsRequest) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on ListOperationsRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the result is a list of violation errors wrapped in
// ListOperationsRequestMultiError, or nil if none found.
func (m *ListOperationsRequest) ValidateAll() error {
	return m.validate(true)
}

func (m *ListOperationsRequest) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Name

	// no validation rules for Filter

	// no validation rules for PageSize

	// no validation rules for PageToken

	if len(errors) > 0 {
		return ListOperationsRequestMultiError(errors)
	}

	return nil
}

// ListOperationsRequestMultiError is an error wrapping multiple validation
// errors returned by ListOperationsRequest.ValidateAll() if the designated
// constraints aren't met.
type ListOperationsRequestMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m ListOperationsRequestMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m ListOperationsRequestMultiError) AllErrors() []error { return m }

// ListOperationsRequestValidationError is the validation error returned by
// ListOperationsRequest.Validate if the designated constraints aren't met.
type ListOperationsRequestValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e ListOperationsRequestValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e ListOperationsRequestValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e ListOperationsRequestValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e ListOperationsRequestValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e ListOperationsRequestValidationError) ErrorName() string {
	return "ListOperationsRequestValidationError"
}

// Error satisfies the builtin error interface
func (e ListOperationsRequestValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sListOperationsRequest.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = ListOperationsRequestValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = ListOperationsRequestValidationError{}

// Validate checks the field values on ListOperationsResponse with the rules
// defined in the proto definition for this message. If any rules are
// violated, the first error encountered is returned, or nil if there are no violations.
func (m *ListOperationsResponse) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on ListOperationsResponse with the rules
// defined in the proto definition for this message. If any rules are
// violated, the result is a list of violation errors wrapped in
// ListOperationsResponseMultiError, or nil if none found.
func (m *ListOperationsResponse) ValidateAll() error {
	return m.validate(true)
}

func (m *ListOperationsResponse) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	for idx, item := range m.GetOperations() {
		_, _ = idx, item

		if all {
			switch v := interface{}(item).(type) {
			case interface{ ValidateAll() error }:
				if err := v.ValidateAll(); err != nil {
					errors = append(errors, ListOperationsResponseValidationError{
						field:  fmt.Sprintf("Operations[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			case interface{ Validate() error }:
				if err := v.Validate(); err != nil {
					errors = append(errors, ListOperationsResponseValidationError{
						field:  fmt.Sprintf("Operations[%v]", idx),
						reason: "embedded message failed validation",
						cause:  err,
					})
				}
			}
		} else if v, ok := interface{}(item).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return ListOperationsResponseValidationError{
					field:  fmt.Sprintf("Operations[%v]", idx),
					reason: "embedded message failed validation",
					cause:  err,
				}
			}
		}

	}

	// no validation rules for NextPageToken

	if len(errors) > 0 {
		return ListOperationsResponseMultiError(errors)
	}

	return nil
}

// ListOperationsResponseMultiError is an error wrapping multiple validation
// errors returned by ListOperationsResponse.ValidateAll() if the designated
// constraints aren't met.
type ListOperationsResponseMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m ListOperationsResponseMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m ListOperationsResponseMultiError) AllErrors() []error { return m }

// ListOperationsResponseValidationError is the validation error returned by
// ListOperationsResponse.Validate if the designated constraints aren't met.
type ListOperationsResponseValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e ListOperationsResponseValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e ListOperationsResponseValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e ListOperationsResponseValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e ListOperationsResponseValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e ListOperationsResponseValidationError) ErrorName() string {
	return "ListOperationsResponseValidationError"
}

// Error satisfies the builtin error interface
func (e ListOperationsResponseValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sListOperationsResponse.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = ListOperationsResponseValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = ListOperationsResponseValidationError{}

// Validate checks the field values on CancelOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the first error encountered is returned, or nil if there are no violations.
func (m *CancelOperationRequest) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on CancelOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the result is a list of violation errors wrapped in
// CancelOperationRequestMultiError, or nil if none found.
func (m *CancelOperationRequest) ValidateAll() error {
	return m.validate(true)
}

func (m *CancelOperationRequest) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Name

	if len(errors) > 0 {
		return CancelOperationRequestMultiError(errors)
	}

	return nil
}

// CancelOperationRequestMultiError is an error wrapping multiple validation
// errors returned by CancelOperationRequest.ValidateAll() if the designated
// constraints aren't met.
type CancelOperationRequestMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m CancelOperationRequestMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m CancelOperationRequestMultiError) AllErrors() []error { return m }

// CancelOperationRequestValidationError is the validation error returned by
// CancelOperationRequest.Validate if the designated constraints aren't met.
type CancelOperationRequestValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e CancelOperationRequestValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e CancelOperationRequestValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e CancelOperationRequestValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e CancelOperationRequestValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e CancelOperationRequestValidationError) ErrorName() string {
	return "CancelOperationRequestValidationError"
}

// Error satisfies the builtin error interface
func (e CancelOperationRequestValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sCancelOperationRequest.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = CancelOperationRequestValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = CancelOperationRequestValidationError{}

// Validate checks the field values on DeleteOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the first error encountered is returned, or nil if there are no violations.
func (m *DeleteOperationRequest) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on DeleteOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the result is a list of violation errors wrapped in
// DeleteOperationRequestMultiError, or nil if none found.
func (m *DeleteOperationRequest) ValidateAll() error {
	return m.validate(true)
}

func (m *DeleteOperationRequest) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Name

	if len(errors) > 0 {
		return DeleteOperationRequestMultiError(errors)
	}

	return nil
}

// DeleteOperationRequestMultiError is an error wrapping multiple validation
// errors returned by DeleteOperationRequest.ValidateAll() if the designated
// constraints aren't met.
type DeleteOperationRequestMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m DeleteOperationRequestMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m DeleteOperationRequestMultiError) AllErrors() []error { return m }

// DeleteOperationRequestValidationError is the validation error returned by
// DeleteOperationRequest.Validate if the designated constraints aren't met.
type DeleteOperationRequestValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e DeleteOperationRequestValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e DeleteOperationRequestValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e DeleteOperationRequestValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e DeleteOperationRequestValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e DeleteOperationRequestValidationError) ErrorName() string {
	return "DeleteOperationRequestValidationError"
}

// Error satisfies the builtin error interface
func (e DeleteOperationRequestValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sDeleteOperationRequest.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = DeleteOperationRequestValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = DeleteOperationRequestValidationError{}

// Validate checks the field values on WaitOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the first error encountered is returned, or nil if there are no violations.
func (m *WaitOperationRequest) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on WaitOperationRequest with the rules
// defined in the proto definition for this message. If any rules are
// violated, the result is a list of violation errors wrapped in
// WaitOperationRequestMultiError, or nil if none found.
func (m *WaitOperationRequest) ValidateAll() error {
	return m.validate(true)
}

func (m *WaitOperationRequest) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for Name

	if all {
		switch v := interface{}(m.GetTimeout()).(type) {
		case interface{ ValidateAll() error }:
			if err := v.ValidateAll(); err != nil {
				errors = append(errors, WaitOperationRequestValidationError{
					field:  "Timeout",
					reason: "embedded message failed validation",
					cause:  err,
				})
			}
		case interface{ Validate() error }:
			if err := v.Validate(); err != nil {
				errors = append(errors, WaitOperationRequestValidationError{
					field:  "Timeout",
					reason: "embedded message failed validation",
					cause:  err,
				})
			}
		}
	} else if v, ok := interface{}(m.GetTimeout()).(interface{ Validate() error }); ok {
		if err := v.Validate(); err != nil {
			return WaitOperationRequestValidationError{
				field:  "Timeout",
				reason: "embedded message failed validation",
				cause:  err,
			}
		}
	}

	if len(errors) > 0 {
		return WaitOperationRequestMultiError(errors)
	}

	return nil
}

// WaitOperationRequestMultiError is an error wrapping multiple validation
// errors returned by WaitOperationRequest.ValidateAll() if the designated
// constraints aren't met.
type WaitOperationRequestMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m WaitOperationRequestMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m WaitOperationRequestMultiError) AllErrors() []error { return m }

// WaitOperationRequestValidationError is the validation error returned by
// WaitOperationRequest.Validate if the designated constraints aren't met.
type WaitOperationRequestValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e WaitOperationRequestValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e WaitOperationRequestValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e WaitOperationRequestValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e WaitOperationRequestValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e WaitOperationRequestValidationError) ErrorName() string {
	return "WaitOperationRequestValidationError"
}

// Error satisfies the builtin error interface
func (e WaitOperationRequestValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sWaitOperationRequest.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = WaitOperationRequestValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = WaitOperationRequestValidationError{}

// Validate checks the field values on OperationInfo with the rules defined in
// the proto definition for this message. If any rules are violated, the first
// error encountered is returned, or nil if there are no violations.
func (m *OperationInfo) Validate() error {
	return m.validate(false)
}

// ValidateAll checks the field values on OperationInfo with the rules defined
// in the proto definition for this message. If any rules are violated, the
// result is a list of violation errors wrapped in OperationInfoMultiError, or
// nil if none found.
func (m *OperationInfo) ValidateAll() error {
	return m.validate(true)
}

func (m *OperationInfo) validate(all bool) error {
	if m == nil {
		return nil
	}

	var errors []error

	// no validation rules for ResponseType

	// no validation rules for MetadataType

	if len(errors) > 0 {
		return OperationInfoMultiError(errors)
	}

	return nil
}

// OperationInfoMultiError is an error wrapping multiple validation errors
// returned by OperationInfo.ValidateAll() if the designated constraints
// aren't met.
type OperationInfoMultiError []error

// Error returns a concatenation of all the error messages it wraps.
func (m OperationInfoMultiError) Error() string {
	var msgs []string
	for _, err := range m {
		msgs = append(msgs, err.Error())
	}
	return strings.Join(msgs, "; ")
}

// AllErrors returns a list of validation violation errors.
func (m OperationInfoMultiError) AllErrors() []error { return m }

// OperationInfoValidationError is the validation error returned by
// OperationInfo.Validate if the designated constraints aren't met.
type OperationInfoValidationError struct {
	field  string
	reason string
	cause  error
	key    bool
}

// Field function returns field value.
func (e OperationInfoValidationError) Field() string { return e.field }

// Reason function returns reason value.
func (e OperationInfoValidationError) Reason() string { return e.reason }

// Cause function returns cause value.
func (e OperationInfoValidationError) Cause() error { return e.cause }

// Key function returns key value.
func (e OperationInfoValidationError) Key() bool { return e.key }

// ErrorName returns error name.
func (e OperationInfoValidationError) ErrorName() string { return "OperationInfoValidationError" }

// Error satisfies the builtin error interface
func (e OperationInfoValidationError) Error() string {
	cause := ""
	if e.cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.cause)
	}

	key := ""
	if e.key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sOperationInfo.%s: %s%s",
		key,
		e.field,
		e.reason,
		cause)
}

var _ error = OperationInfoValidationError{}

var _ interface {
	Field() string
	Reason() string
	Key() bool
	Cause() error
	ErrorName() string
} = OperationInfoValidationError{}

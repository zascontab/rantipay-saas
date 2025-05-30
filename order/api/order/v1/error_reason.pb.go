// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        (unknown)
// source: order/api/order/v1/error_reason.proto

package v1

import (
	_ "github.com/go-kratos/kratos/v2/errors"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type ErrorReason int32

const (
	ErrorReason_CONTENT_MISSING ErrorReason = 0
)

// Enum value maps for ErrorReason.
var (
	ErrorReason_name = map[int32]string{
		0: "CONTENT_MISSING",
	}
	ErrorReason_value = map[string]int32{
		"CONTENT_MISSING": 0,
	}
)

func (x ErrorReason) Enum() *ErrorReason {
	p := new(ErrorReason)
	*p = x
	return p
}

func (x ErrorReason) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (ErrorReason) Descriptor() protoreflect.EnumDescriptor {
	return file_order_api_order_v1_error_reason_proto_enumTypes[0].Descriptor()
}

func (ErrorReason) Type() protoreflect.EnumType {
	return &file_order_api_order_v1_error_reason_proto_enumTypes[0]
}

func (x ErrorReason) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use ErrorReason.Descriptor instead.
func (ErrorReason) EnumDescriptor() ([]byte, []int) {
	return file_order_api_order_v1_error_reason_proto_rawDescGZIP(), []int{0}
}

var File_order_api_order_v1_error_reason_proto protoreflect.FileDescriptor

const file_order_api_order_v1_error_reason_proto_rawDesc = "" +
	"\n" +
	"%order/api/order/v1/error_reason.proto\x12\x12order.api.order.v1\x1a\x13errors/errors.proto*.\n" +
	"\vErrorReason\x12\x19\n" +
	"\x0fCONTENT_MISSING\x10\x00\x1a\x04\xa8E\x90\x03\x1a\x04\xa0E\xf4\x03B-Z+github.com/go-saas/kit/order/api/post/v1;v1b\x06proto3"

var (
	file_order_api_order_v1_error_reason_proto_rawDescOnce sync.Once
	file_order_api_order_v1_error_reason_proto_rawDescData []byte
)

func file_order_api_order_v1_error_reason_proto_rawDescGZIP() []byte {
	file_order_api_order_v1_error_reason_proto_rawDescOnce.Do(func() {
		file_order_api_order_v1_error_reason_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_order_api_order_v1_error_reason_proto_rawDesc), len(file_order_api_order_v1_error_reason_proto_rawDesc)))
	})
	return file_order_api_order_v1_error_reason_proto_rawDescData
}

var file_order_api_order_v1_error_reason_proto_enumTypes = make([]protoimpl.EnumInfo, 1)
var file_order_api_order_v1_error_reason_proto_goTypes = []any{
	(ErrorReason)(0), // 0: order.api.order.v1.ErrorReason
}
var file_order_api_order_v1_error_reason_proto_depIdxs = []int32{
	0, // [0:0] is the sub-list for method output_type
	0, // [0:0] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}

func init() { file_order_api_order_v1_error_reason_proto_init() }
func file_order_api_order_v1_error_reason_proto_init() {
	if File_order_api_order_v1_error_reason_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_order_api_order_v1_error_reason_proto_rawDesc), len(file_order_api_order_v1_error_reason_proto_rawDesc)),
			NumEnums:      1,
			NumMessages:   0,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_order_api_order_v1_error_reason_proto_goTypes,
		DependencyIndexes: file_order_api_order_v1_error_reason_proto_depIdxs,
		EnumInfos:         file_order_api_order_v1_error_reason_proto_enumTypes,
	}.Build()
	File_order_api_order_v1_error_reason_proto = out.File
	file_order_api_order_v1_error_reason_proto_goTypes = nil
	file_order_api_order_v1_error_reason_proto_depIdxs = nil
}

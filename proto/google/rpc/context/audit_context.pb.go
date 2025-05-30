// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        (unknown)
// source: google/rpc/context/audit_context.proto

package context

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	structpb "google.golang.org/protobuf/types/known/structpb"
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

// `AuditContext` provides information that is needed for audit logging.
type AuditContext struct {
	state protoimpl.MessageState `protogen:"open.v1"`
	// Serialized audit log.
	AuditLog []byte `protobuf:"bytes,1,opt,name=audit_log,json=auditLog,proto3" json:"audit_log,omitempty"`
	// An API request message that is scrubbed based on the method annotation.
	// This field should only be filled if audit_log field is present.
	// Service Control will use this to assemble a complete log for Cloud Audit
	// Logs and Google internal audit logs.
	ScrubbedRequest *structpb.Struct `protobuf:"bytes,2,opt,name=scrubbed_request,json=scrubbedRequest,proto3" json:"scrubbed_request,omitempty"`
	// An API response message that is scrubbed based on the method annotation.
	// This field should only be filled if audit_log field is present.
	// Service Control will use this to assemble a complete log for Cloud Audit
	// Logs and Google internal audit logs.
	ScrubbedResponse *structpb.Struct `protobuf:"bytes,3,opt,name=scrubbed_response,json=scrubbedResponse,proto3" json:"scrubbed_response,omitempty"`
	// Number of scrubbed response items.
	ScrubbedResponseItemCount int32 `protobuf:"varint,4,opt,name=scrubbed_response_item_count,json=scrubbedResponseItemCount,proto3" json:"scrubbed_response_item_count,omitempty"`
	// Audit resource name which is scrubbed.
	TargetResource string `protobuf:"bytes,5,opt,name=target_resource,json=targetResource,proto3" json:"target_resource,omitempty"`
	unknownFields  protoimpl.UnknownFields
	sizeCache      protoimpl.SizeCache
}

func (x *AuditContext) Reset() {
	*x = AuditContext{}
	mi := &file_google_rpc_context_audit_context_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *AuditContext) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*AuditContext) ProtoMessage() {}

func (x *AuditContext) ProtoReflect() protoreflect.Message {
	mi := &file_google_rpc_context_audit_context_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use AuditContext.ProtoReflect.Descriptor instead.
func (*AuditContext) Descriptor() ([]byte, []int) {
	return file_google_rpc_context_audit_context_proto_rawDescGZIP(), []int{0}
}

func (x *AuditContext) GetAuditLog() []byte {
	if x != nil {
		return x.AuditLog
	}
	return nil
}

func (x *AuditContext) GetScrubbedRequest() *structpb.Struct {
	if x != nil {
		return x.ScrubbedRequest
	}
	return nil
}

func (x *AuditContext) GetScrubbedResponse() *structpb.Struct {
	if x != nil {
		return x.ScrubbedResponse
	}
	return nil
}

func (x *AuditContext) GetScrubbedResponseItemCount() int32 {
	if x != nil {
		return x.ScrubbedResponseItemCount
	}
	return 0
}

func (x *AuditContext) GetTargetResource() string {
	if x != nil {
		return x.TargetResource
	}
	return ""
}

var File_google_rpc_context_audit_context_proto protoreflect.FileDescriptor

const file_google_rpc_context_audit_context_proto_rawDesc = "" +
	"\n" +
	"&google/rpc/context/audit_context.proto\x12\x12google.rpc.context\x1a\x1cgoogle/protobuf/struct.proto\"\x9f\x02\n" +
	"\fAuditContext\x12\x1b\n" +
	"\taudit_log\x18\x01 \x01(\fR\bauditLog\x12B\n" +
	"\x10scrubbed_request\x18\x02 \x01(\v2\x17.google.protobuf.StructR\x0fscrubbedRequest\x12D\n" +
	"\x11scrubbed_response\x18\x03 \x01(\v2\x17.google.protobuf.StructR\x10scrubbedResponse\x12?\n" +
	"\x1cscrubbed_response_item_count\x18\x04 \x01(\x05R\x19scrubbedResponseItemCount\x12'\n" +
	"\x0ftarget_resource\x18\x05 \x01(\tR\x0etargetResourceBh\n" +
	"\x16com.google.rpc.contextB\x11AuditContextProtoP\x01Z9google.golang.org/genproto/googleapis/rpc/context;contextb\x06proto3"

var (
	file_google_rpc_context_audit_context_proto_rawDescOnce sync.Once
	file_google_rpc_context_audit_context_proto_rawDescData []byte
)

func file_google_rpc_context_audit_context_proto_rawDescGZIP() []byte {
	file_google_rpc_context_audit_context_proto_rawDescOnce.Do(func() {
		file_google_rpc_context_audit_context_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_google_rpc_context_audit_context_proto_rawDesc), len(file_google_rpc_context_audit_context_proto_rawDesc)))
	})
	return file_google_rpc_context_audit_context_proto_rawDescData
}

var file_google_rpc_context_audit_context_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_google_rpc_context_audit_context_proto_goTypes = []any{
	(*AuditContext)(nil),    // 0: google.rpc.context.AuditContext
	(*structpb.Struct)(nil), // 1: google.protobuf.Struct
}
var file_google_rpc_context_audit_context_proto_depIdxs = []int32{
	1, // 0: google.rpc.context.AuditContext.scrubbed_request:type_name -> google.protobuf.Struct
	1, // 1: google.rpc.context.AuditContext.scrubbed_response:type_name -> google.protobuf.Struct
	2, // [2:2] is the sub-list for method output_type
	2, // [2:2] is the sub-list for method input_type
	2, // [2:2] is the sub-list for extension type_name
	2, // [2:2] is the sub-list for extension extendee
	0, // [0:2] is the sub-list for field type_name
}

func init() { file_google_rpc_context_audit_context_proto_init() }
func file_google_rpc_context_audit_context_proto_init() {
	if File_google_rpc_context_audit_context_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_google_rpc_context_audit_context_proto_rawDesc), len(file_google_rpc_context_audit_context_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   1,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_google_rpc_context_audit_context_proto_goTypes,
		DependencyIndexes: file_google_rpc_context_audit_context_proto_depIdxs,
		MessageInfos:      file_google_rpc_context_audit_context_proto_msgTypes,
	}.Build()
	File_google_rpc_context_audit_context_proto = out.File
	file_google_rpc_context_audit_context_proto_goTypes = nil
	file_google_rpc_context_audit_context_proto_depIdxs = nil
}

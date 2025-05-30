// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        (unknown)
// source: payment/event/v1/event.proto

package v1

import (
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

type SubscriptionChangedEvent struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Id            string                 `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *SubscriptionChangedEvent) Reset() {
	*x = SubscriptionChangedEvent{}
	mi := &file_payment_event_v1_event_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *SubscriptionChangedEvent) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*SubscriptionChangedEvent) ProtoMessage() {}

func (x *SubscriptionChangedEvent) ProtoReflect() protoreflect.Message {
	mi := &file_payment_event_v1_event_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use SubscriptionChangedEvent.ProtoReflect.Descriptor instead.
func (*SubscriptionChangedEvent) Descriptor() ([]byte, []int) {
	return file_payment_event_v1_event_proto_rawDescGZIP(), []int{0}
}

func (x *SubscriptionChangedEvent) GetId() string {
	if x != nil {
		return x.Id
	}
	return ""
}

var File_payment_event_v1_event_proto protoreflect.FileDescriptor

const file_payment_event_v1_event_proto_rawDesc = "" +
	"\n" +
	"\x1cpayment/event/v1/event.proto\x12\rpayment.event\"*\n" +
	"\x18SubscriptionChangedEvent\x12\x0e\n" +
	"\x02id\x18\x01 \x01(\tR\x02idB,Z*github.com/go-saas/kit/payment/event/v1;v1b\x06proto3"

var (
	file_payment_event_v1_event_proto_rawDescOnce sync.Once
	file_payment_event_v1_event_proto_rawDescData []byte
)

func file_payment_event_v1_event_proto_rawDescGZIP() []byte {
	file_payment_event_v1_event_proto_rawDescOnce.Do(func() {
		file_payment_event_v1_event_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_payment_event_v1_event_proto_rawDesc), len(file_payment_event_v1_event_proto_rawDesc)))
	})
	return file_payment_event_v1_event_proto_rawDescData
}

var file_payment_event_v1_event_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_payment_event_v1_event_proto_goTypes = []any{
	(*SubscriptionChangedEvent)(nil), // 0: payment.event.SubscriptionChangedEvent
}
var file_payment_event_v1_event_proto_depIdxs = []int32{
	0, // [0:0] is the sub-list for method output_type
	0, // [0:0] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}

func init() { file_payment_event_v1_event_proto_init() }
func file_payment_event_v1_event_proto_init() {
	if File_payment_event_v1_event_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_payment_event_v1_event_proto_rawDesc), len(file_payment_event_v1_event_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   1,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_payment_event_v1_event_proto_goTypes,
		DependencyIndexes: file_payment_event_v1_event_proto_depIdxs,
		MessageInfos:      file_payment_event_v1_event_proto_msgTypes,
	}.Build()
	File_payment_event_v1_event_proto = out.File
	file_payment_event_v1_event_proto_goTypes = nil
	file_payment_event_v1_event_proto_depIdxs = nil
}

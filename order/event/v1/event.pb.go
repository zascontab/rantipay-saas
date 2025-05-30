// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        (unknown)
// source: order/event/v1/event.proto

package v1

import (
	v1 "github.com/go-saas/kit/order/api/order/v1"
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

type OrderPaySuccessEvent struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Order         *v1.Order              `protobuf:"bytes,1,opt,name=order,proto3" json:"order,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *OrderPaySuccessEvent) Reset() {
	*x = OrderPaySuccessEvent{}
	mi := &file_order_event_v1_event_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *OrderPaySuccessEvent) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*OrderPaySuccessEvent) ProtoMessage() {}

func (x *OrderPaySuccessEvent) ProtoReflect() protoreflect.Message {
	mi := &file_order_event_v1_event_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use OrderPaySuccessEvent.ProtoReflect.Descriptor instead.
func (*OrderPaySuccessEvent) Descriptor() ([]byte, []int) {
	return file_order_event_v1_event_proto_rawDescGZIP(), []int{0}
}

func (x *OrderPaySuccessEvent) GetOrder() *v1.Order {
	if x != nil {
		return x.Order
	}
	return nil
}

type OrderRefundSuccessEvent struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Order         *v1.Order              `protobuf:"bytes,1,opt,name=order,proto3" json:"order,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *OrderRefundSuccessEvent) Reset() {
	*x = OrderRefundSuccessEvent{}
	mi := &file_order_event_v1_event_proto_msgTypes[1]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *OrderRefundSuccessEvent) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*OrderRefundSuccessEvent) ProtoMessage() {}

func (x *OrderRefundSuccessEvent) ProtoReflect() protoreflect.Message {
	mi := &file_order_event_v1_event_proto_msgTypes[1]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use OrderRefundSuccessEvent.ProtoReflect.Descriptor instead.
func (*OrderRefundSuccessEvent) Descriptor() ([]byte, []int) {
	return file_order_event_v1_event_proto_rawDescGZIP(), []int{1}
}

func (x *OrderRefundSuccessEvent) GetOrder() *v1.Order {
	if x != nil {
		return x.Order
	}
	return nil
}

var File_order_event_v1_event_proto protoreflect.FileDescriptor

const file_order_event_v1_event_proto_rawDesc = "" +
	"\n" +
	"\x1aorder/event/v1/event.proto\x12\vorder.event\x1a\x1eorder/api/order/v1/order.proto\"G\n" +
	"\x14OrderPaySuccessEvent\x12/\n" +
	"\x05order\x18\x01 \x01(\v2\x19.order.api.order.v1.OrderR\x05order\"J\n" +
	"\x17OrderRefundSuccessEvent\x12/\n" +
	"\x05order\x18\x01 \x01(\v2\x19.order.api.order.v1.OrderR\x05orderB*Z(github.com/go-saas/kit/order/event/v1;v1b\x06proto3"

var (
	file_order_event_v1_event_proto_rawDescOnce sync.Once
	file_order_event_v1_event_proto_rawDescData []byte
)

func file_order_event_v1_event_proto_rawDescGZIP() []byte {
	file_order_event_v1_event_proto_rawDescOnce.Do(func() {
		file_order_event_v1_event_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_order_event_v1_event_proto_rawDesc), len(file_order_event_v1_event_proto_rawDesc)))
	})
	return file_order_event_v1_event_proto_rawDescData
}

var file_order_event_v1_event_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_order_event_v1_event_proto_goTypes = []any{
	(*OrderPaySuccessEvent)(nil),    // 0: order.event.OrderPaySuccessEvent
	(*OrderRefundSuccessEvent)(nil), // 1: order.event.OrderRefundSuccessEvent
	(*v1.Order)(nil),                // 2: order.api.order.v1.Order
}
var file_order_event_v1_event_proto_depIdxs = []int32{
	2, // 0: order.event.OrderPaySuccessEvent.order:type_name -> order.api.order.v1.Order
	2, // 1: order.event.OrderRefundSuccessEvent.order:type_name -> order.api.order.v1.Order
	2, // [2:2] is the sub-list for method output_type
	2, // [2:2] is the sub-list for method input_type
	2, // [2:2] is the sub-list for extension type_name
	2, // [2:2] is the sub-list for extension extendee
	0, // [0:2] is the sub-list for field type_name
}

func init() { file_order_event_v1_event_proto_init() }
func file_order_event_v1_event_proto_init() {
	if File_order_event_v1_event_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_order_event_v1_event_proto_rawDesc), len(file_order_event_v1_event_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   2,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_order_event_v1_event_proto_goTypes,
		DependencyIndexes: file_order_event_v1_event_proto_depIdxs,
		MessageInfos:      file_order_event_v1_event_proto_msgTypes,
	}.Build()
	File_order_event_v1_event_proto = out.File
	file_order_event_v1_event_proto_goTypes = nil
	file_order_event_v1_event_proto_depIdxs = nil
}

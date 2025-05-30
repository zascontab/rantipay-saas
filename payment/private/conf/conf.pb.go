// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        (unknown)
// source: payment/private/conf/conf.proto

package conf

import (
	_ "github.com/go-saas/kit/pkg/blob"
	conf "github.com/go-saas/kit/pkg/conf"
	stripe "github.com/go-saas/kit/pkg/stripe"
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

type Bootstrap struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Data          *conf.Data             `protobuf:"bytes,2,opt,name=data,proto3" json:"data,omitempty"`
	Security      *conf.Security         `protobuf:"bytes,3,opt,name=security,proto3" json:"security,omitempty"`
	Services      *conf.Services         `protobuf:"bytes,4,opt,name=services,proto3" json:"services,omitempty"`
	Logging       *conf.Logging          `protobuf:"bytes,6,opt,name=logging,proto3" json:"logging,omitempty"`
	Tracing       *conf.Tracers          `protobuf:"bytes,7,opt,name=tracing,proto3" json:"tracing,omitempty"`
	App           *conf.AppConfig        `protobuf:"bytes,8,opt,name=app,proto3" json:"app,omitempty"`
	Payment       *PaymentConf           `protobuf:"bytes,500,opt,name=payment,proto3" json:"payment,omitempty"`
	Stripe        *stripe.Conf           `protobuf:"bytes,501,opt,name=stripe,proto3" json:"stripe,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Bootstrap) Reset() {
	*x = Bootstrap{}
	mi := &file_payment_private_conf_conf_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Bootstrap) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Bootstrap) ProtoMessage() {}

func (x *Bootstrap) ProtoReflect() protoreflect.Message {
	mi := &file_payment_private_conf_conf_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Bootstrap.ProtoReflect.Descriptor instead.
func (*Bootstrap) Descriptor() ([]byte, []int) {
	return file_payment_private_conf_conf_proto_rawDescGZIP(), []int{0}
}

func (x *Bootstrap) GetData() *conf.Data {
	if x != nil {
		return x.Data
	}
	return nil
}

func (x *Bootstrap) GetSecurity() *conf.Security {
	if x != nil {
		return x.Security
	}
	return nil
}

func (x *Bootstrap) GetServices() *conf.Services {
	if x != nil {
		return x.Services
	}
	return nil
}

func (x *Bootstrap) GetLogging() *conf.Logging {
	if x != nil {
		return x.Logging
	}
	return nil
}

func (x *Bootstrap) GetTracing() *conf.Tracers {
	if x != nil {
		return x.Tracing
	}
	return nil
}

func (x *Bootstrap) GetApp() *conf.AppConfig {
	if x != nil {
		return x.App
	}
	return nil
}

func (x *Bootstrap) GetPayment() *PaymentConf {
	if x != nil {
		return x.Payment
	}
	return nil
}

func (x *Bootstrap) GetStripe() *stripe.Conf {
	if x != nil {
		return x.Stripe
	}
	return nil
}

type PaymentConf struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *PaymentConf) Reset() {
	*x = PaymentConf{}
	mi := &file_payment_private_conf_conf_proto_msgTypes[1]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *PaymentConf) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*PaymentConf) ProtoMessage() {}

func (x *PaymentConf) ProtoReflect() protoreflect.Message {
	mi := &file_payment_private_conf_conf_proto_msgTypes[1]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use PaymentConf.ProtoReflect.Descriptor instead.
func (*PaymentConf) Descriptor() ([]byte, []int) {
	return file_payment_private_conf_conf_proto_rawDescGZIP(), []int{1}
}

var File_payment_private_conf_conf_proto protoreflect.FileDescriptor

const file_payment_private_conf_conf_proto_rawDesc = "" +
	"\n" +
	"\x1fpayment/private/conf/conf.proto\x12\x14payment.private.conf\x1a\x0fconf/conf.proto\x1a\x0fblob/blob.proto\x1a\x13stripe/stripe.proto\"\xdd\x02\n" +
	"\tBootstrap\x12\x1e\n" +
	"\x04data\x18\x02 \x01(\v2\n" +
	".conf.DataR\x04data\x12*\n" +
	"\bsecurity\x18\x03 \x01(\v2\x0e.conf.SecurityR\bsecurity\x12*\n" +
	"\bservices\x18\x04 \x01(\v2\x0e.conf.ServicesR\bservices\x12'\n" +
	"\alogging\x18\x06 \x01(\v2\r.conf.LoggingR\alogging\x12'\n" +
	"\atracing\x18\a \x01(\v2\r.conf.TracersR\atracing\x12!\n" +
	"\x03app\x18\b \x01(\v2\x0f.conf.AppConfigR\x03app\x12<\n" +
	"\apayment\x18\xf4\x03 \x01(\v2!.payment.private.conf.PaymentConfR\apayment\x12%\n" +
	"\x06stripe\x18\xf5\x03 \x01(\v2\f.stripe.ConfR\x06stripe\"\r\n" +
	"\vPaymentConfB2Z0github.com/go-saas/kit/payment/private/conf;confb\x06proto3"

var (
	file_payment_private_conf_conf_proto_rawDescOnce sync.Once
	file_payment_private_conf_conf_proto_rawDescData []byte
)

func file_payment_private_conf_conf_proto_rawDescGZIP() []byte {
	file_payment_private_conf_conf_proto_rawDescOnce.Do(func() {
		file_payment_private_conf_conf_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_payment_private_conf_conf_proto_rawDesc), len(file_payment_private_conf_conf_proto_rawDesc)))
	})
	return file_payment_private_conf_conf_proto_rawDescData
}

var file_payment_private_conf_conf_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_payment_private_conf_conf_proto_goTypes = []any{
	(*Bootstrap)(nil),      // 0: payment.private.conf.Bootstrap
	(*PaymentConf)(nil),    // 1: payment.private.conf.PaymentConf
	(*conf.Data)(nil),      // 2: conf.Data
	(*conf.Security)(nil),  // 3: conf.Security
	(*conf.Services)(nil),  // 4: conf.Services
	(*conf.Logging)(nil),   // 5: conf.Logging
	(*conf.Tracers)(nil),   // 6: conf.Tracers
	(*conf.AppConfig)(nil), // 7: conf.AppConfig
	(*stripe.Conf)(nil),    // 8: stripe.Conf
}
var file_payment_private_conf_conf_proto_depIdxs = []int32{
	2, // 0: payment.private.conf.Bootstrap.data:type_name -> conf.Data
	3, // 1: payment.private.conf.Bootstrap.security:type_name -> conf.Security
	4, // 2: payment.private.conf.Bootstrap.services:type_name -> conf.Services
	5, // 3: payment.private.conf.Bootstrap.logging:type_name -> conf.Logging
	6, // 4: payment.private.conf.Bootstrap.tracing:type_name -> conf.Tracers
	7, // 5: payment.private.conf.Bootstrap.app:type_name -> conf.AppConfig
	1, // 6: payment.private.conf.Bootstrap.payment:type_name -> payment.private.conf.PaymentConf
	8, // 7: payment.private.conf.Bootstrap.stripe:type_name -> stripe.Conf
	8, // [8:8] is the sub-list for method output_type
	8, // [8:8] is the sub-list for method input_type
	8, // [8:8] is the sub-list for extension type_name
	8, // [8:8] is the sub-list for extension extendee
	0, // [0:8] is the sub-list for field type_name
}

func init() { file_payment_private_conf_conf_proto_init() }
func file_payment_private_conf_conf_proto_init() {
	if File_payment_private_conf_conf_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_payment_private_conf_conf_proto_rawDesc), len(file_payment_private_conf_conf_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   2,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_payment_private_conf_conf_proto_goTypes,
		DependencyIndexes: file_payment_private_conf_conf_proto_depIdxs,
		MessageInfos:      file_payment_private_conf_conf_proto_msgTypes,
	}.Build()
	File_payment_private_conf_conf_proto = out.File
	file_payment_private_conf_conf_proto_goTypes = nil
	file_payment_private_conf_conf_proto_depIdxs = nil
}

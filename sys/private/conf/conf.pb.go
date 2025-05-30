// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        (unknown)
// source: sys/private/conf/conf.proto

package conf

import (
	apisix "github.com/go-saas/kit/pkg/apisix"
	_ "github.com/go-saas/kit/pkg/blob"
	conf "github.com/go-saas/kit/pkg/conf"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	_ "google.golang.org/protobuf/types/known/structpb"
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
	Dev           *conf.Dev              `protobuf:"bytes,9,opt,name=dev,proto3" json:"dev,omitempty"`
	Sys           *SysConf               `protobuf:"bytes,10,opt,name=sys,proto3" json:"sys,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Bootstrap) Reset() {
	*x = Bootstrap{}
	mi := &file_sys_private_conf_conf_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Bootstrap) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Bootstrap) ProtoMessage() {}

func (x *Bootstrap) ProtoReflect() protoreflect.Message {
	mi := &file_sys_private_conf_conf_proto_msgTypes[0]
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
	return file_sys_private_conf_conf_proto_rawDescGZIP(), []int{0}
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

func (x *Bootstrap) GetDev() *conf.Dev {
	if x != nil {
		return x.Dev
	}
	return nil
}

func (x *Bootstrap) GetSys() *SysConf {
	if x != nil {
		return x.Sys
	}
	return nil
}

type SysConf struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Apisix        *apisix.Config         `protobuf:"bytes,1,opt,name=apisix,proto3" json:"apisix,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *SysConf) Reset() {
	*x = SysConf{}
	mi := &file_sys_private_conf_conf_proto_msgTypes[1]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *SysConf) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*SysConf) ProtoMessage() {}

func (x *SysConf) ProtoReflect() protoreflect.Message {
	mi := &file_sys_private_conf_conf_proto_msgTypes[1]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use SysConf.ProtoReflect.Descriptor instead.
func (*SysConf) Descriptor() ([]byte, []int) {
	return file_sys_private_conf_conf_proto_rawDescGZIP(), []int{1}
}

func (x *SysConf) GetApisix() *apisix.Config {
	if x != nil {
		return x.Apisix
	}
	return nil
}

var File_sys_private_conf_conf_proto protoreflect.FileDescriptor

const file_sys_private_conf_conf_proto_rawDesc = "" +
	"\n" +
	"\x1bsys/private/conf/conf.proto\x12\fsys.internal\x1a\x0fconf/conf.proto\x1a\x0fblob/blob.proto\x1a\x13apisix/apisix.proto\x1a\x1cgoogle/protobuf/struct.proto\"\xbe\x02\n" +
	"\tBootstrap\x12\x1e\n" +
	"\x04data\x18\x02 \x01(\v2\n" +
	".conf.DataR\x04data\x12*\n" +
	"\bsecurity\x18\x03 \x01(\v2\x0e.conf.SecurityR\bsecurity\x12*\n" +
	"\bservices\x18\x04 \x01(\v2\x0e.conf.ServicesR\bservices\x12'\n" +
	"\alogging\x18\x06 \x01(\v2\r.conf.LoggingR\alogging\x12'\n" +
	"\atracing\x18\a \x01(\v2\r.conf.TracersR\atracing\x12!\n" +
	"\x03app\x18\b \x01(\v2\x0f.conf.AppConfigR\x03app\x12\x1b\n" +
	"\x03dev\x18\t \x01(\v2\t.conf.DevR\x03dev\x12'\n" +
	"\x03sys\x18\n" +
	" \x01(\v2\x15.sys.internal.SysConfR\x03sys\"1\n" +
	"\aSysConf\x12&\n" +
	"\x06apisix\x18\x01 \x01(\v2\x0e.apisix.ConfigR\x06apisixB.Z,github.com/go-saas/kit/sys/private/conf;confb\x06proto3"

var (
	file_sys_private_conf_conf_proto_rawDescOnce sync.Once
	file_sys_private_conf_conf_proto_rawDescData []byte
)

func file_sys_private_conf_conf_proto_rawDescGZIP() []byte {
	file_sys_private_conf_conf_proto_rawDescOnce.Do(func() {
		file_sys_private_conf_conf_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_sys_private_conf_conf_proto_rawDesc), len(file_sys_private_conf_conf_proto_rawDesc)))
	})
	return file_sys_private_conf_conf_proto_rawDescData
}

var file_sys_private_conf_conf_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_sys_private_conf_conf_proto_goTypes = []any{
	(*Bootstrap)(nil),      // 0: sys.internal.Bootstrap
	(*SysConf)(nil),        // 1: sys.internal.SysConf
	(*conf.Data)(nil),      // 2: conf.Data
	(*conf.Security)(nil),  // 3: conf.Security
	(*conf.Services)(nil),  // 4: conf.Services
	(*conf.Logging)(nil),   // 5: conf.Logging
	(*conf.Tracers)(nil),   // 6: conf.Tracers
	(*conf.AppConfig)(nil), // 7: conf.AppConfig
	(*conf.Dev)(nil),       // 8: conf.Dev
	(*apisix.Config)(nil),  // 9: apisix.Config
}
var file_sys_private_conf_conf_proto_depIdxs = []int32{
	2, // 0: sys.internal.Bootstrap.data:type_name -> conf.Data
	3, // 1: sys.internal.Bootstrap.security:type_name -> conf.Security
	4, // 2: sys.internal.Bootstrap.services:type_name -> conf.Services
	5, // 3: sys.internal.Bootstrap.logging:type_name -> conf.Logging
	6, // 4: sys.internal.Bootstrap.tracing:type_name -> conf.Tracers
	7, // 5: sys.internal.Bootstrap.app:type_name -> conf.AppConfig
	8, // 6: sys.internal.Bootstrap.dev:type_name -> conf.Dev
	1, // 7: sys.internal.Bootstrap.sys:type_name -> sys.internal.SysConf
	9, // 8: sys.internal.SysConf.apisix:type_name -> apisix.Config
	9, // [9:9] is the sub-list for method output_type
	9, // [9:9] is the sub-list for method input_type
	9, // [9:9] is the sub-list for extension type_name
	9, // [9:9] is the sub-list for extension extendee
	0, // [0:9] is the sub-list for field type_name
}

func init() { file_sys_private_conf_conf_proto_init() }
func file_sys_private_conf_conf_proto_init() {
	if File_sys_private_conf_conf_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_sys_private_conf_conf_proto_rawDesc), len(file_sys_private_conf_conf_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   2,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_sys_private_conf_conf_proto_goTypes,
		DependencyIndexes: file_sys_private_conf_conf_proto_depIdxs,
		MessageInfos:      file_sys_private_conf_conf_proto_msgTypes,
	}.Build()
	File_sys_private_conf_conf_proto = out.File
	file_sys_private_conf_conf_proto_goTypes = nil
	file_sys_private_conf_conf_proto_depIdxs = nil
}

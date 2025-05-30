// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.6
// 	protoc        (unknown)
// source: product/api/category/v1/category.proto

package v1

import (
	_ "github.com/envoyproxy/protoc-gen-validate/validate"
	query "github.com/go-saas/kit/pkg/query"
	_ "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2/options"
	_ "google.golang.org/genproto/googleapis/api/annotations"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	fieldmaskpb "google.golang.org/protobuf/types/known/fieldmaskpb"
	_ "google.golang.org/protobuf/types/known/structpb"
	timestamppb "google.golang.org/protobuf/types/known/timestamppb"
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

type CreateProductCategoryRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Key           string                 `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	Name          string                 `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	Parent        string                 `protobuf:"bytes,3,opt,name=parent,proto3" json:"parent,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *CreateProductCategoryRequest) Reset() {
	*x = CreateProductCategoryRequest{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *CreateProductCategoryRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*CreateProductCategoryRequest) ProtoMessage() {}

func (x *CreateProductCategoryRequest) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use CreateProductCategoryRequest.ProtoReflect.Descriptor instead.
func (*CreateProductCategoryRequest) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{0}
}

func (x *CreateProductCategoryRequest) GetKey() string {
	if x != nil {
		return x.Key
	}
	return ""
}

func (x *CreateProductCategoryRequest) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

func (x *CreateProductCategoryRequest) GetParent() string {
	if x != nil {
		return x.Parent
	}
	return ""
}

type UpdateProductCategoryRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Category      *UpdateProductCategory `protobuf:"bytes,1,opt,name=category,proto3" json:"category,omitempty"`
	UpdateMask    *fieldmaskpb.FieldMask `protobuf:"bytes,2,opt,name=update_mask,json=updateMask,proto3" json:"update_mask,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *UpdateProductCategoryRequest) Reset() {
	*x = UpdateProductCategoryRequest{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[1]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *UpdateProductCategoryRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*UpdateProductCategoryRequest) ProtoMessage() {}

func (x *UpdateProductCategoryRequest) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[1]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use UpdateProductCategoryRequest.ProtoReflect.Descriptor instead.
func (*UpdateProductCategoryRequest) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{1}
}

func (x *UpdateProductCategoryRequest) GetCategory() *UpdateProductCategory {
	if x != nil {
		return x.Category
	}
	return nil
}

func (x *UpdateProductCategoryRequest) GetUpdateMask() *fieldmaskpb.FieldMask {
	if x != nil {
		return x.UpdateMask
	}
	return nil
}

type UpdateProductCategory struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Key           string                 `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	Name          string                 `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *UpdateProductCategory) Reset() {
	*x = UpdateProductCategory{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[2]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *UpdateProductCategory) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*UpdateProductCategory) ProtoMessage() {}

func (x *UpdateProductCategory) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[2]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use UpdateProductCategory.ProtoReflect.Descriptor instead.
func (*UpdateProductCategory) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{2}
}

func (x *UpdateProductCategory) GetKey() string {
	if x != nil {
		return x.Key
	}
	return ""
}

func (x *UpdateProductCategory) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

type DeleteProductCategoryRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Key           string                 `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *DeleteProductCategoryRequest) Reset() {
	*x = DeleteProductCategoryRequest{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[3]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *DeleteProductCategoryRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*DeleteProductCategoryRequest) ProtoMessage() {}

func (x *DeleteProductCategoryRequest) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[3]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use DeleteProductCategoryRequest.ProtoReflect.Descriptor instead.
func (*DeleteProductCategoryRequest) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{3}
}

func (x *DeleteProductCategoryRequest) GetKey() string {
	if x != nil {
		return x.Key
	}
	return ""
}

type DeleteProductCategoryReply struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Key           string                 `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	Name          string                 `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *DeleteProductCategoryReply) Reset() {
	*x = DeleteProductCategoryReply{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[4]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *DeleteProductCategoryReply) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*DeleteProductCategoryReply) ProtoMessage() {}

func (x *DeleteProductCategoryReply) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[4]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use DeleteProductCategoryReply.ProtoReflect.Descriptor instead.
func (*DeleteProductCategoryReply) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{4}
}

func (x *DeleteProductCategoryReply) GetKey() string {
	if x != nil {
		return x.Key
	}
	return ""
}

func (x *DeleteProductCategoryReply) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

type GetProductCategoryRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Key           string                 `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *GetProductCategoryRequest) Reset() {
	*x = GetProductCategoryRequest{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[5]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *GetProductCategoryRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*GetProductCategoryRequest) ProtoMessage() {}

func (x *GetProductCategoryRequest) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[5]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use GetProductCategoryRequest.ProtoReflect.Descriptor instead.
func (*GetProductCategoryRequest) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{5}
}

func (x *GetProductCategoryRequest) GetKey() string {
	if x != nil {
		return x.Key
	}
	return ""
}

type ProductCategoryFilter struct {
	state         protoimpl.MessageState       `protogen:"open.v1"`
	Key           *query.StringFilterOperation `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	Name          *query.StringFilterOperation `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	Parent        *query.StringFilterOperation `protobuf:"bytes,3,opt,name=parent,proto3" json:"parent,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *ProductCategoryFilter) Reset() {
	*x = ProductCategoryFilter{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[6]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *ProductCategoryFilter) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*ProductCategoryFilter) ProtoMessage() {}

func (x *ProductCategoryFilter) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[6]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use ProductCategoryFilter.ProtoReflect.Descriptor instead.
func (*ProductCategoryFilter) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{6}
}

func (x *ProductCategoryFilter) GetKey() *query.StringFilterOperation {
	if x != nil {
		return x.Key
	}
	return nil
}

func (x *ProductCategoryFilter) GetName() *query.StringFilterOperation {
	if x != nil {
		return x.Name
	}
	return nil
}

func (x *ProductCategoryFilter) GetParent() *query.StringFilterOperation {
	if x != nil {
		return x.Parent
	}
	return nil
}

type ListProductCategoryRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	PageOffset    int32                  `protobuf:"varint,1,opt,name=page_offset,json=pageOffset,proto3" json:"page_offset,omitempty"`
	PageSize      int32                  `protobuf:"varint,2,opt,name=page_size,json=pageSize,proto3" json:"page_size,omitempty"`
	Search        string                 `protobuf:"bytes,3,opt,name=search,proto3" json:"search,omitempty"`
	Sort          []string               `protobuf:"bytes,4,rep,name=sort,proto3" json:"sort,omitempty"`
	Fields        *fieldmaskpb.FieldMask `protobuf:"bytes,5,opt,name=fields,proto3" json:"fields,omitempty"`
	Filter        *ProductCategoryFilter `protobuf:"bytes,6,opt,name=filter,proto3" json:"filter,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *ListProductCategoryRequest) Reset() {
	*x = ListProductCategoryRequest{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[7]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *ListProductCategoryRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*ListProductCategoryRequest) ProtoMessage() {}

func (x *ListProductCategoryRequest) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[7]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use ListProductCategoryRequest.ProtoReflect.Descriptor instead.
func (*ListProductCategoryRequest) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{7}
}

func (x *ListProductCategoryRequest) GetPageOffset() int32 {
	if x != nil {
		return x.PageOffset
	}
	return 0
}

func (x *ListProductCategoryRequest) GetPageSize() int32 {
	if x != nil {
		return x.PageSize
	}
	return 0
}

func (x *ListProductCategoryRequest) GetSearch() string {
	if x != nil {
		return x.Search
	}
	return ""
}

func (x *ListProductCategoryRequest) GetSort() []string {
	if x != nil {
		return x.Sort
	}
	return nil
}

func (x *ListProductCategoryRequest) GetFields() *fieldmaskpb.FieldMask {
	if x != nil {
		return x.Fields
	}
	return nil
}

func (x *ListProductCategoryRequest) GetFilter() *ProductCategoryFilter {
	if x != nil {
		return x.Filter
	}
	return nil
}

type ListProductCategoryReply struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	TotalSize     int32                  `protobuf:"varint,1,opt,name=total_size,json=totalSize,proto3" json:"total_size,omitempty"`
	FilterSize    int32                  `protobuf:"varint,2,opt,name=filter_size,json=filterSize,proto3" json:"filter_size,omitempty"`
	Items         []*ProductCategory     `protobuf:"bytes,3,rep,name=items,proto3" json:"items,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *ListProductCategoryReply) Reset() {
	*x = ListProductCategoryReply{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[8]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *ListProductCategoryReply) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*ListProductCategoryReply) ProtoMessage() {}

func (x *ListProductCategoryReply) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[8]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use ListProductCategoryReply.ProtoReflect.Descriptor instead.
func (*ListProductCategoryReply) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{8}
}

func (x *ListProductCategoryReply) GetTotalSize() int32 {
	if x != nil {
		return x.TotalSize
	}
	return 0
}

func (x *ListProductCategoryReply) GetFilterSize() int32 {
	if x != nil {
		return x.FilterSize
	}
	return 0
}

func (x *ListProductCategoryReply) GetItems() []*ProductCategory {
	if x != nil {
		return x.Items
	}
	return nil
}

type ProductCategory struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Key           string                 `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	Name          string                 `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	Path          string                 `protobuf:"bytes,3,opt,name=path,proto3" json:"path,omitempty"`
	CreatedAt     *timestamppb.Timestamp `protobuf:"bytes,4,opt,name=created_at,json=createdAt,proto3" json:"created_at,omitempty"`
	Parent        string                 `protobuf:"bytes,5,opt,name=parent,proto3" json:"parent,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *ProductCategory) Reset() {
	*x = ProductCategory{}
	mi := &file_product_api_category_v1_category_proto_msgTypes[9]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *ProductCategory) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*ProductCategory) ProtoMessage() {}

func (x *ProductCategory) ProtoReflect() protoreflect.Message {
	mi := &file_product_api_category_v1_category_proto_msgTypes[9]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use ProductCategory.ProtoReflect.Descriptor instead.
func (*ProductCategory) Descriptor() ([]byte, []int) {
	return file_product_api_category_v1_category_proto_rawDescGZIP(), []int{9}
}

func (x *ProductCategory) GetKey() string {
	if x != nil {
		return x.Key
	}
	return ""
}

func (x *ProductCategory) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

func (x *ProductCategory) GetPath() string {
	if x != nil {
		return x.Path
	}
	return ""
}

func (x *ProductCategory) GetCreatedAt() *timestamppb.Timestamp {
	if x != nil {
		return x.CreatedAt
	}
	return nil
}

func (x *ProductCategory) GetParent() string {
	if x != nil {
		return x.Parent
	}
	return ""
}

var File_product_api_category_v1_category_proto protoreflect.FileDescriptor

const file_product_api_category_v1_category_proto_rawDesc = "" +
	"\n" +
	"&product/api/category/v1/category.proto\x12\x17product.api.category.v1\x1a\x1fgoogle/protobuf/timestamp.proto\x1a(google/api/annotations/annotations.proto\x1a google/protobuf/field_mask.proto\x1a\x1cgoogle/protobuf/struct.proto\x1a\x1fgoogle/api/field_behavior.proto\x1a\x17validate/validate.proto\x1a\x15query/operation.proto\x1a.protoc-gen-openapiv2/options/annotations.proto\"h\n" +
	"\x1cCreateProductCategoryRequest\x12\x10\n" +
	"\x03key\x18\x01 \x01(\tR\x03key\x12\x1e\n" +
	"\x04name\x18\x02 \x01(\tB\n" +
	"\xe0A\x02\xfaB\x04r\x02\x10\x01R\x04name\x12\x16\n" +
	"\x06parent\x18\x03 \x01(\tR\x06parent\"\xb4\x01\n" +
	"\x1cUpdateProductCategoryRequest\x12W\n" +
	"\bcategory\x18\x01 \x01(\v2..product.api.category.v1.UpdateProductCategoryB\v\xe0A\x02\xfaB\x05\x8a\x01\x02\x10\x01R\bcategory\x12;\n" +
	"\vupdate_mask\x18\x02 \x01(\v2\x1a.google.protobuf.FieldMaskR\n" +
	"updateMask\"I\n" +
	"\x15UpdateProductCategory\x12\x1c\n" +
	"\x03key\x18\x01 \x01(\tB\n" +
	"\xe0A\x02\xfaB\x04r\x02\x10\x01R\x03key\x12\x12\n" +
	"\x04name\x18\x02 \x01(\tR\x04name\"0\n" +
	"\x1cDeleteProductCategoryRequest\x12\x10\n" +
	"\x03key\x18\x01 \x01(\tR\x03key\"B\n" +
	"\x1aDeleteProductCategoryReply\x12\x10\n" +
	"\x03key\x18\x01 \x01(\tR\x03key\x12\x12\n" +
	"\x04name\x18\x02 \x01(\tR\x04name\"9\n" +
	"\x19GetProductCategoryRequest\x12\x1c\n" +
	"\x03key\x18\x01 \x01(\tB\n" +
	"\xe0A\x02\xfaB\x04r\x02\x10\x01R\x03key\"\xcd\x01\n" +
	"\x15ProductCategoryFilter\x128\n" +
	"\x03key\x18\x01 \x01(\v2&.query.operation.StringFilterOperationR\x03key\x12:\n" +
	"\x04name\x18\x02 \x01(\v2&.query.operation.StringFilterOperationR\x04name\x12>\n" +
	"\x06parent\x18\x03 \x01(\v2&.query.operation.StringFilterOperationR\x06parent\"\x82\x02\n" +
	"\x1aListProductCategoryRequest\x12\x1f\n" +
	"\vpage_offset\x18\x01 \x01(\x05R\n" +
	"pageOffset\x12\x1b\n" +
	"\tpage_size\x18\x02 \x01(\x05R\bpageSize\x12\x16\n" +
	"\x06search\x18\x03 \x01(\tR\x06search\x12\x12\n" +
	"\x04sort\x18\x04 \x03(\tR\x04sort\x122\n" +
	"\x06fields\x18\x05 \x01(\v2\x1a.google.protobuf.FieldMaskR\x06fields\x12F\n" +
	"\x06filter\x18\x06 \x01(\v2..product.api.category.v1.ProductCategoryFilterR\x06filter\"\x9a\x01\n" +
	"\x18ListProductCategoryReply\x12\x1d\n" +
	"\n" +
	"total_size\x18\x01 \x01(\x05R\ttotalSize\x12\x1f\n" +
	"\vfilter_size\x18\x02 \x01(\x05R\n" +
	"filterSize\x12>\n" +
	"\x05items\x18\x03 \x03(\v2(.product.api.category.v1.ProductCategoryR\x05items\"\x9e\x01\n" +
	"\x0fProductCategory\x12\x10\n" +
	"\x03key\x18\x01 \x01(\tR\x03key\x12\x12\n" +
	"\x04name\x18\x02 \x01(\tR\x04name\x12\x12\n" +
	"\x04path\x18\x03 \x01(\tR\x04path\x129\n" +
	"\n" +
	"created_at\x18\x04 \x01(\v2\x1a.google.protobuf.TimestampR\tcreatedAt\x12\x16\n" +
	"\x06parent\x18\x05 \x01(\tR\x06parent2\x8a\a\n" +
	"\x16ProductCategoryService\x12\xbb\x01\n" +
	"\x13ListProductCategory\x123.product.api.category.v1.ListProductCategoryRequest\x1a1.product.api.category.v1.ListProductCategoryReply\"<\x82\xd3\xe4\x93\x026Z\x1e:\x01*\"\x19/v1/product/category/list\x12\x14/v1/product/category\x12\x96\x01\n" +
	"\x12GetProductCategory\x122.product.api.category.v1.GetProductCategoryRequest\x1a(.product.api.category.v1.ProductCategory\"\"\x82\xd3\xe4\x93\x02\x1c\x12\x1a/v1/product/category/{key}\x12\x99\x01\n" +
	"\x15CreateProductCategory\x125.product.api.category.v1.CreateProductCategoryRequest\x1a(.product.api.category.v1.ProductCategory\"\x1f\x82\xd3\xe4\x93\x02\x19:\x01*\"\x14/v1/product/category\x12\xd2\x01\n" +
	"\x15UpdateProductCategory\x125.product.api.category.v1.UpdateProductCategoryRequest\x1a(.product.api.category.v1.ProductCategory\"X\x82\xd3\xe4\x93\x02R:\x01*Z(:\x01*2#/v1/product/category/{category.key}\x1a#/v1/product/category/{category.key}\x12\xa7\x01\n" +
	"\x15DeleteProductCategory\x125.product.api.category.v1.DeleteProductCategoryRequest\x1a3.product.api.category.v1.DeleteProductCategoryReply\"\"\x82\xd3\xe4\x93\x02\x1c*\x1a/v1/product/category/{key}B3Z1github.com/go-saas/kit/product/api/category/v1;v1b\x06proto3"

var (
	file_product_api_category_v1_category_proto_rawDescOnce sync.Once
	file_product_api_category_v1_category_proto_rawDescData []byte
)

func file_product_api_category_v1_category_proto_rawDescGZIP() []byte {
	file_product_api_category_v1_category_proto_rawDescOnce.Do(func() {
		file_product_api_category_v1_category_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_product_api_category_v1_category_proto_rawDesc), len(file_product_api_category_v1_category_proto_rawDesc)))
	})
	return file_product_api_category_v1_category_proto_rawDescData
}

var file_product_api_category_v1_category_proto_msgTypes = make([]protoimpl.MessageInfo, 10)
var file_product_api_category_v1_category_proto_goTypes = []any{
	(*CreateProductCategoryRequest)(nil), // 0: product.api.category.v1.CreateProductCategoryRequest
	(*UpdateProductCategoryRequest)(nil), // 1: product.api.category.v1.UpdateProductCategoryRequest
	(*UpdateProductCategory)(nil),        // 2: product.api.category.v1.UpdateProductCategory
	(*DeleteProductCategoryRequest)(nil), // 3: product.api.category.v1.DeleteProductCategoryRequest
	(*DeleteProductCategoryReply)(nil),   // 4: product.api.category.v1.DeleteProductCategoryReply
	(*GetProductCategoryRequest)(nil),    // 5: product.api.category.v1.GetProductCategoryRequest
	(*ProductCategoryFilter)(nil),        // 6: product.api.category.v1.ProductCategoryFilter
	(*ListProductCategoryRequest)(nil),   // 7: product.api.category.v1.ListProductCategoryRequest
	(*ListProductCategoryReply)(nil),     // 8: product.api.category.v1.ListProductCategoryReply
	(*ProductCategory)(nil),              // 9: product.api.category.v1.ProductCategory
	(*fieldmaskpb.FieldMask)(nil),        // 10: google.protobuf.FieldMask
	(*query.StringFilterOperation)(nil),  // 11: query.operation.StringFilterOperation
	(*timestamppb.Timestamp)(nil),        // 12: google.protobuf.Timestamp
}
var file_product_api_category_v1_category_proto_depIdxs = []int32{
	2,  // 0: product.api.category.v1.UpdateProductCategoryRequest.category:type_name -> product.api.category.v1.UpdateProductCategory
	10, // 1: product.api.category.v1.UpdateProductCategoryRequest.update_mask:type_name -> google.protobuf.FieldMask
	11, // 2: product.api.category.v1.ProductCategoryFilter.key:type_name -> query.operation.StringFilterOperation
	11, // 3: product.api.category.v1.ProductCategoryFilter.name:type_name -> query.operation.StringFilterOperation
	11, // 4: product.api.category.v1.ProductCategoryFilter.parent:type_name -> query.operation.StringFilterOperation
	10, // 5: product.api.category.v1.ListProductCategoryRequest.fields:type_name -> google.protobuf.FieldMask
	6,  // 6: product.api.category.v1.ListProductCategoryRequest.filter:type_name -> product.api.category.v1.ProductCategoryFilter
	9,  // 7: product.api.category.v1.ListProductCategoryReply.items:type_name -> product.api.category.v1.ProductCategory
	12, // 8: product.api.category.v1.ProductCategory.created_at:type_name -> google.protobuf.Timestamp
	7,  // 9: product.api.category.v1.ProductCategoryService.ListProductCategory:input_type -> product.api.category.v1.ListProductCategoryRequest
	5,  // 10: product.api.category.v1.ProductCategoryService.GetProductCategory:input_type -> product.api.category.v1.GetProductCategoryRequest
	0,  // 11: product.api.category.v1.ProductCategoryService.CreateProductCategory:input_type -> product.api.category.v1.CreateProductCategoryRequest
	1,  // 12: product.api.category.v1.ProductCategoryService.UpdateProductCategory:input_type -> product.api.category.v1.UpdateProductCategoryRequest
	3,  // 13: product.api.category.v1.ProductCategoryService.DeleteProductCategory:input_type -> product.api.category.v1.DeleteProductCategoryRequest
	8,  // 14: product.api.category.v1.ProductCategoryService.ListProductCategory:output_type -> product.api.category.v1.ListProductCategoryReply
	9,  // 15: product.api.category.v1.ProductCategoryService.GetProductCategory:output_type -> product.api.category.v1.ProductCategory
	9,  // 16: product.api.category.v1.ProductCategoryService.CreateProductCategory:output_type -> product.api.category.v1.ProductCategory
	9,  // 17: product.api.category.v1.ProductCategoryService.UpdateProductCategory:output_type -> product.api.category.v1.ProductCategory
	4,  // 18: product.api.category.v1.ProductCategoryService.DeleteProductCategory:output_type -> product.api.category.v1.DeleteProductCategoryReply
	14, // [14:19] is the sub-list for method output_type
	9,  // [9:14] is the sub-list for method input_type
	9,  // [9:9] is the sub-list for extension type_name
	9,  // [9:9] is the sub-list for extension extendee
	0,  // [0:9] is the sub-list for field type_name
}

func init() { file_product_api_category_v1_category_proto_init() }
func file_product_api_category_v1_category_proto_init() {
	if File_product_api_category_v1_category_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_product_api_category_v1_category_proto_rawDesc), len(file_product_api_category_v1_category_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   10,
			NumExtensions: 0,
			NumServices:   1,
		},
		GoTypes:           file_product_api_category_v1_category_proto_goTypes,
		DependencyIndexes: file_product_api_category_v1_category_proto_depIdxs,
		MessageInfos:      file_product_api_category_v1_category_proto_msgTypes,
	}.Build()
	File_product_api_category_v1_category_proto = out.File
	file_product_api_category_v1_category_proto_goTypes = nil
	file_product_api_category_v1_category_proto_depIdxs = nil
}

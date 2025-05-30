// Code generated by protoc-gen-go-http. DO NOT EDIT.
// versions:
// - protoc-gen-go-http v2.8.4
// - protoc             (unknown)
// source: product/api/category/v1/category.proto

package v1

import (
	context "context"
	http "github.com/go-kratos/kratos/v2/transport/http"
	binding "github.com/go-kratos/kratos/v2/transport/http/binding"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the kratos package it is being compiled against.
var _ = new(context.Context)
var _ = binding.EncodeURL

const _ = http.SupportPackageIsVersion1

const OperationProductCategoryServiceCreateProductCategory = "/product.api.category.v1.ProductCategoryService/CreateProductCategory"
const OperationProductCategoryServiceDeleteProductCategory = "/product.api.category.v1.ProductCategoryService/DeleteProductCategory"
const OperationProductCategoryServiceGetProductCategory = "/product.api.category.v1.ProductCategoryService/GetProductCategory"
const OperationProductCategoryServiceListProductCategory = "/product.api.category.v1.ProductCategoryService/ListProductCategory"
const OperationProductCategoryServiceUpdateProductCategory = "/product.api.category.v1.ProductCategoryService/UpdateProductCategory"

type ProductCategoryServiceHTTPServer interface {
	CreateProductCategory(context.Context, *CreateProductCategoryRequest) (*ProductCategory, error)
	DeleteProductCategory(context.Context, *DeleteProductCategoryRequest) (*DeleteProductCategoryReply, error)
	GetProductCategory(context.Context, *GetProductCategoryRequest) (*ProductCategory, error)
	ListProductCategory(context.Context, *ListProductCategoryRequest) (*ListProductCategoryReply, error)
	UpdateProductCategory(context.Context, *UpdateProductCategoryRequest) (*ProductCategory, error)
}

func RegisterProductCategoryServiceHTTPServer(s *http.Server, srv ProductCategoryServiceHTTPServer) {
	r := s.Route("/")
	r.POST("/v1/product/category/list", _ProductCategoryService_ListProductCategory0_HTTP_Handler(srv))
	r.GET("/v1/product/category", _ProductCategoryService_ListProductCategory1_HTTP_Handler(srv))
	r.GET("/v1/product/category/{key}", _ProductCategoryService_GetProductCategory0_HTTP_Handler(srv))
	r.POST("/v1/product/category", _ProductCategoryService_CreateProductCategory0_HTTP_Handler(srv))
	r.PATCH("/v1/product/category/{category.key}", _ProductCategoryService_UpdateProductCategory0_HTTP_Handler(srv))
	r.PUT("/v1/product/category/{category.key}", _ProductCategoryService_UpdateProductCategory1_HTTP_Handler(srv))
	r.DELETE("/v1/product/category/{key}", _ProductCategoryService_DeleteProductCategory0_HTTP_Handler(srv))
}

func _ProductCategoryService_ListProductCategory0_HTTP_Handler(srv ProductCategoryServiceHTTPServer) func(ctx http.Context) error {
	return func(ctx http.Context) error {
		var in ListProductCategoryRequest
		if err := ctx.Bind(&in); err != nil {
			return err
		}
		if err := ctx.BindQuery(&in); err != nil {
			return err
		}
		http.SetOperation(ctx, OperationProductCategoryServiceListProductCategory)
		h := ctx.Middleware(func(ctx context.Context, req interface{}) (interface{}, error) {
			return srv.ListProductCategory(ctx, req.(*ListProductCategoryRequest))
		})
		out, err := h(ctx, &in)
		if err != nil {
			return err
		}
		reply := out.(*ListProductCategoryReply)
		return ctx.Result(200, reply)
	}
}

func _ProductCategoryService_ListProductCategory1_HTTP_Handler(srv ProductCategoryServiceHTTPServer) func(ctx http.Context) error {
	return func(ctx http.Context) error {
		var in ListProductCategoryRequest
		if err := ctx.BindQuery(&in); err != nil {
			return err
		}
		http.SetOperation(ctx, OperationProductCategoryServiceListProductCategory)
		h := ctx.Middleware(func(ctx context.Context, req interface{}) (interface{}, error) {
			return srv.ListProductCategory(ctx, req.(*ListProductCategoryRequest))
		})
		out, err := h(ctx, &in)
		if err != nil {
			return err
		}
		reply := out.(*ListProductCategoryReply)
		return ctx.Result(200, reply)
	}
}

func _ProductCategoryService_GetProductCategory0_HTTP_Handler(srv ProductCategoryServiceHTTPServer) func(ctx http.Context) error {
	return func(ctx http.Context) error {
		var in GetProductCategoryRequest
		if err := ctx.BindQuery(&in); err != nil {
			return err
		}
		if err := ctx.BindVars(&in); err != nil {
			return err
		}
		http.SetOperation(ctx, OperationProductCategoryServiceGetProductCategory)
		h := ctx.Middleware(func(ctx context.Context, req interface{}) (interface{}, error) {
			return srv.GetProductCategory(ctx, req.(*GetProductCategoryRequest))
		})
		out, err := h(ctx, &in)
		if err != nil {
			return err
		}
		reply := out.(*ProductCategory)
		return ctx.Result(200, reply)
	}
}

func _ProductCategoryService_CreateProductCategory0_HTTP_Handler(srv ProductCategoryServiceHTTPServer) func(ctx http.Context) error {
	return func(ctx http.Context) error {
		var in CreateProductCategoryRequest
		if err := ctx.Bind(&in); err != nil {
			return err
		}
		if err := ctx.BindQuery(&in); err != nil {
			return err
		}
		http.SetOperation(ctx, OperationProductCategoryServiceCreateProductCategory)
		h := ctx.Middleware(func(ctx context.Context, req interface{}) (interface{}, error) {
			return srv.CreateProductCategory(ctx, req.(*CreateProductCategoryRequest))
		})
		out, err := h(ctx, &in)
		if err != nil {
			return err
		}
		reply := out.(*ProductCategory)
		return ctx.Result(200, reply)
	}
}

func _ProductCategoryService_UpdateProductCategory0_HTTP_Handler(srv ProductCategoryServiceHTTPServer) func(ctx http.Context) error {
	return func(ctx http.Context) error {
		var in UpdateProductCategoryRequest
		if err := ctx.Bind(&in); err != nil {
			return err
		}
		if err := ctx.BindQuery(&in); err != nil {
			return err
		}
		if err := ctx.BindVars(&in); err != nil {
			return err
		}
		http.SetOperation(ctx, OperationProductCategoryServiceUpdateProductCategory)
		h := ctx.Middleware(func(ctx context.Context, req interface{}) (interface{}, error) {
			return srv.UpdateProductCategory(ctx, req.(*UpdateProductCategoryRequest))
		})
		out, err := h(ctx, &in)
		if err != nil {
			return err
		}
		reply := out.(*ProductCategory)
		return ctx.Result(200, reply)
	}
}

func _ProductCategoryService_UpdateProductCategory1_HTTP_Handler(srv ProductCategoryServiceHTTPServer) func(ctx http.Context) error {
	return func(ctx http.Context) error {
		var in UpdateProductCategoryRequest
		if err := ctx.Bind(&in); err != nil {
			return err
		}
		if err := ctx.BindQuery(&in); err != nil {
			return err
		}
		if err := ctx.BindVars(&in); err != nil {
			return err
		}
		http.SetOperation(ctx, OperationProductCategoryServiceUpdateProductCategory)
		h := ctx.Middleware(func(ctx context.Context, req interface{}) (interface{}, error) {
			return srv.UpdateProductCategory(ctx, req.(*UpdateProductCategoryRequest))
		})
		out, err := h(ctx, &in)
		if err != nil {
			return err
		}
		reply := out.(*ProductCategory)
		return ctx.Result(200, reply)
	}
}

func _ProductCategoryService_DeleteProductCategory0_HTTP_Handler(srv ProductCategoryServiceHTTPServer) func(ctx http.Context) error {
	return func(ctx http.Context) error {
		var in DeleteProductCategoryRequest
		if err := ctx.BindQuery(&in); err != nil {
			return err
		}
		if err := ctx.BindVars(&in); err != nil {
			return err
		}
		http.SetOperation(ctx, OperationProductCategoryServiceDeleteProductCategory)
		h := ctx.Middleware(func(ctx context.Context, req interface{}) (interface{}, error) {
			return srv.DeleteProductCategory(ctx, req.(*DeleteProductCategoryRequest))
		})
		out, err := h(ctx, &in)
		if err != nil {
			return err
		}
		reply := out.(*DeleteProductCategoryReply)
		return ctx.Result(200, reply)
	}
}

type ProductCategoryServiceHTTPClient interface {
	CreateProductCategory(ctx context.Context, req *CreateProductCategoryRequest, opts ...http.CallOption) (rsp *ProductCategory, err error)
	DeleteProductCategory(ctx context.Context, req *DeleteProductCategoryRequest, opts ...http.CallOption) (rsp *DeleteProductCategoryReply, err error)
	GetProductCategory(ctx context.Context, req *GetProductCategoryRequest, opts ...http.CallOption) (rsp *ProductCategory, err error)
	ListProductCategory(ctx context.Context, req *ListProductCategoryRequest, opts ...http.CallOption) (rsp *ListProductCategoryReply, err error)
	UpdateProductCategory(ctx context.Context, req *UpdateProductCategoryRequest, opts ...http.CallOption) (rsp *ProductCategory, err error)
}

type ProductCategoryServiceHTTPClientImpl struct {
	cc *http.Client
}

func NewProductCategoryServiceHTTPClient(client *http.Client) ProductCategoryServiceHTTPClient {
	return &ProductCategoryServiceHTTPClientImpl{client}
}

func (c *ProductCategoryServiceHTTPClientImpl) CreateProductCategory(ctx context.Context, in *CreateProductCategoryRequest, opts ...http.CallOption) (*ProductCategory, error) {
	var out ProductCategory
	pattern := "/v1/product/category"
	path := binding.EncodeURL(pattern, in, false)
	opts = append(opts, http.Operation(OperationProductCategoryServiceCreateProductCategory))
	opts = append(opts, http.PathTemplate(pattern))
	err := c.cc.Invoke(ctx, "POST", path, in, &out, opts...)
	if err != nil {
		return nil, err
	}
	return &out, nil
}

func (c *ProductCategoryServiceHTTPClientImpl) DeleteProductCategory(ctx context.Context, in *DeleteProductCategoryRequest, opts ...http.CallOption) (*DeleteProductCategoryReply, error) {
	var out DeleteProductCategoryReply
	pattern := "/v1/product/category/{key}"
	path := binding.EncodeURL(pattern, in, true)
	opts = append(opts, http.Operation(OperationProductCategoryServiceDeleteProductCategory))
	opts = append(opts, http.PathTemplate(pattern))
	err := c.cc.Invoke(ctx, "DELETE", path, nil, &out, opts...)
	if err != nil {
		return nil, err
	}
	return &out, nil
}

func (c *ProductCategoryServiceHTTPClientImpl) GetProductCategory(ctx context.Context, in *GetProductCategoryRequest, opts ...http.CallOption) (*ProductCategory, error) {
	var out ProductCategory
	pattern := "/v1/product/category/{key}"
	path := binding.EncodeURL(pattern, in, true)
	opts = append(opts, http.Operation(OperationProductCategoryServiceGetProductCategory))
	opts = append(opts, http.PathTemplate(pattern))
	err := c.cc.Invoke(ctx, "GET", path, nil, &out, opts...)
	if err != nil {
		return nil, err
	}
	return &out, nil
}

func (c *ProductCategoryServiceHTTPClientImpl) ListProductCategory(ctx context.Context, in *ListProductCategoryRequest, opts ...http.CallOption) (*ListProductCategoryReply, error) {
	var out ListProductCategoryReply
	pattern := "/v1/product/category"
	path := binding.EncodeURL(pattern, in, true)
	opts = append(opts, http.Operation(OperationProductCategoryServiceListProductCategory))
	opts = append(opts, http.PathTemplate(pattern))
	err := c.cc.Invoke(ctx, "GET", path, nil, &out, opts...)
	if err != nil {
		return nil, err
	}
	return &out, nil
}

func (c *ProductCategoryServiceHTTPClientImpl) UpdateProductCategory(ctx context.Context, in *UpdateProductCategoryRequest, opts ...http.CallOption) (*ProductCategory, error) {
	var out ProductCategory
	pattern := "/v1/product/category/{category.key}"
	path := binding.EncodeURL(pattern, in, false)
	opts = append(opts, http.Operation(OperationProductCategoryServiceUpdateProductCategory))
	opts = append(opts, http.PathTemplate(pattern))
	err := c.cc.Invoke(ctx, "PUT", path, in, &out, opts...)
	if err != nil {
		return nil, err
	}
	return &out, nil
}

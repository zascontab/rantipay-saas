// Code generated by protoc-gen-go-grpc-proxy. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc-proxy v1.2.0
// - protoc             (unknown)
// source: google/api/expr/conformance/v1alpha1/conformance_service.proto

package confpb

import (
	context "context"
	grpc "google.golang.org/grpc"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

var _ ConformanceServiceServer = (*conformanceServiceClientProxy)(nil)

// conformanceServiceClientProxy is the proxy to turn ConformanceService client to server interface.
type conformanceServiceClientProxy struct {
	cc ConformanceServiceClient
}

func NewConformanceServiceClientProxy(cc ConformanceServiceClient) ConformanceServiceServer {
	return &conformanceServiceClientProxy{cc}
}

func (c *conformanceServiceClientProxy) Parse(ctx context.Context, in *ParseRequest) (*ParseResponse, error) {
	return c.cc.Parse(ctx, in)
}
func (c *conformanceServiceClientProxy) Check(ctx context.Context, in *CheckRequest) (*CheckResponse, error) {
	return c.cc.Check(ctx, in)
}
func (c *conformanceServiceClientProxy) Eval(ctx context.Context, in *EvalRequest) (*EvalResponse, error) {
	return c.cc.Eval(ctx, in)
}

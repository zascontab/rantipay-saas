// Code generated by protoc-gen-go-grpc-proxy. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc-proxy v1.2.0
// - protoc             (unknown)
// source: google/logging/v2/logging_metrics.proto

package loggingpb

import (
	context "context"
	grpc "google.golang.org/grpc"
	emptypb "google.golang.org/protobuf/types/known/emptypb"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

var _ MetricsServiceV2Server = (*metricsServiceV2ClientProxy)(nil)

// metricsServiceV2ClientProxy is the proxy to turn MetricsServiceV2 client to server interface.
type metricsServiceV2ClientProxy struct {
	cc MetricsServiceV2Client
}

func NewMetricsServiceV2ClientProxy(cc MetricsServiceV2Client) MetricsServiceV2Server {
	return &metricsServiceV2ClientProxy{cc}
}

func (c *metricsServiceV2ClientProxy) ListLogMetrics(ctx context.Context, in *ListLogMetricsRequest) (*ListLogMetricsResponse, error) {
	return c.cc.ListLogMetrics(ctx, in)
}
func (c *metricsServiceV2ClientProxy) GetLogMetric(ctx context.Context, in *GetLogMetricRequest) (*LogMetric, error) {
	return c.cc.GetLogMetric(ctx, in)
}
func (c *metricsServiceV2ClientProxy) CreateLogMetric(ctx context.Context, in *CreateLogMetricRequest) (*LogMetric, error) {
	return c.cc.CreateLogMetric(ctx, in)
}
func (c *metricsServiceV2ClientProxy) UpdateLogMetric(ctx context.Context, in *UpdateLogMetricRequest) (*LogMetric, error) {
	return c.cc.UpdateLogMetric(ctx, in)
}
func (c *metricsServiceV2ClientProxy) DeleteLogMetric(ctx context.Context, in *DeleteLogMetricRequest) (*emptypb.Empty, error) {
	return c.cc.DeleteLogMetric(ctx, in)
}

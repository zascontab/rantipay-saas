// Code generated by protoc-gen-go-grpc-proxy. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc-proxy v1.2.0
// - protoc             (unknown)
// source: google/api/cloudquotas/v1/cloudquotas.proto

package cloudquotaspb

import (
	context "context"
	grpc "google.golang.org/grpc"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

var _ CloudQuotasServer = (*cloudQuotasClientProxy)(nil)

// cloudQuotasClientProxy is the proxy to turn CloudQuotas client to server interface.
type cloudQuotasClientProxy struct {
	cc CloudQuotasClient
}

func NewCloudQuotasClientProxy(cc CloudQuotasClient) CloudQuotasServer {
	return &cloudQuotasClientProxy{cc}
}

func (c *cloudQuotasClientProxy) ListQuotaInfos(ctx context.Context, in *ListQuotaInfosRequest) (*ListQuotaInfosResponse, error) {
	return c.cc.ListQuotaInfos(ctx, in)
}
func (c *cloudQuotasClientProxy) GetQuotaInfo(ctx context.Context, in *GetQuotaInfoRequest) (*QuotaInfo, error) {
	return c.cc.GetQuotaInfo(ctx, in)
}
func (c *cloudQuotasClientProxy) ListQuotaPreferences(ctx context.Context, in *ListQuotaPreferencesRequest) (*ListQuotaPreferencesResponse, error) {
	return c.cc.ListQuotaPreferences(ctx, in)
}
func (c *cloudQuotasClientProxy) GetQuotaPreference(ctx context.Context, in *GetQuotaPreferenceRequest) (*QuotaPreference, error) {
	return c.cc.GetQuotaPreference(ctx, in)
}
func (c *cloudQuotasClientProxy) CreateQuotaPreference(ctx context.Context, in *CreateQuotaPreferenceRequest) (*QuotaPreference, error) {
	return c.cc.CreateQuotaPreference(ctx, in)
}
func (c *cloudQuotasClientProxy) UpdateQuotaPreference(ctx context.Context, in *UpdateQuotaPreferenceRequest) (*QuotaPreference, error) {
	return c.cc.UpdateQuotaPreference(ctx, in)
}

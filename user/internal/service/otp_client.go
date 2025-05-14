// En user/private/service/otp_client.go (nuevo archivo)

package service

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"
)

// OTPClient es un cliente para el servicio OTP externo
type OTPClient struct {
	baseURL    string
	httpClient *http.Client
}

// GenerateOTPRequest representa la solicitud para generar un OTP
type GenerateOTPRequest struct {
	PhoneNumber   string `json:"phone_number"`
	Purpose       string `json:"purpose"`
	Length        int    `json:"length,omitempty"`
	Complexity    string `json:"complexity,omitempty"`
	ExpiryMinutes int    `json:"expiry_minutes,omitempty"`
	MaxAttempts   int    `json:"max_attempts,omitempty"`
	Channel       string `json:"channel,omitempty"`
}

// GenerateOTPResponse representa la respuesta del servicio OTP
type GenerateOTPResponse struct {
	Success     bool   `json:"success"`
	Message     string `json:"message"`
	OTPId       string `json:"otp_id,omitempty"`
	ExpiresAt   string `json:"expires_at,omitempty"`
	PhoneNumber string `json:"phone_number,omitempty"`
}

// ValidateOTPRequest representa la solicitud para validar un OTP
type ValidateOTPRequest struct {
	PhoneNumber string `json:"phone_number"`
	OTPCode     string `json:"otp_code"`
	Purpose     string `json:"purpose"`
}

// ValidateOTPResponse representa la respuesta de validación del OTP
type ValidateOTPResponse struct {
	Success     bool   `json:"success"`
	Message     string `json:"message"`
	PhoneNumber string `json:"phone_number,omitempty"`
	Valid       bool   `json:"valid"`
}

// NewOTPClient crea una nueva instancia del cliente OTP
func NewOTPClient(baseURL string) *OTPClient {
	return &OTPClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: time.Second * 10,
		},
	}
}

// GenerateOTP solicita la generación de un nuevo código OTP
func (c *OTPClient) GenerateOTP(ctx context.Context, req GenerateOTPRequest) (*GenerateOTPResponse, error) {
	reqBody, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("error al serializar la solicitud: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(
		ctx,
		"POST",
		fmt.Sprintf("%s/api/v1/otp/generate", c.baseURL),
		strings.NewReader(string(reqBody)),
	)
	if err != nil {
		return nil, fmt.Errorf("error al crear la solicitud HTTP: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("error al enviar la solicitud: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		return nil, fmt.Errorf("el servicio OTP respondió con código %d", resp.StatusCode)
	}

	var result GenerateOTPResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("error al decodificar la respuesta: %w", err)
	}

	return &result, nil
}

// ValidateOTP valida un código OTP previamente enviado
func (c *OTPClient) ValidateOTP(ctx context.Context, req ValidateOTPRequest) (*ValidateOTPResponse, error) {
	reqBody, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("error al serializar la solicitud: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(
		ctx,
		"POST",
		fmt.Sprintf("%s/api/v1/otp/validate", c.baseURL),
		strings.NewReader(string(reqBody)),
	)
	if err != nil {
		return nil, fmt.Errorf("error al crear la solicitud HTTP: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("error al enviar la solicitud: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("el servicio OTP respondió con código %d", resp.StatusCode)
	}

	var result ValidateOTPResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("error al decodificar la respuesta: %w", err)
	}

	return &result, nil
}

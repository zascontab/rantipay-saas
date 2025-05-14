package service

import (
	"context"
	"fmt"
	"time"

	klog "github.com/go-kratos/kratos/v2/log"
	"github.com/go-saas/kit/pkg/authn/jwt"
	"github.com/go-saas/kit/user/private/biz"
	"github.com/google/uuid"
)

// TokenGenerator servicio para generar tokens de autenticación
type TokenGenerator struct {
	tokenizer        jwt.Tokenizer
	config           *jwt.TokenizerConfig
	refreshTokenRepo biz.RefreshTokenRepo
	logger           *klog.Helper
}

// NewTokenGenerator crea un nuevo generador de tokens
func NewTokenGenerator(
	tokenizer jwt.Tokenizer,
	config *jwt.TokenizerConfig,
	refreshTokenRepo biz.RefreshTokenRepo,
	logger klog.Logger,
) *TokenGenerator {
	return &TokenGenerator{
		tokenizer:        tokenizer,
		config:           config,
		refreshTokenRepo: refreshTokenRepo,
		logger:           klog.NewHelper(klog.With(logger, "module", "service/token_generator")),
	}
}

// GenerateToken genera tokens de autenticación para un usuario
func (g *TokenGenerator) GenerateToken(ctx context.Context, userID uuid.UUID, clientIP, userAgent string) (*tokenModel, error) {
	// Determinar duración del refresh token (puede provenir de la configuración)
	var duration time.Duration = 30 * 24 * time.Hour // 30 días por defecto

	// Crear refresh token
	refreshToken := biz.NewRefreshToken(userID, duration, userAgent, clientIP)
	if err := g.refreshTokenRepo.Create(ctx, refreshToken); err != nil {
		return nil, fmt.Errorf("failed to create refresh token: %w", err)
	}

	// Generar access token (JWT)
	t, err := g.tokenizer.Issue(jwt.NewUserClaim(userID.String()), 0)
	if err != nil {
		return nil, fmt.Errorf("failed to issue JWT token: %w", err)
	}

	// Determinar tiempo de expiración
	exp := int32(g.config.ExpireDuration.Seconds())

	return &tokenModel{
		accessToken:  t,
		refreshToken: refreshToken.Token,
		expiresIn:    exp,
	}, nil
}

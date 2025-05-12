#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Configurando servicio Companies   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Crear estructura del proyecto
mkdir -p companies-service/{cmd/server,internal/{biz,data,service},api/companies/v1,configs,bin}

# Inicializar módulo Go
cd companies-service
go mod init github.com/rantipay/companies-service
cd ..

# Crear main.go básico
cat > companies-service/cmd/server/main.go << 'EOF'
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var (
	// flagconf is the config flag.
	flagconf string
)

func init() {
	flag.StringVar(&flagconf, "conf", "../../configs", "config path, eg: -conf config.yaml")
}

func main() {
	flag.Parse()

	logger := log.New(os.Stdout, "[Companies] ", log.LstdFlags)
	logger.Printf("Starting Companies service...")

	// Create HTTP server
	mux := http.NewServeMux()

	// Health check endpoint
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"OK"}`))
	})

	// API endpoints
	mux.HandleFunc("/api/v1/companies", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.Method {
		case http.MethodGet:
			w.Write([]byte(`{"data":[{"id":"1","name":"Rantipay Corp","status":"active"},{"id":"2","name":"Test Company","status":"active"}]}`))
		case http.MethodPost:
			w.Write([]byte(`{"data":{"id":"3","name":"New Company","status":"active"}}`))
		default:
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	})

	mux.HandleFunc("/api/v1/companies/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		id := r.URL.Path[len("/api/v1/companies/"):]
		
		if id == "" {
			http.Error(w, "Invalid company ID", http.StatusBadRequest)
			return
		}

		switch r.Method {
		case http.MethodGet:
			w.Write([]byte(fmt.Sprintf(`{"data":{"id":"%s","name":"Company %s","status":"active"}}`, id, id)))
		case http.MethodPut:
			w.Write([]byte(fmt.Sprintf(`{"data":{"id":"%s","name":"Updated Company %s","status":"active"}}`, id, id)))
		case http.MethodDelete:
			w.WriteHeader(http.StatusNoContent)
		default:
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	})

	// Start HTTP server
	server := &http.Server{
		Addr:    ":8010",
		Handler: mux,
	}

	// Graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Start the server in a goroutine
	go func() {
		logger.Printf("Companies service is listening on :8010")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Println("Shutting down server...")

	// Create a deadline to wait for
	ctx, cancel = context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		logger.Fatalf("Server forced to shutdown: %v", err)
	}

	logger.Println("Server exiting")
}
EOF

echo -e "${GREEN}✓ Archivo main.go creado${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicio Companies configurado   ${NC}"
echo -e "${GREEN}==============================================${NC}"
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	port := "8000" // Puerto por defecto
	if len(os.Args) > 1 && os.Args[1] != "" {
		port = os.Args[1]
	}

	// Manejador básico para todas las rutas
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Recibida petición: %s %s\n", r.Method, r.URL.Path)
		
		// Responder con información básica
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{
			"service": "%s",
			"status": "running",
			"message": "Versión mínima para desarrollo con Hot Reload",
			"path": "%s",
			"method": "%s"
		}`, os.Getenv("SERVICE_NAME"), r.URL.Path, r.Method)
	})

	// Iniciar servidor
	fmt.Printf("🚀 Iniciando servicio mínimo para %s en puerto %s...\n", 
		os.Getenv("SERVICE_NAME"), port)
	
	// Manejar señales para apagado graceful
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	
	// Iniciar servidor en goroutine
	go func() {
		if err := http.ListenAndServe(":"+port, nil); err != nil {
			log.Fatalf("❌ Error al iniciar servidor: %v", err)
		}
	}()
	
	fmt.Println("✅ Servidor iniciado. Presiona Ctrl+C para detener.")
	
	// Esperar señal para detener
	<-stop
	fmt.Println("🛑 Deteniendo servidor...")
}

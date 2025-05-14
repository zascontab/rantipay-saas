package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	// Configuración básica
	var port string
	flag.StringVar(&port, "port", "8000", "Puerto para el servidor HTTP")
	flag.Parse()

	// Identificar qué servicio estamos simulando
	serviceName := os.Getenv("SERVICE_NAME")
	if serviceName == "" {
		serviceName = "user-minimal"
	}

	fmt.Printf("🚀 Iniciando servidor mínimo para %s en puerto %s\n", serviceName, port)

	// Manejador para la ruta raíz
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Recibida petición: %s %s", r.Method, r.URL.Path)
		
		// Responder con información básica
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{
			"service": "%s",
			"status": "running",
			"path": "%s",
			"method": "%s",
			"timestamp": "%s"
		}`, serviceName, r.URL.Path, r.Method, time.Now().Format(time.RFC3339))
	})

	// Iniciar el servidor
	serverAddr := ":" + port
	fmt.Printf("Servidor escuchando en http://localhost:%s\n", port)
	if err := http.ListenAndServe(serverAddr, nil); err != nil {
		log.Fatalf("❌ Error al iniciar servidor: %v", err)
	}
}

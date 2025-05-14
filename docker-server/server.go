package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "time"
)

type Response struct {
    Service   string    `json:"service"`
    Status    string    `json:"status"`
    Path      string    `json:"path"`
    Method    string    `json:"method"`
    Timestamp time.Time `json:"timestamp"`
}

func main() {
    port := "80"
    if len(os.Args) > 1 {
        port = os.Args[1]
    }
    
    serviceName := "user-docker"
    if os.Getenv("SERVICE_NAME") != "" {
        serviceName = os.Getenv("SERVICE_NAME")
    }
    
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        log.Printf("Recibida petición: %s %s", r.Method, r.URL.Path)
        
        // Crear respuesta
        resp := Response{
            Service:   serviceName,
            Status:    "running",
            Path:      r.URL.Path,
            Method:    r.Method,
            Timestamp: time.Now(),
        }
        
        // Enviar respuesta JSON
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(resp)
    })
    
    fmt.Printf("Iniciando servidor en puerto %s...\n", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}

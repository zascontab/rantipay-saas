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
    log.Println("Starting Companies Service...")

    // Register handlers
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Companies Service API")
    })

    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "OK")
    })

    http.HandleFunc("/api/v1/companies", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        fmt.Fprintf(w, "{\"companies\": [{\"id\": 1, \"name\": \"Example Company\", \"type\": \"Enterprise\"}]}")
    })

    // Start HTTP server
    go func() {
        log.Println("HTTP server listening on :8010")
        if err := http.ListenAndServe(":8010", nil); err != nil {
            log.Fatalf("HTTP server failed: %v", err)
        }
    }()

    // Wait for termination signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Println("Shutting down Companies Service...")
}

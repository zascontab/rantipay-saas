package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"
)

// Respuesta estándar para compatibilidad con go-saas/kit
type Response struct {
	Data interface{} `json:"data,omitempty"`
	Code int         `json:"code,omitempty"`
	Msg  string      `json:"msg,omitempty"`
}

// Usuario representa un usuario del sistema
type User struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Email     string    `json:"email"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
}

// MenuItem representa un ítem del menú
type MenuItem struct {
	ID         string      `json:"id"`
	ParentID   string      `json:"parent_id"`
	Name       string      `json:"name"`
	Route      string      `json:"route"`
	Component  string      `json:"component"`
	Path       string      `json:"path,omitempty"`
	Redirect   string      `json:"redirect,omitempty"`
	Meta       interface{} `json:"meta,omitempty"`
	Sort       int         `json:"sort"`
	Children   []MenuItem  `json:"children,omitempty"`
	Permission string      `json:"permission,omitempty"`
	Type       string      `json:"type"`
}

// Middleware para CORS
func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

// Función para registrar rutas y logear solicitudes
func logHandler(handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Printf("[%s] %s %s", r.Method, r.URL.Path, r.RemoteAddr)
		handler(w, r)
		log.Printf("[%s] %s %s - Completado en %v", r.Method, r.URL.Path, r.RemoteAddr, time.Since(start))
	}
}

// Controlador para health check
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "OK"})
}

// Controlador para login
func loginHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Recibida solicitud de login desde %s", r.RemoteAddr)

	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var loginData struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	err := json.NewDecoder(r.Body).Decode(&loginData)
	if err != nil {
		log.Printf("Error decodificando cuerpo de solicitud: %v", err)
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	log.Printf("Intento de login para usuario: %s", loginData.Username)

	// Verificar credenciales (simplificado)
	if loginData.Username == "admin@rantipay.com" && loginData.Password == "Admin123!" {
		// Generar un token simple
		token := "dummy-token-for-testing"

		// Respuesta con el token
		w.Header().Set("Content-Type", "application/json")

		response := Response{
			Data: map[string]interface{}{
				"access_token": token,
				"token_type":   "Bearer",
				"expires_at":   time.Now().Add(24 * time.Hour),
				"user": map[string]interface{}{
					"id":         "1",
					"username":   "admin@rantipay.com",
					"first_name": "Admin",
					"last_name":  "User",
					"email":      "admin@rantipay.com",
					"role":       "admin",
				},
			},
			Code: 0,
			Msg:  "ok",
		}

		log.Printf("Login exitoso para usuario: %s", loginData.Username)
		json.NewEncoder(w).Encode(response)
		return
	}

	log.Printf("Login fallido para usuario: %s - Credenciales inválidas", loginData.Username)
	http.Error(w, "Invalid credentials", http.StatusUnauthorized)
}

// Controlador para obtener información del usuario actual
func currentUserHandler(w http.ResponseWriter, r *http.Request) {
	// Usuario ficticio fijo para pruebas
	user := map[string]interface{}{
		"id":         "1",
		"username":   "admin@rantipay.com",
		"first_name": "Admin",
		"last_name":  "User",
		"email":      "admin@rantipay.com",
		"role":       "admin",
		"created_at": time.Now().Add(-24 * time.Hour),
	}

	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: user,
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
}

// Controlador para listar usuarios
func listUsersHandler(w http.ResponseWriter, r *http.Request) {
	// Lista ficticia de usuarios para pruebas
	users := []map[string]interface{}{
		{
			"id":         "1",
			"username":   "admin@rantipay.com",
			"first_name": "Admin",
			"last_name":  "User",
			"email":      "admin@rantipay.com",
			"role":       "admin",
			"created_at": time.Now().Add(-24 * time.Hour),
		},
		{
			"id":         "2",
			"username":   "user@rantipay.com",
			"first_name": "Normal",
			"last_name":  "User",
			"email":      "user@rantipay.com",
			"role":       "user",
			"created_at": time.Now().Add(-48 * time.Hour),
		},
	}

	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: map[string]interface{}{
			"items":      users,
			"pagination": map[string]interface{}{"total": 2, "page": 1, "page_size": 10},
		},
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
}

// Implementación del endpoint logout
func logoutHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Code: 0,
		Msg:  "logged out successfully",
	}
	json.NewEncoder(w).Encode(resp)
}

// Controlador para menús disponibles - IMPORTANTE PARA SOLUCIONAR EL PROBLEMA 404
func menusHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Solicitud recibida para menus/available: %s", r.URL.Path)

	// Menús de forma directa, sin estructura MenuItem para asegurar compatibilidad completa
	menus := []map[string]interface{}{
		{
			"id":        "dashboard",
			"name":      "Dashboard",
			"route":     "/dashboard",
			"component": "LAYOUT",
			"path":      "/dashboard",
			"meta": map[string]interface{}{
				"title":    "Dashboard",
				"icon":     "DashboardOutlined",
				"hideMenu": false,
				"order":    1,
			},
			"sort": 1,
			"type": "dir",
			"children": []map[string]interface{}{
				{
					"id":        "workbench",
					"parent_id": "dashboard",
					"name":      "Workbench",
					"route":     "workbench",
					"component": "/dashboard/workbench/index",
					"path":      "workbench",
					"meta": map[string]interface{}{
						"title":    "Workbench",
						"icon":     "AppstoreOutlined",
						"hideMenu": false,
						"order":    1,
					},
					"sort": 1,
					"type": "menu",
				},
			},
		},
		{
			"id":        "system",
			"name":      "System",
			"route":     "/system",
			"component": "LAYOUT",
			"path":      "/system",
			"meta": map[string]interface{}{
				"title":    "System",
				"icon":     "SettingOutlined",
				"hideMenu": false,
				"order":    100,
			},
			"sort": 100,
			"type": "dir",
			"children": []map[string]interface{}{
				{
					"id":        "users",
					"parent_id": "system",
					"name":      "Users",
					"route":     "users",
					"component": "/system/users/index",
					"path":      "users",
					"meta": map[string]interface{}{
						"title":    "Users",
						"icon":     "UserOutlined",
						"hideMenu": false,
						"order":    1,
					},
					"sort": 1,
					"type": "menu",
				},
				{
					"id":        "companies",
					"parent_id": "system",
					"name":      "Companies",
					"route":     "companies",
					"component": "/system/companies/index",
					"path":      "companies",
					"meta": map[string]interface{}{
						"title":    "Companies",
						"icon":     "BankOutlined",
						"hideMenu": false,
						"order":    2,
					},
					"sort": 2,
					"type": "menu",
				},
			},
		},
	}

	w.Header().Set("Content-Type", "application/json")

	// Importante: Responder solo con el arreglo de menús, no con la estructura Response
	// Esta es una de las claves para resolver el problema de 404
	jsonData, _ := json.Marshal(menus)
	w.Write(jsonData)

	log.Printf("Respuesta enviada para menús: %s", string(jsonData[:100])+"...")
}

// Controlador para el websocket de tiempo real
func realtimeHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Solicitud recibida para realtime: %s", r.URL.Path)

	if strings.Contains(r.URL.Path, "/ws") {
		// Para solicitudes WebSocket, configurar los encabezados necesarios
		w.Header().Set("Upgrade", "websocket")
		w.Header().Set("Connection", "Upgrade")
		// Importante: En una implementación real, aquí se establecería la conexión WebSocket
		// Para este mockup, solo devolvemos un código 101
		w.WriteHeader(http.StatusSwitchingProtocols)
		return
	}

	// Para solicitudes no WebSocket
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: map[string]interface{}{
			"status": "connected",
			"type":   "realtime",
		},
		Code: 0,
		Msg:  "realtime connection established",
	}
	json.NewEncoder(w).Encode(resp)
}

// Controlador catch-all para depuración
func catchAllHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Ruta no manejada: %s", r.URL.Path)

	// Responder con información útil para depuración
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: map[string]interface{}{
			"path":    r.URL.Path,
			"method":  r.Method,
			"query":   r.URL.Query(),
			"message": "Esta ruta no está implementada en el servicio simplificado",
		},
		Code: 1,
		Msg:  "unhandled path",
	}
	json.NewEncoder(w).Encode(resp)
}

// Función principal
func main() {
	// Health check
	http.HandleFunc("/health", corsMiddleware(logHandler(healthHandler)))

	// Rutas de autenticación
	http.HandleFunc("/v1/auth/login", corsMiddleware(logHandler(loginHandler)))
	http.HandleFunc("/v1/auth/logout", corsMiddleware(logHandler(logoutHandler)))

	// Rutas de usuario
	http.HandleFunc("/v1/user/me", corsMiddleware(logHandler(currentUserHandler)))
	http.HandleFunc("/v1/user/all", corsMiddleware(logHandler(listUsersHandler)))
	http.HandleFunc("/v1/user/health", corsMiddleware(logHandler(healthHandler)))

	// IMPORTANTES: Los endpoints problemáticos
	http.HandleFunc("/v1/sys/menus/available", corsMiddleware(logHandler(menusHandler)))
	http.HandleFunc("/v1/realtime/connect/ws", corsMiddleware(logHandler(realtimeHandler)))

	// La ruta raíz
	http.HandleFunc("/", corsMiddleware(logHandler(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" {
			fmt.Fprintf(w, "Simple User Service - Implementación simplificada para Rantipay SaaS")
			return
		}
		catchAllHandler(w, r)
	})))

	// Iniciar servidor
	port := 8000
	fmt.Printf("Simple User Service running on port %d\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}

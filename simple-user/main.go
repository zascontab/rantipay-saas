package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
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
		
		response := map[string]interface{}{
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

// Controlador para menús disponibles
func menusHandler(w http.ResponseWriter, r *http.Request) {
	// Menú simplificado para el dashboard
	menus := []MenuItem{
		{
			ID:        "dashboard",
			Name:      "Dashboard",
			Route:     "/dashboard",
			Component: "LAYOUT",
			Path:      "/dashboard",
			Meta: map[string]interface{}{
				"title":    "Dashboard",
				"icon":     "DashboardOutlined",
				"hideMenu": false,
				"order":    1,
			},
			Sort: 1,
			Type: "dir",
			Children: []MenuItem{
				{
					ID:        "workbench",
					ParentID:  "dashboard",
					Name:      "Workbench",
					Route:     "workbench",
					Component: "/dashboard/workbench/index",
					Path:      "workbench",
					Meta: map[string]interface{}{
						"title":    "Workbench",
						"icon":     "AppstoreOutlined",
						"hideMenu": false,
						"order":    1,
					},
					Sort: 1,
					Type: "menu",
				},
			},
		},
		{
			ID:        "system",
			Name:      "System",
			Route:     "/system",
			Component: "LAYOUT",
			Path:      "/system",
			Meta: map[string]interface{}{
				"title":    "System",
				"icon":     "SettingOutlined",
				"hideMenu": false,
				"order":    100,
			},
			Sort: 100,
			Type: "dir",
			Children: []MenuItem{
				{
					ID:        "users",
					ParentID:  "system",
					Name:      "Users",
					Route:     "users",
					Component: "/system/users/index",
					Path:      "users",
					Meta: map[string]interface{}{
						"title":    "Users",
						"icon":     "UserOutlined",
						"hideMenu": false,
						"order":    1,
					},
					Sort: 1,
					Type: "menu",
				},
				{
					ID:        "companies",
					ParentID:  "system",
					Name:      "Companies",
					Route:     "companies",
					Component: "/system/companies/index",
					Path:      "companies",
					Meta: map[string]interface{}{
						"title":    "Companies",
						"icon":     "BankOutlined",
						"hideMenu": false,
						"order":    2,
					},
					Sort: 2,
					Type: "menu",
				},
			},
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: menus,
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
}

// Controlador para el websocket de tiempo real
func realtimeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotImplemented)
	resp := Response{
		Code: 1,
		Msg:  "Realtime service not implemented in this version",
	}
	json.NewEncoder(w).Encode(resp)
}

// Función principal
func main() {
	// Rutas con middleware
	http.HandleFunc("/health", corsMiddleware(logHandler(healthHandler)))
	http.HandleFunc("/v1/auth/login", corsMiddleware(logHandler(loginHandler)))
	http.HandleFunc("/v1/auth/logout", corsMiddleware(logHandler(logoutHandler)))
	http.HandleFunc("/v1/user/me", corsMiddleware(logHandler(currentUserHandler)))
	http.HandleFunc("/v1/user/all", corsMiddleware(logHandler(listUsersHandler)))
	
	// Nuevas rutas para compatibilidad con go-saas/kit
	http.HandleFunc("/v1/sys/menus/available", corsMiddleware(logHandler(menusHandler)))
	http.HandleFunc("/v1/realtime/connect/ws", corsMiddleware(logHandler(realtimeHandler)))
	
	// Iniciar servidor
	port := 8000
	fmt.Printf("Simple User Service running on port %d\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}

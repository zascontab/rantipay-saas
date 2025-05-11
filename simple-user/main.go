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

// Controlador para login normal
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

	// Aceptar cualquier credencial válida
	if loginData.Username != "" && loginData.Password != "" {
		// Generar un token simple
		token := "dummy-token-for-testing-" + fmt.Sprintf("%d", time.Now().Unix())

		// Respuesta con el token
		w.Header().Set("Content-Type", "application/json")

		response := Response{
			Data: map[string]interface{}{
				"access_token": token,
				"token_type":   "Bearer",
				"expires_at":   time.Now().Add(24 * time.Hour),
				"user": map[string]interface{}{
					"id":         "1",
					"username":   loginData.Username,
					"first_name": "Admin",
					"last_name":  "User",
					"email":      loginData.Username,
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
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)
	json.NewEncoder(w).Encode(Response{
		Code: 401,
		Msg:  "Invalid username or password",
	})
}

// NUEVO: Controlador para web login
func webLoginHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Recibida solicitud de web login desde %s", r.RemoteAddr)

	if r.Method == http.MethodGet {
		// Para GET, devolvemos información sobre el login web
		w.Header().Set("Content-Type", "application/json")
		resp := Response{
			Data: map[string]interface{}{
				"providers": []string{"default"},
				"redirect":  r.URL.Query().Get("redirect"),
			},
			Code: 0,
			Msg:  "ok",
		}
		json.NewEncoder(w).Encode(resp)
		return
	}

	if r.Method == http.MethodPost {
		// Para POST, simulamos un login web
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

		// Devolvemos una respuesta exitosa siempre
		w.Header().Set("Content-Type", "application/json")
		resp := Response{
			Data: map[string]interface{}{
				"redirect": "/dashboard/workbench",
			},
			Code: 0,
			Msg:  "ok",
		}
		json.NewEncoder(w).Encode(resp)
		return
	}

	http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
}

// NUEVO: Controlador para web logout
func webLogoutHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Recibida solicitud de web logout desde %s", r.RemoteAddr)

	// Simulamos un logout web exitoso
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: map[string]interface{}{
			"redirect": "/user/login",
		},
		Code: 0,
		Msg:  "logged out successfully",
	}
	json.NewEncoder(w).Encode(resp)
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

// NUEVO: Controlador para perfil de cuenta
func accountProfileHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Recibida solicitud de perfil de cuenta desde %s", r.RemoteAddr)

	// Perfil ficticio para pruebas
	profile := map[string]interface{}{
		"id":         "1",
		"username":   "admin@rantipay.com",
		"first_name": "Admin",
		"last_name":  "User",
		"email":      "admin@rantipay.com",
		"role":       "admin",
		"created_at": time.Now().Add(-24 * time.Hour),
		"settings": map[string]interface{}{
			"theme":     "light",
			"language":  "en-US",
			"time_zone": "UTC",
		},
	}

	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: profile,
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

// NUEVO: Controlador para planes disponibles
func plansAvailableHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Recibida solicitud de planes disponibles desde %s", r.RemoteAddr)

	// Planes ficticios para pruebas
	plans := []map[string]interface{}{
		{
			"id":          "1",
			"name":        "Free",
			"description": "Basic features for free",
			"price":       0,
			"features":    []string{"1 User", "Basic Support", "Basic Features"},
			"is_active":   true,
		},
		{
			"id":          "2",
			"name":        "Premium",
			"description": "Premium features for businesses",
			"price":       9.99,
			"features":    []string{"5 Users", "Priority Support", "All Features"},
			"is_active":   true,
		},
		{
			"id":          "3",
			"name":        "Enterprise",
			"description": "Enterprise-grade features",
			"price":       49.99,
			"features":    []string{"Unlimited Users", "24/7 Support", "Custom Features"},
			"is_active":   true,
		},
	}

	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: plans,
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
}

// NUEVO: Controlador para mensajes de localización
func localeMsgsHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Recibida solicitud de mensajes de localización desde %s", r.RemoteAddr)

	// Mensajes ficticios para pruebas
	msgs := map[string]interface{}{
		"en-US": map[string]string{
			"app.welcome":   "Welcome to Rantipay SaaS",
			"app.login":     "Login",
			"app.logout":    "Logout",
			"app.dashboard": "Dashboard",
		},
		"es-ES": map[string]string{
			"app.welcome":   "Bienvenido a Rantipay SaaS",
			"app.login":     "Iniciar sesión",
			"app.logout":    "Cerrar sesión",
			"app.dashboard": "Panel de control",
		},
	}

	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: msgs,
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
}

// NUEVO: Controlador para notificaciones
func notificationListHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Recibida solicitud de lista de notificaciones desde %s", r.RemoteAddr)

	// Notificaciones ficticias para pruebas
	notifications := []map[string]interface{}{
		{
			"id":        "1",
			"type":      "info",
			"title":     "Welcome to Rantipay SaaS",
			"content":   "Thank you for choosing Rantipay SaaS.",
			"read":      false,
			"created_at": time.Now().Add(-1 * time.Hour),
		},
		{
			"id":        "2",
			"type":      "success",
			"title":     "Account Setup Complete",
			"content":   "Your account has been configured successfully.",
			"read":      true,
			"created_at": time.Now().Add(-2 * time.Hour),
		},
	}

	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: map[string]interface{}{
			"items":       notifications,
			"total":       2,
			"unread":      1,
			"pagination": map[string]interface{}{"total": 2, "page": 1, "page_size": 10},
		},
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
}

// Controlador para menús disponibles
func menusHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Solicitud recibida para menus/available: %s", r.URL.Path)

	// Menús de forma directa, sin estructura Response
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

// Controlador para stripe config
func stripeConfigHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Solicitud recibida para stripe config: %s", r.URL.Path)

	// Respuesta con configuración ficticia de Stripe
	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: map[string]interface{}{
			"publish_key": "pk_test_dummy_key",
			"is_test":     true,
		},
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
}

// Controlador para tenant/saas current
func saasCurrentHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Solicitud recibida para saas/current: %s", r.URL.Path)

	// Datos ficticios de tenant actual
	tenant := map[string]interface{}{
		"id":          "1",
		"name":        "rantipay",
		"display_name": "Rantipay SaaS",
		"type":        "platform",
		"status":      "active",
		"plan": map[string]interface{}{
			"id":    "1",
			"name":  "Business",
			"price": 99.99,
		},
		"created_at": time.Now().Add(-30 * 24 * time.Hour),
	}

	w.Header().Set("Content-Type", "application/json")
	resp := Response{
		Data: tenant,
		Code: 0,
		Msg:  "ok",
	}
	json.NewEncoder(w).Encode(resp)
	log.Printf("Respuesta enviada para saas/current")
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
	http.HandleFunc("/v1/auth/web/login", corsMiddleware(logHandler(webLoginHandler)))
	http.HandleFunc("/v1/auth/web/logout", corsMiddleware(logHandler(webLogoutHandler)))

	// Rutas de usuario
	http.HandleFunc("/v1/user/me", corsMiddleware(logHandler(currentUserHandler)))
	http.HandleFunc("/v1/user/all", corsMiddleware(logHandler(listUsersHandler)))
	http.HandleFunc("/v1/user/health", corsMiddleware(logHandler(healthHandler)))

	// Rutas de cuenta
	http.HandleFunc("/v1/account/profile", corsMiddleware(logHandler(accountProfileHandler)))

	// Rutas de SaaS/Tenant
	http.HandleFunc("/v1/saas/current", corsMiddleware(logHandler(saasCurrentHandler)))
	http.HandleFunc("/v1/saas/plans/available", corsMiddleware(logHandler(plansAvailableHandler)))

	// Rutas de pago
	http.HandleFunc("/v1/payment/stripe/config", corsMiddleware(logHandler(stripeConfigHandler)))

	// Rutas de sistema
	http.HandleFunc("/v1/sys/menus/available", corsMiddleware(logHandler(menusHandler)))
	http.HandleFunc("/v1/sys/locale/msgs", corsMiddleware(logHandler(localeMsgsHandler)))

	// Rutas de realtime
	http.HandleFunc("/v1/realtime/connect/ws", corsMiddleware(logHandler(realtimeHandler)))
	http.HandleFunc("/v1/realtime/notification/list", corsMiddleware(logHandler(notificationListHandler)))

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

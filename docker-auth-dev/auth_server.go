package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

// Estructuras de datos para Auth Service
type User struct {
	ID        string    `json:"id"`
	Email     string    `json:"email,omitempty"`
	Phone     string    `json:"phone,omitempty"`
	Password  string    `json:"-"` // No devolver contraseña en respuestas
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type SignupRequest struct {
	Email    string `json:"email,omitempty"`
	Phone    string `json:"phone,omitempty"`
	Password string `json:"password,omitempty"`
}

type SigninRequest struct {
	Email    string `json:"email,omitempty"`
	Phone    string `json:"phone,omitempty"`
	Password string `json:"password,omitempty"`
	OTPCode  string `json:"otp_code,omitempty"`
}

type OTPRequest struct {
	Phone string `json:"phone"`
}

type OTPVerifyRequest struct {
	Phone string `json:"phone"`
	Code  string `json:"code"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

type SuccessResponse struct {
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

// Almacén de usuarios en memoria para desarrollo
var (
	users     = make(map[string]User)
	otpCodes  = make(map[string]string) // phone -> code
	userCount = 0
)

func main() {
	port := "80"
	if len(os.Args) > 1 {
		port = os.Args[1]
	}

	// Configurar rutas para la API
	http.HandleFunc("/api/auth/signup", handleSignup)
	http.HandleFunc("/api/auth/signin", handleSignin)
	http.HandleFunc("/api/auth/otp/send", handleOTPSend)
	http.HandleFunc("/api/auth/otp/verify", handleOTPVerify)
	http.HandleFunc("/api/auth/users", handleListUsers)
	http.HandleFunc("/", handleRoot)

	// Iniciar servidor
	serverAddr := fmt.Sprintf(":%s", port)
	fmt.Printf("🔐 Auth Service en desarrollo iniciando en puerto %s...\n", port)
	fmt.Printf("📌 Endpoints disponibles:\n")
	fmt.Printf("   - POST /api/auth/signup\n")
	fmt.Printf("   - POST /api/auth/signin\n")
	fmt.Printf("   - POST /api/auth/otp/send\n")
	fmt.Printf("   - POST /api/auth/otp/verify\n")
	fmt.Printf("   - GET /api/auth/users\n")

	if err := http.ListenAndServe(serverAddr, nil); err != nil {
		log.Fatalf("❌ Error al iniciar servidor: %v", err)
	}
}

// Manejadores para cada endpoint
func handleRoot(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	
	// Mostrar información del servicio
	resp := SuccessResponse{
		Message: "Auth Service API - Entorno de Desarrollo",
		Data: map[string]interface{}{
			"endpoints": []string{
				"POST /api/auth/signup - Registro con email o teléfono",
				"POST /api/auth/signin - Inicio de sesión con email o teléfono",
				"POST /api/auth/otp/send - Enviar código OTP al teléfono",
				"POST /api/auth/otp/verify - Verificar código OTP",
				"GET /api/auth/users - Listar usuarios (solo desarrollo)",
			},
			"version": "0.1.0-dev",
		},
	}
	
	json.NewEncoder(w).Encode(resp)
}

func handleSignup(w http.ResponseWriter, r *http.Request) {
	// Solo aceptar POST
	if r.Method != "POST" {
		respondWithError(w, "Método no permitido", http.StatusMethodNotAllowed)
		return
	}

	// Decodificar request
	var req SignupRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		respondWithError(w, "JSON inválido", http.StatusBadRequest)
		return
	}

	// Validaciones
	if req.Password == "" {
		respondWithError(w, "Contraseña requerida", http.StatusBadRequest)
		return
	}

	// Verificar que se proporcionó email o teléfono
	if req.Email == "" && req.Phone == "" {
		respondWithError(w, "Se requiere email o teléfono", http.StatusBadRequest)
		return
	}

	// Validar email si se proporciona
	if req.Email != "" {
		if !isValidEmail(req.Email) {
			respondWithError(w, "Email inválido", http.StatusBadRequest)
			return
		}
		
		// Verificar si el email ya existe
		for _, user := range users {
			if user.Email == req.Email {
				respondWithError(w, "El email ya está registrado", http.StatusConflict)
				return
			}
		}
	}

	// Validar teléfono si se proporciona
	if req.Phone != "" {
		if !isValidPhone(req.Phone) {
			respondWithError(w, "Teléfono inválido. Debe tener formato +123456789", http.StatusBadRequest)
			return
		}
		
		// Verificar si el teléfono ya existe
		for _, user := range users {
			if user.Phone == req.Phone {
				respondWithError(w, "El teléfono ya está registrado", http.StatusConflict)
				return
			}
		}
	}

	// Crear usuario
	userCount++
	userID := fmt.Sprintf("user_%d", userCount)
	newUser := User{
		ID:        userID,
		Email:     req.Email,
		Phone:     req.Phone,
		Password:  req.Password, // En producción se debe hashear
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	
	// Guardar usuario
	users[userID] = newUser
	
	// Responder con éxito
	respondWithSuccess(w, "Usuario registrado correctamente", map[string]string{
		"user_id": userID,
	})
}

func handleSignin(w http.ResponseWriter, r *http.Request) {
	// Solo aceptar POST
	if r.Method != "POST" {
		respondWithError(w, "Método no permitido", http.StatusMethodNotAllowed)
		return
	}

	// Decodificar request
	var req SigninRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		respondWithError(w, "JSON inválido", http.StatusBadRequest)
		return
	}

	// Verificar que proporcione email o teléfono
	if req.Email == "" && req.Phone == "" {
		respondWithError(w, "Se requiere email o teléfono", http.StatusBadRequest)
		return
	}

	// Verificar login por email/password
	if req.Email != "" && req.Password != "" {
		// Buscar usuario por email
		var foundUser User
		var found bool
		for _, user := range users {
			if user.Email == req.Email {
				foundUser = user
				found = true
				break
			}
		}

		// Verificar si el usuario existe
		if !found {
			respondWithError(w, "Credenciales inválidas", http.StatusUnauthorized)
			return
		}

		// Verificar contraseña
		if foundUser.Password != req.Password {
			respondWithError(w, "Credenciales inválidas", http.StatusUnauthorized)
			return
		}

		// Login exitoso
		respondWithSuccess(w, "Inicio de sesión exitoso", map[string]string{
			"user_id": foundUser.ID,
			"token":   "jwt.token.example", // En producción, generar JWT real
		})
		return
	}

	// Verificar login por teléfono/OTP
	if req.Phone != "" && req.OTPCode != "" {
		// Verificar que el teléfono exista
		var foundUser User
		var found bool
		for _, user := range users {
			if user.Phone == req.Phone {
				foundUser = user
				found = true
				break
			}
		}

		if !found {
			respondWithError(w, "Usuario no encontrado", http.StatusUnauthorized)
			return
		}

		// Verificar OTP
		if otpCode, exists := otpCodes[req.Phone]; !exists || otpCode != req.OTPCode {
			respondWithError(w, "Código OTP inválido", http.StatusUnauthorized)
			return
		}

		// Eliminar OTP usado
		delete(otpCodes, req.Phone)

		// Login exitoso
		respondWithSuccess(w, "Inicio de sesión exitoso", map[string]string{
			"user_id": foundUser.ID,
			"token":   "jwt.token.example", // En producción, generar JWT real
		})
		return
	}

	// Si no proporcionó credenciales correctas
	respondWithError(w, "Credenciales incompletas", http.StatusBadRequest)
}

func handleOTPSend(w http.ResponseWriter, r *http.Request) {
	// Solo aceptar POST
	if r.Method != "POST" {
		respondWithError(w, "Método no permitido", http.StatusMethodNotAllowed)
		return
	}

	// Decodificar request
	var req OTPRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		respondWithError(w, "JSON inválido", http.StatusBadRequest)
		return
	}

	// Validar teléfono
	if req.Phone == "" || !isValidPhone(req.Phone) {
		respondWithError(w, "Teléfono inválido", http.StatusBadRequest)
		return
	}

	// Generar código OTP (en producción se integraría con servicio OTP existente)
	otpCode := generateOTPCode()
	otpCodes[req.Phone] = otpCode

	// Simular envío de OTP
	log.Printf("📲 OTP generado para %s: %s", req.Phone, otpCode)

	// Respuesta exitosa
	respondWithSuccess(w, "Código OTP enviado", map[string]string{
		"phone": req.Phone,
		"code":  otpCode, // En producción no se debería devolver el código
	})
}

func handleOTPVerify(w http.ResponseWriter, r *http.Request) {
	// Solo aceptar POST
	if r.Method != "POST" {
		respondWithError(w, "Método no permitido", http.StatusMethodNotAllowed)
		return
	}

	// Decodificar request
	var req OTPVerifyRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		respondWithError(w, "JSON inválido", http.StatusBadRequest)
		return
	}

	// Validar datos
	if req.Phone == "" || req.Code == "" {
		respondWithError(w, "Teléfono y código son requeridos", http.StatusBadRequest)
		return
	}

	// Verificar código OTP
	if otpCode, exists := otpCodes[req.Phone]; !exists || otpCode != req.Code {
		respondWithError(w, "Código OTP inválido", http.StatusUnauthorized)
		return
	}

	// Eliminar OTP usado
	delete(otpCodes, req.Phone)

	// Verificación exitosa
	respondWithSuccess(w, "Código OTP verificado correctamente", nil)
}

func handleListUsers(w http.ResponseWriter, r *http.Request) {
	// Solo GET permitido
	if r.Method != "GET" {
		respondWithError(w, "Método no permitido", http.StatusMethodNotAllowed)
		return
	}

	// Preparar lista de usuarios (sin contraseñas)
	userList := make([]User, 0, len(users))
	for _, user := range users {
		user.Password = "" // No enviar contraseña
		userList = append(userList, user)
	}

	// Responder con la lista
	respondWithSuccess(w, fmt.Sprintf("Total usuarios: %d", len(userList)), userList)
}

// Funciones auxiliares
func respondWithError(w http.ResponseWriter, message string, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	response := ErrorResponse{Error: message}
	json.NewEncoder(w).Encode(response)
}

func respondWithSuccess(w http.ResponseWriter, message string, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	response := SuccessResponse{
		Message: message,
		Data:    data,
	}
	json.NewEncoder(w).Encode(response)
}

func isValidEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	match, _ := regexp.MatchString(pattern, email)
	return match
}

func isValidPhone(phone string) bool {
	// Validar formato +123456789
	return strings.HasPrefix(phone, "+") && len(phone) > 8
}

func generateOTPCode() string {
	// En un entorno real, generaríamos un código aleatorio
	// Para desarrollo, usamos un código fijo para facilitar pruebas
	return "123456"
}

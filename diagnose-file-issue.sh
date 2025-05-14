#!/bin/bash

# Este script crea una versión de diagnóstico simplificada para encontrar el archivo faltante

echo "🔍 Iniciando diagnóstico detallado del problema..."

PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
SERVICE="user"  # Empezamos con el servicio user, puedes cambiarlo a saas o sys

# Crear directorio para el código de diagnóstico
mkdir -p $PROJECT_ROOT/$SERVICE/debug
cd $PROJECT_ROOT/$SERVICE

# Crear un programa Go simple que imprime la información del error
cat > debug/debug.go << 'EOF'
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"runtime/debug"
)

func main() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("🚨 RECOVERED PANIC:", r)
			fmt.Println("🚨 STACK TRACE:")
			debug.PrintStack()
		}
	}()

	// Imprimir información del entorno
	fmt.Println("🔍 DIAGNÓSTICO DE ARCHIVO NO ENCONTRADO")
	fmt.Println("====================================")
	fmt.Println("📂 Directorio de trabajo:", mustGetwd())
	fmt.Println("📝 Variables de entorno:")
	for _, env := range os.Environ() {
		fmt.Println("   ", env)
	}

	// Intentar abrir el archivo de configuración
	configFile := "./configs/config.yaml"
	fmt.Println("🔄 Intentando abrir:", configFile)
	_, err := os.Stat(configFile)
	if err != nil {
		fmt.Println("❌ Error al abrir archivo:", err)
	} else {
		fmt.Println("✅ Archivo encontrado:", configFile)
	}

	// Intentar abrir los directorios comunes
	checkPaths := []string{
		"./configs",
		"../configs.dev",
		"./cmd",
		"./internal",
		"./internal/server",
		"./internal/data",
	}

	for _, path := range checkPaths {
		fmt.Println("🔄 Verificando directorio:", path)
		fi, err := os.Stat(path)
		if err != nil {
			fmt.Println("❌ Error:", err)
		} else if fi.IsDir() {
			fmt.Println("✅ Directorio encontrado:", path)
			// Listar archivos en el directorio
			files, err := os.ReadDir(path)
			if err != nil {
				fmt.Println("  ❌ Error al listar archivos:", err)
			} else {
				fmt.Println("  📁 Contenido:")
				for _, file := range files {
					fmt.Printf("    - %s (%s)\n", file.Name(), fileType(file))
				}
			}
		} else {
			fmt.Println("ℹ️ No es un directorio:", path)
		}
	}

	// Ejecutar código principal para ver dónde falla
	fmt.Println("\n🧪 EJECUTANDO CÓDIGO PRINCIPAL PARA DETECTAR ERROR")
	fmt.Println("====================================")
	
	// Intentar cargar el código principal con recuperación de pánico
	fmt.Println("🔄 Cargando archivo principal: ./cmd/user/main.go")
	executeMain()
}

func executeMain() {
	// Intenta ejecutar el código original
	fmt.Println("⚠️ Esto simulará la ejecución del código principal para detectar dónde ocurre el error...")
	
	// Obtener la ruta completa del ejecutable user
	exePath, err := filepath.Abs("./cmd/user/main.go")
	if err != nil {
		fmt.Println("❌ Error al obtener ruta del ejecutable:", err)
		return
	}
	
	fmt.Println("📝 Ruta del ejecutable:", exePath)
	
	// Ejecutar el programa original para ver el error
	cmd := exec.Command("go", "run", "-v", exePath)
	cmd.Env = os.Environ()
	output, err := cmd.CombinedOutput()
	
	fmt.Println("📝 Salida del programa original:")
	fmt.Println(string(output))
	
	if err != nil {
		fmt.Println("❌ Error al ejecutar el programa:", err)
	}
}

func mustGetwd() string {
	dir, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	return dir
}

func fileType(file os.DirEntry) string {
	if file.IsDir() {
		return "directorio"
	}
	return "archivo"
}
EOF

# Añadir la importación exec que falta
sed -i '5i\\t"os/exec"' debug/debug.go

# Compilar y ejecutar el diagnóstico
echo "🔨 Compilando programa de diagnóstico..."
go build -o debug/diagtool debug/debug.go

if [ -f debug/diagtool ]; then
    echo "✅ Programa de diagnóstico compilado correctamente."
    echo "🚀 Ejecutando diagnóstico..."
    ./debug/diagtool > $PROJECT_ROOT/logs/$SERVICE-diagnostico.log 2>&1
    
    echo "📝 Diagnóstico guardado en $PROJECT_ROOT/logs/$SERVICE-diagnostico.log"
    echo "📊 Mostrando resultados:"
    cat $PROJECT_ROOT/logs/$SERVICE-diagnostico.log
else
    echo "❌ Error al compilar el programa de diagnóstico."
fi

echo ""
echo "🔍 Diagnóstico completo. Si el error persiste, por favor envía el archivo de log para análisis."
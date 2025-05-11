# Plan de Integración de Servicios Personalizados con Rantipay SaaS Híbrido

Este documento describe el enfoque para integrar los servicios personalizados de Rantipay con el sistema híbrido go-saas/kit simplificado.

## Arquitectura Actual

Actualmente, tenemos un sistema híbrido con los siguientes componentes funcionando:
- Frontend: Basado en go-saas/kit-frontend, disponible en http://localhost:8080
- API Gateway: Basado en NGINX, disponible en http://localhost:81
- Servicio User Simplificado: Un servicio Go básico, disponible en http://localhost:8000
- Infraestructura:
  - MySQL: Base de datos relacional
  - Redis: Caché
  - ETCD: Registro de servicios y descubrimiento

## Plan de Integración por Fases

### Fase 1: Integración del Servicio de Compañías

#### Paso 1: Crear estructura básica del servicio
- Crear un nuevo directorio companies-service
- Implementar un servicio Go básico con endpoints para CRUD de compañías
- Configurar conexión a la base de datos compartida MySQL

#### Paso 2: Integrar con el API Gateway
- Actualizar la configuración de NGINX para incluir rutas al servicio de compañías
- Configurar autenticación básica para proteger los endpoints

#### Paso 3: Crear UI básica
- Extender el frontend para incluir pantallas para gestión de compañías
- Integrar con el API Gateway para las operaciones CRUD

### Fase 2: Integración del Servicio de Delivery

#### Paso 1: Adaptar el servicio existente
- Revisar y adaptar el servicio de Delivery existente para la nueva arquitectura
- Implementar endpoints compatibles con el API Gateway

#### Paso 2: Integrar con el API Gateway
- Actualizar la configuración de NGINX para incluir rutas al servicio de Delivery
- Configurar autenticación y autorización para proteger los endpoints

#### Paso 3: Crear UI para Delivery
- Extender el frontend para incluir pantallas para gestión de Delivery
- Integrar con el API Gateway para las operaciones necesarias

### Fase 3: Integración de OTP y WhatsApp Service

#### Paso 1: Adaptar los servicios existentes
- Revisar y adaptar los servicios para la nueva arquitectura
- Implementar endpoints compatibles con el API Gateway

#### Paso 2: Integrar con el API Gateway
- Actualizar la configuración de NGINX para incluir rutas a los servicios
- Configurar autenticación y autorización para proteger los endpoints

#### Paso 3: Crear UI para gestión de notificaciones
- Extender el frontend para incluir pantallas para gestión de notificaciones
- Integrar con el API Gateway para las operaciones necesarias

### Fase 4: Integración de Servicios Financieros

#### Paso 1: Adaptar los servicios existentes
- Revisar y adaptar los servicios para la nueva arquitectura
- Implementar endpoints compatibles con el API Gateway

#### Paso 2: Integrar con el API Gateway
- Actualizar la configuración de NGINX para incluir rutas a los servicios financieros
- Configurar autenticación y autorización para proteger los endpoints

#### Paso 3: Crear UI para gestión financiera
- Extender el frontend para incluir pantallas para gestión financiera
- Integrar con el API Gateway para las operaciones necesarias

### Fase 5: Integración con Odoo Manager

#### Paso 1: Adaptar el servicio existente
- Revisar y adaptar el servicio para la nueva arquitectura
- Implementar endpoints compatibles con el API Gateway

#### Paso 2: Integrar con el API Gateway
- Actualizar la configuración de NGINX para incluir rutas al servicio Odoo Manager
- Configurar autenticación y autorización para proteger los endpoints

#### Paso 3: Crear UI para gestión de Odoo
- Extender el frontend para incluir pantallas para gestión de Odoo
- Integrar con el API Gateway para las operaciones necesarias

## Estrategia de Implementación

Para cada integración, seguiremos estos principios:

1. Enfoque Incremental: Integrar un servicio a la vez, asegurando que funcione correctamente antes de pasar al siguiente.
2. Compatibilidad con API Gateway: Todos los servicios deben exponerse a través del API Gateway, que centraliza la autenticación y el enrutamiento.
3. Autenticación y Autorización: Utilizar un enfoque consistente para la autenticación y autorización a través de todos los servicios.
4. Pruebas: Implementar pruebas automáticas para cada servicio y para la integración completa.
5. Documentación: Mantener una documentación actualizada de cada servicio y sus endpoints.

## Próximos Pasos

1. Comenzar con la implementación del servicio de compañías
2. Configurar integración con el API Gateway
3. Crear UI básica para gestión de compañías
4. Probar la integración completa
5. Documentar el proceso y las lecciones aprendidas
6. Pasar a la siguiente fase de integración

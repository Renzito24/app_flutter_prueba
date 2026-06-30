# LOCUSTAF - Especificación Técnica de Desarrollo

Versión: 1.0

Última actualización: Junio 2026

---

# 1. Objetivo del documento

Este documento establece las normas técnicas, la arquitectura, las tecnologías, las convenciones de desarrollo y las decisiones de diseño del proyecto LOCUSTAF.

Su finalidad es garantizar que todo el desarrollo del sistema siga una estructura consistente, facilitando el mantenimiento, la escalabilidad y la incorporación de nuevas funcionalidades.

Este documento constituye la referencia técnica principal del proyecto y deberá ser utilizado tanto por los desarrolladores como por herramientas de inteligencia artificial (OpenCode, Claude, GitHub Copilot, ChatGPT u otras) antes de realizar cualquier modificación en el código.

Toda nueva funcionalidad deberá respetar las reglas establecidas en este documento.

# 2. Estado actual del proyecto

Actualmente LOCUSTAF se encuentra en etapa de desarrollo del Producto Mínimo Viable (MVP).

El proyecto ya cuenta con una base funcional desarrollada en Flutter y Firebase, incluyendo autenticación, navegación, gestión de empleados, gestión de lugares de trabajo, registro de asistencias mediante geolocalización, historial, justificativos médicos, reportes básicos y perfiles de usuario.

A partir de este punto el objetivo no será reescribir el proyecto, sino evolucionarlo progresivamente, manteniendo la mayor cantidad posible del código existente y aplicando mejoras de forma incremental.

# 3. Filosofía de desarrollo

LOCUSTAF se desarrollará mediante una estrategia de evolución incremental.

No se realizarán reestructuraciones completas del proyecto mientras el MVP continúe en desarrollo.

Las mejoras arquitectónicas deberán implementarse únicamente cuando aporten un beneficio real al sistema y no impliquen rehacer funcionalidades ya implementadas.

Se priorizará:

- estabilidad del sistema;
- simplicidad del código;
- mantenibilidad;
- cumplimiento del MVP;
- entregas funcionales.

El objetivo principal es obtener un sistema estable y completamente operativo antes de aplicar optimizaciones arquitectónicas de mayor complejidad.

# 4. Arquitectura del proyecto

## Arquitectura adoptada

LOCUSTAF utilizará una arquitectura modular basada en funcionalidades (Feature-First), manteniendo una separación clara entre la interfaz de usuario, la lógica de negocio y el acceso a los servicios de Firebase.

No se implementará Clean Architecture completa durante el desarrollo del MVP, ya que el objetivo principal es priorizar la entrega de funcionalidades estables y completamente operativas.

La organización del proyecto buscará mantener un código limpio, reutilizable y fácil de mantener, evitando complejidad innecesaria.

La gestión del estado continuará utilizando Provider, ya que el proyecto posee una implementación funcional sobre esta tecnología y una migración a Riverpod implicaría reescribir gran parte del sistema sin aportar beneficios inmediatos para el MVP.

Las mejoras arquitectónicas futuras podrán evaluarse una vez finalizada la primera versión estable del sistema.

---

## Principios de desarrollo

Durante todo el proyecto deberán respetarse los siguientes principios:

- Responsabilidad única por clase.
- Separación entre interfaz y lógica de negocio.
- Componentes reutilizables.
- Código legible antes que código complejo.
- Evitar duplicación de lógica.
- Mantener funciones pequeñas y descriptivas.
- Favorecer la reutilización de widgets.
- Documentar únicamente cuando aporte valor.

El objetivo es desarrollar un sistema sencillo de mantener, comprender y extender.
---

## Índice

1. [Requerimientos Funcionales](#1-requerimientos-funcionales)
2. [Casos de Uso](#2-casos-de-uso)
3. [Arquitectura Flutter](#3-arquitectura-flutter)
4. [Arquitectura Firebase](#4-arquitectura-firebase)
5. [Modelo de Datos Firestore](#5-modelo-de-datos-firestore)
6. [Diseño de Colecciones](#6-diseño-de-colecciones)
7. [Estructura de Carpetas](#7-estructura-de-carpetas)
8. [Roadmap de Desarrollo](#8-roadmap-de-desarrollo)

---

## 1. Requerimientos Funcionales

### 1.1 Módulo de Autenticación

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-01 | El sistema debe permitir iniciar sesión con email y contraseña utilizando Firebase Authentication | Alta |
| RF-02 | El sistema debe detectar si es el primer inicio de sesión y forzar el cambio de contraseña | Alta |
| RF-03 | El administrador debe poder resetear la contraseña de un usuario (se reinicia a su DNI) | Alta |
| RF-04 | El sistema debe mantener la sesión persistente hasta que el usuario cierre sesión explícitamente | Alta |
| RF-05 | El sistema debe redirigir al dashboard correspondiente según el rol (admin/supervisor/empleado) | Alta |
| RF-06 | El sistema debe cerrar sesión automáticamente por inactividad (tiempo configurable, default 15 min) | Media |
| RF-07 | El sistema debe limitar intentos de login (5 intentos, bloqueo de 5 minutos) | Media |

### 1.2 Módulo de Dashboard Administrativo

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-08 | El dashboard debe mostrar KPIs: presentes, ausentes, tardanzas, total empleados | Alta |
| RF-09 | El dashboard debe incluir un gráfico de donut con el resumen del día actual | Alta |
| RF-10 | El dashboard debe incluir un gráfico de barras con tendencia semanal (7 días) | Alta |
| RF-11 | El dashboard debe incluir un gráfico de barras mensual con promedios de 4 semanas | Alta |
| RF-12 | El dashboard debe mostrar una tabla de asistencias agrupadas por turno | Alta |
| RF-13 | El dashboard debe mostrar alertas para empleados con >3 tardanzas o >3 ausencias en 7 días | Media |
| RF-14 | El dashboard debe permitir filtrar por fecha y buscar por DNI | Alta |

### 1.3 Módulo de Gestión de Usuarios

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-15 | El sistema debe permitir crear usuarios con: DNI, legajo, nombre, apellido, email, teléfono, edad, género, fecha de nacimiento, domicilio, estudios | Alta |
| RF-16 | El sistema debe auto-generar el username en formato `nombre.apellido` | Alta |
| RF-17 | El sistema debe asignar como contraseña inicial el DNI del usuario | Alta |
| RF-18 | El sistema debe soportar 3 roles: `admin`, `supervisor`, `empleado` | Alta |
| RF-19 | El sistema debe permitir editar usuarios (excepto DNI y legajo) | Alta |
| RF-20 | El sistema debe permitir soft-delete de usuarios (campo `activo = false`) | Alta |
| RF-21 | El sistema debe permitir reactivar usuarios eliminados | Alta |
| RF-22 | El sistema debe permitir buscar usuarios por nombre, DNI o legajo | Alta |
| RF-23 | El sistema debe permitir asignar un turno a cada usuario | Alta |

### 1.4 Módulo de Gestión de Turnos

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-24 | El sistema debe permitir crear turnos con: nombre, hora de inicio, hora de fin, tolerancia en minutos, días válidos, descripción | Alta |
| RF-25 | El sistema debe permitir editar y eliminar turnos | Alta |
| RF-26 | El sistema debe permitir asignar empleados a un turno (individual o masivo con selección múltiple) | Alta |
| RF-27 | El sistema debe permitir desasignar empleados de un turno | Alta |
| RF-28 | El sistema debe mostrar los empleados asignados a cada turno | Alta |

### 1.5 Módulo de Geolocalización (NUEVO)

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-29 | El administrador debe poder crear ubicaciones laborales con: nombre, dirección, latitud, longitud, radio en metros | Alta |
| RF-30 | El administrador debe poder editar y eliminar ubicaciones laborales | Alta |
| RF-31 | El administrador debe poder visualizar ubicaciones en un mapa | Alta |
| RF-32 | El administrador debe poder seleccionar la ubicación en el mapa mediante un pin arrastrable | Media |
| RF-33 | El sistema debe almacenar todas las ubicaciones laborales en Firestore | Alta |
| RF-34 | El sistema debe validar que el empleado esté dentro del radio de alguna ubicación laboral para permitir la marcación | Alta |
| RF-35 | El sistema debe calcular la distancia entre la ubicación GPS del empleado y cada ubicación laboral usando el método Haversine | Alta |

### 1.6 Módulo de Registro de Asistencias

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-36 | El empleado debe poder marcar entrada solo si está dentro del radio de una ubicación laboral | Alta |
| RF-37 | El empleado debe poder marcar salida solo si está dentro del radio de una ubicación laboral | Alta |
| RF-38 | El empleado debe poder marcar inicio de descanso solo si está dentro del radio de una ubicación laboral | Alta |
| RF-39 | El empleado debe poder marcar fin de descanso solo si está dentro del radio de una ubicación laboral | Alta |
| RF-40 | Cada marcación debe registrar: fecha, hora, usuario, latitud, longitud, precisión GPS, ubicación laboral asociada, tipo de evento | Alta |
| RF-41 | El sistema debe detectar automáticamente el estado de la asistencia: puntual, tarde, salida anticipada, jornada incompleta, ausente | Alta |
| RF-42 | El sistema debe bloquear la marcación de entrada si el empleado está de licencia/vacaciones | Alta |
| RF-43 | El sistema debe calcular horas extra cuando la salida excede el horario del turno | Media |
| RF-44 | El empleado debe poder ver su historial de asistencias | Alta |

### 1.7 Módulo de Justificaciones

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-45 | El empleado debe poder crear una justificación para una fecha específica | Alta |
| RF-46 | Los motivos disponibles deben ser: enfermedad, dormirse, fuerza mayor, otros | Alta |
| RF-47 | El empleado puede agregar observaciones (máximo 500 caracteres) | Alta |
| RF-48 | El empleado puede adjuntar un documento (PDF, JPG, PNG, máximo 5MB) que se almacena en Firebase Storage | Alta |
| RF-49 | El sistema debe evitar justificaciones duplicadas para la misma fecha y usuario | Alta |
| RF-50 | El empleado debe poder ver sus justificaciones | Media |

### 1.8 Módulo de Licencias / Vacaciones

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-51 | El administrador/supervisor debe poder crear licencias para empleados con: fecha inicio, fecha fin, motivo, observaciones | Alta |
| RF-52 | El sistema debe validar que la fecha de inicio no sea posterior a la fecha de fin | Alta |
| RF-53 | El sistema debe validar que no haya superposición con otras licencias del mismo empleado | Alta |
| RF-54 | El sistema debe impedir la creación de licencias para usuarios admin | Alta |
| RF-55 | El sistema debe cancelar licencias existentes con notificación al empleado | Alta |
| RF-56 | El sistema debe filtrar licencias por rango de fechas | Media |

### 1.9 Módulo de Reportes

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-57 | El sistema debe permitir generar reportes filtrando por: rango de fechas, DNI, tipo de incidencia, turno | Alta |
| RF-58 | Los reportes deben incluir: nombre, legajo, DNI, fechas, estados (Presente/Tarde/Salida Anticipada/Sin Egreso/Ausente/Licencia) | Alta |
| RF-59 | El sistema debe exportar reportes en formato Excel (.xlsx) | Alta |
| RF-60 | El sistema debe exportar reportes en formato CSV | Alta |
| RF-61 | El sistema debe exportar reportes en formato PDF | Alta |

### 1.10 Módulo de Notificaciones

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-62 | El sistema debe generar notificaciones de tipo: tardanza, ausencia, recordatorio de egreso, tardanzas reiteradas, vacaciones, información | Alta |
| RF-63 | El sistema debe mostrar un badge con la cantidad de notificaciones no leídas en tiempo real | Alta |
| RF-64 | El sistema debe mostrar un dropdown con las últimas 5 notificaciones no leídas | Alta |
| RF-65 | El sistema debe tener una página de historial completo de notificaciones | Alta |
| RF-66 | El sistema debe permitir marcar notificaciones como leídas (individual o todas) | Alta |
| RF-67 | El sistema debe enviar notificaciones push usando Firebase Cloud Messaging | Alta |
| RF-68 | El sistema debe ejecutar tareas programadas: detección de ausencias (20:00), recordatorio de egreso (cada 5 minutos post horario) | Media |

### 1.11 Módulo de Configuración

| ID | Requerimiento | Prioridad |
|----|---------------|-----------|
| RF-69 | El usuario debe poder ver y editar su perfil (nombre, email, teléfono) | Alta |
| RF-70 | El usuario debe poder cambiar su contraseña (requiere contraseña actual) | Alta |
| RF-71 | El sistema debe mostrar los datos del usuario en el pie de la barra lateral (avatar con iniciales, nombre, rol) | Media |

---

## 2. Casos de Uso

### 2.1 Actores

| Actor | Descripción |
|-------|-------------|
| **Empleado** | Usuario con rol `empleado`. Accede a su dashboard personal, marca asistencias, justifica inasistencias, ve notificaciones |
| **Administrador** | Usuario con rol `admin`. Acceso completo a todas las funcionalidades del sistema |
| **Supervisor** | Usuario con rol `supervisor`. Acceso de solo lectura a datos administrativos, puede gestionar licencias y generar reportes |

### 2.2 Especificación de Casos de Uso

#### CU-01: Iniciar Sesión

| Campo | Valor |
|-------|-------|
| **Actor** | Empleado, Administrador, Supervisor |
| **Precondiciones** | Usuario registrado en Firebase Auth y Firestore |
| **Flujo principal** | 1. Usuario ingresa email y contraseña<br>2. Sistema valida credenciales con Firebase Auth<br>3. Sistema recupera datos del usuario desde Firestore `users`<br>4. Sistema verifica si es primer login<br>5. Si es primer login, redirige a cambio de contraseña<br>6. Si no, redirige al dashboard según rol |
| **Flujo alterno (credenciales inválidas)** | 2a. Firebase Auth retorna error<br>3a. Sistema muestra "Credenciales inválidas"<br>4a. Sistema incrementa contador de intentos<br>5a. Si supera 5 intentos, bloquea por 5 minutos |
| **Postcondiciones** | Sesión iniciada, usuario redirigido al dashboard correspondiente |

#### CU-02: Ver Dashboard Personal (Empleado)

| Campo | Valor |
|-------|-------|
| **Actor** | Empleado |
| **Precondiciones** | Empleado autenticado |
| **Flujo principal** | 1. Empleado accede al dashboard<br>2. Sistema muestra tarjeta con marcaciones del día (entrada, salida, descansos si corresponde)<br>3. Sistema muestra estado actual (Dentro/Fuera del área laboral)<br>4. Sistema muestra botones de acción (Entrada/Salida/Descanso según corresponda)<br>5. Sistema muestra historial resumido de los últimos 5 días |
| **Postcondiciones** | Dashboard visualizado |

#### CU-03 a CU-06: Marcaciones GPS

| Campo | CU-03: Entrada | CU-04: Salida | CU-05: Inicio Descanso | CU-06: Fin Descanso |
|-------|----------------|---------------|------------------------|---------------------|
| **Actor** | Empleado | Empleado | Empleado | Empleado |
| **Precondición** | Autenticado, sin entrada hoy | Autenticado, con entrada hoy | Autenticado, con entrada hoy, sin descanso activo | Autenticado, con descanso activo |
| **Flujo** | 1. Obtener GPS<br>2. Verificar radio<br>3. Verificar licencia<br>4. Registrar evento<br>5. Actualizar attendance | Misma lógica | Misma lógica | Misma lógica |
| **Fuera de radio** | Error: "Debe estar en su lugar de trabajo" | Idem | Idem | Idem |
| **Licencia activa** | Error: "No puede marcar durante su licencia" | Idem | Idem | Idem |
| **Postcondición** | Evento registrado en `attendance_events`, attendance actualizado | Idem | Idem | Idem |

#### CU-07: Ver Historial de Asistencias

| Campo | Valor |
|-------|-------|
| **Actor** | Empleado |
| **Precondiciones** | Empleado autenticado |
| **Flujo principal** | 1. Empleado navega a "Historial"<br>2. Sistema obtiene `attendance` por userId ordenado por fecha descendente<br>3. Sistema muestra lista con fecha, hora entrada, hora salida, estado |
| **Postcondiciones** | Historial visualizado |

#### CU-08: Crear Justificación

| Campo | Valor |
|-------|-------|
| **Actor** | Empleado |
| **Precondiciones** | Empleado autenticado |
| **Flujo principal** | 1. Empleado selecciona fecha a justificar<br>2. Empleado selecciona motivo<br>3. Empleado escribe observaciones (opcional)<br>4. Empleado adjunta documento (opcional)<br>5. Sistema valida datos<br>6. Sistema guarda en Firestore `justifications`<br>7. Si hay documento, lo sube a Firebase Storage |
| **Postcondiciones** | Justificación creada |

#### CU-09 a CU-18: Funcionalidades Admin

| ID | Nombre | Descripción breve |
|----|--------|-------------------|
| CU-09 | Ver Dashboard Admin | KPIs, gráficos, alertas, tabla por turno. Filtros por fecha y DNI |
| CU-10 | CRUD Usuarios | Crear, listar, buscar, editar, eliminar (soft-delete), reactivar, resetear password |
| CU-11 | CRUD Turnos | Crear, editar, eliminar turnos. Asignar/desasignar empleados |
| CU-12 | CRUD Ubicaciones | Crear con mapa, editar, eliminar ubicaciones laborales con radio |
| CU-13 | Ver Asistencias | Listado diario de asistencias con filtro por turno, navegación entre días |
| CU-14 | Gestionar Licencias | Crear, cancelar licencias. Validar fechas y superposición |
| CU-15 | Generar Reportes | Filtros avanzados, exportación Excel/CSV/PDF |
| CU-16 | Ver Notificaciones | Historial completo, filtrar por tipo, marcar como leídas |
| CU-17 | Configurar Perfil | Editar perfil, cambiar contraseña |

---

## 3. Arquitectura Flutter

### 3.1 Patrón Arquitectónico

**Clean Architecture + Feature-first** con las siguientes capas:

```
┌─────────────────────────────────────────────────────┐
│                  PRESENTATION                        │
│  (Providers Riverpod, Pages, Widgets)                │
├─────────────────────────────────────────────────────┤
│                      DOMAIN                          │
│  (Entities, Use Cases, Repository Interfaces)        │
├─────────────────────────────────────────────────────┤
│                       DATA                           │
│  (Models, Datasources [Firebase], Repository Impl)  │
├─────────────────────────────────────────────────────┤
│                      CORE                            │
│  (Theme, Constants, Errors, Network, Utils)          │
├─────────────────────────────────────────────────────┤
│                    FLUTTER/FIREBASE                   │
│  (Flutter SDK, Firebase Auth, Firestore, Storage,    │
│   FCM, Geolocator, Google Maps)                     │
└─────────────────────────────────────────────────────┘
```

### 3.2 Gestión de Estado: Riverpod

| Provider | Uso |
|----------|-----|
| `StateProvider` | Estados simples (loading, error) |
| `StateNotifierProvider` | Estados complejos con lógica (auth, attendance) |
| `FutureProvider` | Datos asíncronos de Firestore (usuarios, turnos) |
| `StreamProvider` | Streams en tiempo real (notificaciones) |
| `Provider` | Servicios singleton (GPS, Firebase) |

### 3.3 Dependencias Principales (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_storage: ^12.x
  firebase_messaging: ^15.x
  
  # Estado
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  
  # Geolocalización
  geolocator: ^12.x
  google_maps_flutter: ^2.x
  
  # Navegación
  go_router: ^14.x
  
  # Utilidades
  freezed_annotation: ^2.x
  json_annotation: ^4.x
  intl: ^0.19.x
  image_picker: ^1.x
  file_picker: ^8.x
  path_provider: ^2.x
  connectivity_plus: ^6.x
  
  # UI
  fl_chart: ^0.69.x
  shimmer: ^3.x
  flutter_svg: ^2.x
  
dev_dependencies:
  build_runner: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
  riverpod_generator: ^2.x
  flutter_test:
    sdk: flutter
  mocktail: ^1.x
```

### 3.4 Tema Visual (Material 3)

```dart
class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const primaryHover = Color(0xFF4338CA);
  static const primarySoft = Color(0xFFEEF2FF);
  
  static const success = Color(0xFF10B981);
  static const successSoft = Color(0xFFECFDF5);
  static const successDark = Color(0xFF065F46);
  
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFFFBEB);
  static const warningDark = Color(0xFF92400E);
  
  static const danger = Color(0xFFEF4444);
  static const dangerSoft = Color(0xFFFEF2F2);
  static const dangerDark = Color(0xFF991B1B);
  
  static const info = Color(0xFF0EA5E9);
  static const infoSoft = Color(0xFFF0F9FF);
  
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate50 = Color(0xFFF8FAFC);
  static const white = Color(0xFFFFFFFF);
  
  static const sidebarBg = slate900;
  static const sidebarActive = primary;
  static const sidebarText = Color(0xFF94A3B8);
  static const sidebarTextActive = white;
}
```

### 3.5 Esquema de Rutas (GoRouter)

```
/login                               → LoginPage

/admin/dashboard                     → AdminDashboardPage
/admin/usuarios                      → UsersListPage
/admin/usuarios/nuevo                → UserFormPage
/admin/usuarios/:id                  → UserFormPage (editar)
/admin/turnos                        → ShiftsListPage
/admin/turnos/nuevo                  → ShiftFormPage
/admin/turnos/:id                    → ShiftFormPage (editar)
/admin/turnos/:id/asignar            → ShiftAssignmentPage
/admin/ubicaciones                   → LocationsListPage (NUEVO)
/admin/ubicaciones/nueva             → LocationFormPage (NUEVO)
/admin/ubicaciones/:id               → LocationFormPage (NUEVO)
/admin/asistencias                   → AttendanceViewPage
/admin/reportes                      → ReportsPage
/admin/vacaciones                    → VacationsPage
/admin/notificaciones                → NotificationsPage
/admin/configuracion                 → ConfigurationPage

/dashboard                           → EmployeeDashboardPage
/dashboard/historial                 → AttendanceHistoryPage
/justificar                          → JustificationFormPage
/notificaciones                      → NotificationsHistoryPage
```

---

## 4. Arquitectura Firebase

### 4.1 Servicios Firebase

| Servicio | Propósito |
|----------|-----------|
| **Firebase Authentication** | Autenticación email/contraseña, gestión de sesiones |
| **Cloud Firestore** | Base de datos NoSQL principal |
| **Firebase Storage** | Almacenamiento de documentos de justificaciones |
| **Firebase Cloud Messaging** | Notificaciones push en tiempo real |

### 4.2 Reglas de Seguridad Firestore

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() { return request.auth != null; }
    function isAdmin() { return isAuthenticated() && request.auth.token.rol == 'admin'; }
    function isSupervisor() { return isAuthenticated() && request.auth.token.rol == 'supervisor'; }
    function isAdminOrSupervisor() { return isAdmin() || isSupervisor(); }
    function isOwner(userId) { return isAuthenticated() && request.auth.uid == userId; }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin();
      allow update: if isAdmin() || isOwner(userId);
      allow delete: if isAdmin();
    }
    
    match /shifts/{shiftId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    match /work_locations/{locationId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    match /attendance/{docId} {
      allow read: if isAuthenticated() && (isOwner(resource.data.userId) || isAdminOrSupervisor());
      allow create: if isAuthenticated();
      allow update: if isAuthenticated();
      allow delete: if false;
    }
    
    match /attendance_events/{eventId} {
      allow read: if isAuthenticated() && (isOwner(resource.data.userId) || isAdminOrSupervisor());
      allow create: if isAuthenticated();
      allow update: if false;
      allow delete: if false;
    }
    
    match /justifications/{justId} {
      allow read: if isAuthenticated() && (isOwner(resource.data.userId) || isAdminOrSupervisor());
      allow create: if isAuthenticated();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    match /notifications/{notifId} {
      allow read: if isAuthenticated() && (isOwner(resource.data.userId) || isAdmin());
      allow create: if isAdmin();
      allow update: if isOwner(resource.data.userId);
      allow delete: if false;
    }
    
    match /vacations/{vacId} {
      allow read: if isAuthenticated();
      allow create: if isAdminOrSupervisor();
      allow update: if isAdminOrSupervisor();
      allow delete: if isAdmin();
    }
  }
}
```

### 4.3 Estructura de Tópicos FCM

| Tópico | Suscriptores |
|--------|-------------|
| `admin` | Todos los admins |
| `supervisor` | Todos los supervisores |
| `empleado` | Todos los empleados |
| `user_{userId}` | Usuario específico |

### 4.4 Cloud Functions (futuro)

| Función | Trigger | Propósito |
|---------|---------|-----------|
| `detectAbsences` | Scheduled (20:00) | Detectar empleados sin marcación |
| `sendExitReminder` | Scheduled (cada 5 min) | Recordar marcar salida |
| `sendPushNotification` | Firestore onCreate | Enviar FCM al crear notificación |
| `onUserCreate` | Auth onCreate | Crear documento en Firestore |

---

## 5. Modelo de Datos Firestore

### 5.1 Colección: `users`

```
/{userId}
  ├── dni: String
  ├── legajo: String
  ├── nombre: String
  ├── apellido: String
  ├── username: String
  ├── email: String
  ├── rol: String ("admin" | "supervisor" | "empleado")
  ├── telefono: String?
  ├── edad: Number?
  ├── genero: String?
  ├── fechaNacimiento: Timestamp?
  ├── domicilio: String?
  ├── estudios: String?
  ├── turnoId: String? (FK -> shifts)
  ├── activo: Boolean (default: true)
  ├── primerLogin: Boolean (default: true)
  ├── fcmToken: String?
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp
```

### 5.2 Colección: `shifts`

```
/{shiftId}
  ├── nombre: String
  ├── horaInicio: String ("08:00")
  ├── horaFin: String ("17:00")
  ├── toleranciaMinutos: Number (15)
  ├── descripcion: String?
  ├── diasValidos: Array<Number> ([0,1,2,3,4,5,6])
  ├── activo: Boolean
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp
```

### 5.3 Colección: `work_locations` (NUEVO)

```
/{locationId}
  ├── nombre: String ("Panadería Central")
  ├── direccion: String ("Av. Corrientes 1234")
  ├── latitud: Number (-34.603722)
  ├── longitud: Number (-58.381592)
  ├── radioMetros: Number (30)
  ├── activo: Boolean
  ├── createdBy: String (UID admin)
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp
```

### 5.4 Colección: `attendance`

```
/{attendanceId}
  ├── userId: String (FK -> users)
  ├── userDni: String
  ├── fecha: Timestamp
  ├── horaIngreso: Timestamp?
  │   ├── latitud: Number?
  │   ├── longitud: Number?
  │   ├── precision: Number?
  │   └── ubicacionId: String?
  ├── horaEgreso: Timestamp?
  │   ├── latitud: Number?
  │   ├── longitud: Number?
  │   ├── precision: Number?
  │   └── ubicacionId: String?
  ├── descansoInicio: Timestamp?
  │   ├── latitud: Number?
  │   ├── longitud: Number?
  │   ├── precision: Number?
  │   └── ubicacionId: String?
  ├── descansoFin: Timestamp?
  │   ├── latitud: Number?
  │   ├── longitud: Number?
  │   ├── precision: Number?
  │   └── ubicacionId: String?
  ├── estado: String ("puntual" | "tarde" | "ausente" | "jornada_incompleta" | "salida_anticipada")
  ├── horasExtra: Number
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp
```

### 5.5 Colección: `attendance_events` (NUEVO - registro GPS)

```
/{eventId}
  ├── userId: String (FK -> users)
  ├── userDni: String
  ├── attendanceId: String? (FK -> attendance)
  ├── fecha: Timestamp
  ├── tipo: String ("entrada" | "salida" | "descanso_inicio" | "descanso_fin")
  ├── latitud: Number
  ├── longitud: Number
  ├── precision: Number (precisión GPS en metros)
  ├── ubicacionId: String? (FK -> work_locations)
  ├── ubicacionNombre: String?
  ├── dentroRadio: Boolean
  └── createdAt: Timestamp (inmutable)
```

### 5.6 Colección: `justifications`

```
/{justId}
  ├── userId: String (FK -> users)
  ├── userDni: String
  ├── fecha: Timestamp
  ├── motivo: String ("enfermedad" | "dormirse" | "fuerza_mayor" | "otros")
  ├── observaciones: String? (max 500)
  ├── documentUrl: String? (Storage URL)
  ├── documentName: String?
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp
```

### 5.7 Colección: `notifications`

```
/{notifId}
  ├── userId: String (FK -> users)
  ├── tipo: String ("tardanza" | "ausencia" | "recordatorio_egreso" | "tardanzas_reiteradas" | "vacaciones" | "info")
  ├── mensaje: String
  ├── leida: Boolean (default: false)
  ├── fecha: Timestamp
  └── createdAt: Timestamp
```

### 5.8 Colección: `vacations`

```
/{vacId}
  ├── userId: String (FK -> users)
  ├── userDni: String
  ├── fechaInicio: Timestamp
  ├── fechaFin: Timestamp
  ├── motivo: String?
  ├── observaciones: String?
  ├── createdBy: String (UID admin)
  ├── createdAt: Timestamp
  └── updatedAt: Timestamp
```

---

## 6. Diseño de Colecciones

### 6.1 Diagrama de Relaciones

```
users ──┬──> shifts (turnoId)
        ├──> attendance (userId)
        ├──> attendance_events (userId)
        ├──> justifications (userId)
        ├──> notifications (userId)
        └──> vacations (userId)

work_locations ──> attendance (ubicacionId*)
                ──> attendance_events (ubicacionId)
```

### 6.2 Índices Compuestos

| Colección | Campos | Razón |
|-----------|--------|-------|
| `attendance` | `userId` ASC, `fecha` DESC | Dashboard empleado |
| `attendance` | `fecha` ASC, `estado` ASC | Dashboard admin |
| `attendance_events` | `userId` ASC, `fecha` DESC | Historial empleado |
| `notifications` | `userId` ASC, `leida` ASC, `fecha` DESC | Badge + historial |
| `vacations` | `userId` ASC, `fechaInicio` ASC | Verificar licencia activa |
| `vacations` | `fechaInicio` ASC, `fechaFin` ASC | Reportes |
| `justifications` | `userId` ASC, `fecha` DESC | Historial empleado |

### 6.3 Firebase Storage

```
/justifications/{userId}/{timestamp}_{filename}
/avatars/{userId}/profile.jpg
```

---

## 7. Estructura de Carpetas

```
presentispro_app/
├── android/
├── ios/
├── assets/
│   ├── images/
│   │   ├── login_bg.png
│   │   ├── logo.png
│   │   └── form_header.png
│   └── fonts/
│       └── Inter/
├── firebase/
│   ├── firebase.json
│   ├── firestore.indexes.json
│   ├── firestore.rules
│   └── storage.rules
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_constants.dart
│   │   │   └── firestore_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── extensions/
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── date_formatter.dart
│   │   │   ├── gps_utils.dart (Haversine)
│   │   │   ├── debouncer.dart
│   │   │   └── permission_utils.dart
│   │   ├── network/
│   │   │   ├── network_info.dart
│   │   │   └── api_client.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   └── extensions/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/ (datasources, models, repositories)
│   │   │   ├── domain/ (entities, repositories, usecases)
│   │   │   └── presentation/ (providers, pages, widgets)
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── attendance/
│   │   │   ├── data/
│   │   │   │   ├── datasources/ (attendance, gps, event)
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/ (attendance_record, event_type, gps_coordinates)
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/ (check_in, check_out, start_break, end_break, get_history)
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/
│   │   │       └── widgets/ (gps_status_indicator, attendance_button, proximity_indicator, timeline)
│   │   ├── locations/ (NUEVO)
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/ (work_location)
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/ (create, update, delete, get_all, check_proximity)
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── pages/ (list, form with map, map view)
│   │   │       └── widgets/ (location_map_picker, location_card, radius_slider)
│   │   ├── users/
│   │   ├── shifts/
│   │   ├── justifications/
│   │   ├── vacations/
│   │   ├── reports/
│   │   └── notifications/
│   └── shared/
│       ├── widgets/
│       │   ├── app_scaffold.dart
│       │   ├── admin_shell.dart
│       │   ├── employee_shell.dart
│       │   ├── app_sidebar.dart
│       │   ├── app_header.dart
│       │   ├── notification_bell.dart
│       │   ├── kpi_card.dart
│       │   ├── status_badge.dart
│       │   ├── loading_skeleton.dart
│       │   ├── empty_state.dart
│       │   ├── error_state.dart
│       │   ├── confirm_dialog.dart
│       │   └── date_range_picker.dart
│       └── providers/
│           ├── auth_state_provider.dart
│           └── connectivity_provider.dart
├── test/
│   ├── unit/
│   │   ├── core/utils/gps_utils_test.dart
│   │   └── features/*/usecases/*_test.dart
│   ├── widget/
│   │   └── features/*/pages/*_test.dart
│   └── integration/
│       ├── auth_flow_test.dart
│       ├── attendance_flow_test.dart
│       └── gps_flow_test.dart
├── pubspec.yaml
├── analysis_options.yaml
├── .env.example
├── .gitignore
└── README.md
```

---

## 8. Roadmap de Desarrollo

### 8.1 Sprints

| Sprint | Nombre | Días | Tareas |
|--------|--------|------|--------|
| 0 | Setup | 3 | Proyecto Flutter, Firebase config, tema Material 3, Riverpod, estructura carpetas, GoRouter base |
| 1 | Auth | 4 | Firebase Auth login, pantalla login split-screen, cambio contraseña primer login, sesión persistente |
| 2 | Core UI | 5 | AppShell (sidebar admin/empleado), header breadcrumb, notification bell, componentes comunes (KPI card, skeleton, states) |
| 3 | Usuarios | 5 | CRUD usuarios Firestore, lista con búsqueda, roles, soft-delete, reset password |
| 4 | Turnos | 4 | CRUD turnos, asignación masiva/individual, desasignación |
| 5 | GPS Locations | 6 | CRUD ubicaciones con mapa Google Maps, pin arrastrable, slider radio, algoritmo Haversine |
| 6 | Asistencias | 7 | Marcación GPS (entrada/salida/descanso), verificación radio+licencia, attendance_events, detección estado, horas extra |
| 7 | Dashboard Admin | 5 | KPIs, gráfico donut, barras semanal, barras mensual, tabla por turno, alertas |
| 8 | Dashboard Empleado | 3 | Panel personal, timeline eventos, indicador GPS, botón marcación, historial |
| 9 | Justificaciones | 4 | Formulario justificación, carga documentos Storage, validación duplicados |
| 10 | Licencias | 4 | CRUD licencias, validación fechas+superposición, bloqueo marcación, cancelación |
| 11 | Reportes | 6 | Filtros avanzados, tabla resultados, exportación Excel/CSV/PDF |
| 12 | Notificaciones | 5 | FCM push, badge tiempo real, dropdown últimas 5, historial, Cloud Functions |
| 13 | Configuración | 2 | Perfil usuario, cambio contraseña, avatar sidebar |
| 14 | Testing + QA | 6 | Tests unitarios, widget, integration, pruebas GPS reales, optimización, bugs |
| 15 | Release | 4 | Build Android APK/AAB, iOS, stores, documentación |

**Total: ~73 días hábiles (~3.5 meses)**

### 8.2 Hitos

| Hito | Sprint | Día | Entregable |
|------|--------|-----|------------|
| MVP | 6 | 34 | Auth + usuarios + turnos + marcación GPS funcional |
| Alpha | 10 | 50 | Todos los módulos base |
| Beta | 13 | 63 | Funcionalidad completa |
| RC | 14 | 69 | Tests pasados, bugs corregidos |
| Release | 15 | 73 | APK/AAB, documentación |

---

## Apéndice A: Algoritmo Haversine

```dart
class GpsUtils {
  static double calculateDistance({
    required double lat1, required double lon1,
    required double lat2, required double lon2,
  }) {
    const earthRadius = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static bool isWithinRadius({
    required double userLat, required double userLon,
    required double locationLat, required double locationLon,
    required double radiusMeters,
  }) {
    return calculateDistance(
      lat1: userLat, lon1: userLon,
      lat2: locationLat, lon2: locationLon,
    ) <= radiusMeters;
  }

  static WorkLocation? findNearestLocation({
    required double userLat, required double userLon,
    required List<WorkLocation> locations,
  }) {
    WorkLocation? nearest;
    double minDistance = double.infinity;
    for (final loc in locations) {
      if (!loc.activo) continue;
      final dist = calculateDistance(
        lat1: userLat, lon1: userLon,
        lat2: loc.latitud, lon2: loc.longitud,
      );
      if (dist <= loc.radioMetros && dist < minDistance) {
        minDistance = dist;
        nearest = loc;
      }
    }
    return nearest;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
```

## Apéndice B: Flujo de Marcación GPS

```
[Presiona "Marcar Entrada"]
       │
       ▼
[Permisos GPS] ──No──> [Solicitar activar GPS]
       │
      Sí
       │
       ▼
[Obtener ubicación] ──Precisión ≥30m──> [Esperar... reintentar]
       │
     <30m
       │
       ▼
[Obtener ubicaciones activas] ──Sin datos──> [Error: sin ubicaciones]
       │
     Con datos
       │
       ▼
[Haversine: ¿dentro de algún radio?] ──No──> [Error: fuera del área]
       │
      Sí
       │
       ▼
[¿Está de licencia?] ──Sí──> [Error: está de licencia]
       │
      No
       │
       ▼
[Registrar attendance_events]
[Actualizar attendance]
[Evaluar puntualidad vs turno+tolerancia]
       │
       ▼
[Mostrar confirmación: "Entrada 08:15 hs (Tarde)"]
```

---

*Fin del documento de especificación.*

# LOCUSTAF MASTER SPEC — PresentisPRO → Flutter + Firebase

> **Proyecto:** Sistema de Control de Presentismo — ISFT 182  
> **Origen:** PresentisPRO (Flask + SQLite/PostgreSQL + Bootstrap 5)  
> **Destino:** Flutter + Firebase + Riverpod + Material 3  
> **Versión Especificación:** 1.0  
> **Fecha:** Junio 2026

---

## 1. Resumen Ejecutivo

PresentisPRO es un sistema web de control de asistencia laboral desarrollado en Flask con arquitectura Service-Repository-Controller. Gestiona empleados, turnos, marcaciones de ingreso/egreso, justificaciones, licencias, notificaciones y reportes exportables. Usa autenticación por sesión con bcrypt, roles (admin/supervisor/empleado), y un motor de reglas de negocio para clasificar automáticamente cada marcación como puntual, tarde, ausente, salida anticipada o jornada incompleta.

**Nuevo sistema:** Aplicación móvil multiplataforma (Android + iOS) desarrollada en Flutter, reemplazando la marcación tradicional por geolocalización con geocercas. Se migra la lógica de negocio completa manteniendo la misma experiencia visual, navegación y flujos.

---

## 2. Inventario Completo de Pantallas

### 2.1 Login (LOG-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Inicio de Sesión |
| **Ruta** | /login |
| **Propósito** | Autenticar usuario con username y contraseña |
| **Componentes** | Split-screen: imagen izquierda + formulario oscuro derecha |
| **Campos** | username (text, required, autofocus), password (password, required, toggle visibility) |
| **Botones** | "Entrar al Sistema" (submit, full-width, primary) |
| **Acciones** | POST login → valida credenciales → redirige según rol; rate limiting (5 intentos, 5 min bloqueo) |
| **Permisos** | Público (sin autenticación) |
| **Flujo** | Login exitoso → si primer_login=1 → /change-password → /dashboard según rol |
| **Estados** | Error: "Usuario no existe", "Contraseña incorrecta", "Usuario inactivo", "Demasiados intentos" |

### 2.2 Cambio de Contraseña (PWD-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Cambiar Contraseña |
| **Ruta** | /change-password |
| **Propósito** | Primer login o cambio voluntario de contraseña |
| **Componentes** | Split-screen matching login, alerta informativa |
| **Campos** | old_password (password, required si no es primer_login), new_password (password, required, min 8), confirm_password (password, required) |
| **Botones** | "Establecer y Continuar" (primer login) / "Actualizar Contraseña" (voluntario) |
| **Acciones** | POST → valida coincidencia y longitud → cambia contraseña → redirige a dashboard |
| **Permisos** | Usuario autenticado con primer_login=1 o must_change_password=1 |
| **Flujo** | Éxito → flash success → redirige a dashboard según rol |

### 2.3 Admin Dashboard (DASH-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Panel de Control |
| **Ruta** | /admin/dashboard |
| **Propósito** | Vista general de estadísticas del día |
| **Componentes** | Filtros (fecha + DNI), 4 KPIs, gráfico donut, gráfico barras semanal, gráfico barras mensual, tabla por turno, alertas de tardanzas/ausencias reiteradas |
| **Campos** | fecha (date, default hoy), dni (text, placeholder "Buscar DNI") |
| **Botones** | "Filtrar" |
| **Acciones** | GET → aplica filtros → renderiza con Chart.js |
| **Permisos** | admin, supervisor |
| **Variables** | data (presentes/tardanzas/ausentes/total/porcentajes), alertas_tardanzas (>=3 en 7 días), alertas_ausencias (>=3 en 7 días), datos_semanales (7 días), datos_mensuales (4 semanas), asistencia_turnos (por turno), kpis, filtro_dni, filtro_fecha |

### 2.4 Employee Dashboard (DASH-02)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Mi Asistencia |
| **Ruta** | /employee/dashboard |
| **Propósito** | Marcación de ingreso/egreso + historial personal |
| **Componentes** | Card principal con gradiente según estado, alerta de tardanzas, tabla historial (15 registros), sidebar de justificaciones (10 últimas) |
| **Botones** | "Marcar Ingreso" (grande, verde), "Marcar Egreso" (grande, rojo), "Nueva Solicitud" (a justificar) |
| **Acciones** | POST /api/check-in, POST /api/check-out (AJAX con recarga 2s) |
| **Permisos** | empleado (admin/supervisor redirigen a admin/dashboard) |
| **Estados card** | Sin ingreso (gradient slate), Con ingreso sin egreso (gradient green), Jornada completa (gradient teal) |
| **Tardanza** | Si >=3 tardanzas en 7 días → alerta warning |

### 2.5 Usuarios — Lista (USR-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Usuarios |
| **Ruta** | /admin/usuarios |
| **Propósito** | Gestionar usuarios del sistema |
| **Componentes** | Buscador (client-side), tabla con avatar, nombre, username, DNI, legajo, rol (badge), turno, acciones |
| **Botones** | "Nuevo Usuario" (admin-only), "Editar", "Resetear Clave", "Eliminar" |
| **Permisos** | admin (todo), supervisor (solo empleados, no puede editar/eliminar admins) |
| **Roles badge** | Admin: danger, Supervisor: warning, Empleado: info |

### 2.6 Usuarios — Formulario (USR-02)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Nuevo / Editar Usuario |
| **Ruta** | /admin/usuarios/nuevo, /admin/usuarios/editar/<id> |
| **Propósito** | Crear o editar un usuario |
| **Componentes** | Card-header con imagen decorativa, formulario en dos columnas |
| **Campos** | nombre*, apellido*, dni* (solo crear), legajo* (solo crear), rol* (select: empleado/supervisor/admin), email, telefono, domicilio, genero (select: M/F/O), turno_id (select) |
| **Botones** | "Volver a la lista", "Cancelar", "Crear Usuario" / "Guardar Cambios", "Reactivar Usuario" (si aplica) |
| **Acciones** | Crear: valida DNI 7-8 dígitos, email regex, teléfono regex, username auto-generado, password inicial = DNI; Editar: actualiza campos, sincroniza username |
| **Permisos** | admin |
| **Flujo especial** | Si DNI/legajo pertenece a usuario inactivo → muestra checkbox de reactivación |

### 2.7 Turnos — Lista (SHF-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Turnos |
| **Ruta** | /admin/turnos |
| **Propósito** | Listar y gestionar turnos |
| **Componentes** | Cards de turno con indicador de color (verde: mañana, amber: tarde, indigo: noche, slate: otro) |
| **Botones** | "Nuevo Turno", "Editar", "Eliminar", "Asignar Empleados", "Ver Empleados" |
| **Permisos** | admin |
| **Card info** | Nombre, hora inicio-fin, tolerancia, descripción |

### 2.8 Turnos — Formulario (SHF-02)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Nuevo / Editar Turno |
| **Ruta** | /admin/turnos/nuevo, /admin/turnos/editar/<id> |
| **Propósito** | Crear o editar un turno |
| **Campos** | nombre* (select: Mañana/Tarde/Noche/otro), hora_inicio* (time), hora_fin* (time), tolerancia_minutos (number, default 15, min 0, max 60), dias_validos* (checkboxes L-D), descripcion (textarea) |
| **Botones** | "Volver", "Cancelar", "Crear Turno" / "Guardar Cambios" |
| **Permisos** | admin |

### 2.9 Turnos — Asignar Empleados (SHF-03)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Asignar Empleados |
| **Ruta** | /admin/turnos/asignar/<id> |
| **Propósito** | Vincular/desvincular empleados a un turno |
| **Componentes** | Dos paneles: izquierda empleados asignados (con Quitar), derecha empleados disponibles (con checkboxes + Select All) |
| **Botones** | "Volver a Turnos", "Quitar" (por empleado), "Vincular Empleados Seleccionados" |
| **Permisos** | admin |

### 2.10 Turnos — Ver Empleados (SHF-04)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Empleados del Turno |
| **Ruta** | /admin/turnos/<id>/usuarios |
| **Propósito** | Ver empleados asignados a un turno |
| **Componentes** | Tabla con nombre, DNI, legajo |
| **Permisos** | admin |

### 2.11 Asistencias (ATT-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Asistencias |
| **Ruta** | /admin/asistencias |
| **Propósito** | Visualizar asistencias del día por turno |
| **Componentes** | Navegación día (prev/next/hoy), filtro por turno, 4 stat cards (total/presentes/tardes/ausentes), tabla con nombre, DNI, legajo, hora ingreso, hora egreso, estado (badge coloreado) |
| **Botones** | Día anterior (<), Día siguiente (>), "Hoy", filtros de turno |
| **Estados badge** | Puntual (success), Tarde (warning), Ausente (danger), Tarde Justificado (success), Salida Anticipada (warning), Jornada Incompleta (info), Sin Egreso (info) |
| **Permisos** | admin, supervisor |

### 2.12 Reportes (RPT-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Reportes |
| **Ruta** | /admin/reportes |
| **Propósito** | Generar reportes exportables |
| **Campos** | fecha_inicio* (date, default 1ro del mes), fecha_fin* (date, default hoy), dni (text), tipo_incidencia (select: todos/presente/tarde/salida_anticipada/jornada_incompleta), turno_id (select) |
| **Botones** | "Exportar CSV", "Exportar Excel", "Exportar PDF" — cada uno llama a endpoint separado con filtros como query params |
| **Acciones** | GET /admin/exportar-csv, /admin/exportar-excel, /admin/exportar-pdf |
| **Leyenda** | Badge de colores para cada tipo de incidencia |
| **Permisos** | admin, supervisor |

### 2.13 Vacaciones / Licencias (VAC-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Licencias |
| **Ruta** | /admin/vacaciones |
| **Propósito** | Gestionar licencias del personal |
| **Componentes** | Formulario de nueva licencia, tabla de licencias activas, filtro por fecha |
| **Campos nuevo** | empleado* (select), fecha_desde* (date), fecha_hasta* (date), motivo (text), observaciones (textarea) |
| **Campos filtro** | fecha (date) |
| **Botones** | "Agregar", "Filtrar", "Limpiar", "Cancelar" (por licencia) |
| **Permisos** | admin, supervisor |

### 2.14 Configuración (CFG-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Configuración |
| **Ruta** | /admin/configuracion |
| **Propósito** | Editar perfil del admin y cambiar contraseña |
| **Campos** | nombre*, apellido*, username*, current_password* (requerido para cambios), new_password (min 8, opcional), confirm_password |
| **Botones** | "Cancelar", "Guardar Cambios" |
| **Permisos** | admin, supervisor |

### 2.15 Notificaciones — Lista (NTF-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Notificaciones |
| **Ruta** | /notificaciones |
| **Propósito** | Historial completo de notificaciones |
| **Componentes** | Lista con badge de tipo (Llegada Tarde / Ausencia / Recordatorio Egreso / Alerta Tardanzas / info), mensaje, timestamp, botón "Marcar leída" |
| **Botones** | "Marcar todas como leídas", "Marcar como leída" (por item) |
| **Permisos** | Todos los roles autenticados |

### 2.16 Notificaciones — Bell Component (NTF-02)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Campana de Notificaciones |
| **Ubicación** | Header de todas las pantallas logged-in |
| **Propósito** | Polling de notificaciones no leídas cada 30s |
| **Componentes** | Ícono campana con badge numérico, dropdown con últimas 5, toast en tiempo real |
| **Botones** | "Marcar todas leídas", "Ver todas" |
| **API** | GET /api/notificaciones?limite=5&no_leidas=true, GET /api/notificaciones/contador, POST /api/notificaciones/marcar-todas-leidas |

### 2.17 Justificar (JUS-01)

| Atributo | Detalle |
|----------|---------|
| **Nombre** | Justificar Inasistencia |
| **Ruta** | /employee/justificar |
| **Propósito** | Enviar justificación por tardanza/ausencia |
| **Componentes** | Card-header con imagen decorativa, alerta informativa |
| **Campos** | motivo* (select: Enfermedad/Dormirse/Fuerza Mayor/Otros), observaciones (textarea, max 500), documento (file, pdf/jpg/png) |
| **Botones** | "Volver al Panel", "Cancelar", "Enviar Solicitud" |
| **Permisos** | empleado |

---

## 3. Mapa de Navegación Completo

### 3.1 Árbol de Navegación

```
[Login] ──► [Change Password] ──► [Dashboard según rol]
                                        │
                    ┌───────────────────┴───────────────────┐
                    ▼                                       ▼
          [Admin Dashboard]                        [Employee Dashboard]
          /admin/dashboard                        /employee/dashboard
                    │                                       │
        ┌───────────┼───────────┬───────────┐               │
        ▼           ▼           ▼           ▼               │
    [Usuarios]  [Turnos]  [Asistencias]  [Vacaciones]     │
    /admin/      /admin/   /admin/        /admin/           │
    usuarios     turnos    asistencias    vacaciones         │
        │           │                                        │
        ▼           ▼                                        ▼
    [Nuevo]    [Nuevo]  [Asignar]  [Justificar]
    /editar    /editar  Empleados  /employee/justificar
                                   
        ┌───────────┬───────────┬───────────┐
        ▼           ▼           ▼           ▼
    [Reportes] [Config.]  [Notificaciones]
    /admin/    /admin/    /notificaciones
    reportes   config.
```

### 3.2 Sidebar — Admin
- **PRINCIPAL:** Dashboard
- **GESTIÓN:** Usuarios, Turnos, Asistencias, Vacaciones / Licencias
- **ANÁLISIS:** Reportes
- **SISTEMA:** Notificaciones, Configuración

### 3.3 Sidebar — Empleado
- **MI PORTAL:** Mi Asistencia, Justificaciones
- **SISTEMA:** Notificaciones

---

---

## 4. Auditoría Visual Completa

### 4.1 Paleta de Colores Exacta

| Token | Hex | RGB | Uso |
|-------|-----|-----|-----|
| `--primary` | `#4F46E5` | `79,70,229` | Botones, links activos, foco, marca |
| `--primary-hover` | `#4338CA` | `67,56,202` | Hover botones primarios |
| `--primary-soft` | `#EEF2FF` | `238,242,255` | Fondos acento, focus rings |
| `--success` | `#10B981` | `16,185,129` | Badges "Presente", donut |
| `--success-soft` | `#ECFDF5` | `236,253,245` | Fondo badges success |
| `--success-dark` | `#065F46` | `6,95,70` | Texto badges success |
| `--warning` | `#F59E0B` | `245,158,11` | Badges "Tarde", donut |
| `--warning-soft` | `#FFFBEB` | `255,251,235` | Fondo badges warning |
| `--warning-dark` | `#92400E` | `146,64,14` | Texto badges warning |
| `--danger` | `#EF4444` | `239,68,68` | Badges "Ausente", btn egreso |
| `--danger-soft` | `#FEF2F2` | `254,242,242` | Fondo badges danger |
| `--danger-dark` | `#991B1B` | `153,27,27` | Texto badges danger |
| `--info` | `#0EA5E9` | `14,165,233` | Badges "Sin egreso" |
| `--info-soft` | `#F0F9FF` | `240,249,255` | Fondo badges info |

**Slate:**
| Token | Hex | Uso |
|-------|-----|-----|
| `--slate-50` | `#F8FAFC` | Fondo página, cabeceras tabla |
| `--slate-100` | `#F1F5F9` | Bordes celda, skeleton |
| `--slate-200` | `#E2E8F0` | Bordes card, input, tabla |
| `--slate-300` | `#CBD5E1` | Texto secundario sidebar |
| `--slate-400` | `#94A3B8` | Labels login, placeholder |
| `--slate-500` | `#64748B` | Breadcrumb, subtítulos |
| `--slate-600` | `#475569` | Texto logout header |
| `--slate-700` | `#334155` | Texto celdas, labels form |
| `--slate-800` | `#1E293B` | Borde sidebar, color body |
| `--slate-900` | `#0F172A` | Fondo sidebar, fondo login |

**Login específico:**
| Elemento | Valor |
|----------|-------|
| Fondo login | `#0F172A` |
| Input bg | `rgba(30,41,59,0.5)` |
| Input focus bg | `rgba(30,41,59,0.8)` |
| Input border | `rgba(255,255,255,0.1)` |
| Input text | `#FFFFFF` |
| Label | `#94A3B8` |
| Error bg | `rgba(239,68,68,0.1)` |
| Error border | `rgba(239,68,68,0.2)` |
| Error text | `#F87171` |

### 4.2 Tipografía

- **Familia:** `'Inter', -apple-system, sans-serif`
- **Pesos:** 400 (regular), 500 (medium), 600 (semibold), 700 (bold), 800 (extrabold)

| Contexto | Size | Weight | Color |
|----------|------|--------|-------|
| Logo brand | 18px | 700 | white |
| Login title | 32px | 800 | white |
| Page title | 24px | 700 | `#0F172A` |
| Page subtitle | 14px | 400 | `#64748B` |
| Sidebar section | 11px | 600 | `#CBD5E1` |
| Sidebar link | 14px | 500 | `#CBD5E1` |
| Stat value | 30px | 700 | `#0F172A` |
| Stat label | 14px | 500 | `#64748B` |
| Table header | 12px | 600 | `#64748B` |
| Table cell | 14px | 400 | `#334155` |
| Form label | 14px | 600 | `#334155` |
| Button | 14px | 600 | según variante |
| Badge | 12px | 600 | según estado |

### 4.3 Layout

**Login:** Split-screen >=992px (imagen flex:1.2 + formulario flex:1), mobile solo formulario.

**Dashboard:** Sidebar fija 260px + Header sticky 64px + Contenido con padding 32px.

### 4.4 Sidebar

- **Width:** 260px, fixed left, 100vh, z-index 1000
- **Fondo:** `#0F172A`, border-right `#1E293B`
- **Brand:** Gradient `#4F46E5` → `#818CF8`, icon 32x32, text 18px 700
- **Links:** padding 10px 12px, radius 8px, gap 12px, icon 18px stroke-2
- **Hover:** bg `#1E293B`, active bg `#4F46E5`
- **Footer:** border-top `#1E293B`, avatar 36px, name 13px 600, role 11px
- **Mobile:** translateX(-100%) con overlay `rgba(15,23,42,0.5)`, backdrop-filter blur

### 4.5 Cards

| Variante | Radius | Border | Padding | Shadow |
|----------|--------|--------|---------|--------|
| card-saas | 12px | 1px `#E2E8F0` | body 24px | sm |
| stat-card-modern | 16px | 1px `#E2E8F0` | 24px | sm, hover md |
| card-header-image | 12px top | — | h:180px | gradient overlay |

### 4.6 Formularios

| Propiedad | Valor |
|-----------|-------|
| Input padding | 10px 14px |
| Input radius | 8px |
| Input border | 1px `#E2E8F0` |
| Input focus | border `#4F46E5` + shadow `0 0 0 4px #EEF2FF` |
| Label | 14px 600 `#334155`, mb-6 |
| Transición | all 0.2s cubic-bezier(0.4,0,0.2,1) |

### 4.7 Botones

| Variante | BG | Border | Color | Hover |
|----------|----|--------|-------|-------|
| Primary | `#4F46E5` | none | white | `#4338CA` + shadow |
| Outline | white | 1px `#E2E8F0` | `#334155` | `#F8FAFC` |

Common: radius 8px, 14px 600, gap 8px, min-h 44px, min-w 44px.

### 4.8 Sombras

| Level | Value |
|-------|-------|
| sm (cards) | `0 1px 2px 0 rgb(0 0 0 / 0.05)` |
| md | `0 4px 6px -1px rgb(0 0 0 / 0.1)` |
| Button hover | `0 4px 12px rgba(79,70,229,0.3)` |

### 4.9 Tablas

- thead: bg `#F8FAFC`, 12px 600 uppercase `#64748B`, letter-spacing 0.05em
- tbody td: padding 16px, 14px, color `#334155`, border-bottom `#F1F5F9`
- tr:hover: bg `#F8FAFC`
- Mobile (<=767px): thead hidden, tr → card, td con data-label

### 4.10 Skeleton Loading

```css
.skeleton-pulse {
  background: linear-gradient(90deg, #E2E8F0 25%, #F1F5F9 50%, #E2E8F0 75%);
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s ease-in-out infinite;
}
```

---

## 5. Componentes Reutilizables

| # | Componente | Descripción | Uso en |
|---|------------|-------------|--------|
| 1 | card-saas | Card blanca con radius 12, border slate-200, shadow-sm, mb-24 | Todas las pantallas |
| 2 | stat-card-modern | Card de KPI con icono, valor y label | Dashboard admin, Asistencias |
| 3 | badge-saas (+ variants) | Badge de estado con color semántico | Tablas (asistencias, usuarios) |
| 4 | table-saas + responsive | Tabla con diseño desktop/mobile responsive | Usuarios, Asistencias, Reportes |
| 5 | form-input-saas + label | Input con padding, radio 8, focus ring primary | Todos los formularios |
| 6 | btn-primary-saas / btn-outline-saas | Botones con variantes primary y outline | Todas las acciones |
| 7 | sidebar + sidebar-link | Navegación lateral con iconos SVG | Admin base, Employee base |
| 8 | top-header + breadcrumb + logout | Barra superior sticky | Admin base, Employee base |
| 9 | notification-bell | Campana con badge, dropdown y polling 30s | Header de todas las páginas |
| 10 | page-title + page-subtitle | Título y subtítulo de página | Todas las páginas |
| 11 | skeleton-pulse | Loader animado tipo shimmer | Dashboard admin (charts) |
| 12 | card-header-image | Header decorativo con imagen y gradiente | Formularios |
| 13 | alert-saas | Alertas con ícono SVG y estilo semántico | Dashboard empleado |
| 14 | flash messages | Alertas Bootstrap con íconos SVG | Header de todas las páginas |

---

## 6. Reglas de Negocio

### 6.1 Evaluación de Ingreso

- Si `hora_ingreso <= hora_inicio_turno + tolerancia_minutos` → **puntual**
- Si `hora_ingreso > hora_inicio_turno + tolerancia_minutos` → **tarde**
- Si no hay turno asignado: tolerancia default 15 min sobre hora 09:00
- Si el día actual no está en `dias_validos` del turno → se ignora el turno

### 6.2 Evaluación de Egreso

- `salida_anticipada`: si `hora_egreso < hora_fin_turno`
- `horas_extra`: si `hora_egreso > hora_fin_turno`
- `normal`: si coincide exactamente

### 6.3 Clasificación de Registro Completo

| Ingreso | Egreso | Justificación | Estado Final |
|---------|--------|---------------|--------------|
| No hay registro | — | — | **ausente** |
| puntual | Sí, normal | — | **presente** |
| puntual | Sí, antes | — | **salida_anticipada** |
| tarde | — | No | **tarde** |
| tarde | — | Sí | **presente** (justificado) |
| cualquier | No | — | **jornada_incompleta** |
| cualquier | Sí | Sí (si tarde) | **presente** |
| — | — | En licencia | **licencia** |

### 6.4 Detección de Ausentes (Cron Diario 20:00)

1. Obtener empleados activos sin registro de asistencia hoy
2. Por cada uno, verificar que el día esté en `dias_validos` del turno
3. Verificar que NO esté de vacaciones
4. Insertar registro con estado `ausente` y hora NULL

### 6.5 Vacaciones / Licencias

- No se puede crear licencia para admin
- No se puede crear licencia si hay solapamiento con otra existente
- Fecha fin debe ser >= fecha inicio
- Usuario con licencia activa NO puede marcar ingreso/egreso
- Al crear: notificación al empleado + notificación a admins

### 6.6 Usuarios

- Username auto-generado: `nombre.apellido` en minúsculas
- Si username duplicado: se añade sufijo numérico (base1, base2, etc.)
- Password inicial: DNI del empleado (min 7 dígitos)
- Primer login: must_change_password = True → redirige a change-password
- DNI: 7-8 dígitos numéricos
- Email: validación regex
- Teléfono: validación regex

### 6.7 Notificaciones Automáticas

| Evento | Tipo | Trigger |
|--------|------|---------|
| Llegada tarde | tardanza | Al marcar ingreso después del límite |
| Ausencia del día | ausencia | Cron diario 20:00 |
| Recordatorio egreso | recordatorio_egreso | 30 min después del fin de turno (cada 5 min) |
| Licencia creada | vacaciones | Al crear/cancelar licencia |

### 6.8 Reportes

- Rango de fechas obligatorio
- Si no hay registro de un empleado en una fecha del rango → se genera registro con estado `ausente`
- Filtros disponibles: fecha, DNI, turno, tipo de incidencia
- Formatos: CSV, Excel (openpyxl), PDF (reportlab)

---

## 7. Modelo de Datos Actual

### 7.1 Entidades y Esquema SQLite

**users**
| Campo | Tipo | Restricciones |
|-------|------|---------------|
| id | INTEGER | PK AUTOINCREMENT |
| dni | TEXT | UNIQUE NOT NULL |
| legajo | TEXT | UNIQUE NOT NULL |
| nombre | TEXT | NOT NULL |
| apellido | TEXT | NOT NULL |
| username | TEXT | UNIQUE NOT NULL |
| password | TEXT | NOT NULL |
| rol | TEXT | CHECK(admin/supervisor/empleado) DEFAULT empleado |
| primer_login | INTEGER | DEFAULT 1 |
| must_change_password | INTEGER | DEFAULT 0 |
| telefono | TEXT | NULLABLE |
| email | TEXT | NULLABLE |
| edad | INTEGER | NULLABLE |
| genero | TEXT | NULLABLE |
| fecha_nacimiento | TEXT | NULLABLE |
| domicilio | TEXT | NULLABLE |
| estudios | TEXT | NULLABLE |
| turno_id | INTEGER | FK -> shifts(id) NULLABLE |
| activo | INTEGER | DEFAULT 1 |

**shifts**
| Campo | Tipo | Restricciones |
|-------|------|---------------|
| id | INTEGER | PK AUTOINCREMENT |
| nombre | TEXT | NOT NULL |
| hora_inicio | TEXT (HH:MM) | NOT NULL |
| hora_fin | TEXT (HH:MM) | NOT NULL |
| tolerancia_minutos | INTEGER | DEFAULT 15 |
| descripcion | TEXT | NULLABLE |
| dias_validos | TEXT | DEFAULT '0,1,2,3,4,5,6' |
| activo | INTEGER | DEFAULT 1 |

**attendance**
| Campo | Tipo | Restricciones |
|-------|------|---------------|
| id | INTEGER | PK AUTOINCREMENT |
| user_id | INTEGER | FK -> users(id) |
| user_dni | TEXT | FK -> users(dni) |
| fecha | TEXT (YYYY-MM-DD) | — |
| hora_ingreso | TEXT (HH:MM:SS) | NULLABLE |
| hora_egreso | TEXT (HH:MM:SS) | NULLABLE |
| estado | TEXT | — |
| horas_extra | REAL | DEFAULT 0 |

**justifications**
| Campo | Tipo | Restricciones |
|-------|------|---------------|
| id | INTEGER | PK AUTOINCREMENT |
| user_id | INTEGER | FK -> users(id) |
| user_dni | TEXT | FK -> users(dni) |
| fecha | TEXT | — |
| motivo | TEXT | CHECK(enfermedad/dormirse/fuerza_mayor/otros) |
| observaciones | TEXT | NULLABLE |
| documento_path | TEXT | NULLABLE |

**notifications**
| Campo | Tipo | Restricciones |
|-------|------|---------------|
| id | INTEGER | PK AUTOINCREMENT |
| user_id | INTEGER | FK -> users(id) |
| tipo | TEXT | — |
| mensaje | TEXT | — |
| leida | INTEGER | DEFAULT 0 |
| fecha | TEXT | — |

**vacations**
| Campo | Tipo | Restricciones |
|-------|------|---------------|
| id | INTEGER | PK AUTOINCREMENT |
| user_id | INTEGER | NOT NULL, FK -> users(id) |
| user_dni | TEXT | FK -> users(dni) |
| fecha_inicio | TEXT | NOT NULL |
| fecha_fin | TEXT | NOT NULL |
| motivo | TEXT | NULLABLE |
| observaciones | TEXT | NULLABLE |
| created_by | INTEGER | NOT NULL, FK -> users(id) |
| created_at | TEXT | DEFAULT datetime('now') |

### 7.2 Índices Existentes

```sql
CREATE INDEX idx_attendance_user_date ON attendance(user_id, fecha);
CREATE INDEX idx_attendance_fecha ON attendance(fecha);
CREATE INDEX idx_users_turno ON users(turno_id);
CREATE INDEX idx_users_rol ON users(rol);
CREATE INDEX idx_notifications_user ON notifications(user_id, leida);
CREATE INDEX idx_vacations_user ON vacations(user_id);
CREATE INDEX idx_vacations_dates ON vacations(fecha_inicio, fecha_fin);
```

### 7.3 Relaciones

- users.turno_id -> shifts(id) (N:1)
- attendance.user_id -> users(id) (N:1)
- attendance.user_dni -> users(dni) (N:1)
- justifications.user_id -> users(id) (N:1)
- vacations.user_id -> users(id) (N:1)
- vacations.created_by -> users(id) (N:1)
- notifications.user_id -> users(id) (N:1)

---

---

## 8. Adaptación a Flutter + Firebase

### 8.1 Stack Tecnológico

| Capa | Tecnología | Propósito |
|------|-----------|-----------|
| UI | Flutter 3.x + Dart 3.x | Framework multiplataforma |
| Diseño | Material 3 (M3) | Sistema de diseño nativo |
| Estado | Riverpod 2.x | Manejo de estado reactivo |
| Navegación | GoRouter | Enrutamiento declarativo con redirecciones por rol |
| Backend | Firebase | BaaS completo |
| Auth | Firebase Auth + email/password | Autenticación segura |
| DB | Cloud Firestore | Base de datos NoSQL en tiempo real |
| Storage | Firebase Storage | Almacenamiento de archivos (justificaciones) |
| Push | Firebase Cloud Messaging | Notificaciones push |
| Maps | flutter_map (OSM) + latlong2 | Mapas para geolocalización |
| Charts | fl_chart | Gráficos donut y barras |
| HTTP | dio | Cliente HTTP (si necesario) |
| Local | shared_preferences | Caché local |

### 8.2 Arquitectura Flutter

```
lib/
├── main.dart                           # Entry point + providers
├── app.dart                            # MaterialApp.router configuración
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart             # Tokens de color
│   │   ├── app_text_styles.dart        # Tokens tipográficos
│   │   ├── app_spacing.dart            # Espaciados constantes
│   │   └── app_borders.dart            # Radios, sombras
│   ├── theme/
│   │   └── app_theme.dart              # ThemeData Material 3
│   ├── router/
│   │   └── app_router.dart             # GoRouter + redirect guards
│   ├── errors/
│   │   └── exceptions.dart             # Excepciones personalizadas
│   └── utils/
│       ├── date_utils.dart             # Formateo fechas
│       ├── validators.dart             # Validación formularios
│       └── geo_utils.dart              # Cálculos distancia GPS
│
├── data/
│   ├── firebase/
│   │   ├── auth_service.dart           # Firebase Auth wrapper
│   │   ├── firestore_service.dart      # Firestore CRUD genérico
│   │   └── storage_service.dart        # Firebase Storage wrapper
│   ├── repositories/
│   │   ├── user_repository.dart
│   │   ├── shift_repository.dart
│   │   ├── attendance_repository.dart
│   │   ├── justification_repository.dart
│   │   ├── vacation_repository.dart
│   │   ├── notification_repository.dart
│   │   └── location_repository.dart
│   └── models/
│       ├── user_model.dart
│       ├── shift_model.dart
│       ├── attendance_record.dart
│       ├── justification_model.dart
│       ├── vacation_model.dart
│       ├── notification_model.dart
│       └── work_location_model.dart
│
├── domain/
│   ├── services/
│   │   ├── auth_service.dart           # Login, register, change password
│   │   ├── attendance_service.dart     # Check-in/out, stats
│   │   ├── rules_service.dart          # Business rules engine
│   │   ├── admin_service.dart          # Dashboard data, alerts
│   │   ├── report_service.dart         # Report generation
│   │   ├── vacation_service.dart       # Licenses
│   │   ├── notification_service.dart   # Notifications
│   │   └── location_service.dart       # GPS validation
│   └── enums/
│       ├── attendance_state.dart
│       ├── user_role.dart
│       ├── justification_motive.dart
│       └── notification_type.dart
│
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart          # AuthNotifier (login, logout, session)
│   │   ├── user_provider.dart          # Listado y CRUD usuarios
│   │   ├── shift_provider.dart         # CRUD turnos
│   │   ├── attendance_provider.dart    # Marcación + historial
│   │   ├── admin_dashboard_provider.dart
│   │   ├── employee_dashboard_provider.dart
│   │   ├── report_provider.dart
│   │   ├── vacation_provider.dart
│   │   └── notification_provider.dart  # Polling + badge count
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── change_password_screen.dart
│   │   ├── admin/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── users_list_screen.dart
│   │   │   ├── user_form_screen.dart
│   │   │   ├── shifts_list_screen.dart
│   │   │   ├── shift_form_screen.dart
│   │   │   ├── shift_assign_screen.dart
│   │   │   ├── attendance_screen.dart
│   │   │   ├── reports_screen.dart
│   │   │   ├── vacations_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── notifications_screen.dart
│   │   ├── employee/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── justification_screen.dart
│   │   └── location/
│   │       ├── work_locations_screen.dart
│   │       └── work_location_form_screen.dart
│   │
│   ├── widgets/
│   │   ├── layout/
│   │   │   ├── app_scaffold.dart
│   │   │   ├── sidebar.dart
│   │   │   ├── sidebar_section.dart
│   │   │   ├── sidebar_link.dart
│   │   │   ├── app_header.dart
│   │   │   └── notification_bell.dart
│   │   ├── common/
│   │   │   ├── app_card.dart
│   │   │   ├── stat_card.dart
│   │   │   ├── app_table.dart
│   │   │   ├── app_badge.dart
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_dropdown.dart
│   │   │   ├── app_date_picker.dart
│   │   │   ├── app_time_picker.dart
│   │   │   ├── app_skeleton.dart
│   │   │   ├── app_empty_state.dart
│   │   │   ├── app_alert.dart
│   │   │   ├── app_flash_message.dart
│   │   │   ├── app_confirm_dialog.dart
│   │   │   └── app_loading_overlay.dart
│   │   └── charts/
│   │       ├── attendance_donut_chart.dart
│   │       ├── weekly_bar_chart.dart
│   │       └── monthly_bar_chart.dart
```

### 8.3 Estructura Firestore

```
/users/{userId}                     -> Datos del usuario
/shifts/{shiftId}                  -> Configuración de turnos
/attendance/{attendanceId}         -> Registros de asistencia
/justifications/{justId}           -> Justificaciones
/vacations/{vacationId}            -> Licencias/vacaciones
/notifications/{notificationId}    -> Notificaciones
/workLocations/{locationId}        -> Ubicaciones laborales (geocercas)
```

### 8.4 Autenticación (Firebase Auth)

| Función | Implementación |
|---------|---------------|
| Login | FirebaseAuth.signInWithEmailAndPassword |
| Logout | FirebaseAuth.signOut |
| Change password | Reautenticar + user.updatePassword |
| Reset password | Admin: cambia en Firestore + marca primer_login |
| Session persistencia | FirebaseAuth mantiene sesión automáticamente |
| Auth state listener | authStateChanges() -> Riverpod provider |

### 8.5 Reglas de Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth.uid == userId
                   || request.auth.token.role in ['admin', 'supervisor'];
      allow write: if request.auth.token.role == 'admin';
    }
    match /attendance/{doc} {
      allow read: if request.auth.token.role in ['admin', 'supervisor']
                   || resource.data.userId == request.auth.uid;
      allow create: if request.auth.uid != null;
    }
    match /workLocations/{doc} {
      allow read, write: if request.auth.token.role == 'admin';
    }
  }
}
```

### 8.6 GoRouter — Definición de Rutas

```dart
GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final auth = ref.read(authProvider);
    final logged = auth.isLoggedIn;
    final location = state.matchedLocation;

    if (!logged && location != '/login') return '/login';
    if (logged && location == '/login') return '/dashboard';

    if (logged && location == '/dashboard') {
      if (auth.role == 'empleado') return '/employee/dashboard';
      return '/admin/dashboard';
    }

    if (['/admin/users', '/admin/shifts'].contains(location)
        && auth.role != 'admin') return '/admin/dashboard';

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/change-password', builder: (_, __) => ChangePasswordScreen()),
    ShellRoute(
      builder: (_, __, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/admin/dashboard', builder: ...),
        GoRoute(path: '/admin/users', builder: ...),
        GoRoute(path: '/admin/users/new', builder: ...),
        GoRoute(path: '/admin/users/:id/edit', builder: ...),
        GoRoute(path: '/admin/shifts', builder: ...),
        GoRoute(path: '/admin/shifts/new', builder: ...),
        GoRoute(path: '/admin/shifts/:id/edit', builder: ...),
        GoRoute(path: '/admin/shifts/:id/assign', builder: ...),
        GoRoute(path: '/admin/attendance', builder: ...),
        GoRoute(path: '/admin/reports', builder: ...),
        GoRoute(path: '/admin/vacations', builder: ...),
        GoRoute(path: '/admin/profile', builder: ...),
        GoRoute(path: '/admin/locations', builder: ...),
        GoRoute(path: '/admin/locations/new', builder: ...),
        GoRoute(path: '/employee/dashboard', builder: ...),
        GoRoute(path: '/employee/justify', builder: ...),
        GoRoute(path: '/notifications', builder: ...),
      ],
    ),
  ],
);
```

### 8.7 Mapeo de Pantallas a Navegación

| Pantalla Original | Ruta Flutter | Permiso |
|-------------------|-------------|---------|
| /login | /login | Público |
| /change-password | /change-password | Auth |
| /admin/dashboard | /admin/dashboard | Admin/Supervisor |
| /admin/usuarios | /admin/users | Admin/Supervisor |
| /admin/usuarios/nuevo | /admin/users/new | Admin |
| /admin/usuarios/editar/:id | /admin/users/:id/edit | Admin |
| /admin/turnos | /admin/shifts | Admin |
| /admin/turnos/nuevo | /admin/shifts/new | Admin |
| /admin/turnos/editar/:id | /admin/shifts/:id/edit | Admin |
| /admin/turnos/asignar/:id | /admin/shifts/:id/assign | Admin |
| /admin/asistencias | /admin/attendance | Admin/Supervisor |
| /admin/reportes | /admin/reports | Admin/Supervisor |
| /admin/vacaciones | /admin/vacations | Admin/Supervisor |
| /admin/configuracion | /admin/profile | Admin/Supervisor |
| /employee/dashboard | /employee/dashboard | Empleado |
| /employee/justificar | /employee/justify | Empleado |
| /notificaciones | /notifications | Auth |
| — (nuevo) | /admin/locations | Admin |
| — (nuevo) | /admin/locations/new | Admin |

---

## 9. Adaptación de Geolocalización

### 9.1 Visión General

Se reemplaza la marcación tradicional (API check-in/check-out sin validación geográfica) por un sistema basado en **geolocalización con geocercas**. El empleado debe estar físicamente dentro del radio autorizado de su lugar de trabajo para poder marcar ingreso y egreso.

### 9.2 Flujo de Marcación con GPS

```
1. Empleado abre la app -> Dashboard
2. Presiona "Marcar Ingreso"
3. App solicita permisos de ubicación (si no concedidos)
4. Obtiene coordenadas GPS actuales (lat, lng, precisión)
5. Busca geocercas activas (workLocations donde el empleado está asignado)
6. Calcula distancia desde su posición a cada geocerca
7. Si alguna distancia <= radio_metros -> PERMITIDO
   - Envía a Firestore: userId, timestamp, lat, lng, precision, locationId
   - Evalúa regla de tardanza contra el turno asignado
   - Muestra resultado: "Ingreso registrado" / "Llegó tarde"
8. Si ninguna distancia <= radio -> DENEGADO
   - Muestra mensaje: "No estás en una ubicación laboral autorizada"
   - Muestra distancia a la geocerca más cercana
```

### 9.3 Modelo Firestore: workLocations

```typescript
/workLocations/{locationId}
{
  name: string,
  address: string | null,
  latitude: number,
  longitude: number,
  radiusMeters: number,       // 20-500
  isActive: boolean,
  assignedUserIds: string[],
  assignedShiftIds: string[],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### 9.4 Reglas de Validación GPS

```dart
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000; // Earth radius in meters
  // Haversine formula implementation
  // ...
  return distance;
}

bool isValidLocation({
  required double userLat,
  required double userLng,
  required double locationLat,
  required double locationLng,
  required double radiusMeters,
  required double gpsPrecision,
}) {
  final distance = calculateDistance(userLat, userLng, locationLat, locationLng);
  if (gpsPrecision > 50) return false; // prevent spoofing
  return distance <= (radiusMeters + gpsPrecision);
}
```

### 9.5 Nuevo Documento de Asistencia con GPS

```typescript
/attendance/{attendanceId}
{
  userId: string,
  userDni: string,
  date: string,
  checkIn: {
    timestamp: Timestamp,
    latitude: number,
    longitude: number,
    precision: number,
    locationId: string
  } | null,
  checkOut: {
    timestamp: Timestamp,
    latitude: number,
    longitude: number,
    precision: number,
    locationId: string
  } | null,
  status: string,
  overtimeHours: number,
  shiftId: string | null
}
```

### 9.6 Pantallas Nuevas

| Pantalla | Ruta | Propósito | Botones |
|----------|------|-----------|---------|
| Ubicaciones Laborales | /admin/locations | Listar geocercas | Nueva Ubicación, Editar, Eliminar |
| Formulario Ubicación | /admin/locations/new | Crear/editar geocerca | Guardar, Cancelar, Seleccionar en Mapa |

### 9.7 Formulario de Ubicación Laboral

**Campos:** nombre* (text), dirección (text), latitud* (number), longitud* (number), radio_metros* (number, default 100, min 20, max 500), activa (switch, default true), empleados_asignados (multi-select, opcional), turnos_asignados (multi-select, opcional), mapa interactivo con pin arrastrable.

### 9.8 Mantener Intacto

| Módulo | Cambio |
|--------|--------|
| Turnos | Sin cambios |
| Licencias | Sin cambios |
| Reportes | Sin cambios (nuevos campos GPS en datos) |
| Usuarios | Sin cambios (se agrega: ubicaciones asignadas) |
| Dashboard | Sin cambios |
| Configuraciones | Sin cambios |

---

## 10. Modelo Firestore

### 10.1 Colecciones y Documentos

**users/{userId}**
```typescript
{
  uid: string,              // Firebase Auth UID
  dni: string,
  legajo: string,
  nombre: string,
  apellido: string,
  username: string,
  email: string | null,
  telefono: string | null,
  rol: 'admin' | 'supervisor' | 'empleado',
  genero: 'M' | 'F' | 'O' | null,
  domicilio: string | null,
  turnoId: string | null,
  activo: boolean,
  primerLogin: boolean,
  mustChangePassword: boolean,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**shifts/{shiftId}**
```typescript
{
  nombre: string,
  horaInicio: string,
  horaFin: string,
  toleranciaMinutos: number,
  descripcion: string | null,
  diasValidos: number[],
  activo: boolean,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**attendance/{attendanceId}**
```typescript
{
  userId: string,
  userDni: string,
  date: string,
  checkIn: { timestamp, latitude, longitude, precision, locationId } | null,
  checkOut: { timestamp, latitude, longitude, precision, locationId } | null,
  status: string,
  overtimeHours: number,
  shiftId: string | null,
  createdAt: Timestamp
}
```

**justifications/{justificationId}**
```typescript
{
  userId: string,
  userDni: string,
  date: string,
  motivo: string,
  observaciones: string | null,
  documentoUrl: string | null,
  createdAt: Timestamp
}
```

**vacations/{vacationId}**
```typescript
{
  userId: string,
  userDni: string,
  fechaInicio: string,
  fechaFin: string,
  motivo: string | null,
  observaciones: string | null,
  createdBy: string,
  createdAt: Timestamp
}
```

**notifications/{notificationId}**
```typescript
{
  userId: string,
  tipo: string,
  mensaje: string,
  leida: boolean,
  createdAt: Timestamp
}
```

### 10.2 Índices Compuestos Recomendados

| Colección | Campos | Propósito |
|-----------|--------|-----------|
| attendance | userId ASC, date DESC | Historial por usuario |
| attendance | date ASC, shiftId ASC | Vista admin por día/turno |
| attendance | date ASC, status ASC | Filtro por estado |
| notifications | userId ASC, createdAt DESC | Notificaciones recientes |
| notifications | userId ASC, leida ASC | No leídas |
| vacations | userId ASC, fechaInicio DESC | Licencias por usuario |
| vacations | fechaInicio ASC, fechaFin ASC | Activas en fecha |

### 10.3 Seguridad — Custom Claims

```javascript
admin.auth().setCustomUserClaims(uid, { role: 'admin' });
// Verify in rules with: request.auth.token.role
```

### 10.4 Migración de Datos

| Origen (SQLite) | Destino (Firestore) | Estrategia |
|-----------------|---------------------|------------|
| users | /users/{uid} | Asignar nuevo UID, mantener DNI |
| shifts | /shifts/{id} | Migrar 1:1 con mismo ID |
| attendance | /attendance/{id} | checkIn sin GPS, migrar timestamp |
| justifications | /justifications/{id} | Migrar docs a Storage |
| vacations | /vacations/{id} | Migrar 1:1 |
| notifications | /notifications/{id} | Migrar 1:1 |

---

---

## 11. Design System Flutter

### 11.1 Tema Material 3 — AppTheme

```dart
class AppTheme {
  static const _primary = Color(0xFF4F46E5);
  static const _onPrimary = Colors.white;
  static const _primaryContainer = Color(0xFFEEF2FF);
  static const _onPrimaryContainer = Color(0xFF4338CA);
  static const _secondary = Color(0xFF0EA5E9);
  static const _error = Color(0xFFEF4444);
  static const _errorContainer = Color(0xFFFEF2F2);
  static const _onErrorContainer = Color(0xFF991B1B);
  static const _surface = Colors.white;
  static const _onSurface = Color(0xFF0F172A);
  static const _success = Color(0xFF10B981);
  static const _successContainer = Color(0xFFECFDF5);
  static const _onSuccessContainer = Color(0xFF065F46);
  static const _warning = Color(0xFFF59E0B);
  static const _warningContainer = Color(0xFFFFFBEB);
  static const _onWarningContainer = Color(0xFF92400E);
  static const _info = Color(0xFF0EA5E9);
  static const _infoContainer = Color(0xFFF0F9FF);

  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  static const sidebarBackground = Color(0xFF0F172A);
  static const sidebarBorder = Color(0xFF1E293B);
  static const sidebarLinkColor = Color(0xFFCBD5E1);
  static const sidebarLinkHover = Color(0xFF1E293B);
  static const sidebarLinkActive = Color(0xFF4F46E5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: _primary,
        onPrimary: _onPrimary,
        primaryContainer: _primaryContainer,
        onPrimaryContainer: _onPrimaryContainer,
        secondary: _secondary,
        error: _error,
        errorContainer: _errorContainer,
        onErrorContainer: _onErrorContainer,
        surface: _surface,
        onSurface: _onSurface,
        outline: slate200,
        outlineVariant: slate100,
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: slate50,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: slate800,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: slate200),
        ),
        margin: EdgeInsets.only(bottom: 24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: slate700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: Size(44, 44),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: slate700,
          minimumSize: Size(44, 44),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          side: BorderSide(color: slate200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: slate900,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _primary,
      ),
      dividerTheme: DividerThemeData(color: slate200, thickness: 1),
    );
  }
}
```

### 11.2 Tokens de Color — AppColors

```dart
class AppColors {
  static const success = Color(0xFF10B981);
  static const successContainer = Color(0xFFECFDF5);
  static const onSuccessContainer = Color(0xFF065F46);
  static const warning = Color(0xFFF59E0B);
  static const warningContainer = Color(0xFFFFFBEB);
  static const onWarningContainer = Color(0xFF92400E);
  static const danger = Color(0xFFEF4444);
  static const dangerContainer = Color(0xFFFEF2F2);
  static const onDangerContainer = Color(0xFF991B1B);
  static const info = Color(0xFF0EA5E9);
  static const infoContainer = Color(0xFFF0F9FF);

  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  static const shiftMorning = Color(0xFF10B981);
  static const shiftAfternoon = Color(0xFFF59E0B);
  static const shiftNight = Color(0xFF4F46E5);
  static const shiftOther = Color(0xFF64748B);

  static const employeeNoEntryGradient = [slate900, Color(0xFF1E1B4B)];
  static const employeeWithEntryGradient = [Color(0xFF065F46), Color(0xFF047857)];
  static const employeeCompleteGradient = [Color(0xFF065F46), Color(0xFF0D9488)];
}
```

### 11.3 Tipografía — AppTextStyles

```dart
class AppTextStyles {
  static const _font = 'Inter';

  static final pageTitle = TextStyle(
    fontFamily: _font, fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.slate900, letterSpacing: -0.02,
  );
  static final pageSubtitle = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.slate500,
  );
  static final cardTitle = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.slate900,
  );
  static final statValue = TextStyle(
    fontFamily: _font, fontSize: 30, fontWeight: FontWeight.w700,
    color: AppColors.slate900,
  );
  static final statLabel = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.slate500,
  );
  static final tableHeader = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.slate500, letterSpacing: 0.05,
  );
  static final tableCell = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.slate700,
  );
  static final formLabel = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.slate700,
  );
  static final badge = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w600,
  );
  static final button = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600,
  );
  static final sidebarLink = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.slate300,
  );
  static final sidebarSection = TextStyle(
    fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.slate300, letterSpacing: 0.05,
  );
  static final loginTitle = TextStyle(
    fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w800,
    color: Colors.white, letterSpacing: -0.025,
  );
  static final loginSubtitle = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.slate500,
  );
}
```

### 11.4 Espaciados — AppSpacing

```dart
class AppSpacing {
  static const pagePadding = 32.0;
  static const pagePaddingTablet = 16.0;
  static const pagePaddingMobile = 12.0;
  static const cardPadding = 24.0;
  static const cardHeaderPadding = 16.0;
  static const cardGap = 24.0;
  static const kpiGap = 16.0;
  static const formFieldGap = 16.0;
  static const inputPaddingH = 14.0;
  static const inputPaddingV = 10.0;
  static const buttonMinSize = 44.0;
  static const buttonPaddingH = 18.0;
  static const buttonPaddingV = 10.0;
  static const sidebarWidth = 260.0;
  static const headerHeight = 64.0;
  static const headerHeightMobile = 56.0;
  static const radiusCard = 12.0;
  static const radiusStatCard = 16.0;
  static const radiusButton = 8.0;
  static const radiusInput = 8.0;
  static const radiusBadge = 6.0;
  static const radiusSidebarLink = 8.0;
  static const radiusLogin = 12.0;

  static List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> shadowButton = [
    BoxShadow(color: Color(0x4D4F46E5), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
```

### 11.5 Custom Widgets — Especificaciones

| Widget | Parámetros | Descripción |
|--------|-----------|-------------|
| AppCard | {Widget child, EdgeInsets? padding} | Card radius 12, border slate-200, shadow-sm |
| StatCard | {IconData icon, Color iconBg, String label, String value, Widget? trend} | KPI 44x44 icon, 30px value, 14px label |
| AppBadge | {String label, BadgeType type} | Container padding 4x10, radius 6, color semántico |
| AppButton | {String label, VoidCallback onPressed, ButtonVariant variant} | Min 44x44, radius 8, 14px 600 |
| AppTextField | {String label, TextEditingController ctrl, bool required} | Input label 14px 600 + border slate-200 |
| AppSidebar | {List items, String activeRoute} | NavigationDrawer slate-900, 260px |
| AppHeader | {List breadcrumbs, Widget? actions} | AppBar blanco 64px + breadcrumbs + logout |
| AppTable | {List columns, List rows, bool responsive} | Desktop table + mobile card view |
| SkeletonShimmer | {double width, double height, double radius} | Shimmer animado 1.5s |
| EmptyState | {String title, String subtitle} | SVG 64px + h4 + p |
| NotificationBell | {int unreadCount, List recent} | Badge + dropdown + polling 30s |
| DonutChart | {int presentes, int tardanzas, int ausentes} | PieChart cutout 78% |
| WeeklyBarChart | {List days} | BarChart grouped |
| MonthlyBarChart | {List weeks} | BarChart grouped |

---

## 12. Roadmap de Desarrollo

### Fase 1: Infraestructura (2 semanas)

| # | Tarea | Detalle |
|---|-------|---------|
| 1.1 | Inicializar proyecto Flutter | flutter create |
| 1.2 | Configurar dependencias | riverpod, go_router, firebase, fl_chart, flutter_map, etc. |
| 1.3 | Configurar Firebase | Auth, Firestore, Storage, FCM |
| 1.4 | Configurar lint | analysis_options.yaml |
| 1.5 | Estructura de directorios | core/, data/, domain/, presentation/ |
| 1.6 | Design System base | AppColors, AppTextStyles, AppSpacing, AppTheme |
| 1.7 | Router base | GoRouter + redirect por auth |
| 1.8 | Firebase Auth service | login(), logout(), authStateChanges() |

### Fase 2: Autenticación (1 semana)

| # | Tarea |
|---|-------|
| 2.1 | Login Screen (split desktop / full mobile) |
| 2.2 | Change Password Screen (primer login + voluntario) |
| 2.3 | Auth Provider (Riverpod AuthNotifier) |
| 2.4 | Custom Claims (rol en Firebase Auth) |
| 2.5 | Logout |

### Fase 3: Usuarios (1.5 semanas)

| # | Tarea |
|---|-------|
| 3.1 | User model + repository Firestore |
| 3.2 | Users List Screen (buscador, tabla responsive, badges) |
| 3.3 | User Form Screen (crear/editar con validaciones) |
| 3.4 | Reactivación de usuario (detectar inactivo) |
| 3.5 | Reset password + eliminar usuario (soft delete) |
| 3.6 | UserProvider (Riverpod CRUD) |

### Fase 4: Turnos (1 semana)

| # | Tarea |
|---|-------|
| 4.1 | Shift model + repository |
| 4.2 | Shifts List Screen (cards con indicador de color) |
| 4.3 | Shift Form Screen (nombre, horas, tolerancia, días) |
| 4.4 | Shift Assign Screen (dos paneles, select all) |
| 4.5 | Ver empleados del turno |

### Fase 5: Geolocalización (2 semanas)

| # | Tarea |
|---|-------|
| 5.1 | WorkLocation model + repository |
| 5.2 | Work Locations List Screen |
| 5.3 | Work Location Form Screen (mapa interactivo) |
| 5.4 | Location Service (Haversine, validación precisión) |
| 5.5 | Permisos GPS (Android Manifest + iOS Info.plist) |
| 5.6 | Check-in with GPS (ubicación + geocerca + crear attendance) |
| 5.7 | Check-out with GPS (mismo flujo) |
| 5.8 | Employee Dashboard (card estados, botón marcación) |
| 5.9 | Business Rules (evaluar tardanza, clasificar registro) |
| 5.10 | Attendance Provider |

### Fase 6: Licencias (1 semana)

| # | Tarea |
|---|-------|
| 6.1 | Vacation model + repository |
| 6.2 | Vacations Screen (nuevo + tabla + filtro) |
| 6.3 | Validaciones (solapamiento, fechas, no admin) |
| 6.4 | Notificaciones push al crear/cancelar |
| 6.5 | Bloqueo de marcación si está de licencia |

### Fase 7: Reportes + Dashboard (2 semanas)

| # | Tarea |
|---|-------|
| 7.1 | Admin Dashboard (KPIs, donut, barras, alertas) |
| 7.2 | Attendance Screen admin (navegación día, filtro turno) |
| 7.3 | Reports Screen (filtros fecha/DNI/turno/incidencia) |
| 7.4 | Export CSV + Excel + PDF |
| 7.5 | Notification Bell (polling 30s, badge, toast) |
| 7.6 | Notifications Screen (lista + marcar leídas) |
| 7.7 | Profile Screen (editar perfil + cambiar contraseña) |
| 7.8 | Justification Screen (formulario + subida archivo) |

### Fase 8: Producción (1.5 semanas)

| # | Tarea |
|---|-------|
| 8.1 | Responsive testing (múltiples tamaños) |
| 8.2 | Offline support (Firestore persistence) |
| 8.3 | Push notifications (FCM) |
| 8.4 | Error handling (try/catch en providers) |
| 8.5 | Loading states (skeleton loaders) |
| 8.6 | Empty states |
| 8.7 | Animaciones + reduced-motion support |
| 8.8 | Dark mode (opcional) |
| 8.9 | Build signing (keystore + iOS certificates) |
| 8.10 | Testing (widget + integration tests) |
| 8.11 | Code cleanup + lint |
| 8.12 | README con instrucciones de build |

---

**Total estimado: 12 semanas (3 meses)**

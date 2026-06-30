# Auditoría Visual y Guía de Diseño: PresentisPRO

> **Versión:** 1.0  
> **Propósito:** Replicar exactamente la experiencia visual de PresentisPRO (Flask + Bootstrap) en Flutter Material 3.  
> **Audiencia:** Desarrolladores Flutter que nunca vieron el proyecto original.  
> **Fuentes analizadas:** dashboard.css (769 líneas), login.html, change_password.html, ase.html (admin y employee), dashboard.html (admin y employee), usuarios.html, usuario_form.html, 	urnos.html, 	urno_form.html, 	urno_asignar.html, sistencias.html, eportes.html, acaciones.html, configuracion.html, justificar.html, 
otificaciones.html, 
otification_bell.html.

---

## 1. Paleta de Colores Completa

### 1.1 Mapa de Colores Exactos

| Rol | Hex | RGB | CSS Variable | Uso |
|-----|-----|-----|--------------|-----|
| **PRIMARY** | #4F46E5 | 79,70,229 | --primary | Botones, links activos, focus, marca |
| **PRIMARY HOVER** | #4338CA | 67,56,202 | --primary-hover | Hover botones primarios |
| **PRIMARY SOFT** | #EEF2FF | 238,242,255 | --primary-soft | Fondos acento, focus rings |
| **GRADIENT END (sidebar)** | #818CF8 | 129,140,248 | -- | Extremo gradient logo sidebar |
| **GRADIENT END (login)** | #A855F7 | 168,85,247 | -- | Extremo gradient logo login |

| Rol | Hex | RGB | CSS Variable | Uso |
|-----|-----|-----|--------------|-----|
| **SUCCESS** | #10B981 | 16,185,129 | --success | Badges "Presente", donut |
| **SUCCESS SOFT** | #ECFDF5 | 236,253,245 | --success-soft | Fondo badges success |
| **SUCCESS DARK** | #065F46 | 6,95,70 | --success-dark | Texto badges success |

| Rol | Hex | RGB | CSS Variable | Uso |
|-----|-----|-----|--------------|-----|
| **WARNING** | #F59E0B | 245,158,11 | --warning | Badges "Tarde", donut |
| **WARNING SOFT** | #FFFBEB | 255,251,235 | --warning-soft | Fondo badges warning |
| **WARNING DARK** | #92400E | 146,64,14 | --warning-dark | Texto badges warning |

| Rol | Hex | RGB | CSS Variable | Uso |
|-----|-----|-----|--------------|-----|
| **DANGER** | #EF4444 | 239,68,68 | --danger | Badges "Ausente", btn egreso, donut |
| **DANGER SOFT** | #FEF2F2 | 254,242,242 | --danger-soft | Fondo badges danger, hover logout |
| **DANGER DARK** | #991B1B | 153,27,27 | --danger-dark | Texto badges danger |

| Rol | Hex | RGB | CSS Variable | Uso |
|-----|-----|-----|--------------|-----|
| **INFO** | #0EA5E9 | 14,165,233 | --info | Badges "Sin egreso", turno |
| **INFO SOFT** | #F0F9FF | 240,249,255 | --info-soft | Fondo badges info |

### 1.2 Paleta Slate

| Nombre | Hex | CSS Variable | Uso |
|--------|-----|--------------|-----|
| **Slate 50** | #F8FAFC | --slate-50 | Fondo pagina, cabeceras tabla |
| **Slate 100** | #F1F5F9 | --slate-100 | Bordes celda, skeleton |
| **Slate 200** | #E2E8F0 | --slate-200 | Bordes card, input, tabla |
| **Slate 300** | #CBD5E1 | --slate-300 | Texto secundario sidebar |
| **Slate 400** | #94A3B8 | --slate-400 | Labels login, placeholder |
| **Slate 500** | #64748B | --slate-500 | Breadcrumb, subtitulos |
| **Slate 600** | #475569 | --slate-600 | Texto logout header |
| **Slate 700** | #334155 | --slate-700 | Texto celdas, labels form |
| **Slate 800** | #1E293B | --slate-800 | Borde sidebar, color body |
| **Slate 900** | #0F172A | --slate-900 | Fondo sidebar, fondo login |

### 1.3 Login Colors

| Elemento | Valor |
|----------|-------|
| Fondo | #0F172A |
| Input bg | gba(30,41,59,0.5) |
| Input focus bg | gba(30,41,59,0.8) |
| Input border | gba(255,255,255,0.1) |
| Input text | #FFFFFF |
| Label | #94A3B8 |
| Gradient imagen | linear-gradient(rgba(79,70,229,0.2), rgba(15,23,42,0.8)) |
| Error bg | gba(239,68,68,0.1) |
| Error border | gba(239,68,68,0.2) |
| Error text | #F87171 |
| Info alert bg | gba(99,102,241,0.1) |
| Info alert border | gba(99,102,241,0.2) |
| Info alert text | #A5B4FC |

### 1.4 Employee Dashboard Gradients

| Estado | Gradient |
|--------|----------|
| Sin ingreso | linear-gradient(135deg, #0F172A, #1E1B4B) |
| Con ingreso | linear-gradient(135deg, #065F46, #047857) |
| Jornada completa | linear-gradient(135deg, #065F46, #0D9488) |

### 1.5 Attendance Badge Colors

| Estado | Background | Texto |
|--------|------------|-------|
| Presente | #ECFDF5 | #065F46 |
| Tarde | #FFFBEB | #92400E |
| Ausente | #FEF2F2 | #991B1B |
| Tarde justif. | #ECFDF5 | #065F46 |
| Salida ant. | #FFFBEB | #92400E |
| Sin egreso | #F0F9FF | #0EA5E9 |

### 1.6 Turno Indicator Colors

| Turno | Color |
|-------|-------|
| Mañana | #10B981 (success) |
| Tarde | #F59E0B (warning) |
| Noche | #4F46E5 (primary) |
| Otro | #64748B (slate-500) |

### 1.7 Role Badge Colors

| Rol | Background | Texto |
|-----|------------|-------|
| Administrador | #FEF2F2 | #991B1B |
| Supervisor | #FFFBEB | #92400E |
| Empleado | #F0F9FF | #0EA5E9 |

---

## 2. Tipografias

### 2.1 Familia

- **Primaria:** Inter (Google Fonts)
- **Fallback:** -apple-system, sans-serif
- **URL:** https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap

### 2.2 Pesos

| Peso | Valor | Uso |
|------|-------|-----|
| Regular | 400 | Parrafos, texto general |
| Medium | 500 | Labels sidebar, form |
| SemiBold | 600 | Card titles, botones, badges |
| Bold | 700 | Page titles, KPI values |
| ExtraBold | 800 | Logo, login title |

### 2.3 Jerarquia

| Contexto | Size | Weight | Color | Letter-spacing |
|----------|------|--------|-------|----------------|
| Logo brand | 18px | 700 | white | -0.025em |
| Logo login | 24px | 800 | white | -0.02em |
| Login title | 32px | 800 | white | -0.025em |
| Login subtitle | 16px | 400 | #64748B | -- |
| Hero h2 | 42px | 800 | white | -- |
| Hero p | 18px | 400 | rgba255,0.8 | -- |
| Page title | 24px | 700 | #0F172A | -0.02em |
| Page subtitle | 14px | 400 | #64748B | -- |
| Section title sidebar | 11px | 600 | #CBD5E1 | 0.05em uppercase |
| Sidebar link | 14px | 500 | #CBD5E1 | -- |
| User name sidebar | 13px | 600 | white | -- |
| User role sidebar | 11px | 400 | #CBD5E1 | -- |
| Breadcrumb | 14px | -- | #64748B | -- |
| Card title | 16px | 600 | #0F172A | -- |
| Stat value | 30px | 700 | #0F172A | -- |
| Stat label | 14px | 500 | #64748B | -- |
| Table header | 12px | 600 | #64748B | 0.05em uppercase |
| Table cell | 14px | 400 | #334155 | -- |
| Form label | 14px | 600 | #334155 | -- |
| Form input | 14px | 400 | slate-800 | -- |
| Button | 14px | 600 | -- | -- |
| Badge | 12px | 600 | segun estado | -- |

---

## 3. Layout General

### 3.1 Login (split-screen, dark)

`
┌─────────────────────────────────────────────┐
│ ┌──────────────────┬──────────────────────┐ │
│ │ IMAGE (flex:1.2) │ FORM (flex:1)         │ │
│ │ Desktop >=992px  │ bg: #0F172A           │ │
│ │ padding: 80px    │ padding: 40px         │ │
│ │ max-w: 600px     │ centered vertical     │ │
│ │ Gradient overlay │                       │ │
│ │ indigo->slate    │ Card max-w: 440px     │ │
│ └──────────────────┴──────────────────────┘ │
└─────────────────────────────────────────────┘
`

### 3.2 Dashboard (logged in)

`
┌──────────────────────────────────────────────┐
│ ┌──────────┬───────────────────────────────┐ │
│ │ SIDEBAR  │ HEADER (sticky, h:64px)       │ │
│ │ w:260px  │ bg: white, border-b: slate200 │ │
│ │ fixed    │ padding: 0 32px               │ │
│ │ z:1000   │ breadcrumb | bell + logout    │ │
│ │          ├───────────────────────────────┤ │
│ │ slate900 │ PAGE CONTENT (padding: 32px)   │ │
│ │          │ ┌────┬────┬────┬────┐         │ │
│ │ sections │ │KPI │KPI │KPI │KPI │         │ │
│ │          │ └────┴────┴────┴────┘         │ │
│ │ footer   │ ┌─────────┬─────────┐         │ │
│ │ user     │ │donut 6c │bar sem6c│         │ │
│ │          │ ├─────────┼─────────┤         │ │
│ │          │ │bar mens6│tabla 6c │         │ │
│ │          │ └─────────┴─────────┘         │ │
│ │          │ ┌───────────────────────┐     │ │
│ │          │ │ Alertas (opcional)     │     │ │
│ │          │ └───────────────────────┘     │ │
│ └──────────┴───────────────────────────────┘ │
└──────────────────────────────────────────────┘
`

### 3.3 Employee Dashboard

`
┌────────────────────────────────────┐
│ ┌────────────────────────────────┐ │
│ │ CARD PRINCIPAL (col-md-10)     │ │
│ │ center, border:0, shadow-lg    │ │
│ │ bg: gradient segun estado      │ │
│ │ padding: p-5, text-center      │ │
│ │ "Control de Jornada" (label)   │ │
│ │ "lunes, 01 de enero" (h2)      │ │
│ │ Btn grande: px-5 py-3 fs-18    │ │
│ └────────────────────────────────┘ │
│                                    │
│ ┌────────────────┬────────────────┐ │
│ │ HISTORIAL 7col │ JUSTIFIC. 5col │ │
│ │ ultimos 15     │ ultimas 10     │ │
│ └────────────────┴────────────────┘ │
└────────────────────────────────────┘
`

### 3.4 Card Distribution

- **Admin Dashboard:** ow g-4, 2x2 grid col-lg-6 con h-100
- **KPIs:** ow g-3, col-md-3 col-6
- **Turnos:** ow g-4, col-md-4 (3 columns)
- **Forms:** card-saas max-w-800 mx-auto

---

## 4. Sidebar

### 4.1 Dimensions

| Propiedad | Valor |
|-----------|-------|
| Width | 260px |
| Position | fixed, top:0, left:0 |
| Height | 100vh |
| Z-index | 1000 |
| Border-right | 1px solid #1E293B |
| Transition | transform 0.3s ease |

### 4.2 Colors

| Elemento | Valor |
|----------|-------|
| Background | #0F172A |
| Brand gradient | linear-gradient(135deg, #4F46E5, #818CF8) |
| Brand icon | 32x32, radius 8px |
| Brand text | 18px, 700, white |
| Brand span | #4F46E5 |
| Section title | 11px, 600, uppercase, #CBD5E1, letter-spacing 0.05em |
| Link default | 14px, 500, #CBD5E1 |
| Link hover | bg #1E293B, text white |
| Link active | bg #4F46E5, text white |
| Link radius | 8px |
| Link padding | 10px 12px |
| Link margin-bottom | 2px |
| Link icon | 18px, stroke-width 2 |
| Footer | border-top 1px solid #1E293B, bg gba(255,255,255,0.03) |
| Avatar | 36px, bg #334155, border 2px #1E293B |
| User name | 13px, 600, white |
| User role | 11px, 400, #CBD5E1 |

### 4.3 Behavior

| Estado | Accion |
|--------|--------|
| Desktop >991px | Always visible, translateX(0) |
| Tablet <=991px | Hidden (translateX(-100%)), toggle con .active |
| Overlay | gba(15,23,42,0.5), ackdrop-filter: blur(4px) |
| Toggle button | hidden on desktop, visible on mobile |

### 4.4 Menus

**Admin:**
- PRINCIPAL: Dashboard
- GESTION: Usuarios, Turnos(admin), Asistencias, Vacaciones
- ANALISIS: Reportes
- SISTEMA: Notificaciones, Configuracion

**Employee:**
- MI PORTAL: Mi Asistencia, Justificaciones
- SISTEMA: Notificaciones

---

## 5. Dashboard Administrativo

### 5.1 KPIs

ow g-3 with col-md-3 col-6. Each: stat-card-modern
- bg white, radius 16px, padding 24px, border 1px slate-200
- Hover: shadow-md + border slate-300
- Label: 14px, 500, #64748B
- Value: 30px, 700, #0F172A

### 5.2 Charts (Chart.js)

| Grafico | Tipo | Tamaño | Colores |
|---------|------|--------|---------|
| Resumen dia | Doughnut | max-w 200px, cutout 78% | #10B981, #F59E0B, #EF4444 |
| Tendencia semanal | Bar grouped | h:260px, borderRadius 4, barPct 0.7 | mismos |
| Promedio mensual | Bar grouped | h:260px | mismos |

Chart defaults: font Inter, color #94A3B8. Legend bottom, boxWidth 12, padding 14, font 11px.

### 5.3 Spacing

| Contexto | Valor |
|----------|-------|
| Page padding | 32px desktop, 24px tablet, 16px mobile |
| Page header mb | 32px |
| Card mb | 24px |
| Card body | 24px |
| Grid gap | g-4 (24px) cards, g-3 (16px) KPIs |

### 5.4 Borders

| Element | Border |
|---------|--------|
| Card | 1px solid #E2E8F0 |
| Input | 1px solid #E2E8F0 |
| Input focus | #4F46E5 + shadow   0 0 4px #EEF2FF |
| Sidebar | 1px solid #1E293B |

### 5.5 Shadows

| Level | Value |
|-------|-------|
| sm (cards) |   1px 2px 0 rgb(0 0 0 / 0.05) |
| md |   4px 6px -1px rgb(0 0 0 / 0.1) |
| Button primary hover |   4px 12px rgba(79,70,229,0.3) |
| Button login |   10px 15px -3px rgba(79,70,229,0.3) |

---

## 6. Formularios

### 6.1 Default (internal forms)

| Propiedad | Valor |
|-----------|-------|
| Input | padding 10px 14px, radius 8px, border slate-200 |
| Input focus | border primary, shadow 0 0 0 4px primary-soft |
| Label | 14px, 600, #334155, mb 6px |
| Transition | all 0.2s cubic-bezier(0.4,0,0.2,1) |

### 6.2 Login (dark)

| Propiedad | Valor |
|-----------|-------|
| Input bg | gba(30,41,59,0.5) |
| Input focus bg | gba(30,41,59,0.8) |
| Input border | gba(255,255,255,0.1) |
| Input radius | 12px |
| Input padding | 14px 20px |
| Input text | white, 15px |
| Button | bg #4F46E5, radius 12px, padding 16px, 16px 700 |

### 6.3 Buttons

| Variant | BG | Border | Color | Hover |
|---------|----|--------|-------|-------|
| Primary | #4F46E5 | none | white | #4338CA + shadow |
| Outline | white | 1px #E2E8F0 | #334155 | #F8FAFC |

Common: radius 8px, 14px 600, gap 8px, min-h 44px, min-w 44px.

Special:
- **Marcar Ingreso:** px-5 py-3 fs-18 (large)
- **Marcar Egreso:** bg #EF4444, shadow gba(239,68,68,0.3)
- **Export Excel:** order-color rgba(16,185,129,0.2), g rgba(16,185,129,0.05)
- **Export PDF:** order-color rgba(239,68,68,0.2), g rgba(239,68,68,0.05)

---

## 7. Tablas

### 7.1 Desktop

| Part | Propiedades |
|------|-------------|
| Class | 	able-saas, width 100%, border-collapse separate |
| thead th | bg #F8FAFC, padding 12px 16px, 12px 600 uppercase, color #64748B, letter-spacing 0.05em, border-bottom slate-200 |
| tbody td | padding 16px, 14px, color #334155, border-bottom #F1F5F9 |
| tr:hover | bg #F8FAFC |

### 7.2 Mobile (<=767px)

	able-saas-responsive: thead hidden, tr becomes card (padding 14px, mb 12px, border 1px slate-200, radius 12px). td becomes flex row with data-label before.

### 7.3 Filters

In card-saas before table: ow g-2 align-items-end. Date input width 160px. DNI input width 140px. Turno filter: pills with tn-primary-saas / tn-outline-saas.

### 7.4 Search

Icono lupa left, ps-5, placeholder "Buscar por nombre, DNI, legajo...". Client-side JS filtering.

---

## 8. Componentes Reutilizables

### 8.1 Cards

| Variante | Border-radius | Border | Padding | Shadow |
|----------|---------------|--------|---------|--------|
| card-saas | 12px | 1px slate-200 | body 24px, header 16px 24px | sm |
| stat-card-modern | 16px | 1px slate-200 | 24px | sm, hover md |
| card-header-image | 12px 12px 0 0 | -- | h:180px, gradient overlay | -- |

### 8.2 Badges

Base: inline-flex, padding 4px 10px, radius 6px, 12px 600.
- success: bg #ECFDF5, text #065F46
- warning: bg #FFFBEB, text #92400E
- danger: bg #FEF2F2, text #991B1B
- info: bg #F0F9FF, text #0EA5E9

### 8.3 Alerts

3 types:
- Flash: Bootstrap alert, border-0 shadow-sm rounded-4
- Inline dashboard: warning-soft/danger-soft bg, 1px solid border, p-3 rounded-3
- Employee: lert-saas bg-warning-soft p-4 rounded-4 with emoji

### 8.4 Empty States

SVG icon 64px #CBD5E1, h4 700 #334155, p #64748B.

### 8.5 Skeleton

`css
.skeleton-pulse {
  background: linear-gradient(90deg, #E2E8F0 25%, #F1F5F9 50%, #E2E8F0 75%);
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s ease-in-out infinite;
}
`
Donut: 180x180 circle. Bar: 100% x 240px. Legend: 80x14px.

---

## 9. Responsive Design

### 9.1 Breakpoints

| Name | Max-width | Changes |
|------|-----------|---------|
| Desktop | >991px | Sidebar visible, split login |
| Tablet | 991px | Sidebar hidden + overlay, padding reduced |
| Mobile | 767px | Table cards, stack filters, header 56px |
| Tiny | 480px | Logout icon-only, padding minimal |

### 9.2 Key Changes Per Breakpoint

**Tablet (<=991px):**
- Sidebar: translateX(-100%), toggle visible
- Main: margin-left 0
- Header padding: 0 16px
- Page padding: 24px 16px
- Title: 20px, stat: 24px

**Mobile (<=767px):**
- Page padding: 16px 12px
- Title: 18px
- Header h: 56px
- Tables card-view (data-label)
- Filters stack (100% width)
- Input font: 16px (prevent iOS zoom)
- Card footer buttons: column, full width
- Stat card: 18px padding

**Tiny (<=480px):**
- Page padding: 12px 10px
- Sidebar link: 8px 10px, 13px
- Logout text hidden (icon only)

---

## 10. Guia de Diseno para Flutter Material 3

### 10.1 ColorScheme

`dart
ColorScheme(
  brightness: Brightness.light,
  primary: const Color(0xFF4F46E5),
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFEEF2FF),
  onPrimaryContainer: const Color(0xFF4338CA),
  secondary: const Color(0xFF0EA5E9),
  onSecondary: Colors.white,
  error: const Color(0xFFEF4444),
  onError: Colors.white,
  errorContainer: const Color(0xFFFEF2F2),
  onErrorContainer: const Color(0xFF991B1B),
  surface: Colors.white,
  onSurface: const Color(0xFF0F172A),
  surfaceVariant: const Color(0xFFF8FAFC),
  onSurfaceVariant: const Color(0xFF64748B),
  outline: const Color(0xFFE2E8F0),
  outlineVariant: const Color(0xFFF1F5F9),
)
`

### 10.2 Component Mapping

| Original | Flutter Widget | Key Props |
|----------|---------------|-----------|
| card-saas | Card | shape: RoundedRect(borderRadius:12, side:slate-200), elevation:0, mb:24 |
| stat-card-modern | Card | shape: RoundedRect(borderRadius:16), elevation:0, hover: shadow |
| btn-primary-saas | FilledButton | styleFrom(bg:primary, fg:white, padding:18x10, minSize:44, radius:8) |
| btn-outline-saas | OutlinedButton | styleFrom(fg:slate-700, side:slate-200) |
| form-input-saas | TextField | InputDecoration(border:OutlineInput(radius:8, side:slate-200), filled:white) |
| badge-saas | Container | padding:10x4, decoration:BoxColor(radius:6), Text(12px,600) |
| sidebar | NavigationDrawer | bg:slate-900, width:260 |
| sidebar-link | NavigationDrawerDestination | selectedBg:primary |
| avatar | CircleAvatar | bg:slate-700, radius:18 |

### 10.3 Spacing Constants

`dart
class AppSpacing {
  static const pagePadding = 32.0;
  static const pagePaddingTablet = 16.0;
  static const pagePaddingMobile = 12.0;
  static const cardPadding = 24.0;
  static const cardHeaderPadding = 16.0;
  static const cardGap = 24.0;       // g-4
  static const kpiGap = 16.0;        // g-3
  static const formFieldGap = 16.0;  // mb-3
  static const buttonMinSize = 44.0;
  static const borderRadius = 12.0;
  static const inputRadius = 8.0;
  static const sidebarWidth = 260.0;
  static const headerHeight = 64.0;
  static const headerHeightMobile = 56.0;
}
`

### 10.4 Login Layout

`dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 992) {
      return Row(children: [
        Expanded(flex: 6, child: ImageSection()),
        Expanded(flex: 5, child: FormSection()),
      ]);
    }
    return FormSection(); // mobile only form
  },
);
`

### 10.5 Dashboard Layout

`dart
Scaffold(
  drawer: NavigationDrawer(...), // 260px
  appBar: AppBar(
    leading: MenuButton(), // mobile toggle
    title: Breadcrumb(),
    actions: [NotificationBell(), LogoutButton()],
  ),
  body: Padding(
    padding: EdgeInsets.all(AppSpacing.pagePadding),
    child: ... // content
  ),
);
`

### 10.6 Responsive Table

`dart
if (width > 767) {
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(...),
  );
} else {
  ListView.builder(
    itemBuilder: (_, i) => Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(children: [
          _row('Label', item.value),
          _row('Otro', item.other),
        ]),
      ),
    ),
  );
}
`

### 10.7 Animations

| Original | Flutter |
|----------|---------|
| transition 0.2s | curve Curves.fastOutSlowIn, duration 200ms |
| skeleton 1.5s | Shimmer package |
| login fadeInUp 0.6s | FadeTransition + SlideTransition |
| sidebar 0.3s | AnimationController + SlideTransition |
| reduced-motion | MediaQuery.disableAnimations |

### 10.8 Charts (fl_chart)

`dart
// Donut - PieChart
PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(color: successGreen, value: presentes),
      PieChartSectionData(color: warningAmber, value: tardanzas),
      PieChartSectionData(color: dangerRed, value: ausentes),
    ],
    centerSpaceRadius: 70, // cutout 78%
    sectionsSpace: 0,
  ),
);

// Bar - BarChart
BarChart(
  BarChartData(
    barGroups: [
      BarChartGroupData(x: i, barRods: [
        BarChartRodData(to: value, color: color, width: 12, borderRadius: 4),
      ]),
    ],
  ),
);
`

### 10.9 Responsive Font Sizes

`dart
double rfs(BuildContext context, double desktop, {double? tablet, double? mobile}) {
  final w = MediaQuery.of(context).size.width;
  if (w <= 480) return mobile ?? desktop * 0.85;
  if (w <= 767) return tablet ?? desktop * 0.9;
  return desktop;
}
`

---

*Fin del documento de auditoria visual.*

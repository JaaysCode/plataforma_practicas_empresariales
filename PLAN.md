# Plan: Plataforma de Prácticas Empresariales — Equipo 4

## Context
App móvil Flutter para gestionar ofertas de práctica, postulaciones de estudiantes y seguimiento del proceso de selección.  
Stack: Firebase Auth + Firestore + Drift (local) + Provider + offline-first sync.

---

## Tech Stack & Dependencies

```yaml
dependencies:
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  drift: ^2.x
  drift_flutter: ^0.x
  provider: ^6.x
  connectivity_plus: ^6.x
  uuid: ^4.x
  intl: ^0.x
  logger: ^2.x
  path_provider: ^2.x

dev_dependencies:
  drift_dev: ^2.x
  build_runner: ^2.x
  mockito: ^5.x
```

---

## Estructura del proyecto

```
lib/
├── main.dart                        # Firebase init, MultiProvider
├── firebase_options.dart            # Generado por FlutterFire CLI
├── data/
│   ├── app_database.dart            # @DriftDatabase
│   └── app_database.g.dart          # Generado por build_runner
├── models/
│   ├── user_profile.dart            # uid, name, email, UserRole, AccountStatus
│   ├── empresa.dart
│   ├── oferta.dart                  # OfertaEstado enum
│   ├── postulacion.dart             # PostulacionEstado enum
│   ├── seguimiento.dart
│   └── documento.dart
├── services/
│   ├── auth_service.dart            # Wrapper Firebase Auth
│   ├── permission_service.dart      # Guards por rol y estado de cuenta
│   ├── oferta_remote_service.dart   # CRUD Firestore para ofertas
│   ├── postulacion_remote_service.dart
│   ├── user_remote_service.dart     # Leer/escribir users/{uid}
│   └── sync_service.dart            # Reintento de pendingSync
├── providers/
│   ├── auth_provider.dart           # Estado UserProfile, login/logout
│   ├── oferta_provider.dart         # Lista de ofertas + CRUD
│   └── postulacion_provider.dart    # Lista de postulaciones + CRUD
├── validators/
│   ├── form_validators.dart         # Validaciones de campos
│   └── business_rules.dart         # Reglas de negocio (funciones puras, testeables)
├── pages/
│   ├── splash_page.dart             # Verifica auth → rutea
│   ├── login_page.dart
│   ├── pending_approval_page.dart
│   ├── blocked_page.dart
│   ├── student/
│   │   ├── student_home_page.dart
│   │   ├── ofertas_list_page.dart
│   │   ├── oferta_detail_page.dart
│   │   └── mis_postulaciones_page.dart
│   ├── empresa/
│   │   ├── empresa_home_page.dart
│   │   ├── mis_ofertas_page.dart
│   │   ├── create_edit_oferta_page.dart
│   │   └── candidatos_page.dart
│   └── coordinador/
│       ├── coordinador_home_page.dart
│       ├── postulaciones_review_page.dart
│       └── gestionar_usuarios_page.dart
└── widgets/
    ├── sync_badge.dart              # Indicador visual pendingSync
    ├── estado_badge.dart            # Chip de color según estado
    ├── empty_state_widget.dart
    ├── error_state_widget.dart
    └── loading_state_widget.dart

test/
├── unit/
│   ├── permission_service_test.dart
│   └── business_rules_test.dart
└── widget/
    ├── empty_state_widget_test.dart
    ├── blocked_page_test.dart
    ├── pending_page_test.dart
    └── sync_badge_test.dart

docs/
├── pruebas.md
├── rc_candidate.md
├── release_checklist.md
└── bugs-backlog.md
```

---

## Modelos de datos

### Enums
```dart
enum UserRole { estudiante, empresa, coordinador }
enum AccountStatus { pendingApproval, active, blocked }
enum OfertaEstado { borrador, publicada, cerrada }
enum PostulacionEstado { postulado, preseleccionado, aprobado, rechazado }
enum SyncStatus { synced, pendingSync, failedSync }
```

### Modelos principales
Todos deben incluir: `copyWith()`, `toJson()`, `fromJson()`, `toFirestore()`, `fromFirestore()`.

| Modelo | Campos clave |
|--------|-------------|
| UserProfile | uid, name, email, role, status, createdAt, lastLoginAt |
| Empresa | id, nombre, sector, descripcion, contactoEmail, ownerUid, syncStatus |
| Oferta | id, titulo, descripcion, empresaId, requisitos, vacantes, estado, fechaPublicacion, fechaCierre, syncStatus |
| Postulacion | id, ofertaId, estudianteId, estado, motivoRechazo?, fechaPostulacion, syncStatus |
| Seguimiento | id, postulacionId, descripcion, fecha, creadoPor, syncStatus |
| Documento | id, postulacionId, tipo, nombre, url, syncStatus |

---

## Esquema Firestore

```
users/{uid}
  uid, name, email, role, status, createdAt, lastLoginAt

empresas/{empresaId}
  nombre, sector, descripcion, contactoEmail, ownerUid

ofertas/{ofertaId}
  titulo, descripcion, empresaId, requisitos, vacantes,
  estado, fechaPublicacion, fechaCierre, syncStatus

postulaciones/{postulacionId}
  ofertaId, estudianteId, estado, motivoRechazo,
  fechaPostulacion, syncStatus

postulaciones/{postulacionId}/seguimientos/{id}
  descripcion, fecha, creadoPor

postulaciones/{postulacionId}/documentos/{id}
  tipo, nombre, url
```

---

## Tablas Drift (local)

Tablas: `OfertasTable`, `PostulacionesTable`, `SeguimientosTable`, `DocumentosTable`  
Cada tabla incluye columna `syncStatus` (synced / pendingSync / failedSync).  
Usar `TypeConverter` para enums (OfertaEstado, PostulacionEstado).

---

## Flujo de autenticación y ruteo

```
SplashPage
  └─ FirebaseAuth.authStateChanges()
       ├─ null → LoginPage
       └─ user → fetch users/{uid} de Firestore
                  ├─ status=pendingApproval → PendingApprovalPage
                  ├─ status=blocked        → BlockedPage
                  └─ status=active
                       ├─ role=estudiante   → StudentHomePage
                       ├─ role=empresa      → EmpresaHomePage
                       └─ role=coordinador  → CoordinadorHomePage
```

LoginPage: email + contraseña → Firebase Auth → actualiza `lastLoginAt` en Firestore.

---

## Roles y permisos

### PermissionService (`lib/services/permission_service.dart`)

```dart
class PermissionService {
  bool canAccessMainModule(UserProfile u) => u.status == AccountStatus.active;

  bool canCreatePostulacion(UserProfile u) =>
      u.status == AccountStatus.active && u.role == UserRole.estudiante;

  bool canApprovePostulacion(UserProfile u) =>
      u.status == AccountStatus.active && u.role == UserRole.coordinador;

  bool canPreseleccionarCandidato(UserProfile u) =>
      u.status == AccountStatus.active && u.role == UserRole.empresa;

  bool canPublishOferta(UserProfile u) =>
      u.status == AccountStatus.active && u.role == UserRole.empresa;

  bool canManageUsers(UserProfile u) =>
      u.status == AccountStatus.active && u.role == UserRole.coordinador;
}
```

---

## Reglas de negocio (mínimo 6)

En `lib/validators/business_rules.dart` — funciones puras, sin dependencias de UI.

1. **Sin doble postulación**: estudiante no puede postularse si ya existe una postulacion con mismo ofertaId+estudianteId.
2. **Oferta cerrada**: `oferta.estado` debe ser `publicada` para aceptar postulacion.
3. **Rechazo requiere motivo**: `motivoRechazo` no puede ser null/vacío al rechazar.
4. **Coordinador aprueba**: solo coordinador puede cambiar estado a `aprobado`/`rechazado`.
5. **Empresa preselecciona**: solo empresa (dueña de la oferta) puede marcar `preseleccionado`.
6. **Transiciones terminales**: `aprobado` y `rechazado` no tienen transiciones de salida.

---

## Máquina de estados (Postulacion)

```
postulado ──(empresa)──────→ preseleccionado ──(coordinador)──→ aprobado
    │                                │
    └──(coordinador + motivo)──→ rechazado ←──(coordinador + motivo)──┘

TERMINALES: aprobado, rechazado
```

---

## Offline-first y sincronización

Patrón de `money_app`:

1. Crear/actualizar → guardar en Drift con `syncStatus=pendingSync`
2. Intentar escritura en Firestore
3. Éxito → `syncStatus=synced`
4. Fallo → dejar como `pendingSync`
5. `SyncService` escucha `connectivity_plus`, reintenta todos los `pendingSync` al reconectar
6. `SyncBadge` widget muestra indicador visual cuando un registro está `pendingSync`

---

## Usuarios de prueba

| Email | Contraseña | Rol | Estado | Qué valida |
|-------|-----------|-----|--------|------------|
| estudiante@test.com | 123456 | estudiante | active | Flujo de postulación |
| empresa@test.com | 123456 | empresa | active | Crear oferta + preselección |
| coordinador@test.com | 123456 | coordinador | active | Aprobar/rechazar |
| bloqueado@test.com | 123456 | estudiante | blocked | Pantalla de acceso bloqueado |

---

## Plan de pruebas

### Unit tests (mínimo 6) — `test/unit/`

| # | Test | Archivo |
|---|------|---------|
| 1 | active+estudiante → canCreatePostulacion=true | permission_service_test.dart |
| 2 | pendingApproval → canCreatePostulacion=false | permission_service_test.dart |
| 3 | blocked → canAccessMainModule=false | permission_service_test.dart |
| 4 | coordinador → canApprovePostulacion=true | permission_service_test.dart |
| 5 | estudiante → canApprovePostulacion=false | permission_service_test.dart |
| 6 | rechazar sin motivo → false | business_rules_test.dart |
| 7 | oferta cerrada → canApply=false | business_rules_test.dart |
| 8 | postulación duplicada → canApply=false | business_rules_test.dart |

### Widget tests (mínimo 4) — `test/widget/`

| # | Widget | Qué valida |
|---|--------|-----------|
| 1 | EmptyStateWidget | muestra mensaje cuando no hay datos |
| 2 | BlockedPage | renderiza contenido de acceso bloqueado |
| 3 | PendingApprovalPage | renderiza pantalla de espera |
| 4 | SyncBadge | muestra indicador cuando syncStatus=pendingSync |

---

## Orden de implementación

1. Configurar Firebase: `flutterfire configure`
2. Agregar dependencias en `pubspec.yaml` → `flutter pub get`
3. Modelos (6 modelos + enums)
4. Drift DB (tablas + `dart run build_runner build`)
5. AuthService + UserRemoteService
6. PermissionService + BusinessRules
7. Providers: AuthProvider, OfertaProvider, PostulacionProvider
8. Servicios remotos: OfertaRemoteService, PostulacionRemoteService
9. SyncService
10. Widgets reutilizables: EmptyState, ErrorState, LoadingState, SyncBadge, EstadoBadge
11. Pages: Splash, Login, PendingApproval, Blocked
12. Pages: flujo Estudiante (lista → detalle → postular → mis postulaciones)
13. Pages: flujo Empresa (mis ofertas → crear/editar → candidatos)
14. Pages: flujo Coordinador (revisar postulaciones → gestionar usuarios)
15. Unit tests (8 casos)
16. Widget tests (4 casos)
17. `firestore.rules`
18. Docs: pruebas.md, rc_candidate.md, release_checklist.md, bugs-backlog.md
19. README.md completo
20. `flutter build apk`

---

## Verificación final

- `flutter test` → todos los tests pasan
- Login con cada usuario de prueba → ruteo correcto
- Empresa: crear oferta borrador → publicar → ver candidatos
- Estudiante: navegar ofertas → postularse → ver postulación creada
- Coordinador: revisar → aprobar / rechazar con motivo
- Desactivar internet → crear postulación → ver badge pendingSync → reconectar → sincronización automática
- `flutter build apk` → `build/app/outputs/flutter-apk/app-release.apk`

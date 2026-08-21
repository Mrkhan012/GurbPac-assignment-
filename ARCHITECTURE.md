# TaskFlow — Architecture & Technical Design Document

## 1. Architectural Philosophy

TaskFlow follows **Clean / Layered Architecture** with strict boundary separation and Dependency Inversion.

```
                    ┌─────────────────────────┐
                    │    Presentation Layer   │
                    │ (Cubits, States, UI)    │
                    └────────────┬────────────┘
                                 │ depends on
                                 ▼
                    ┌─────────────────────────┐
                    │      Domain Layer       │
                    │  (Entities, UseCases,   │
                    │  Repository Interfaces) │
                    └────────────▲────────────┘
                                 │ implements
                    ┌────────────┴────────────┐
                    │       Data Layer        │
                    │ (DataSources, Models,   │
                    │   Repo Implementations) │
                    └─────────────────────────┘
```

### Layer Breakdown

1. **Domain Layer**:
   - Contains pure Dart code with **zero dependencies** on Flutter UI or third-party storage/network frameworks.
   - Declares pure entities (`User`, `Project`, `TaskItem`, `TaskComment`, `AppNotification`, `AuthToken`).
   - Declares abstract contracts for repositories (`AuthRepository`, `ProjectRepository`, `TaskRepository`, `UserRepository`, `NotificationRepository`).
   - Encapsulates business logic rules in UseCases:
     - **RBAC**: Checks user role (`org_admin` vs `member`) before allowing destructive operations like project deletion.
     - **Org Scoping**: Validates that assigned users belong to the same organization before allowing task assignment.

2. **Data Layer**:
   - Implements domain repository interfaces (`AuthRepositoryImpl`, `ProjectRepositoryImpl`, etc.).
   - Converts raw JSON payloads to typed `Model` objects which extend domain `Entities`.
   - `MockDataSource`: Centrally parses `TaskFlow-MockData.json`, maintains in-memory mutable collections, and simulates real backend network calls.
   - Integrates `StorageService` for caching and secure token persistence.
   - Swapping to a real REST API would simply require implementing a `RemoteDataSourceImpl` using `http`/`dio` without changing any Domain or Presentation code.

3. **Presentation Layer**:
   - Uses **BLoC / Cubit** (`flutter_bloc`) for reactive state management.
   - Every feature follows standard state hierarchy: `Initial` → `Loading` → `Success` → `Empty` → `Error`.
   - Screens are decoupled from business logic and delegate state transitions entirely to Cubits.
   - Atomic and reusable widgets (`ProjectCard`, `TaskCard`, `StatusBadge`, `PriorityBadge`, `UserAvatar`, `OfflineBanner`, `StateViews`).

4. **Core Layer**:
   - Common utilities, date formatters, validators, theme design system, failure hierarchy, service locator (`GetIt`), and simulation controls.

---

## 2. State Management Strategy

All states are immutable and extend `Equatable` for efficient widget rebuilds.

```
Cubits
├── AuthCubit           -> AuthInitial, AuthLoading, Authenticated, Unauthenticated, AuthError, SessionExpired
├── ProjectListCubit    -> ProjectListInitial, ProjectListLoading, ProjectListSuccess, ProjectListEmpty, ProjectListError
├── ProjectDetailCubit  -> ProjectDetailInitial, ProjectDetailLoading, ProjectDetailSuccess, ProjectDetailError
├── TaskListCubit       -> TaskListInitial, TaskListLoading, TaskListSuccess, TaskListEmpty, TaskListError
├── TaskDetailCubit     -> TaskDetailInitial, TaskDetailLoading, TaskDetailSuccess, TaskDetailError
├── NotificationCubit   -> NotificationInitial, NotificationLoading, NotificationSuccess, NotificationEmpty, NotificationError
├── ThemeCubit          -> ThemeState (Light / Dark mode)
└── DebugSimulationCubit-> DebugSimulationState (Offline toggle, Delay ms, Simulated Error Type)
```

---

## 3. Data & Storage Flow

```
UI Action ──► Cubit ──► UseCase (RBAC & Org Validation)
                            │
                            ▼
                    Repository Implementation
                       │                 │
             (Online)  ▼                 ▼ (Offline / Error)
                 MockDataSource        StorageService (Cache)
                       │
                       ▼
                 Network Simulator (Delay / Error Injection)
```

- **Authentication Storage**: `FlutterSecureStorage` securely saves `access_token` and `refresh_token`.
- **Offline Caching**: `StorageService` automatically caches the latest loaded projects and tasks per organization, providing uninterrupted viewing when offline.

---

## 4. Security & RBAC Enforcement

1. **Security**:
   - Passwords are never stored in persistent memory.
   - Tokens are stored using platform-encrypted secure storage (`Keychain` on iOS, `KeyStore` / `EncryptedSharedPreferences` on Android).
   - Mock token expiry is handled with simulated refresh requests.
2. **Role-Based Authorization**:
   - `org_admin`: Full CRUD access on projects, tasks, and task assignments.
   - `member`: Read/Write access on tasks and comments; prohibited from deleting projects.
   - Domain layer strictly enforces `PermissionFailure` if a non-admin triggers unauthorized actions.

# Life Companion App – Plan de Implementación

Una app móvil Flutter holística que unifica gestión de tareas, hábitos, finanzas personales y gamificación en una sola interfaz con Clean Architecture.

## Stack Final

| Herramienta        | Rol                                |
| ------------------ | ---------------------------------- |
| Flutter            | Framework UI                       |
| sqflite            | Base de datos SQLite local         |
| flutter_bloc       | Gestor de estado (BLoC)            |
| get_it             | Inyección de dependencias          |
| go_router          | Navegación declarativa             |
| dartz              | Tipos funcionales (Either, Option) |
| equatable          | Comparación de objetos             |
| intl               | Formateo de fechas/moneda          |
| fl_chart           | Gráficas (finanzas, hábitos)       |
| confetti           | Animaciones de celebración         |
| shared_preferences | Configuraciones rápidas            |

---

## Propuesta de Cambios

### Scaffolding del Proyecto

#### [NEW] Proyecto Flutter en `scratch/life_companion/`

- `pubspec.yaml` con todas las dependencias listadas arriba
- `lib/main.dart` como punto de entrada con inicialización de GetIt y GoRouter

---

### Core (Infraestructura Compartida)

#### [NEW] `lib/core/di/injection_container.dart`

Registro de todas las dependencias: DataSources → Repos → UseCases → BLoCs.

#### [NEW] `lib/core/storage/database_helper.dart`

Singleton SQLite con todos los `CREATE TABLE` (Categories, Tasks, Events, Habits, HabitLogs, Notes, Alarms, ScreenTimeLogs, Suggestions, UserStats, Rewards, XpLogs, Accounts, FinanceCategories, Transactions, Budgets) + seed data inicial.

#### [NEW] `lib/core/router/app_router.dart`

GoRouter con rutas: `/`, `/tasks`, `/habits`, `/finances`, `/settings`, `/rewards`.

#### [NEW] `lib/core/theme/app_theme.dart`

Tema dark glassmorphism con paleta violeta/turquesa, tipografía Inter.

#### [NEW] `lib/core/constants/app_constants.dart`

Strings, colores y tamaños globales.

---

### Feature: Agenda & Tareas

#### [NEW] `lib/features/agenda/domain/entities/task_entity.dart`

#### [NEW] `lib/features/agenda/domain/repositories/i_task_repository.dart`

#### [NEW] `lib/features/agenda/domain/use_cases/` (get, create, update, delete, complete)

#### [NEW] `lib/features/agenda/data/models/task_model.dart`

#### [NEW] `lib/features/agenda/data/datasources/task_local_datasource.dart`

#### [NEW] `lib/features/agenda/data/repositories/task_repository_impl.dart`

#### [NEW] `lib/features/agenda/presentation/pages/tasks_page.dart`

#### [NEW] `lib/features/agenda/presentation/widgets/task_card.dart`

#### [NEW] `lib/features/agenda/presentation/state/task_bloc.dart`

---

### Feature: Hábitos

#### [NEW] `lib/features/habits/domain/entities/` (habit_entity, habit_log_entity)

#### [NEW] `lib/features/habits/domain/repositories/i_habit_repository.dart`

#### [NEW] `lib/features/habits/domain/use_cases/` (get, create, complete, get_logs)

#### [NEW] `lib/features/habits/data/` (models, datasource, repository_impl)

#### [NEW] `lib/features/habits/presentation/pages/habits_page.dart`

#### [NEW] `lib/features/habits/presentation/widgets/habit_card.dart`

#### [NEW] `lib/features/habits/presentation/state/habit_bloc.dart`

---

### Feature: Finanzas

#### [NEW] `lib/features/finances/domain/entities/` (account, transaction, budget)

#### [NEW] `lib/features/finances/domain/use_cases/` (get_transactions, add_transaction, get_budgets, check_budget_alert)

#### [NEW] `lib/features/finances/data/` (models, datasource, repository_impl)

#### [NEW] `lib/features/finances/presentation/pages/finances_page.dart` (con gráfica fl_chart)

#### [NEW] `lib/features/finances/presentation/state/finance_bloc.dart`

---

### Feature: Gamificación

#### [NEW] `lib/features/gamification/domain/entities/` (user_stats, reward, xp_log)

#### [NEW] `lib/features/gamification/domain/use_cases/` (get_stats, add_xp, redeem_reward)

#### [NEW] `lib/features/gamification/data/` (models, datasource, repository_impl)

#### [NEW] `lib/features/gamification/presentation/widgets/` (xp_bar, coin_display, reward_card)

#### [NEW] `lib/features/gamification/presentation/state/gamification_bloc.dart`

---

### Dashboard

#### [NEW] `lib/features/dashboard/presentation/pages/dashboard_page.dart`

Pantalla principal que cambia selon momento del día (greeting mañana/tarde/noche), muestra tareas del día, hábitos pendientes, balance y barra de XP.

---

## Plan de Verificación

### Pruebas Manuales (en emulador o dispositivo físico Android)

Después de `flutter run`:

1. **CRUD Tareas**: Crear una tarea, marcarla como completada y borrarla. Verificar que persiste al cerrar y reabrir la app.
2. **Rachas de Hábitos**: Crear un hábito diario, completarlo hoy. Verificar que `current_streak` en `UserStats` sube.
3. **Transacción Financiera**: Añadir un gasto de $100 MXN. Verificar que el balance de la cuenta disminuye y aparece en la lista.
4. **Sistema XP/Monedas**: Completar un hábito y verificar que aparece la animación de confeti y el XP aumenta visualmente.
5. **Tema / Navegación**: Cambiar entre todas las pantallas vía Bottom Navigation Bar sin crashes.

### Verificación de Build

```bash
flutter pub get
flutter analyze
flutter run
```

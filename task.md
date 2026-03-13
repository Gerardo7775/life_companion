# Life Companion App - Task List

## Fase 0-9: Completadas ✅

## Fase 10: Productividad y Enfoque

### Sub-feature 1: ⏱️ Temporizador Pomodoro
- [/] Tabla `PomodoroSessions` en DatabaseHelper (con `onUpgrade`)
- [/] Domain: entidades Pomodoro
- [/] Data: PomodoroLocalDataSource
- [/] Presentation: PomodoroState → PomodoroBloc → PomodoroPage
- [ ] Registrar en DI + main.dart
- [ ] Ruta `/pomodoro` en AppRouter (fuera de ShellRoute)
- [ ] Botón ▶ en TaskCard → lanzar Pomodoro

### Sub-feature 2: 🎯 Metas a Largo Plazo (Goals)
- [ ] Tablas `Goals` y `GoalItems` en DatabaseHelper
- [ ] Domain: entidades GoalEntity, GoalItemEntity
- [ ] Data: GoalsLocalDataSource
- [ ] Presentation: GoalsState → GoalsBloc → GoalsPage → GoalDetailPage
- [ ] Registrar en DI + main.dart
- [ ] Ruta `/goals` y `/goals/:id` en AppRouter
- [ ] MainShell: reemplazar "Rewards" por "Metas"

### Sub-feature 3: 🌅 Modo Rutina (Mañana/Noche)
- [ ] RoutinePage (reutiliza HabitBloc existente)
- [ ] Ruta `/routine` con queryParam `type`
- [ ] Banner en DashboardPage con acceso rápido

## Fase 11: Bienestar Digital (Screen Time)
- [x] Configurar plugins `app_usage` y `permission_handler`
- [x] Modificar AndroidManifest (`PACKAGE_USAGE_STATS`)
- [x] Crear Service para obtención de App Usage data
- [x] Crear ScreenTimePage (Gráficos y desglose de apps)

## Fase 12: Hub de Estadísticas Generales (Insights)
- [x] Modificar `insights_page.dart` para agrupar TaskBloc, HabitBloc, GoalsBloc y Uso de Teléfono
- [x] Integrar cards de resumen para cada rubro (Productividad, Rachas, Desempeño)
- [x] Agregar acceso rápido desde el Dashboard a Insights

### Integración Final
- [ ] `flutter build apk --debug` pasa sin errores

import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/agenda/presentation/pages/tasks_page.dart';
import '../../features/habits/presentation/pages/habits_page.dart';
import '../../features/finances/presentation/pages/finances_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/gamification/presentation/pages/rewards_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/pomodoro/presentation/pages/pomodoro_page.dart';
import '../../features/routine/presentation/pages/routine_page.dart';
import '../../features/wellness/presentation/pages/wellness_page.dart';
import '../../features/wellness/presentation/pages/mood_check_page.dart';
import '../../features/wellness/presentation/pages/journal_page.dart';
import '../../features/wellness/presentation/pages/journal_entry_page.dart';
import '../../features/wellness/presentation/pages/insights_page.dart';
import '../widgets/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Pantallas full-screen (sin bottom nav) ──────────────────────────────
    GoRoute(
      path: '/pomodoro',
      builder: (context, state) {
        final taskId = int.tryParse(state.uri.queryParameters['taskId'] ?? '');
        final taskTitle = state.uri.queryParameters['taskTitle'];
        return PomodoroPage(taskId: taskId, taskTitle: taskTitle);
      },
    ),
    GoRoute(
      path: '/routine',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'] ?? 'morning';
        return RoutinePage(type: type);
      },
    ),
    // Wellness (sin shell, pantallas completas)
    GoRoute(path: '/wellness', builder: (_, __) => const WellnessPage()),
    GoRoute(path: '/wellness/mood', builder: (_, __) => const MoodCheckPage()),
    GoRoute(path: '/wellness/journal', builder: (_, __) => const JournalPage()),
    GoRoute(
      path: '/wellness/journal/new',
      builder: (context, state) {
        final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
        return JournalEntryPage(entryId: id);
      },
    ),
    GoRoute(path: '/wellness/insights', builder: (_, __) => const InsightsPage()),

    // ── Shell principal con bottom nav ──────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
        GoRoute(path: '/tasks', builder: (context, state) => const TasksPage()),
        GoRoute(path: '/habits', builder: (context, state) => const HabitsPage()),
        GoRoute(path: '/finances', builder: (context, state) => const FinancesPage()),
        GoRoute(path: '/goals', builder: (context, state) => const GoalsPage()),
        GoRoute(path: '/rewards', builder: (context, state) => const RewardsPage()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
      ],
    ),
  ],
);

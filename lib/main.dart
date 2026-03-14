import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_theme.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/daily_checker_service.dart';
import 'core/theme/theme_cubit.dart';
import 'features/agenda/presentation/state/task_bloc.dart';
import 'features/agenda/presentation/state/task_state.dart';
import 'features/habits/presentation/state/habit_bloc.dart';
import 'features/habits/presentation/state/habit_state.dart';
import 'features/finances/presentation/state/finance_bloc.dart';
import 'features/finances/presentation/state/finance_state.dart';
import 'features/gamification/presentation/state/gamification_bloc.dart';
import 'features/gamification/presentation/state/gamification_state.dart';
import 'features/goals/presentation/state/goals_bloc.dart';
import 'features/goals/presentation/state/goals_state.dart';
import 'features/pomodoro/presentation/state/pomodoro_bloc.dart';
import 'features/wellness/presentation/state/wellness_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  await initDependencies();
  // Inicializar notificaciones y solicitar permiso
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();
  await NotificationService.instance.scheduleMoodReminder();
  
  // Revisar rachas de hábitos diarias y aplicar Modo Hardcore
  await DailyCheckerService.checkDailyProgress();

  runApp(const LifeCompanionApp());
}


class LifeCompanionApp extends StatelessWidget {
  const LifeCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (_) => sl<TaskBloc>()..add(const LoadTasksEvent()),
        ),
        BlocProvider<HabitBloc>(
          create: (_) => sl<HabitBloc>()..add(LoadHabitsEvent()),
        ),
        BlocProvider<FinanceBloc>(
          create: (_) => sl<FinanceBloc>()..add(LoadFinancesEvent()),
        ),
        BlocProvider<GamificationBloc>(
          create: (_) => sl<GamificationBloc>()..add(LoadGamificationEvent()),
        ),
        BlocProvider<GoalsBloc>(
          create: (_) => sl<GoalsBloc>()..add(LoadGoalsEvent()),
        ),
        BlocProvider<PomodoroBloc>(
          create: (_) => sl<PomodoroBloc>(),
        ),
        BlocProvider<WellnessBloc>(
          create: (_) => sl<WellnessBloc>(),
        ),
      ],
      child: BlocProvider<ThemeCubit>(
        create: (_) => ThemeCubit(),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'Life Companion',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}

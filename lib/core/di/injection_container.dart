import 'package:get_it/get_it.dart';
import '../storage/database_helper.dart';

// Agenda
import '../../features/agenda/data/datasources/task_local_datasource.dart';
import '../../features/agenda/data/repositories/task_repository_impl.dart';
import '../../features/agenda/domain/use_cases/task_use_cases.dart';
import '../../features/agenda/presentation/state/task_bloc.dart';

// Habits
import '../../features/habits/data/datasources/habit_local_datasource.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/use_cases/habit_use_cases.dart';
import '../../features/habits/presentation/state/habit_bloc.dart';

// Finances
import '../../features/finances/data/datasources/finance_local_datasource.dart';
import '../../features/finances/presentation/state/finance_bloc.dart';

// Gamification
import '../../features/gamification/data/datasources/gamification_local_datasource.dart';
import '../../features/gamification/presentation/state/gamification_bloc.dart';

// Pomodoro
import '../../features/pomodoro/data/datasources/pomodoro_local_datasource.dart';
import '../../features/pomodoro/presentation/state/pomodoro_bloc.dart';

// Goals
import '../../features/goals/data/datasources/goals_local_datasource.dart';
import '../../features/goals/presentation/state/goals_bloc.dart';

// Wellness
import '../../features/wellness/data/datasources/wellness_local_datasource.dart';
import '../../features/wellness/presentation/state/wellness_bloc.dart';



final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─────────── Core ───────────
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // ─────────── Agenda / Tasks ───────────
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSource(sl()),
  );
  sl.registerLazySingleton<TaskRepositoryImpl>(
    () => TaskRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetTasksUseCase(sl<TaskRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl<TaskRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl<TaskRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl<TaskRepositoryImpl>()));
  sl.registerLazySingleton(() => CompleteTaskUseCase(sl<TaskRepositoryImpl>()));

  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl(),
      createTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      completeTask: sl(),
    ),
  );

  // ─────────── Habits ───────────
  sl.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSource(sl()),
  );
  sl.registerLazySingleton<HabitRepositoryImpl>(
    () => HabitRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetHabitsUseCase(sl<HabitRepositoryImpl>()));
  sl.registerLazySingleton(
    () => CreateHabitUseCase(sl<HabitRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => UpdateHabitUseCase(sl<HabitRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => DeleteHabitUseCase(sl<HabitRepositoryImpl>()),
  );
  sl.registerLazySingleton(() => LogHabitUseCase(sl<HabitRepositoryImpl>()));

  sl.registerFactory(
    () => HabitBloc(
      getHabits: sl(),
      createHabit: sl(),
      updateHabit: sl(),
      deleteHabit: sl(),
      logHabit: sl(),
    ),
  );

  // ─────────── Finances ───────────
  sl.registerLazySingleton<FinanceLocalDataSource>(
    () => FinanceLocalDataSource(sl()),
  );

  sl.registerFactory(() => FinanceBloc(sl()));

  // ─────────── Gamification ───────────
  sl.registerLazySingleton<GamificationLocalDataSource>(
    () => GamificationLocalDataSource(sl()),
  );

  sl.registerFactory(() => GamificationBloc(sl()));

  // ─────────── Pomodoro ───────────
  sl.registerLazySingleton<PomodoroLocalDataSource>(
    () => PomodoroLocalDataSource(sl()),
  );
  sl.registerFactory(() => PomodoroBloc(sl()));

  // ─────────── Goals ───────────
  sl.registerLazySingleton<GoalsLocalDataSource>(
    () => GoalsLocalDataSource(sl()),
  );
  sl.registerFactory(() => GoalsBloc(sl()));

  // ─────────── Wellness ───────────
  sl.registerLazySingleton<WellnessLocalDataSource>(
    () => WellnessLocalDataSource(sl()),
  );
  sl.registerFactory(() => WellnessBloc(sl()));
}


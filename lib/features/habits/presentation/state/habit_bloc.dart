import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/use_cases/habit_use_cases.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final GetHabitsUseCase _getHabits;
  final CreateHabitUseCase _createHabit;
  final UpdateHabitUseCase _updateHabit;
  final DeleteHabitUseCase _deleteHabit;
  final LogHabitUseCase _logHabit;

  HabitBloc({
    required GetHabitsUseCase getHabits,
    required CreateHabitUseCase createHabit,
    required UpdateHabitUseCase updateHabit,
    required DeleteHabitUseCase deleteHabit,
    required LogHabitUseCase logHabit,
  }) : _getHabits = getHabits,
       _createHabit = createHabit,
       _updateHabit = updateHabit,
       _deleteHabit = deleteHabit,
       _logHabit = logHabit,
       super(HabitInitial()) {
    on<LoadHabitsEvent>(_onLoad);
    on<CreateHabitEvent>(_onCreate);
    on<UpdateHabitEvent>(_onUpdate);
    on<DeleteHabitEvent>(_onDelete);
    on<LogHabitEvent>(_onLog);
  }

  Future<void> _syncNotifications(List<HabitEntity> habits) async {
    for (final h in habits) {
      if (h.reminderTime != null && h.id != null) {
        final parts = h.reminderTime!.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 8;
          final min = int.tryParse(parts[1]) ?? 0;
          await NotificationService.instance.scheduleHabitReminder(
            habitId: h.id!,
            habitName: h.name,
            hour: hour,
            minute: min,
          );
        }
      } else if (h.id != null) {
        // Si ya no tiene recordatorio, nos aseguramos de cancelarlo
        await NotificationService.instance.cancelHabitReminder(h.id!);
      }
    }
  }

  Future<void> _onLoad(LoadHabitsEvent event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    final result = await _getHabits();
    await result.fold(
      (f) async => emit(HabitError(f.message)),
      (h) async {
        await _syncNotifications(h);
        emit(HabitLoaded(h));
      },
    );
  }

  Future<void> _onCreate(
    CreateHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    await _createHabit(event.habit);
    final result = await _getHabits();
    await result.fold(
      (f) async => emit(HabitError(f.message)),
      (h) async {
        await _syncNotifications(h);
        emit(HabitLoaded(h));
      },
    );
  }

  Future<void> _onUpdate(
    UpdateHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    await _updateHabit(event.habit);
    final result = await _getHabits();
    await result.fold(
      (f) async => emit(HabitError(f.message)),
      (h) async {
        await _syncNotifications(h);
        emit(HabitLoaded(h));
      },
    );
  }

  Future<void> _onDelete(
    DeleteHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    await NotificationService.instance.cancelHabitReminder(event.habitId);
    await _deleteHabit(event.habitId);
    final result = await _getHabits();
    await result.fold(
      (f) async => emit(HabitError(f.message)),
      (h) async {
        await _syncNotifications(h);
        emit(HabitLoaded(h));
      },
    );
  }

  Future<void> _onLog(LogHabitEvent event, Emitter<HabitState> emit) async {
    final logResult = await _logHabit(event.habitId, event.value);
    final habitsResult = await _getHabits();
    habitsResult.fold((f) => emit(HabitError(f.message)), (habits) {
      final name = logResult.fold((_) => '', (h) => h.name);
      final completed = logResult.fold((_) => false, (h) => h.isCompletedToday);
      if (completed) {
        emit(HabitCompletedSuccess(habits, name));
      } else {
        emit(HabitLoaded(habits));
      }
    });
  }
}


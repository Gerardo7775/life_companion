import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/pomodoro_local_datasource.dart';
import 'pomodoro_state.dart';


class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final PomodoroLocalDataSource _dataSource;
  Timer? _timer;

  PomodoroBloc(this._dataSource) : super(const PomodoroState()) {
    on<PomodoroInitEvent>(_onInit);
    on<PomodoroStartEvent>(_onStart);
    on<PomodoroPauseEvent>(_onPause);
    on<PomodoroResetEvent>(_onReset);
    on<PomodoroTickEvent>(_onTick);
    on<PomodoroSkipEvent>(_onSkip);
  }

  void _onInit(PomodoroInitEvent event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    final secs = event.config.workMinutes * 60;
    emit(PomodoroState(
      phase: PomodoroPhase.idle,
      totalSeconds: secs,
      remainingSeconds: secs,
      config: event.config,
      taskId: event.taskId,
      taskTitle: event.taskTitle,
    ));
  }

  void _onStart(PomodoroStartEvent event, Emitter<PomodoroState> emit) {
    if (state.isCompleted) return;
    final phase =
        state.phase == PomodoroPhase.idle ? PomodoroPhase.working : state.phase;
    emit(state.copyWith(isRunning: true, phase: phase, isCompleted: false));
    _startTimer();
  }

  void _onPause(PomodoroPauseEvent event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    emit(state.copyWith(isRunning: false));
  }

  void _onReset(PomodoroResetEvent event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    final secs = state.config.workMinutes * 60;
    emit(state.copyWith(
      phase: PomodoroPhase.idle,
      remainingSeconds: secs,
      totalSeconds: secs,
      isRunning: false,
      isCompleted: false,
    ));
  }

  Future<void> _onTick(
      PomodoroTickEvent event, Emitter<PomodoroState> emit) async {
    if (state.remainingSeconds <= 1) {
      _cancelTimer();
      // Guardar sesión completada si era de trabajo
      if (state.phase == PomodoroPhase.working) {
        await _dataSource.saveSession(
          taskId: state.taskId,
          taskTitle: state.taskTitle,
          durationMinutes: state.config.workMinutes,
          sessionType: 'work',
        );
        final completed = state.completedWorkSessions + 1;
        final isLongBreak =
            completed % state.config.sessionsBeforeLongBreak == 0;
        final nextPhase =
            isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
        final breakSecs = isLongBreak
            ? state.config.longBreakMinutes * 60
            : state.config.shortBreakMinutes * 60;
        // Notificación al completar sesión de trabajo
        NotificationService.instance.showPomodoroAlert(isWorkPhase: true);
        emit(state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isCompleted: true,
          completedWorkSessions: completed,
          phase: nextPhase,
          totalSeconds: breakSecs,
        ));

      } else {
        // Fin de descanso → notificación y volver a trabajo
        NotificationService.instance.showPomodoroAlert(isWorkPhase: false);
        final secs = state.config.workMinutes * 60;
        emit(state.copyWith(
          remainingSeconds: 0,
          isRunning: false,
          isCompleted: true,
          phase: PomodoroPhase.working,
          totalSeconds: secs,
        ));

      }
    } else {
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    }
  }

  void _onSkip(PomodoroSkipEvent event, Emitter<PomodoroState> emit) {
    _cancelTimer();
    // Pasar a la siguiente fase sin guardar sesión
    if (state.phase == PomodoroPhase.working) {
      final completed = state.completedWorkSessions + 1;
      final isLongBreak =
          completed % state.config.sessionsBeforeLongBreak == 0;
      final nextPhase =
          isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      final breakSecs = isLongBreak
          ? state.config.longBreakMinutes * 60
          : state.config.shortBreakMinutes * 60;
      emit(state.copyWith(
        phase: nextPhase,
        totalSeconds: breakSecs,
        remainingSeconds: breakSecs,
        isRunning: false,
        isCompleted: false,
        completedWorkSessions: completed,
      ));
    } else {
      final secs = state.config.workMinutes * 60;
      emit(state.copyWith(
        phase: PomodoroPhase.working,
        totalSeconds: secs,
        remainingSeconds: secs,
        isRunning: false,
        isCompleted: false,
      ));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(PomodoroTickEvent());
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}

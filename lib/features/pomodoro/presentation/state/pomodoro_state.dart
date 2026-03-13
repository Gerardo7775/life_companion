import 'package:equatable/equatable.dart';
import '../../domain/entities/pomodoro_entities.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();
  @override
  List<Object?> get props => [];
}

/// Inicializa o resetea el timer con config y tarea opcional
class PomodoroInitEvent extends PomodoroEvent {
  final int? taskId;
  final String? taskTitle;
  final PomodoroConfig config;
  const PomodoroInitEvent({
    this.taskId,
    this.taskTitle,
    this.config = const PomodoroConfig(),
  });
  @override
  List<Object?> get props => [taskId, config.workMinutes];
}

/// Arranca o reanuda el timer
class PomodoroStartEvent extends PomodoroEvent {}

/// Pausa el timer
class PomodoroPauseEvent extends PomodoroEvent {}

/// Resetea la sesión actual al tiempo original
class PomodoroResetEvent extends PomodoroEvent {}

/// Tick interno – emitido por el timer cada segundo
class PomodoroTickEvent extends PomodoroEvent {}

/// Solicita saltar al siguiente tipo de sesión
class PomodoroSkipEvent extends PomodoroEvent {}

// ─── States ──────────────────────────────────────────────────────────────────
enum PomodoroPhase { idle, working, shortBreak, longBreak }

class PomodoroState extends Equatable {
  final PomodoroPhase phase;
  final int totalSeconds;     // duración total de la fase actual
  final int remainingSeconds; // segundos que quedan
  final bool isRunning;
  final bool isCompleted;     // la fase actual terminó
  final int completedWorkSessions;
  final int? taskId;
  final String? taskTitle;
  final PomodoroConfig config;

  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.totalSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.isRunning = false,
    this.isCompleted = false,
    this.completedWorkSessions = 0,
    this.taskId,
    this.taskTitle,
    this.config = const PomodoroConfig(),
  });

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - remainingSeconds / totalSeconds;

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
    int? completedWorkSessions,
    int? taskId,
    String? taskTitle,
    PomodoroConfig? config,
  }) =>
      PomodoroState(
        phase: phase ?? this.phase,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        isRunning: isRunning ?? this.isRunning,
        isCompleted: isCompleted ?? this.isCompleted,
        completedWorkSessions:
            completedWorkSessions ?? this.completedWorkSessions,
        taskId: taskId ?? this.taskId,
        taskTitle: taskTitle ?? this.taskTitle,
        config: config ?? this.config,
      );

  @override
  List<Object?> get props => [
        phase, remainingSeconds, isRunning, isCompleted,
        completedWorkSessions, taskId,
      ];
}

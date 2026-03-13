import 'package:equatable/equatable.dart';

class PomodoroSessionEntity extends Equatable {
  final int? id;
  final int? taskId;
  final String? taskTitle;
  final int durationMinutes;      // duración real en minutos
  final String sessionType;       // 'work' | 'short_break' | 'long_break'
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime? completedAt;

  const PomodoroSessionEntity({
    this.id,
    this.taskId,
    this.taskTitle,
    this.durationMinutes = 25,
    this.sessionType = 'work',
    this.isCompleted = false,
    required this.startedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, taskId, sessionType, startedAt];
}

class PomodoroConfig {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;

  const PomodoroConfig({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });
}

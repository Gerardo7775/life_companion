import 'package:equatable/equatable.dart';
import '../../domain/entities/habit_entity.dart';

// Events
abstract class HabitEvent extends Equatable {
  const HabitEvent();
  @override
  List<Object?> get props => [];
}

class LoadHabitsEvent extends HabitEvent {}

class CreateHabitEvent extends HabitEvent {
  final HabitEntity habit;
  const CreateHabitEvent(this.habit);
  @override
  List<Object?> get props => [habit];
}

class UpdateHabitEvent extends HabitEvent {
  final HabitEntity habit;
  const UpdateHabitEvent(this.habit);
  @override
  List<Object?> get props => [habit];
}

class DeleteHabitEvent extends HabitEvent {
  final int habitId;
  const DeleteHabitEvent(this.habitId);
  @override
  List<Object?> get props => [habitId];
}

class LogHabitEvent extends HabitEvent {
  final int habitId;
  final double value;
  const LogHabitEvent(this.habitId, {this.value = 1.0});
  @override
  List<Object?> get props => [habitId, value];
}

// States
abstract class HabitState extends Equatable {
  const HabitState();
  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<HabitEntity> habits;
  const HabitLoaded(this.habits);
  @override
  List<Object?> get props => [habits];
}

class HabitCompletedSuccess extends HabitState {
  final List<HabitEntity> habits;
  final String habitName;
  const HabitCompletedSuccess(this.habits, this.habitName);
  @override
  List<Object?> get props => [habits, habitName];
}

class HabitError extends HabitState {
  final String message;
  const HabitError(this.message);
  @override
  List<Object?> get props => [message];
}

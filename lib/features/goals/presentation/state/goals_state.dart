import 'package:equatable/equatable.dart';
import '../../domain/entities/goal_entities.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class GoalsEvent extends Equatable {
  const GoalsEvent();
  @override
  List<Object?> get props => [];
}

class LoadGoalsEvent extends GoalsEvent {}

class CreateGoalEvent extends GoalsEvent {
  final GoalEntity goal;
  const CreateGoalEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class DeleteGoalEvent extends GoalsEvent {
  final int goalId;
  const DeleteGoalEvent(this.goalId);
  @override
  List<Object?> get props => [goalId];
}

class AddGoalItemEvent extends GoalsEvent {
  final GoalItemEntity item;
  const AddGoalItemEvent(this.item);
  @override
  List<Object?> get props => [item];
}

class ToggleGoalItemEvent extends GoalsEvent {
  final int itemId;
  final bool completed;
  const ToggleGoalItemEvent(this.itemId, this.completed);
  @override
  List<Object?> get props => [itemId, completed];
}

class DeleteGoalItemEvent extends GoalsEvent {
  final int itemId;
  const DeleteGoalItemEvent(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class GoalsState extends Equatable {
  const GoalsState();
  @override
  List<Object?> get props => [];
}

class GoalsInitial extends GoalsState {}
class GoalsLoading extends GoalsState {}

class GoalsLoaded extends GoalsState {
  final List<GoalEntity> goals;
  const GoalsLoaded(this.goals);
  @override
  List<Object?> get props => [goals];
}

class GoalsError extends GoalsState {
  final String message;
  const GoalsError(this.message);
  @override
  List<Object?> get props => [message];
}

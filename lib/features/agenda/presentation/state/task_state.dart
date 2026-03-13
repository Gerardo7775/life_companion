import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final String? filterStatus;
  const LoadTasksEvent({this.filterStatus});
  @override
  List<Object?> get props => [filterStatus];
}

class CreateTaskEvent extends TaskEvent {
  final TaskEntity task;
  const CreateTaskEvent(this.task);
  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;
  const UpdateTaskEvent(this.task);
  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final int taskId;
  const DeleteTaskEvent(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class CompleteTaskEvent extends TaskEvent {
  final int taskId;
  const CompleteTaskEvent(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

// ─── States ───────────────────────────────────────────────────────────────────
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  const TaskLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskOperationSuccess extends TaskState {
  final String message;
  final List<TaskEntity> tasks;
  const TaskOperationSuccess(this.message, this.tasks);
  @override
  List<Object?> get props => [message, tasks];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/i_task_repository.dart';

class GetTasksUseCase {
  final ITaskRepository repository;
  GetTasksUseCase(this.repository);
  Future<Either<Failure, List<TaskEntity>>> call({String? status}) =>
      repository.getTasks(status: status);
}

class CreateTaskUseCase {
  final ITaskRepository repository;
  CreateTaskUseCase(this.repository);
  Future<Either<Failure, TaskEntity>> call(TaskEntity task) =>
      repository.createTask(task);
}

class UpdateTaskUseCase {
  final ITaskRepository repository;
  UpdateTaskUseCase(this.repository);
  Future<Either<Failure, TaskEntity>> call(TaskEntity task) =>
      repository.updateTask(task);
}

class DeleteTaskUseCase {
  final ITaskRepository repository;
  DeleteTaskUseCase(this.repository);
  Future<Either<Failure, bool>> call(int id) => repository.deleteTask(id);
}

class CompleteTaskUseCase {
  final ITaskRepository repository;
  CompleteTaskUseCase(this.repository);
  Future<Either<Failure, TaskEntity>> call(int id) =>
      repository.completeTask(id);
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class ITaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks({String? status});
  Future<Either<Failure, TaskEntity>> getTaskById(int id);
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
  Future<Either<Failure, bool>> deleteTask(int id);
  Future<Either<Failure, TaskEntity>> completeTask(int id);
}

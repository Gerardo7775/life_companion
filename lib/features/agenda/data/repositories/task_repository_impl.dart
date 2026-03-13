import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final TaskLocalDataSource dataSource;
  TaskRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks({String? status}) async {
    try {
      return Right(await dataSource.getTasks(status: status));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(int id) async {
    try {
      final task = await dataSource.getTaskById(id);
      if (task == null) {
        return const Left(NotFoundFailure('Tarea no encontrada'));
      }
      return Right(task);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      return Right(await dataSource.insertTask(TaskModel.fromEntity(task)));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      return Right(await dataSource.updateTask(TaskModel.fromEntity(task)));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTask(int id) async {
    try {
      return Right(await dataSource.deleteTask(id));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> completeTask(int id) async {
    try {
      final task = await dataSource.completeTask(id);
      if (task == null) {
        return const Left(NotFoundFailure('Tarea no encontrada'));
      }
      return Right(task);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

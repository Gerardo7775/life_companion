import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/i_habit_repository.dart';
import '../datasources/habit_local_datasource.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements IHabitRepository {
  final HabitLocalDataSource dataSource;
  HabitRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits() async {
    try {
      return Right(await dataSource.getHabits());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> createHabit(HabitEntity habit) async {
    try {
      return Right(await dataSource.insertHabit(HabitModel.fromEntity(habit)));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> updateHabit(HabitEntity habit) async {
    try {
      return Right(await dataSource.insertHabit(HabitModel.fromEntity(habit)));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteHabit(int id) async {
    try {
      return Right(await dataSource.deleteHabit(id));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> logHabit(
    int habitId,
    double value,
  ) async {
    try {
      final habit = await dataSource.logHabit(habitId, value);
      if (habit == null) {
        return const Left(NotFoundFailure('Hábito no encontrado'));
      }
      return Right(habit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HabitLogEntity>>> getLogsForHabit(
    int habitId,
    DateTime from,
    DateTime to,
  ) async {
    return const Right([]);
  }
}

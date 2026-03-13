import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit_entity.dart';

abstract class IHabitRepository {
  Future<Either<Failure, List<HabitEntity>>> getHabits();
  Future<Either<Failure, HabitEntity>> createHabit(HabitEntity habit);
  Future<Either<Failure, HabitEntity>> updateHabit(HabitEntity habit);
  Future<Either<Failure, bool>> deleteHabit(int id);
  Future<Either<Failure, HabitEntity>> logHabit(int habitId, double value);
  Future<Either<Failure, List<HabitLogEntity>>> getLogsForHabit(
    int habitId,
    DateTime from,
    DateTime to,
  );
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit_entity.dart';
import '../repositories/i_habit_repository.dart';

class GetHabitsUseCase {
  final IHabitRepository repository;
  GetHabitsUseCase(this.repository);
  Future<Either<Failure, List<HabitEntity>>> call() => repository.getHabits();
}

class CreateHabitUseCase {
  final IHabitRepository repository;
  CreateHabitUseCase(this.repository);
  Future<Either<Failure, HabitEntity>> call(HabitEntity habit) =>
      repository.createHabit(habit);
}

class DeleteHabitUseCase {
  final IHabitRepository repository;
  DeleteHabitUseCase(this.repository);
  Future<Either<Failure, bool>> call(int id) => repository.deleteHabit(id);
}

class LogHabitUseCase {
  final IHabitRepository repository;
  LogHabitUseCase(this.repository);
  Future<Either<Failure, HabitEntity>> call(int habitId, double value) =>
      repository.logHabit(habitId, value);
}

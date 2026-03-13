import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/goals_local_datasource.dart';
import 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final GoalsLocalDataSource _dataSource;

  GoalsBloc(this._dataSource) : super(GoalsInitial()) {
    on<LoadGoalsEvent>(_onLoad);
    on<CreateGoalEvent>(_onCreate);
    on<DeleteGoalEvent>(_onDelete);
    on<AddGoalItemEvent>(_onAddItem);
    on<ToggleGoalItemEvent>(_onToggleItem);
    on<DeleteGoalItemEvent>(_onDeleteItem);
  }

  Future<void> _onLoad(
      LoadGoalsEvent event, Emitter<GoalsState> emit) async {
    emit(GoalsLoading());
    try {
      final goals = await _dataSource.getGoals();
      emit(GoalsLoaded(goals));
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateGoalEvent event, Emitter<GoalsState> emit) async {
    try {
      await _dataSource.createGoal(event.goal);
      add(LoadGoalsEvent());
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteGoalEvent event, Emitter<GoalsState> emit) async {
    try {
      await _dataSource.deleteGoal(event.goalId);
      add(LoadGoalsEvent());
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onAddItem(
      AddGoalItemEvent event, Emitter<GoalsState> emit) async {
    try {
      await _dataSource.addItem(event.item);
      add(LoadGoalsEvent());
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onToggleItem(
      ToggleGoalItemEvent event, Emitter<GoalsState> emit) async {
    try {
      await _dataSource.toggleItem(event.itemId, event.completed);
      add(LoadGoalsEvent());
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
      DeleteGoalItemEvent event, Emitter<GoalsState> emit) async {
    try {
      await _dataSource.deleteItem(event.itemId);
      add(LoadGoalsEvent());
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }
}

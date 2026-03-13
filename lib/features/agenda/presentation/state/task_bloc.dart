import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_cases/task_use_cases.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase _getTasks;
  final CreateTaskUseCase _createTask;
  final UpdateTaskUseCase _updateTask;
  final DeleteTaskUseCase _deleteTask;
  final CompleteTaskUseCase _completeTask;

  TaskBloc({
    required GetTasksUseCase getTasks,
    required CreateTaskUseCase createTask,
    required UpdateTaskUseCase updateTask,
    required DeleteTaskUseCase deleteTask,
    required CompleteTaskUseCase completeTask,
  }) : _getTasks = getTasks,
       _createTask = createTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _completeTask = completeTask,
       super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoad);
    on<CreateTaskEvent>(_onCreate);
    on<UpdateTaskEvent>(_onUpdate);
    on<DeleteTaskEvent>(_onDelete);
    on<CompleteTaskEvent>(_onComplete);
  }

  Future<void> _onLoad(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await _getTasks(status: event.filterStatus);
    result.fold(
      (f) => emit(TaskError(f.message)),
      (tasks) => emit(TaskLoaded(tasks)),
    );
  }

  Future<void> _onCreate(CreateTaskEvent event, Emitter<TaskState> emit) async {
    final result = await _createTask(event.task);
    await result.fold((f) async => emit(TaskError(f.message)), (_) async {
      final all = await _getTasks();
      all.fold(
        (f) => emit(TaskError(f.message)),
        (tasks) => emit(TaskOperationSuccess('Tarea creada ✓', tasks)),
      );
    });
  }

  Future<void> _onUpdate(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    final result = await _updateTask(event.task);
    await result.fold((f) async => emit(TaskError(f.message)), (_) async {
      final all = await _getTasks();
      all.fold(
        (f) => emit(TaskError(f.message)),
        (tasks) => emit(TaskOperationSuccess('Tarea actualizada ✓', tasks)),
      );
    });
  }

  Future<void> _onDelete(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final result = await _deleteTask(event.taskId);
    await result.fold((f) async => emit(TaskError(f.message)), (_) async {
      final all = await _getTasks();
      all.fold(
        (f) => emit(TaskError(f.message)),
        (tasks) => emit(TaskOperationSuccess('Tarea eliminada', tasks)),
      );
    });
  }

  Future<void> _onComplete(
    CompleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _completeTask(event.taskId);
    await result.fold((f) async => emit(TaskError(f.message)), (_) async {
      final all = await _getTasks();
      all.fold(
        (f) => emit(TaskError(f.message)),
        (tasks) => emit(TaskOperationSuccess('¡Tarea completada! 🎉', tasks)),
      );
    });
  }
}

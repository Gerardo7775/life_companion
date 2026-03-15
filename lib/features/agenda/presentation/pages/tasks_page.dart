import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/task_entity.dart';
import '../state/task_bloc.dart';
import '../state/task_state.dart';
import '../widgets/task_card.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(const LoadTasksEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: BlocConsumer<TaskBloc, TaskState>(
                listener: (ctx, state) {
                  if (state is TaskOperationSuccess) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                builder: (ctx, state) {
                  if (state is TaskLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (state is TaskError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }
                  final tasks = _filteredTasks(
                    state is TaskLoaded
                        ? state.tasks
                        : state is TaskOperationSuccess
                        ? state.tasks
                        : [],
                  );
                  if (tasks.isEmpty) return _buildEmptyState();
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: tasks.length,
                    itemBuilder: (_, i) => TaskCard(
                      task: tasks[i],
                      onComplete: () => ctx.read<TaskBloc>().add(
                        CompleteTaskEvent(tasks[i].id!),
                      ),
                      onDelete: () => _confirmDelete(ctx, tasks[i].id!),
                      onTap: () => _showTaskForm(ctx, task: tasks[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva tarea'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mis Tareas', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d MMMM', 'es').format(now),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            _tabBtn('Todas', 'all'),
            _tabBtn('Pendientes', 'pending'),
            _tabBtn('Completadas', 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(String label, String filter) {
    final isActive = _activeFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeFilter = filter);
          context.read<TaskBloc>().add(
            LoadTasksEvent(filterStatus: filter == 'all' ? null : filter),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }

  List<TaskEntity> _filteredTasks(List<TaskEntity> tasks) {
    if (_activeFilter == 'all') return tasks;
    return tasks.where((t) => t.status == _activeFilter).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin tareas aquí',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Toca el botón + para agregar una!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, int taskId) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(
          'Eliminar tarea',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: const Text(
          '¿Seguro que quieres eliminar esta tarea?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<TaskBloc>().add(DeleteTaskEvent(taskId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showTaskForm(BuildContext ctx, {TaskEntity? task}) {
    final titleCtrl = TextEditingController(text: task?.title);
    final descCtrl = TextEditingController(text: task?.description);
    int priority = task?.priority ?? 2;
    DateTime? dueDate = task?.dueDate;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bsCtx) => StatefulBuilder(
        builder: (bsCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bsCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                task == null ? 'Nueva Tarea' : 'Editar Tarea',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text('Prioridad', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3, 4].map((p) {
                  final labels = ['Baja', 'Media', 'Alta', 'Urgente'];
                  final colors = [
                    AppColors.textHint,
                    AppColors.info,
                    AppColors.warning,
                    AppColors.error,
                  ];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setModalState(() => priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: priority == p
                                ? colors[p - 1].withValues(alpha: 0.2)
                                : AppColors.bgCardLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: priority == p
                                  ? colors[p - 1]
                                  : AppColors.glassBorder,
                              width: priority == p ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            labels[p - 1],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors[p - 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primary,
                          surface: AppColors.bgCard,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setModalState(() => dueDate = picked);
                },
                child: GlassCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dueDate != null
                            ? DateFormat(
                                'EEEE, d MMMM yyyy',
                                'es',
                              ).format(dueDate!)
                            : 'Fecha límite (opcional)',
                        style: TextStyle(
                          color: dueDate != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final entity = TaskEntity(
                      id: task?.id,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      priority: priority,
                      dueDate: dueDate,
                      status: task?.status ?? 'pending',
                    );
                    if (task == null) {
                      ctx.read<TaskBloc>().add(CreateTaskEvent(entity));
                    } else {
                      ctx.read<TaskBloc>().add(UpdateTaskEvent(entity));
                    }
                    Navigator.pop(bsCtx);
                  },
                  child: Text(task == null ? 'Crear Tarea' : 'Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
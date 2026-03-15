import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/habit_entity.dart';
import '../state/habit_bloc.dart';
import '../state/habit_state.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});
  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(LoadHabitsEvent());
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: BlocConsumer<HabitBloc, HabitState>(
                    listener: (ctx, state) {
                      if (state is HabitCompletedSuccess) {
                        _confetti.play();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              '¡"${state.habitName}" completado! 🎉 +50 XP',
                            ),
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
                      if (state is HabitLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }
                      final habits = state is HabitLoaded
                          ? state.habits
                          : state is HabitCompletedSuccess
                          ? state.habits
                          : <HabitEntity>[];
                      if (habits.isEmpty) return _buildEmptyState();
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: habits.length,
                        itemBuilder: (_, i) => _HabitCard(
                          habit: habits[i],
                          onLog: () => ctx.read<HabitBloc>().add(
                            LogHabitEvent(habits[i].id!),
                          ),
                          onEdit: () => _showHabitForm(ctx, existingHabit: habits[i]),
                          onDelete: () => ctx.read<HabitBloc>().add(
                            DeleteHabitEvent(habits[i].id!),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Confeti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                AppColors.warning,
                AppColors.success,
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHabitForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo hábito'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? '🌅 Buenos días'
        : now.hour < 18
        ? '☀️ Buenas tardes'
        : '🌙 Buenas noches';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            'Mis Hábitos',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.loop_rounded,
          size: 64,
          color: AppColors.accent.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 16),
        Text(
          'Sin hábitos todavía',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textHint),
        ),
        const SizedBox(height: 8),
        Text(
          '¡Empieza con algo pequeño!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );

  void _showHabitForm(BuildContext ctx, {HabitEntity? existingHabit}) {
    final nameCtrl = TextEditingController(text: existingHabit?.name ?? '');
    final unitCtrl = TextEditingController(text: existingHabit?.unit ?? 'vez');
    double target = existingHabit?.targetValue ?? 1;
    String timeOfDay = existingHabit?.timeOfDay ?? 'anytime';
    TimeOfDay? reminderTime;

    if (existingHabit?.reminderTime != null) {
      final parts = existingHabit!.reminderTime!.split(':');
      if (parts.length == 2) {
        reminderTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.parse(parts[1]));
      }
    }

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
                existingHabit != null ? 'Editar Hábito' : 'Nuevo Hábito',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre del hábito *',
                  prefixIcon: Icon(Icons.loop_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta diaria',
                          style: Theme.of(ctx).textTheme.labelLarge,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primary,
                              onPressed: () => setModalState(
                                () => target = (target - 1).clamp(1, 100),
                              ),
                            ),
                            Text(
                              '$target',
                              style: Theme.of(ctx).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                              onPressed: () => setModalState(
                                () => target = (target + 1).clamp(1, 100),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        hintText: 'vasos, km...',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Momento del día',
                style: Theme.of(ctx).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in {
                    'anytime': '🌀 Cualquiera',
                    'morning': '🌅 Mañana',
                    'afternoon': '☀️ Tarde',
                    'evening': '🌙 Noche',
                  }.entries)
                    FilterChip(
                      label: Text(entry.value),
                      selected: timeOfDay == entry.key,
                      onSelected: (_) =>
                          setModalState(() => timeOfDay = entry.key),
                      selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recordatorio',
                    style: Theme.of(ctx).textTheme.labelLarge,
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: ctx,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setModalState(() => reminderTime = time);
                      }
                    },
                    icon: Icon(
                      reminderTime != null
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: reminderTime != null ? AppColors.primary : AppColors.textHint,
                    ),
                    label: Text(
                      reminderTime != null
                          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
                          : 'Añadir hora',
                      style: TextStyle(
                        color: reminderTime != null ? AppColors.primary : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    
                    String? formattedReminder;
                    if (reminderTime != null) {
                      formattedReminder = '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}';
                    }

                    final newHabit = HabitEntity(
                      id: existingHabit?.id,
                      name: nameCtrl.text.trim(),
                      targetValue: target,
                      categoryColor: existingHabit?.categoryColor,
                      unit: unitCtrl.text.trim().isEmpty
                          ? 'vez'
                          : unitCtrl.text.trim(),
                      timeOfDay: timeOfDay,
                      reminderTime: formattedReminder,
                    );

                    if (existingHabit != null) {
                      ctx.read<HabitBloc>().add(UpdateHabitEvent(newHabit));
                    } else {
                      ctx.read<HabitBloc>().add(CreateHabitEvent(newHabit));
                    }
                    Navigator.pop(bsCtx);
                  },
                  child: Text(existingHabit != null ? 'Guardar Cambios' : 'Crear Hábito'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _HabitCard extends StatelessWidget {
  final HabitEntity habit;
  final VoidCallback onLog;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _HabitCard({
    required this.habit,
    required this.onLog,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _catColor {
    if (habit.categoryColor == null) return AppColors.accent;
    try {
      return Color(int.parse(habit.categoryColor!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = habit.targetValue > 0
        ? (habit.achievedToday / habit.targetValue).clamp(0.0, 1.0)
        : 0.0;
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      borderColor: habit.isCompletedToday
          ? AppColors.success.withValues(alpha: 0.5)
          : AppColors.glassBorder,
      child: Row(
        children: [
          // Circle progress
          GestureDetector(
            onTap: habit.isCompletedToday ? null : onLog,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.toDouble(),
                    backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    color: habit.isCompletedToday
                        ? AppColors.success
                        : _catColor,
                    strokeWidth: 4,
                  ),
                  habit.isCompletedToday
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 22,
                        )
                      : Icon(Icons.add_rounded, color: _catColor, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: habit.isCompletedToday
                        ? TextDecoration.lineThrough
                        : null,
                    color: habit.isCompletedToday
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${habit.achievedToday.toStringAsFixed(habit.achievedToday.truncateToDouble() == habit.achievedToday ? 0 : 1)} / ${habit.targetValue.toStringAsFixed(habit.targetValue.truncateToDouble() == habit.targetValue ? 0 : 1)} ${habit.unit}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak} días seguidos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20),
            color: AppColors.textHint,
            onPressed: onEdit,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.error.withValues(alpha: 0.8),
            onPressed: onDelete,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

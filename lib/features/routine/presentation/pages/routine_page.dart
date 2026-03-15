import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/safe_pop_scope.dart';
import '../../../gamification/presentation/state/gamification_bloc.dart';
import '../../../gamification/presentation/state/gamification_state.dart';
import '../../../habits/presentation/state/habit_bloc.dart';
import '../../../habits/presentation/state/habit_state.dart';

class RoutinePage extends StatefulWidget {
  final String type; // 'morning' | 'evening' | 'anytime'

  const RoutinePage({super.key, required this.type});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _title {
    return switch (widget.type) {
      'morning' => 'Rutina de Mañana ☀️',
      'evening' => 'Rutina de Noche 🌙',
      _ => 'Rutina del Día 🌤️',
    };
  }

  String get _subtitle {
    return switch (widget.type) {
      'morning' => 'Empieza el día con energía',
      'evening' => 'Cierra el día con calma',
      _ => 'Hábitos para cualquier momento',
    };
  }

  Color get _themeColor {
    return switch (widget.type) {
      'morning' => const Color(0xFFFFB74D),
      'evening' => AppColors.primary,
      _ => AppColors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      fallbackRoute: '/',
      child: Stack(
        children: [
          Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
            title: Text(
              _title,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          body: BlocConsumer<HabitBloc, HabitState>(
            listener: (ctx, state) {
              if (state is HabitCompletedSuccess) {
                // Verificar si todos los habitos de la rutina están completos
                final routineHabits = _getRoutineHabits(state.habits, widget.type);
                if (routineHabits.isNotEmpty &&
                    routineHabits.every((h) => h.isCompletedToday)) {
                  _confetti.play();
                  ctx.read<GamificationBloc>().add(
                      AddXpEvent(xp: 30, coins: 10, source: 'routine_complete'));
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.success,
                      content: const Row(
                        children: [
                          Icon(Icons.celebration_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text('¡Rutina Completa! +30 XP 🎉'),
                        ],
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            builder: (ctx, state) {
              if (state is! HabitLoaded) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              final habits = _getRoutineHabits(state.habits, widget.type);
              if (habits.isEmpty) {
                return _EmptyRoutine(type: widget.type, color: _themeColor);
              }
              final done = habits.where((h) => h.isCompletedToday).length;
              final progress = done / habits.length;
              return SafeArea(
                child: Column(
                  children: [
                    // Barra de progreso global
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(16),
                        borderColor: _themeColor.withValues(alpha: 0.3),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_subtitle,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13)),
                                Text('$done / ${habits.length}',
                                    style: TextStyle(
                                        color: _themeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation(_themeColor),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: habits.length,
                        itemBuilder: (ctx, i) {
                          final habit = habits[i];
                          return _RoutineHabitTile(
                            habit: habit,
                            color: _themeColor,
                            index: i + 1,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Confeti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
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
    );
  }

  List<dynamic> _getRoutineHabits(List habits, String type) {
    if (type == 'anytime') return habits;
    return habits.where((h) => h.timeOfDay == type).toList();
  }
}

class _RoutineHabitTile extends StatelessWidget {
  final dynamic habit;
  final Color color;
  final int index;
  const _RoutineHabitTile({required this.habit, required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday as bool;
    return GestureDetector(
      onTap: isCompleted
          ? null
          : () => context.read<HabitBloc>().add(LogHabitEvent(habit.id!)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? color.withValues(alpha: 0.12)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? color.withValues(alpha: 0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            // Número o check
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isCompleted
                  ? Icon(Icons.check_circle_rounded, color: color, size: 32, key: const ValueKey('check'))
                  : Container(
                      key: const ValueKey('num'),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withValues(alpha: 0.5)),
                          color: color.withValues(alpha: 0.08)),
                      child: Center(
                        child: Text(
                          '$index',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name as String,
                    style: TextStyle(
                      color: isCompleted ? AppColors.textHint : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (habit.currentStreak > 0)
                    Text(
                      '🔥 ${habit.currentStreak} días de racha',
                      style: const TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3))),
                child: Text('Completar',
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutine extends StatelessWidget {
  final String type;
  final Color color;
  const _EmptyRoutine({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = type == 'morning' ? 'mañana' : type == 'evening' ? 'noche' : 'hoy';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type == 'morning' ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                color: color, size: 56),
            const SizedBox(height: 20),
            Text('Sin hábitos de $label',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Ve a Hábitos y asigna el horario "$type" a los hábitos que quieras incluir en esta rutina.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
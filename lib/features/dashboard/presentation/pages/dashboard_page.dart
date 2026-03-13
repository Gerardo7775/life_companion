import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../agenda/presentation/state/task_bloc.dart';
import '../../../agenda/presentation/state/task_state.dart';
import '../../../habits/presentation/state/habit_bloc.dart';
import '../../../habits/presentation/state/habit_state.dart';
import '../../../finances/presentation/state/finance_bloc.dart';
import '../../../finances/presentation/state/finance_state.dart';
import '../../../gamification/presentation/state/gamification_bloc.dart';
import '../../../gamification/presentation/state/gamification_state.dart';
import '../../../wellness/presentation/state/wellness_bloc.dart';
import '../../../wellness/presentation/state/wellness_state.dart';
import '../../../agenda/domain/entities/task_entity.dart';
import '../../../habits/domain/entities/habit_entity.dart';
import '../../domain/services/suggestion_engine.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>().add(LoadTasksEvent());
      context.read<HabitBloc>().add(LoadHabitsEvent());
      context.read<FinanceBloc>().add(LoadFinancesEvent());
      context.read<GamificationBloc>().add(LoadGamificationEvent());
      context.read<WellnessBloc>().add(LoadWellnessEvent());
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días ☀️';
    if (hour < 19) return 'Buenas tardes 🌤️';
    return 'Buenas noches 🌙';
  }

  LinearGradient get _headerGradient {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppColors.morningGradient;
    if (hour < 19) return AppColors.afternoonGradient;
    return AppColors.eveningGradient;
  }

  @override
  Widget build(BuildContext context) {
    final taskState = context.watch<TaskBloc>().state;
    final habitState = context.watch<HabitBloc>().state;
    
    final tasks = taskState is TaskLoaded ? taskState.tasks : <TaskEntity>[];
    final habits = habitState is HabitLoaded ? habitState.habits : <HabitEntity>[];
    final suggestion = SuggestionEngine.generateSuggestion(tasks: tasks, habits: habits);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(gradient: _headerGradient),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'es')
                          .format(DateTime.now()),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _XpBarWidget(),
                    const SizedBox(height: 16),
                    GlassCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      backgroundColor: Colors.black.withValues(alpha: 0.2),
                      borderColor: Colors.white.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          Text(suggestion.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              suggestion.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cards de resumen rápido
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Expanded(child: _TaskSummaryCard()),
                    const SizedBox(width: 10),
                    Expanded(child: _HabitSummaryCard()),
                    const SizedBox(width: 10),
                    Expanded(child: _FinanceSummaryCard()),
                  ],
                ),
              ),
            ),

            // Card de Bienestar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: _WellnessCard(),
              ),
            ),

            // Accesos rápidos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accesos rápidos',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: _ShortcutButton(
                              icon: Icons.timer_rounded,
                              color: AppColors.primary,
                              label: 'Pomodoro',
                              onTap: () => context.go('/pomodoro'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: _ShortcutButton(
                              icon: Icons.wb_sunny_rounded,
                              color: AppColors.warning,
                              label: 'Rutina',
                              onTap: () => context.go('/routine?type=morning'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: _ShortcutButton(
                              icon: Icons.flag_rounded,
                              color: AppColors.accent,
                              label: 'Mis Metas',
                              onTap: () => context.go('/goals'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: _ShortcutButton(
                              icon: Icons.insights_rounded,
                              color: const Color(0xFF26C6DA),
                              label: 'Insights',
                              onTap: () => context.go('/wellness/insights'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tareas de hoy
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tareas pendientes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.go('/tasks'),
                      child: const Text(
                        'Ver todas',
                        style:
                            TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _TasksSliver(),

            // Hábitos de hoy
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hábitos de hoy',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.go('/habits'),
                      child: const Text(
                        'Ver todos',
                        style:
                            TextStyle(color: AppColors.catHabits, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _HabitsSliver(),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _XpBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (ctx, state) {
        if (state is! GamificationLoaded) return const SizedBox.shrink();
        final stats = state.stats;
        return GlassCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stats.levelName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${stats.totalXp} / ${stats.xpForNextLevel} XP',
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stats.levelProgress,
                        backgroundColor: AppColors.bgCardLight,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  Text(
                    '${stats.coins}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (ctx, state) {
        final pending = state is TaskLoaded
            ? state.tasks.where((t) => t.status != 'completed').length
            : 0;
        return _QuickCard(
          icon: Icons.task_alt_rounded,
          color: AppColors.catTasks,
          label: 'Tareas',
          value: '$pending',
          sub: 'pendientes',
          onTap: () => context.go('/tasks'),
        );
      },
    );
  }
}

class _HabitSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (ctx, state) {
        final done = state is HabitLoaded
            ? state.habits.where((h) => h.isCompletedToday).length
            : 0;
        final total = state is HabitLoaded ? state.habits.length : 0;
        return _QuickCard(
          icon: Icons.repeat_rounded,
          color: AppColors.catHabits,
          label: 'Hábitos',
          value: '$done/$total',
          sub: 'completados',
          onTap: () => context.go('/habits'),
        );
      },
    );
  }
}

class _FinanceSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (ctx, state) {
        final balance = state is FinanceLoaded ? state.totalBalance : 0.0;
        final fmt = NumberFormat.compact(locale: 'es_MX');
        return _QuickCard(
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.catFinance,
          label: 'Balance',
          value: '\$${fmt.format(balance)}',
          sub: 'MXN',
          onTap: () => context.go('/finances'),
        );
      },
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(12),
        borderColor: color.withValues(alpha: 0.3),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(color: AppColors.textHint, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wellness Card ─────────────────────────────────────────────────────────

class _WellnessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WellnessBloc, WellnessState>(
      builder: (ctx, state) {
        final loaded = state is WellnessLoaded ? state : null;
        final todayMood = loaded?.todayMood;
        final weekAvg = loaded?.weeklyAvgMood ?? 0.0;

        return GestureDetector(
          onTap: () => context.go('/wellness'),
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(16),
            borderColor: const Color(0xFF26C6DA).withValues(alpha: 0.3),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    todayMood?.moodEmoji ?? '❓',
                    key: ValueKey(todayMood?.moodEmoji),
                    style: const TextStyle(fontSize: 38),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayMood != null
                            ? 'Ánimo hoy: ${todayMood.moodLabel}'
                            : '¿Cómo te sientes hoy?',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weekAvg > 0
                            ? 'Promedio semanal: ${weekAvg.toStringAsFixed(1)}/5  •  Toca para ver más'
                            : 'Registra tu estado de ánimo y lleva un diario',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                      if (loaded != null && loaded.recentMoods.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: loaded.recentMoods.take(5).map((m) =>
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(m.moodEmoji,
                                style: const TextStyle(fontSize: 16)),
                            )
                          ).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF26C6DA).withValues(alpha: 0.1),
                      ),
                      child: const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF26C6DA), size: 20),
                    ),
                    if (todayMood == null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('nuevo',
                            style: TextStyle(
                                color: AppColors.error, fontSize: 9)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Shortcut Button ───────────────────────────────────────────────────────

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ShortcutButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        borderColor: color.withValues(alpha: 0.25),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tasks Sliver ──────────────────────────────────────────────────────────

class _TasksSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (ctx, state) {
        if (state is! TaskLoaded) {
          return const SliverToBoxAdapter(child: SizedBox(height: 60));
        }
        final pending =
            state.tasks.where((t) => t.status != 'completed').take(3).toList();
        if (pending.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GlassCard(
                margin: EdgeInsets.zero,
                child: const Text(
                  '¡Sin tareas pendientes hoy! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textHint),
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final task = pending[i];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: GlassCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.priority == 3
                              ? AppColors.error
                              : task.priority == 2
                                  ? AppColors.warning
                                  : AppColors.catWork,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (task.dueDate != null)
                        Text(
                          DateFormat('d MMM', 'es').format(task.dueDate!),
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            childCount: pending.length,
          ),
        );
      },
    );
  }
}

// ─── Habits Sliver ─────────────────────────────────────────────────────────

class _HabitsSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (ctx, state) {
        if (state is! HabitLoaded) {
          return const SliverToBoxAdapter(child: SizedBox(height: 60));
        }
        final habits = state.habits.take(4).toList();
        if (habits.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GlassCard(
                margin: EdgeInsets.zero,
                child: const Text(
                  'Aún no tienes hábitos. ¡Crea el primero! 💪',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textHint),
                ),
              ),
            ),
          );
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: habits.map((h) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: h.isCompletedToday
                        ? AppColors.catHabits.withValues(alpha: 0.2)
                        : AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: h.isCompletedToday
                          ? AppColors.catHabits.withValues(alpha: 0.5)
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        h.isCompletedToday
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: h.isCompletedToday
                            ? AppColors.catHabits
                            : AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        h.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: h.isCompletedToday
                              ? AppColors.catHabits
                              : AppColors.textSecondary,
                          fontWeight: h.isCompletedToday
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/goal_entities.dart';
import '../state/goals_bloc.dart';
import '../state/goals_state.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  @override
  void initState() {
    super.initState();
    context.read<GoalsBloc>().add(LoadGoalsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mis Metas 🎯',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 2),
                          const Text('Tus objetivos a largo plazo',
                              style: TextStyle(
                                  color: AppColors.textHint, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showCreateGoalDialog(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3))),
                        child: const Icon(Icons.add_rounded,
                            color: AppColors.primary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Lista de metas ───────────────────────────────────────────────
            BlocBuilder<GoalsBloc, GoalsState>(
              builder: (ctx, state) {
                if (state is GoalsLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )),
                  );
                }
                if (state is GoalsLoaded && state.goals.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyGoals());
                }
                if (state is GoalsLoaded) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _GoalCard(goal: state.goals[i]),
                      childCount: state.goals.length,
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? targetDate;
    String selectedColor = '#7C4DFF';

    final colors = [
      ('#7C4DFF', AppColors.primary),
      ('#00E5CC', AppColors.accent),
      ('#FF4B6E', AppColors.error),
      ('#FFD740', AppColors.warning),
      ('#00C896', AppColors.success),
      ('#00B0FF', AppColors.catWork),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.glassBorder,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nueva Meta',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration:
                        const InputDecoration(labelText: 'Título de la meta'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)'),
                  ),
                  const SizedBox(height: 16),
                  // Selector de color
                  const Text('Color:',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: colors.map((c) {
                      final isSelected = selectedColor == c.$1;
                      return GestureDetector(
                        onTap: () => setModal(() => selectedColor = c.$1),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.$2,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Fecha límite
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate:
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary)),
                          child: child!,
                        ),
                      );
                      if (d != null) setModal(() => targetDate = d);
                    },
                    child: GlassCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            targetDate != null
                                ? DateFormat('d MMMM yyyy', 'es')
                                    .format(targetDate!)
                                : 'Seleccionar fecha límite (opcional)',
                            style: TextStyle(
                                color: targetDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                                fontSize: 14),
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
                        context.read<GoalsBloc>().add(CreateGoalEvent(
                              GoalEntity(
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim().isEmpty
                                    ? null
                                    : descCtrl.text.trim(),
                                colorHex: selectedColor,
                                targetDate: targetDate,
                                createdAt: DateTime.now(),
                              ),
                            ));
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Crear Meta'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── GoalCard ──────────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final GoalEntity goal;
  const _GoalCard({required this.goal});

  Color get _color {
    try {
      return Color(int.parse(goal.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.targetDate?.difference(DateTime.now()).inDays;

    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.2),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) =>
          context.read<GoalsBloc>().add(DeleteGoalEvent(goal.id!)),
      child: GlassCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: EdgeInsets.zero,
        borderColor: _color.withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showGoalDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: _color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    if (daysLeft != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: daysLeft < 7
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          daysLeft >= 0 ? '$daysLeft días' : 'Vencida',
                          style: TextStyle(
                              color: daysLeft < 7
                                  ? AppColors.error
                                  : AppColors.textHint,
                              fontSize: 11),
                        ),
                      ),
                  ],
                ),
                if (goal.description != null) ...[
                  const SizedBox(height: 6),
                  Text(goal.description!,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          backgroundColor: AppColors.bgCardLight,
                          valueColor: AlwaysStoppedAnimation(_color),
                          minHeight: 7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${goal.completedItems}/${goal.totalItems}',
                      style: TextStyle(
                          color: _color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalDetail(BuildContext context) {
    final titleCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (ctx, scroll) => Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: _color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(goal.title,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold))),
                      Text('${(goal.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              color: _color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Items list
                Expanded(
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...goal.items.map((item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Checkbox(
                              value: item.isCompleted,
                              activeColor: _color,
                              onChanged: (v) {
                                context.read<GoalsBloc>().add(
                                    ToggleGoalItemEvent(item.id!, v ?? false));
                                Navigator.of(ctx).pop();
                              },
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                  color: item.isCompleted
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.textHint, size: 18),
                              onPressed: () {
                                context
                                    .read<GoalsBloc>()
                                    .add(DeleteGoalItemEvent(item.id!));
                                Navigator.of(ctx).pop();
                              },
                            ),
                          )),
                      const SizedBox(height: 8),
                      // Agregar ítem
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: titleCtrl,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 14),
                              decoration: const InputDecoration(
                                  hintText: 'Agregar paso o tarea...',
                                  isDense: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12)),
                            onPressed: () {
                              if (titleCtrl.text.trim().isEmpty) return;
                              context.read<GoalsBloc>().add(AddGoalItemEvent(
                                    GoalItemEntity(
                                        goalId: goal.id!,
                                        itemType: 'custom',
                                        title: titleCtrl.text.trim()),
                                  ));
                              titleCtrl.clear();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('+ Agregar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1)),
            child: const Icon(Icons.flag_rounded,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Sin metas aún',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              '¡Define tus objetivos a largo plazo y divídelos en pasos accionables!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint, fontSize: 14)),
        ],
      ),
    );
  }
}

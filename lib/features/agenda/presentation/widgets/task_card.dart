import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onTap,
  });

  Color _priorityColor() {
    switch (task.priority) {
      case 4:
        return AppColors.error;
      case 3:
        return AppColors.warning;
      case 2:
        return AppColors.info;
      default:
        return AppColors.textHint;
    }
  }

  String _priorityLabel() {
    switch (task.priority) {
      case 4:
        return 'Urgente';
      case 3:
        return 'Alta';
      case 2:
        return 'Media';
      default:
        return 'Baja';
    }
  }

  Color _cardColor() {
    if (task.isCompleted) return AppColors.bgCard;
    final color = task.categoryColor != null
        ? Color(int.parse(task.categoryColor!.replaceFirst('#', '0xFF')))
        : AppColors.primary;
    return color.withValues(alpha: 0.08);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return GlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      borderColor: task.isCompleted
          ? AppColors.glassBorder
          : (_priorityColor().withValues(alpha: 0.4)),
      shadows: const [],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor(),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox circular
                GestureDetector(
                  onTap: task.isCompleted ? null : onComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppColors.success
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.success
                            : _priorityColor(),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (task.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description!,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Prioridad
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _priorityColor().withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _priorityLabel(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _priorityColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Categoría
                          if (task.categoryName != null)
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: task.categoryColor != null
                                        ? Color(
                                            int.parse(
                                              task.categoryColor!.replaceFirst(
                                                '#',
                                                '0xFF',
                                              ),
                                            ),
                                          )
                                        : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.categoryName!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          const Spacer(),
                          // Fecha
                          if (task.dueDate != null)
                            Text(
                              DateFormat('d MMM', 'es').format(task.dueDate!),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textHint,
                                fontWeight: isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.textHint,
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

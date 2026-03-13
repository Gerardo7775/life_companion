import 'package:equatable/equatable.dart';

// ─── Goals Entities ──────────────────────────────────────────────────────────

class GoalEntity extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final String? iconName;
  final String colorHex;
  final DateTime? targetDate;
  final bool isCompleted;
  final DateTime createdAt;
  final List<GoalItemEntity> items;   // tareas/hábitos vinculados

  const GoalEntity({
    this.id,
    required this.title,
    this.description,
    this.iconName,
    this.colorHex = '#7C4DFF',
    this.targetDate,
    this.isCompleted = false,
    required this.createdAt,
    this.items = const [],
  });

  int get totalItems => items.length;
  int get completedItems => items.where((i) => i.isCompleted).length;
  double get progress =>
      totalItems == 0 ? 0 : completedItems / totalItems;

  GoalEntity copyWith({
    int? id,
    String? title,
    String? description,
    String? iconName,
    String? colorHex,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? createdAt,
    List<GoalItemEntity>? items,
  }) =>
      GoalEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        iconName: iconName ?? this.iconName,
        colorHex: colorHex ?? this.colorHex,
        targetDate: targetDate ?? this.targetDate,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [id, title, isCompleted, progress];
}

class GoalItemEntity extends Equatable {
  final int? id;
  final int goalId;
  final String itemType; // 'task' | 'habit' | 'custom'
  final int? linkedId;   // id de la tarea o hábito vinculado
  final String title;
  final bool isCompleted;

  const GoalItemEntity({
    this.id,
    required this.goalId,
    required this.itemType,
    this.linkedId,
    required this.title,
    this.isCompleted = false,
  });

  GoalItemEntity copyWith({bool? isCompleted}) =>
      GoalItemEntity(
        id: id,
        goalId: goalId,
        itemType: itemType,
        linkedId: linkedId,
        title: title,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  List<Object?> get props => [id, goalId, itemType, linkedId, isCompleted];
}

import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    super.id,
    required super.title,
    super.description,
    super.categoryId,
    super.categoryName,
    super.categoryColor,
    super.dueDate,
    super.priority,
    super.status,
    super.estimatedDuration,
    super.completedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String?,
    categoryId: map['category_id'] as int?,
    categoryName: map['cat_name'] as String?,
    categoryColor: map['cat_color'] as String?,
    dueDate: map['due_date'] != null
        ? DateTime.tryParse(map['due_date'])
        : null,
    priority: map['priority'] as int? ?? 1,
    status: map['status'] as String? ?? 'pending',
    estimatedDuration: map['estimated_duration'] as int?,
    completedAt: map['completed_at'] != null
        ? DateTime.tryParse(map['completed_at'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'category_id': categoryId,
    'due_date': dueDate?.toIso8601String(),
    'priority': priority,
    'status': status,
    'estimated_duration': estimatedDuration,
    'completed_at': completedAt?.toIso8601String(),
  };

  factory TaskModel.fromEntity(TaskEntity e) => TaskModel(
    id: e.id,
    title: e.title,
    description: e.description,
    categoryId: e.categoryId,
    categoryName: e.categoryName,
    categoryColor: e.categoryColor,
    dueDate: e.dueDate,
    priority: e.priority,
    status: e.status,
    estimatedDuration: e.estimatedDuration,
    completedAt: e.completedAt,
  );
}

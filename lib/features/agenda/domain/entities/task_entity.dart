import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final DateTime? dueDate;
  final int priority; // 1:Baja 2:Media 3:Alta 4:Urgente
  final String status; // pending | in_progress | completed
  final int? estimatedDuration; // minutos
  final DateTime? completedAt;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.dueDate,
    this.priority = 1,
    this.status = 'pending',
    this.estimatedDuration,
    this.completedAt,
  });

  bool get isCompleted => status == 'completed';

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    int? categoryId,
    String? categoryName,
    String? categoryColor,
    DateTime? dueDate,
    int? priority,
    String? status,
    int? estimatedDuration,
    DateTime? completedAt,
  }) => TaskEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    categoryColor: categoryColor ?? this.categoryColor,
    dueDate: dueDate ?? this.dueDate,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    completedAt: completedAt ?? this.completedAt,
  );

  @override
  List<Object?> get props => [id, title, status, priority, dueDate];
}

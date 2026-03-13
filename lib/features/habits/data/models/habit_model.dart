import '../../domain/entities/habit_entity.dart';

class HabitModel extends HabitEntity {
  const HabitModel({
    super.id,
    required super.name,
    super.description,
    super.categoryId,
    super.categoryName,
    super.categoryColor,
    super.frequencyType,
    super.frequencyData,
    super.timeOfDay,
    super.reminderTime,
    super.targetValue,
    super.unit,
    super.isCompletedToday,
    super.achievedToday,
    super.currentStreak,
  });

  factory HabitModel.fromMap(Map<String, dynamic> m) => HabitModel(
    id: m['id'] as int?,
    name: m['name'] as String,
    description: m['description'] as String?,
    categoryId: m['category_id'] as int?,
    categoryName: m['cat_name'] as String?,
    categoryColor: m['cat_color'] as String?,
    frequencyType: m['frequency_type'] as String? ?? 'daily',
    frequencyData: m['frequency_data'] as String?,
    timeOfDay: m['time_of_day'] as String? ?? 'anytime',
    reminderTime: m['reminder_time'] as String?,
    targetValue: (m['target_value'] as num?)?.toDouble() ?? 1.0,
    unit: m['unit'] as String? ?? 'vez',
    isCompletedToday: (m['today_completed'] as int? ?? 0) == 1,
    achievedToday: (m['today_achieved'] as num?)?.toDouble() ?? 0.0,
    currentStreak: m['streak'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'category_id': categoryId,
    'frequency_type': frequencyType,
    'frequency_data': frequencyData,
    'time_of_day': timeOfDay,
    'reminder_time': reminderTime,
    'target_value': targetValue,
    'unit': unit,
  };

  factory HabitModel.fromEntity(HabitEntity e) => HabitModel(
    id: e.id,
    name: e.name,
    description: e.description,
    categoryId: e.categoryId,
    categoryName: e.categoryName,
    categoryColor: e.categoryColor,
    frequencyType: e.frequencyType,
    frequencyData: e.frequencyData,
    timeOfDay: e.timeOfDay,
    reminderTime: e.reminderTime,
    targetValue: e.targetValue,
    unit: e.unit,
    isCompletedToday: e.isCompletedToday,
    achievedToday: e.achievedToday,
    currentStreak: e.currentStreak,
  );
}

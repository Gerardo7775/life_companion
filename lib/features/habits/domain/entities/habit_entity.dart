import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String frequencyType; // daily | weekly | specific_days
  final String? frequencyData; // "1,3,5" para Lun, Mié, Vie
  final String timeOfDay; // morning | afternoon | evening | anytime
  final String? reminderTime; // "08:30"
  final double targetValue;
  final String unit;
  final bool isCompletedToday;
  final double achievedToday;
  final int currentStreak;

  const HabitEntity({
    this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.frequencyType = 'daily',
    this.frequencyData,
    this.timeOfDay = 'anytime',
    this.reminderTime,
    this.targetValue = 1,
    this.unit = 'vez',
    this.isCompletedToday = false,
    this.achievedToday = 0,
    this.currentStreak = 0,
  });

  HabitEntity copyWith({
    int? id,
    String? name,
    String? description,
    int? categoryId,
    String? categoryName,
    String? categoryColor,
    String? frequencyType,
    String? frequencyData,
    String? timeOfDay,
    String? reminderTime,
    double? targetValue,
    String? unit,
    bool? isCompletedToday,
    double? achievedToday,
    int? currentStreak,
  }) => HabitEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    categoryColor: categoryColor ?? this.categoryColor,
    frequencyType: frequencyType ?? this.frequencyType,
    frequencyData: frequencyData ?? this.frequencyData,
    timeOfDay: timeOfDay ?? this.timeOfDay,
    reminderTime: reminderTime ?? this.reminderTime,
    targetValue: targetValue ?? this.targetValue,
    unit: unit ?? this.unit,
    isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    achievedToday: achievedToday ?? this.achievedToday,
    currentStreak: currentStreak ?? this.currentStreak,
  );

  @override
  List<Object?> get props =>
      [id, name, reminderTime, isCompletedToday, currentStreak];
}

class HabitLogEntity extends Equatable {
  final int? id;
  final int habitId;
  final DateTime logDate;
  final double achievedValue;
  final bool isCompleted;

  const HabitLogEntity({
    this.id,
    required this.habitId,
    required this.logDate,
    this.achievedValue = 0,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, habitId, logDate];
}

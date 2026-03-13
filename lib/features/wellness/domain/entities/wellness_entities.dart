import 'package:equatable/equatable.dart';

// ─── Mood Log ────────────────────────────────────────────────────────────────

class MoodLogEntity extends Equatable {
  final int? id;
  final int moodScore;     // 1-5
  final String moodEmoji;  // 😔 😟 😐 😊 😄
  final List<String> tags; // ['estresado', 'productivo', 'cansado' ...]
  final String? note;
  final DateTime loggedAt;

  const MoodLogEntity({
    this.id,
    required this.moodScore,
    required this.moodEmoji,
    this.tags = const [],
    this.note,
    required this.loggedAt,
  });

  String get moodLabel {
    return switch (moodScore) {
      1 => 'Muy mal',
      2 => 'Mal',
      3 => 'Regular',
      4 => 'Bien',
      5 => 'Excelente',
      _ => 'Regular',
    };
  }

  @override
  List<Object?> get props => [id, moodScore, loggedAt];
}

// ─── Journal Entry ───────────────────────────────────────────────────────────

class JournalEntryEntity extends Equatable {
  final int? id;
  final String title;
  final String content;
  final int? moodLogId;
  final int? moodScore;   // denormalizado para mostrar en lista
  final String? moodEmoji;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntryEntity({
    this.id,
    required this.title,
    required this.content,
    this.moodLogId,
    this.moodScore,
    this.moodEmoji,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntryEntity copyWith({
    int? id,
    String? title,
    String? content,
    int? moodLogId,
    int? moodScore,
    String? moodEmoji,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      JournalEntryEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        moodLogId: moodLogId ?? this.moodLogId,
        moodScore: moodScore ?? this.moodScore,
        moodEmoji: moodEmoji ?? this.moodEmoji,
        tags: tags ?? this.tags,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, title, createdAt];
}

// ─── Insight ─────────────────────────────────────────────────────────────────

class WellnessInsightEntity extends Equatable {
  final String type;     // 'habit_mood' | 'finance_mood' | 'streak_mood'
  final String title;
  final String body;
  final double correlation; // -1.0 a 1.0 o promedio descriptivo
  final String icon;
  final bool isPositive;

  const WellnessInsightEntity({
    required this.type,
    required this.title,
    required this.body,
    required this.correlation,
    required this.icon,
    required this.isPositive,
  });

  @override
  List<Object?> get props => [type, title];
}

// ─── Mood constants ───────────────────────────────────────────────────────────

class MoodData {
  static const List<(int, String, String)> moods = [
    (1, '😔', 'Muy mal'),
    (2, '😟', 'Mal'),
    (3, '😐', 'Regular'),
    (4, '😊', 'Bien'),
    (5, '😄', 'Excelente'),
  ];

  static const List<String> commonTags = [
    'productivo', 'estresado', 'cansado', 'feliz', 'ansioso',
    'motivado', 'tranquilo', 'triste', 'energético', 'relajado',
  ];
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/wellness_entities.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class WellnessEvent extends Equatable {
  const WellnessEvent();
  @override
  List<Object?> get props => [];
}

class LoadWellnessEvent extends WellnessEvent {}

class LogMoodEvent extends WellnessEvent {
  final int moodScore;
  final String moodEmoji;
  final List<String> tags;
  final String? note;
  const LogMoodEvent({
    required this.moodScore,
    required this.moodEmoji,
    this.tags = const [],
    this.note,
  });
  @override
  List<Object?> get props => [moodScore, moodEmoji];
}

class SaveJournalEntryEvent extends WellnessEvent {
  final JournalEntryEntity entry;
  const SaveJournalEntryEvent(this.entry);
  @override
  List<Object?> get props => [entry];
}

class DeleteJournalEntryEvent extends WellnessEvent {
  final int entryId;
  const DeleteJournalEntryEvent(this.entryId);
  @override
  List<Object?> get props => [entryId];
}

class LoadInsightsEvent extends WellnessEvent {}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class WellnessState extends Equatable {
  const WellnessState();
  @override
  List<Object?> get props => [];
}

class WellnessInitial extends WellnessState {}
class WellnessLoading extends WellnessState {}
class WellnessError extends WellnessState {
  final String message;
  const WellnessError(this.message);
  @override
  List<Object?> get props => [message];
}

class WellnessLoaded extends WellnessState {
  final MoodLogEntity? todayMood;           // puede ser null si no se ha registrado
  final List<MoodLogEntity> recentMoods;    // últimos 7 días
  final List<JournalEntryEntity> journal;
  final double weeklyAvgMood;
  const WellnessLoaded({
    this.todayMood,
    required this.recentMoods,
    required this.journal,
    required this.weeklyAvgMood,
  });
  @override
  List<Object?> get props => [todayMood, recentMoods, journal, weeklyAvgMood];
}

class MoodLoggedSuccess extends WellnessLoaded {
  const MoodLoggedSuccess({
    super.todayMood,
    required super.recentMoods,
    required super.journal,
    required super.weeklyAvgMood,
  });
}

class JournalSavedSuccess extends WellnessLoaded {
  const JournalSavedSuccess({
    super.todayMood,
    required super.recentMoods,
    required super.journal,
    required super.weeklyAvgMood,
  });
}

class InsightsLoaded extends WellnessState {
  final List<WellnessInsightEntity> insights;
  const InsightsLoaded(this.insights);
  @override
  List<Object?> get props => [insights];
}

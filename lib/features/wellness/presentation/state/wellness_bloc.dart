import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/wellness_local_datasource.dart';
import 'wellness_state.dart';

class WellnessBloc extends Bloc<WellnessEvent, WellnessState> {
  final WellnessLocalDataSource _dataSource;

  WellnessBloc(this._dataSource) : super(WellnessInitial()) {
    on<LoadWellnessEvent>(_onLoad);
    on<LogMoodEvent>(_onLogMood);
    on<SaveJournalEntryEvent>(_onSaveJournal);
    on<DeleteJournalEntryEvent>(_onDeleteJournal);
    on<LoadInsightsEvent>(_onLoadInsights);
  }

  Future<void> _onLoad(
      LoadWellnessEvent event, Emitter<WellnessState> emit) async {
    emit(WellnessLoading());
    try {
      final todayMood = await _dataSource.getTodayMood();
      final recentMoods = await _dataSource.getRecentMoods();
      final journal = await _dataSource.getJournalEntries();
      final weekAvg = await _dataSource.getWeeklyAvgMood();
      emit(WellnessLoaded(
        todayMood: todayMood,
        recentMoods: recentMoods,
        journal: journal,
        weeklyAvgMood: weekAvg,
      ));
    } catch (e) {
      emit(WellnessError(e.toString()));
    }
  }

  Future<void> _onLogMood(
      LogMoodEvent event, Emitter<WellnessState> emit) async {
    try {
      await _dataSource.logMood(
        moodScore: event.moodScore,
        moodEmoji: event.moodEmoji,
        tags: event.tags,
        note: event.note,
      );
      final todayMood = await _dataSource.getTodayMood();
      final recentMoods = await _dataSource.getRecentMoods();
      final journal = await _dataSource.getJournalEntries();
      final weekAvg = await _dataSource.getWeeklyAvgMood();
      emit(MoodLoggedSuccess(
        todayMood: todayMood,
        recentMoods: recentMoods,
        journal: journal,
        weeklyAvgMood: weekAvg,
      ));
    } catch (e) {
      emit(WellnessError(e.toString()));
    }
  }

  Future<void> _onSaveJournal(
      SaveJournalEntryEvent event, Emitter<WellnessState> emit) async {
    try {
      await _dataSource.saveJournalEntry(event.entry);
      final todayMood = await _dataSource.getTodayMood();
      final recentMoods = await _dataSource.getRecentMoods();
      final journal = await _dataSource.getJournalEntries();
      final weekAvg = await _dataSource.getWeeklyAvgMood();
      emit(JournalSavedSuccess(
        todayMood: todayMood,
        recentMoods: recentMoods,
        journal: journal,
        weeklyAvgMood: weekAvg,
      ));
    } catch (e) {
      emit(WellnessError(e.toString()));
    }
  }

  Future<void> _onDeleteJournal(
      DeleteJournalEntryEvent event, Emitter<WellnessState> emit) async {
    try {
      await _dataSource.deleteJournalEntry(event.entryId);
      add(LoadWellnessEvent());
    } catch (e) {
      emit(WellnessError(e.toString()));
    }
  }

  Future<void> _onLoadInsights(
      LoadInsightsEvent event, Emitter<WellnessState> emit) async {
    try {
      final insights = await _dataSource.generateInsights();
      emit(InsightsLoaded(insights));
    } catch (e) {
      emit(WellnessError(e.toString()));
    }
  }
}

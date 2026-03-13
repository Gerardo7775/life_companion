import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/gamification_local_datasource.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationLocalDataSource _dataSource;

  GamificationBloc(this._dataSource) : super(GamificationInitial()) {
    on<LoadGamificationEvent>(_onLoad);
    on<AddXpEvent>(_onAddXp);
    on<PenalizeXpEvent>(_onPenalizeXp);
    on<RedeemRewardEvent>(_onRedeem);
  }

  Future<void> _onLoad(
    LoadGamificationEvent event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());
    try {
      final stats = await _dataSource.getUserStats();
      final rewards = await _dataSource.getRewards();
      final logs = await _dataSource.getRecentXpLogs();
      emit(
          GamificationLoaded(stats: stats, rewards: rewards, recentLogs: logs));
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onAddXp(
    AddXpEvent event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      await _dataSource.addXp(event.xp, event.coins, event.source);
      add(LoadGamificationEvent());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onPenalizeXp(
    PenalizeXpEvent event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      await _dataSource.removeXp(event.xpToLose, event.reason);
      add(LoadGamificationEvent());
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }

  Future<void> _onRedeem(
    RedeemRewardEvent event,
    Emitter<GamificationState> emit,
  ) async {
    try {
      final success = await _dataSource.redeemReward(event.rewardId);
      final stats = await _dataSource.getUserStats();
      final rewards = await _dataSource.getRewards();
      final logs = await _dataSource.getRecentXpLogs();
      if (success) {
        final name = rewards
                .where((r) => r.id == event.rewardId)
                .map((r) => r.name)
                .firstOrNull ??
            '';
        emit(
          RewardRedeemedSuccess(
            stats: stats,
            rewards: rewards,
            recentLogs: logs,
            rewardName: name,
          ),
        );
      } else {
        emit(
          RewardRedeemFailed(stats: stats, rewards: rewards, recentLogs: logs),
        );
      }
    } catch (e) {
      emit(GamificationError(e.toString()));
    }
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/gamification_entities.dart';

abstract class GamificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGamificationEvent extends GamificationEvent {}

class AddXpEvent extends GamificationEvent {
  final int xp;
  final int coins;
  final String source;
  AddXpEvent({required this.xp, required this.coins, required this.source});
  @override
  List<Object?> get props => [xp, coins, source];
}

class PenalizeXpEvent extends GamificationEvent {
  final int xpToLose;
  final String reason;
  PenalizeXpEvent({required this.xpToLose, required this.reason});
  @override
  List<Object?> get props => [xpToLose, reason];
}

class RedeemRewardEvent extends GamificationEvent {
  final int rewardId;
  RedeemRewardEvent(this.rewardId);
  @override
  List<Object?> get props => [rewardId];
}

// ── States ──────────────────────────────────────────────────

abstract class GamificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class GamificationLoaded extends GamificationState {
  final UserStatsEntity stats;
  final List<RewardEntity> rewards;
  final List<XpLogEntity> recentLogs;

  GamificationLoaded({
    required this.stats,
    required this.rewards,
    required this.recentLogs,
  });

  @override
  List<Object?> get props => [stats, rewards, recentLogs];
}

class GamificationError extends GamificationState {
  final String message;
  GamificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class RewardRedeemedSuccess extends GamificationLoaded {
  final String rewardName;
  RewardRedeemedSuccess({
    required super.stats,
    required super.rewards,
    required super.recentLogs,
    required this.rewardName,
  });
  @override
  List<Object?> get props => [stats, rewards, rewardName];
}

class RewardRedeemFailed extends GamificationLoaded {
  RewardRedeemFailed({
    required super.stats,
    required super.rewards,
    required super.recentLogs,
  });
}

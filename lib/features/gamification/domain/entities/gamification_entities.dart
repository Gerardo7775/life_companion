import 'package:equatable/equatable.dart';

class UserStatsEntity extends Equatable {
  final int? id;
  final int totalXp;
  final int coins;
  final int currentStreak;
  final int longestStreak;
  final int tasksCompleted;
  final int habitsCompleted;
  final String level;

  const UserStatsEntity({
    this.id,
    this.totalXp = 0,
    this.coins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.tasksCompleted = 0,
    this.habitsCompleted = 0,
    this.level = 'Principiante',
  });

  int get xpForNextLevel {
    final thresholds = [100, 300, 600, 1000, 1500, 2200, 3000];
    for (final t in thresholds) {
      if (totalXp < t) return t;
    }
    return totalXp + 1000;
  }

  double get levelProgress {
    final next = xpForNextLevel;
    final thresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000];
    int prev = 0;
    for (int i = 1; i < thresholds.length; i++) {
      if (totalXp < thresholds[i]) {
        prev = thresholds[i - 1];
        break;
      }
    }
    final range = next - prev;
    if (range <= 0) return 1.0;
    return ((totalXp - prev) / range).clamp(0.0, 1.0);
  }

  String get levelName {
    if (totalXp < 100) return 'Principiante';
    if (totalXp < 300) return 'Aprendiz';
    if (totalXp < 600) return 'Intermedio';
    if (totalXp < 1000) return 'Avanzado';
    if (totalXp < 1500) return 'Experto';
    if (totalXp < 2200) return 'Maestro';
    if (totalXp < 3000) return 'Élite';
    return 'Legendario';
  }

  @override
  List<Object?> get props => [id, totalXp, coins, currentStreak];
}

class RewardEntity extends Equatable {
  final int? id;
  final String name;
  final String description;
  final int costCoins;
  final String iconName;
  final bool isRedeemed;
  final DateTime? redeemedAt;

  const RewardEntity({
    this.id,
    required this.name,
    required this.description,
    required this.costCoins,
    this.iconName = 'emoji_events',
    this.isRedeemed = false,
    this.redeemedAt,
  });

  @override
  List<Object?> get props => [id, name, costCoins, isRedeemed];
}

class XpLogEntity extends Equatable {
  final int? id;
  final int amount;
  final String source;
  final DateTime createdAt;

  const XpLogEntity({
    this.id,
    required this.amount,
    required this.source,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, source, createdAt];
}

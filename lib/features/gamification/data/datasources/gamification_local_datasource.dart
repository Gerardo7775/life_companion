import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/gamification_entities.dart';

class GamificationLocalDataSource {
  final DatabaseHelper dbHelper;
  GamificationLocalDataSource(this.dbHelper);

  Future<UserStatsEntity> getUserStats() async {
    final db = await dbHelper.database;
    final maps = await db.query('UserStats', where: 'id = 1');
    if (maps.isEmpty) {
      return const UserStatsEntity();
    }
    final m = maps.first;
    final xp = (m['current_xp'] as int?) ?? 0;
    final coins = (m['coins'] as int?) ?? 0;
    final streak = (m['current_streak'] as int?) ?? 0;

    // Contar tareas completadas
    final taskCount = Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM Tasks WHERE status = 'completed'",
          ),
        ) ??
        0;

    // Contar hábitos completados (logs)
    final habitCount = Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM HabitLogs WHERE is_completed = 1",
          ),
        ) ??
        0;

    final stats = UserStatsEntity(
      id: 1,
      totalXp: xp,
      coins: coins,
      currentStreak: streak,
      tasksCompleted: taskCount,
      habitsCompleted: habitCount,
    );
    return UserStatsEntity(
      id: stats.id,
      totalXp: stats.totalXp,
      coins: stats.coins,
      currentStreak: stats.currentStreak,
      tasksCompleted: stats.tasksCompleted,
      habitsCompleted: stats.habitsCompleted,
      level: stats.levelName,
    );
  }

  Future<void> addXp(int xp, int coins, String source) async {
    final db = await dbHelper.database;
    await db.rawUpdate(
      'UPDATE UserStats SET current_xp = current_xp + ?, coins = coins + ? WHERE id = 1',
      [xp, coins],
    );
    await db.insert('XpLogs', {
      'source_type': source,
      'source_id': 0,
      'xp_earned': xp,
      'coins_earned': coins,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeXp(int xp, String source) async {
    final db = await dbHelper.database;
    await db.rawUpdate(
      'UPDATE UserStats SET current_xp = MAX(0, current_xp - ?) WHERE id = 1',
      [xp],
    );
    await db.insert('XpLogs', {
      'source_type': source,
      'source_id': 0,
      'xp_earned': -xp,
      'coins_earned': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<RewardEntity>> getRewards() async {
    final db = await dbHelper.database;
    final maps = await db.query('Rewards', orderBy: 'cost ASC');
    return maps
        .map(
          (m) => RewardEntity(
            id: m['id'] as int?,
            name: m['title'] as String,
            description: m['description'] as String? ?? '',
            costCoins: m['cost'] as int,
            iconName: m['icon_name'] as String? ?? 'emoji_events',
            isRedeemed: (m['is_redeemed'] as int?) == 1,
            redeemedAt: m['redeemed_at'] != null
                ? DateTime.tryParse(m['redeemed_at'] as String)
                : null,
          ),
        )
        .toList();
  }

  Future<bool> redeemReward(int rewardId) async {
    final db = await dbHelper.database;
    final stats = await getUserStats();
    final reward = await db.query(
      'Rewards',
      where: 'id = ?',
      whereArgs: [rewardId],
    );
    if (reward.isEmpty) return false;
    final cost = reward.first['cost'] as int;
    if (stats.coins < cost) return false;

    await db.rawUpdate(
      'UPDATE UserStats SET coins = coins - ? WHERE id = 1',
      [cost],
    );
    await db.update(
      'Rewards',
      {
        'is_redeemed': 1,
        'redeemed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [rewardId],
    );
    return true;
  }

  Future<List<XpLogEntity>> getRecentXpLogs({int limit = 10}) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'XpLogs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps
        .map(
          (m) => XpLogEntity(
            id: m['id'] as int?,
            amount: (m['xp_earned'] as int?) ?? 0,
            source: m['source_type'] as String? ?? '',
            createdAt: DateTime.tryParse(
                  m['created_at'] as String? ?? '',
                ) ??
                DateTime.now(),
          ),
        )
        .toList();
  }
}

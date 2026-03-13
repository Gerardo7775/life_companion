import '../../../../core/storage/database_helper.dart';

class PomodoroLocalDataSource {
  final DatabaseHelper _db;
  PomodoroLocalDataSource(this._db);

  Future<void> saveSession({
    int? taskId,
    String? taskTitle,
    required int durationMinutes,
    required String sessionType,
  }) async {
    final db = await _db.database;
    await db.insert('PomodoroSessions', {
      'task_id': taskId,
      'task_title': taskTitle,
      'duration_minutes': durationMinutes,
      'session_type': sessionType,
      'is_completed': 1,
      'started_at': DateTime.now()
          .subtract(Duration(minutes: durationMinutes))
          .toIso8601String(),
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> getCompletedSessionsToday() async {
    final db = await _db.database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final res = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM PomodoroSessions "
      "WHERE session_type='work' AND is_completed=1 AND completed_at >= ?",
      [start],
    );
    return (res.first['cnt'] as int?) ?? 0;
  }

  Future<int> getTotalMinutesToday() async {
    final db = await _db.database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final res = await db.rawQuery(
      "SELECT COALESCE(SUM(duration_minutes), 0) as total "
      "FROM PomodoroSessions "
      "WHERE session_type='work' AND is_completed=1 AND completed_at >= ?",
      [start],
    );
    return (res.first['total'] as int?) ?? 0;
  }
}

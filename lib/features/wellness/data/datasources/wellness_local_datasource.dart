import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/wellness_entities.dart';

class WellnessLocalDataSource {
  final DatabaseHelper _db;
  WellnessLocalDataSource(this._db);

  // ── Mood Logs ──────────────────────────────────────────────────────────────

  Future<MoodLogEntity?> getTodayMood() async {
    final db = await _db.database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end   = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    final res = await db.query(
      'MoodLogs',
      where: 'logged_at >= ? AND logged_at <= ?',
      whereArgs: [start, end],
      orderBy: 'logged_at DESC',
      limit: 1,
    );
    if (res.isEmpty) return null;
    return _mapMood(res.first);
  }

  Future<List<MoodLogEntity>> getRecentMoods({int days = 7}) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final res = await db.query(
      'MoodLogs',
      where: 'logged_at >= ?',
      whereArgs: [since],
      orderBy: 'logged_at ASC',
    );
    return res.map(_mapMood).toList();
  }

  Future<List<MoodLogEntity>> getMoodsLast30Days() async =>
      getRecentMoods(days: 30);

  Future<MoodLogEntity> logMood({
    required int moodScore,
    required String moodEmoji,
    required List<String> tags,
    String? note,
  }) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('MoodLogs', {
      'mood_score': moodScore,
      'mood_emoji': moodEmoji,
      'tags': tags.join(','),
      'note': note,
      'logged_at': now,
    });
    return MoodLogEntity(
      id: id,
      moodScore: moodScore,
      moodEmoji: moodEmoji,
      tags: tags,
      note: note,
      loggedAt: DateTime.now(),
    );
  }

  MoodLogEntity _mapMood(Map<String, dynamic> m) => MoodLogEntity(
    id: m['id'] as int?,
    moodScore: m['mood_score'] as int,
    moodEmoji: m['mood_emoji'] as String,
    tags: ((m['tags'] as String?) ?? '').split(',').where((t) => t.isNotEmpty).toList(),
    note: m['note'] as String?,
    loggedAt: DateTime.parse(m['logged_at'] as String),
  );

  // ── Journal ────────────────────────────────────────────────────────────────

  Future<List<JournalEntryEntity>> getJournalEntries({int limit = 30}) async {
    final db = await _db.database;
    final res = await db.query(
      'JournalEntries',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return res.map(_mapJournal).toList();
  }

  Future<JournalEntryEntity> saveJournalEntry(JournalEntryEntity entry) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    if (entry.id == null) {
      final id = await db.insert('JournalEntries', {
        'title': entry.title,
        'content': entry.content,
        'mood_log_id': entry.moodLogId,
        'mood_score': entry.moodScore,
        'mood_emoji': entry.moodEmoji,
        'tags': entry.tags.join(','),
        'created_at': now,
        'updated_at': now,
      });
      return entry.copyWith(id: id, createdAt: DateTime.now(), updatedAt: DateTime.now());
    } else {
      await db.update(
        'JournalEntries',
        {
          'title': entry.title,
          'content': entry.content,
          'tags': entry.tags.join(','),
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      return entry.copyWith(updatedAt: DateTime.now());
    }
  }

  Future<void> deleteJournalEntry(int id) async {
    final db = await _db.database;
    await db.delete('JournalEntries', where: 'id = ?', whereArgs: [id]);
  }

  JournalEntryEntity _mapJournal(Map<String, dynamic> m) => JournalEntryEntity(
    id: m['id'] as int?,
    title: m['title'] as String,
    content: m['content'] as String,
    moodLogId: m['mood_log_id'] as int?,
    moodScore: m['mood_score'] as int?,
    moodEmoji: m['mood_emoji'] as String?,
    tags: ((m['tags'] as String?) ?? '').split(',').where((t) => t.isNotEmpty).toList(),
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  // ── Insights / Correlaciones ───────────────────────────────────────────────

  Future<List<WellnessInsightEntity>> generateInsights() async {
    final db = await _db.database;
    final insights = <WellnessInsightEntity>[];
    final since = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

    // 1. Promedio general de ánimo
    final avgRes = await db.rawQuery(
      'SELECT AVG(mood_score) as avg FROM MoodLogs WHERE logged_at >= ?', [since],
    );
    final avg = (avgRes.first['avg'] as double?) ?? 0.0;
    if (avg > 0) {
      final label = avg >= 4.0 ? 'Excelente' : avg >= 3.0 ? 'Regular' : 'Bajo';
      insights.add(WellnessInsightEntity(
        type: 'avg_mood',
        title: 'Tu ánimo este mes',
        body: 'Tu puntuación promedio es ${avg.toStringAsFixed(1)}/5 — $label.',
        correlation: avg / 5.0,
        icon: avg >= 4 ? '😄' : avg >= 3 ? '😐' : '😟',
        isPositive: avg >= 3.5,
      ));
    }

    // 2. Correlación hábitos → ánimo
    final habitMoodRes = await db.rawQuery('''
      SELECT 
        DATE(m.logged_at) as day,
        m.mood_score,
        (SELECT COUNT(*) FROM HabitLogs l 
         WHERE DATE(l.log_date) = DATE(m.logged_at) AND l.is_completed = 1) as habits_done
      FROM MoodLogs m
      WHERE m.logged_at >= ?
      ORDER BY day
    ''', [since]);

    if (habitMoodRes.length >= 5) {
      double sumHighHabits = 0, cntHigh = 0, sumLowHabits = 0, cntLow = 0;
      for (final row in habitMoodRes) {
        final done = (row['habits_done'] as int?) ?? 0;
        final mood = (row['mood_score'] as int?) ?? 0;
        if (done >= 3) { sumHighHabits += mood; cntHigh++; }
        else { sumLowHabits += mood; cntLow++; }
      }
      if (cntHigh > 0 && cntLow > 0) {
        final avgHigh = sumHighHabits / cntHigh;
        final avgLow  = sumLowHabits / cntLow;
        final diff = avgHigh - avgLow;
        if (diff.abs() > 0.3) {
          insights.add(WellnessInsightEntity(
            type: 'habit_mood',
            title: 'Hábitos y bienestar',
            body: 'Los días que completas 3+ hábitos, tu ánimo es ${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} puntos ${diff > 0 ? 'mejor' : 'peor'} en promedio.',
            correlation: diff / 5.0,
            icon: '💪',
            isPositive: diff > 0,
          ));
        }
      }
    }

    // 3. Mejor día de la semana
    final dayMoodRes = await db.rawQuery('''
      SELECT CAST(strftime('%w', logged_at) as INTEGER) as dow,
             AVG(mood_score) as avg_mood
      FROM MoodLogs
      WHERE logged_at >= ?
      GROUP BY dow
      ORDER BY avg_mood DESC
      LIMIT 1
    ''', [since]);
    if (dayMoodRes.isNotEmpty) {
      final dow = (dayMoodRes.first['dow'] as int?) ?? 0;
      final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
      final dayAvg = (dayMoodRes.first['avg_mood'] as double?) ?? 0;
      if (dayAvg > 0) {
        insights.add(WellnessInsightEntity(
          type: 'best_day',
          title: 'Mejor día de la semana',
          body: 'Los ${dayNames[dow]} sueles estar de mejor ánimo (${dayAvg.toStringAsFixed(1)}/5 en promedio).',
          correlation: dayAvg / 5.0,
          icon: '📅',
          isPositive: true,
        ));
      }
    }

    // 4. Promedio de entradas de diario
    final journalCount = (await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM JournalEntries WHERE created_at >= ?', [since],
    )).first['cnt'] as int? ?? 0;
    if (journalCount > 0) {
      insights.add(WellnessInsightEntity(
        type: 'journal_streak',
        title: 'Reflexión activa',
        body: 'Has escrito $journalCount entradas en el diario este mes. La escritura reflexiva mejora el bienestar.',
        correlation: (journalCount / 30.0).clamp(0, 1),
        icon: '📓',
        isPositive: true,
      ));
    }

    if (insights.isEmpty) {
      insights.add(WellnessInsightEntity(
        type: 'empty',
        title: 'Aún sin datos suficientes',
        body: 'Registra tu ánimo por al menos 5 días para ver correlaciones personalizadas.',
        correlation: 0,
        icon: '🔍',
        isPositive: true,
      ));
    }

    return insights;
  }

  Future<double> getWeeklyAvgMood() async {
    final db = await _db.database;
    final since = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
    final res = await db.rawQuery(
      'SELECT AVG(mood_score) as avg FROM MoodLogs WHERE logged_at >= ?', [since],
    );
    return (res.first['avg'] as double?) ?? 0.0;
  }
}

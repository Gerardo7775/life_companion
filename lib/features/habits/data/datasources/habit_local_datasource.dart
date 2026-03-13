import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_helper.dart';
import '../models/habit_model.dart';

class HabitLocalDataSource {
  final DatabaseHelper dbHelper;
  HabitLocalDataSource(this.dbHelper);

  Future<List<HabitModel>> getHabits() async {
    final db = await dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await db.rawQuery(
      '''
      SELECT h.*, c.name as cat_name, c.color_hex as cat_color,
             hl.is_completed as today_completed, hl.achieved_value as today_achieved,
             (SELECT COUNT(*) FROM HabitLogs hl2
              WHERE hl2.habit_id = h.id AND hl2.is_completed = 1
              AND hl2.log_date >= date('now', '-30 days')) as streak
      FROM Habits h
      LEFT JOIN Categories c ON h.category_id = c.id
      LEFT JOIN HabitLogs hl ON hl.habit_id = h.id AND hl.log_date = ?
    ''',
      [today],
    );
    return maps.map((m) => HabitModel.fromMap(m)).toList();
  }

  Future<HabitModel> insertHabit(HabitModel habit) async {
    final db = await dbHelper.database;
    final id = await db.insert(
      'Habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return habit.copyWith(id: id) as HabitModel;
  }

  Future<bool> deleteHabit(int id) async {
    final db = await dbHelper.database;
    final rows = await db.delete('Habits', where: 'id = ?', whereArgs: [id]);
    return rows > 0;
  }

  Future<HabitModel?> logHabit(int habitId, double value) async {
    final db = await dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await db.query(
      'HabitLogs',
      where: 'habit_id = ? AND log_date = ?',
      whereArgs: [habitId, today],
    );

    final habit = await db.rawQuery(
      '''
      SELECT * FROM Habits WHERE id = ?
    ''',
      [habitId],
    );
    if (habit.isEmpty) return null;
    final targetVal = (habit.first['target_value'] as num?)?.toDouble() ?? 1.0;
    final newValue =
        (existing.isNotEmpty
            ? (existing.first['achieved_value'] as num).toDouble()
            : 0.0) +
        value;
    final isCompleted = newValue >= targetVal ? 1 : 0;

    if (existing.isNotEmpty) {
      await db.update(
        'HabitLogs',
        {'achieved_value': newValue, 'is_completed': isCompleted},
        where: 'habit_id = ? AND log_date = ?',
        whereArgs: [habitId, today],
      );
    } else {
      await db.insert('HabitLogs', {
        'habit_id': habitId,
        'log_date': today,
        'achieved_value': newValue,
        'is_completed': isCompleted,
      });
    }

    final updated = await getHabits();
    return updated.firstWhere(
      (h) => h.id == habitId,
      orElse: () => HabitModel.fromMap(habit.first),
    );
  }
}

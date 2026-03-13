import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_helper.dart';
import '../models/task_model.dart';

class TaskLocalDataSource {
  final DatabaseHelper dbHelper;
  TaskLocalDataSource(this.dbHelper);

  Future<List<TaskModel>> getTasks({String? status}) async {
    final db = await dbHelper.database;
    final query =
        '''
      SELECT t.*, c.name as cat_name, c.color_hex as cat_color
      FROM Tasks t
      LEFT JOIN Categories c ON t.category_id = c.id
      ${status != null ? "WHERE t.status = '$status'" : ''}
      ORDER BY t.priority DESC, t.due_date ASC
    ''';
    final maps = await db.rawQuery(query);
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<TaskModel?> getTaskById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      '''
      SELECT t.*, c.name as cat_name, c.color_hex as cat_color
      FROM Tasks t LEFT JOIN Categories c ON t.category_id = c.id
      WHERE t.id = ?
    ''',
      [id],
    );
    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  Future<TaskModel> insertTask(TaskModel task) async {
    final db = await dbHelper.database;
    final id = await db.insert(
      'Tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return task.copyWith(id: id) as TaskModel;
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final db = await dbHelper.database;
    await db.update(
      'Tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  Future<bool> deleteTask(int id) async {
    final db = await dbHelper.database;
    final rows = await db.delete('Tasks', where: 'id = ?', whereArgs: [id]);
    return rows > 0;
  }

  Future<TaskModel?> completeTask(int id) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'Tasks',
      {'status': 'completed', 'completed_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
    return getTaskById(id);
  }
}

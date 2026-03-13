import '../../../../core/storage/database_helper.dart';
import '../../domain/entities/goal_entities.dart';

class GoalsLocalDataSource {
  final DatabaseHelper _db;
  GoalsLocalDataSource(this._db);

  Future<List<GoalEntity>> getGoals() async {
    final db = await _db.database;
    final goalsRaw = await db.query('Goals', orderBy: 'created_at DESC');
    final List<GoalEntity> goals = [];
    for (final g in goalsRaw) {
      final items = await db.query(
        'GoalItems',
        where: 'goal_id = ?',
        whereArgs: [g['id']],
      );
      goals.add(GoalEntity(
        id: g['id'] as int?,
        title: g['title'] as String,
        description: g['description'] as String?,
        iconName: g['icon_name'] as String?,
        colorHex: (g['color_hex'] as String?) ?? '#7C4DFF',
        targetDate: g['target_date'] != null
            ? DateTime.tryParse(g['target_date'] as String)
            : null,
        isCompleted: (g['is_completed'] as int?) == 1,
        createdAt: DateTime.parse(g['created_at'] as String),
        items: items.map((i) => GoalItemEntity(
          id: i['id'] as int?,
          goalId: i['goal_id'] as int,
          itemType: i['item_type'] as String,
          linkedId: i['linked_id'] as int?,
          title: i['title'] as String,
          isCompleted: (i['is_completed'] as int?) == 1,
        )).toList(),
      ));
    }
    return goals;
  }

  Future<GoalEntity> createGoal(GoalEntity goal) async {
    final db = await _db.database;
    final id = await db.insert('Goals', {
      'title': goal.title,
      'description': goal.description,
      'icon_name': goal.iconName,
      'color_hex': goal.colorHex,
      'target_date': goal.targetDate?.toIso8601String(),
      'is_completed': 0,
      'created_at': goal.createdAt.toIso8601String(),
    });
    return goal.copyWith(id: id, items: []);
  }

  Future<void> updateGoal(GoalEntity goal) async {
    final db = await _db.database;
    await db.update(
      'Goals',
      {
        'title': goal.title,
        'description': goal.description,
        'icon_name': goal.iconName,
        'color_hex': goal.colorHex,
        'target_date': goal.targetDate?.toIso8601String(),
        'is_completed': goal.isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(int goalId) async {
    final db = await _db.database;
    await db.delete('GoalItems', where: 'goal_id = ?', whereArgs: [goalId]);
    await db.delete('Goals', where: 'id = ?', whereArgs: [goalId]);
  }

  Future<GoalItemEntity> addItem(GoalItemEntity item) async {
    final db = await _db.database;
    final id = await db.insert('GoalItems', {
      'goal_id': item.goalId,
      'item_type': item.itemType,
      'linked_id': item.linkedId,
      'title': item.title,
      'is_completed': 0,
    });
    return GoalItemEntity(
      id: id,
      goalId: item.goalId,
      itemType: item.itemType,
      linkedId: item.linkedId,
      title: item.title,
    );
  }

  Future<void> toggleItem(int itemId, bool completed) async {
    final db = await _db.database;
    await db.update(
      'GoalItems',
      {'is_completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> deleteItem(int itemId) async {
    final db = await _db.database;
    await db.delete('GoalItems', where: 'id = ?', whereArgs: [itemId]);
  }
}

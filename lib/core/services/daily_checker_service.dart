import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../storage/database_helper.dart';
import '../../features/gamification/data/datasources/gamification_local_datasource.dart';

class DailyCheckerService {
  static Future<void> checkDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastOpenedStr = prefs.getString('last_opened_date');
    
    if (lastOpenedStr != null && lastOpenedStr != todayStr) {
      final lastOpenedDate = DateTime.parse(lastOpenedStr);
      final todayDate = DateTime.parse(todayStr);
      
      // Si ha pasado al menos 1 día
      if (todayDate.isAfter(lastOpenedDate)) {
        await _processPastDays(lastOpenedDate, todayDate, prefs);
      }
    }
    
    await prefs.setString('last_opened_date', todayStr);
  }

  static Future<void> _processPastDays(DateTime fromDate, DateTime toDate, SharedPreferences prefs) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final gamificationDs = GamificationLocalDataSource(dbHelper);
    
    final isHardcore = prefs.getBool('hardcore_mode_enabled') ?? false;
    
    // Obtener todos los hábitos activos
    final habits = await db.query('Habits');
    
    int totalFailedHabits = 0;
    
    // Por cada día de diferencia, verificar hábitos
    for (var date = fromDate; date.isBefore(toDate); date = date.add(const Duration(days: 1))) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      for (final habit in habits) {
        final habitId = habit['id'] as int;
        // Revisar si hay un log completado para ese día
        final logs = await db.query(
          'HabitLogs',
          where: 'habit_id = ? AND log_date = ? AND is_completed = 1',
          whereArgs: [habitId, dateStr],
        );
        
        if (logs.isEmpty) {
          totalFailedHabits++;
          // current_streak se calcula dinámicamente en el datasource, no existe
          // como columna en Habits. Para "romper" la racha de un día pasado
          // insertamos un log de ese día con is_completed = 0 si no existía ninguno.
          await db.insert(
            'HabitLogs',
            {
              'habit_id': habitId,
              'log_date': dateStr,
              'achieved_value': 0,
              'is_completed': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    
    // Aplicar penalización si Hardcore está activo
    if (isHardcore && totalFailedHabits > 0) {
      final xpToLose = totalFailedHabits * 10;
      await gamificationDs.removeXp(xpToLose, 'hardcore_penalty');
    }
  }
}

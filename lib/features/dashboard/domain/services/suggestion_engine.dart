import '../../../habits/domain/entities/habit_entity.dart';
import '../../../agenda/domain/entities/task_entity.dart';

class SuggestionResult {
  final String message;
  final String icon;

  const SuggestionResult(this.message, this.icon);
}

class SuggestionEngine {
  static SuggestionResult generateSuggestion({
    required List<TaskEntity> tasks,
    required List<HabitEntity> habits,
  }) {
    final now = DateTime.now();
    final hour = now.hour;

    // 1. Tareas de máxima prioridad (urgentes y vencen pronto)
    final pendingTasks = tasks.where((t) => t.status != 'completed').toList();
    final highPriority = pendingTasks.where((t) => t.priority == 3).toList();

    if (highPriority.isNotEmpty) {
      // Ordenar por cercanía de fecha
      highPriority.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

      final topTask = highPriority.first;
      String verb = 'Avanza en';
      if (topTask.dueDate != null) {
        final diff = topTask.dueDate!.difference(now);
        if (diff.inHours < 24 && diff.inHours > 0) {
          verb = 'Queda poco tiempo para';
        } else if (diff.inHours <= 0) {
          verb = '¡Urgente! Completa';
        }
      }
      return SuggestionResult('$verb tu tarea prioritaria: "${topTask.title}"', '🔥');
    }

    // 2. Hábitos matutinos
    if (hour < 12) {
      final morningHabits = habits.where((h) => h.timeOfDay == 'morning').toList();
      final pendingMorning = morningHabits.where((h) => !h.isCompletedToday).toList();
      
      if (pendingMorning.isNotEmpty) {
        return SuggestionResult('¡Buen día! Empieza con energía completando tu hábito: "${pendingMorning.first.name}"', '🌅');
      } else if (morningHabits.isNotEmpty) {
        return const SuggestionResult('¡Excelente mañana! Ya completaste todos tus hábitos matutinos.', '☕');
      }
    }

    // 3. Hábitos de tarde/noche
    if (hour >= 18) {
      final eveningHabits = habits.where((h) => h.timeOfDay == 'evening').toList();
      final pendingEvening = eveningHabits.where((h) => !h.isCompletedToday).toList();

      if (pendingEvening.isNotEmpty) {
        return SuggestionResult('Antes de descansar, no olvides tu hábito: "${pendingEvening.first.name}"', '🌙');
      }
    }

    // 4. Analizar tiempo libre general si no hay urgencias y hay tareas pendientes
    if (pendingTasks.isNotEmpty) {
      final shortTasks = pendingTasks.where((t) => (t.estimatedDuration ?? 0) <= 15 && (t.estimatedDuration ?? 0) > 0).toList();
      if (shortTasks.isNotEmpty) {
        return SuggestionResult('¿Tienes un rato libre? Puedes liquidar rápidamente: "${shortTasks.first.title}"', '⚡');
      }
      return SuggestionResult('Sigue avanzando a buen ritmo. Tienes ${pendingTasks.length} tarea(s) pendiente(s).', '🎯');
    }

    // 5. Todo limpio
    return const SuggestionResult('¡Todo el día está despejado! Buen trabajo, tómate un descanso.', '🎉');
  }
}

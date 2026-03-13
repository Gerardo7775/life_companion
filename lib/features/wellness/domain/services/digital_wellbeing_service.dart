import 'package:app_usage/app_usage.dart';

class DigitalWellbeingService {
  static final DigitalWellbeingService instance =
      DigitalWellbeingService._internal();
  DigitalWellbeingService._internal();

  /// Solicita el permiso especial para leer Usage Stats vía Settings.
  Future<bool> checkAndRequestPermission() async {
    // Si la librería soporta verificar de forma directa o usamos PermissionHandler:
    // Permission.appUsage no siempre funciona en algunas versiones ya que es un permiso especial (AppOps).
    // Sin embargo, podemos verificar si hay datos o si cae en excepcion.
    try {
      final now = DateTime.now();
      // Un chequeo de 1 minuto para forzar excepción de permisos.
      await AppUsage()
          .getAppUsage(now.subtract(const Duration(minutes: 1)), now);
      return true; // Tenemos permisos
    } catch (e) {
      // Necesitamos pedírselo al usuario
      return false;
    }
  }

  /// Retorna las aplicaciones agrupadas y ordenadas del día actual
  Future<List<AppUsageInfo>> getDailyUsage() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final infos = await AppUsage().getAppUsage(startOfDay, now);

      // Filtrar apps sin tiempo y aquellas nativas genéricas si es posible (launchers, ui)
      final filtered = infos.where((info) => info.usage.inMinutes > 0).toList();

      // Ordenar de mayor a menor uso
      filtered.sort((a, b) => b.usage.compareTo(a.usage));

      return filtered;
    } on Exception catch (e) {
      if (e.toString().contains('usage')) {
        throw Exception(
            'Faltan permisos de uso de datos. Ve a Ajustes > Datos de Uso.');
      }
      throw Exception('Error al obtener uso de aplicaciones: $e');
    } catch (e) {
      throw Exception('Error al obtener uso de aplicaciones: $e');
    }
  }

  /// Calcula el tiempo en pantalla total del día actual sumando todas las apps excluyendo launchers típicos.
  Future<Duration> getTotalScreenTime() async {
    final apps = await getDailyUsage();
    Duration total = Duration.zero;
    for (var app in apps) {
      // Intentamos filtrar launchers / systemUI genéricos
      if (app.packageName.contains('launcher') ||
          app.packageName.contains('systemui') ||
          app.packageName == 'android') {
        continue;
      }
      total += app.usage;
    }
    return total;
  }
}

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio centralizado de notificaciones locales.
/// Llama a [init] una sola vez al arrancar la app.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // ─── IDs reservados ────────────────────────────────────────────────────
  static const int _moodReminderId = 9000;
  static const int _pomodoroWorkDoneId = 9001;
  static const int _pomodoroBreakDoneId = 9002;

  // ─── Canales Android ───────────────────────────────────────────────────
  static const _chHabits = AndroidNotificationChannel(
    'habits_reminders',
    'Recordatorios de Habitos',
    description: 'Notificaciones diarias para tus habitos',
    importance: Importance.high,
  );
  static const _chMood = AndroidNotificationChannel(
    'mood_reminder',
    'Recordatorio de Animo',
    description: 'Recordatorio diario para registrar tu estado de animo',
    importance: Importance.defaultImportance,
  );
  static const _chPomodoro = AndroidNotificationChannel(
    'pomodoro_alerts',
    'Alertas Pomodoro',
    description: 'Te avisa cuando termina una sesion de Pomodoro',
    importance: Importance.high,
  );

  // ─── Init ──────────────────────────────────────────────────────────────
  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_chHabits);
    await androidPlugin?.createNotificationChannel(_chMood);
    await androidPlugin?.createNotificationChannel(_chPomodoro);
  }

  // ─── Permisos ──────────────────────────────────────────────────────────
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await plugin?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await plugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  // ─── Preferencias ──────────────────────────────────────────────────────
  static const _keyHabits = 'notif_habits';
  static const _keyMood = 'notif_mood';
  static const _keyPomodoro = 'notif_pomodoro';

  Future<bool> isHabitsEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_keyHabits) ?? true;
  Future<bool> isMoodEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_keyMood) ?? true;
  Future<bool> isPomodoroEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_keyPomodoro) ?? true;

  Future<void> setHabitsEnabled(bool v) async {
    await (await SharedPreferences.getInstance()).setBool(_keyHabits, v);
    if (!v) await _plugin.cancelAll();
  }

  Future<void> setMoodEnabled(bool v) async {
    await (await SharedPreferences.getInstance()).setBool(_keyMood, v);
    if (v) {
      await scheduleMoodReminder();
    } else {
      await _plugin.cancel(_moodReminderId);
    }
  }

  Future<void> setPomodoroEnabled(bool v) async {
    await (await SharedPreferences.getInstance()).setBool(_keyPomodoro, v);
  }

  // ─── Habitos ───────────────────────────────────────────────────────────

  Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    if (!await isHabitsEnabled()) return;

    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      habitId,
      'Hora de tu habito',
      'Es momento de: $habitName!',
      t,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chHabits.id,
          _chHabits.name,
          channelDescription: _chHabits.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelHabitReminder(int habitId) async {
    await _plugin.cancel(habitId);
  }

  // ─── Animo ─────────────────────────────────────────────────────────────

  Future<void> scheduleMoodReminder() async {
    if (!await isMoodEnabled()) return;

    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      _moodReminderId,
      'Como estuvo tu dia?',
      'Tomate un momento para registrar tu estado de animo.',
      t,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chMood.id,
          _chMood.name,
          channelDescription: _chMood.description,
          importance: Importance.defaultImportance,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelMoodReminder() async {
    await _plugin.cancel(_moodReminderId);
  }

  // ─── Pomodoro ──────────────────────────────────────────────────────────

  Future<void> showPomodoroAlert({required bool isWorkPhase}) async {
    if (!await isPomodoroEnabled()) return;

    final id = isWorkPhase ? _pomodoroWorkDoneId : _pomodoroBreakDoneId;
    final title = isWorkPhase ? 'Sesion completada!' : 'Descanso terminado';
    final body = isWorkPhase
        ? 'Bien hecho. Toma un descanso.'
        : 'Listo! Vuelve a la concentracion.';

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chPomodoro.id,
          _chPomodoro.name,
          channelDescription: _chPomodoro.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}

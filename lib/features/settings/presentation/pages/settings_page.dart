import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _habitsNotif = true;
  bool _moodNotif = true;
  bool _pomodoroNotif = true;
  bool _hardcoreMode = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final ns = NotificationService.instance;
    final h = await ns.isHabitsEnabled();
    final m = await ns.isMoodEnabled();
    final p = await ns.isPomodoroEnabled();
    final prefs = await SharedPreferences.getInstance();
    final hc = prefs.getBool('hardcore_mode_enabled') ?? false;

    if (mounted) {
      setState(() {
        _habitsNotif = h;
        _moodNotif = m;
        _pomodoroNotif = p;
        _hardcoreMode = hc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajustes',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personaliza tu experiencia',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Sección Apariencia
                    _SectionHeader(title: 'Apariencia'),
                    const SizedBox(height: 8),
                    GlassCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.dark_mode_rounded,
                            iconColor: AppColors.primary,
                            title: 'Tema',
                            subtitle: 'Oscuro',
                            trailing: const Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: AppColors.textHint,
                            ),
                          ),
                          _Divider(),
                          _SettingsTile(
                            icon: Icons.language_rounded,
                            iconColor: AppColors.accent,
                            title: 'Idioma',
                            subtitle: 'Español',
                            trailing: const Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sección Hábitos
                    _SectionHeader(title: 'Hábitos y Tareas'),
                    const SizedBox(height: 8),
                    GlassCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.notifications_active_rounded,
                            iconColor: AppColors.warning,
                            title: 'Recordatorios',
                            subtitle: 'Mañana · Tarde · Noche',
                          ),
                          _Divider(),
                          _SettingsTile(
                            icon: Icons.today_rounded,
                            iconColor: AppColors.catTasks,
                            title: 'Inicio de semana',
                            subtitle: 'Lunes',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sección Finanzas
                    _SectionHeader(title: 'Finanzas'),
                    const SizedBox(height: 8),
                    GlassCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: _SettingsTile(
                        icon: Icons.attach_money_rounded,
                        iconColor: AppColors.catFinance,
                        title: 'Moneda',
                        subtitle: 'MXN — Peso Mexicano',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sección Gamificación
                    _SectionHeader(title: 'Gamificación'),
                    const SizedBox(height: 8),
                    GlassCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _NotifToggle(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.error,
                            title: 'Modo Hardcore',
                            subtitle: 'Perderás XP si no cumples tus hábitos',
                            value: _hardcoreMode,
                            onChanged: (v) async {
                              setState(() => _hardcoreMode = v);
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('hardcore_mode_enabled', v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sección Notificaciones
                    _SectionHeader(title: 'Notificaciones'),
                    const SizedBox(height: 8),
                    GlassCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _NotifToggle(
                            icon: Icons.repeat_rounded,
                            iconColor: AppColors.catHabits,
                            title: 'Recordatorios de hábitos',
                            subtitle: 'Notificación a la hora de cada hábito',
                            value: _habitsNotif,
                            onChanged: (v) async {
                              setState(() => _habitsNotif = v);
                              await NotificationService.instance
                                  .setHabitsEnabled(v);
                            },
                          ),
                          _Divider(),
                          _NotifToggle(
                            icon: Icons.sentiment_satisfied_alt_rounded,
                            iconColor: const Color(0xFF26C6DA),
                            title: 'Recordatorio de ánimo',
                            subtitle: 'Todos los días a las 21:00',
                            value: _moodNotif,
                            onChanged: (v) async {
                              setState(() => _moodNotif = v);
                              await NotificationService.instance
                                  .setMoodEnabled(v);
                            },
                          ),
                          _Divider(),
                          _NotifToggle(
                            icon: Icons.timer_rounded,
                            iconColor: AppColors.primary,
                            title: 'Alertas Pomodoro',
                            subtitle:
                                'Al terminar sesión de trabajo o descanso',
                            value: _pomodoroNotif,
                            onChanged: (v) async {
                              setState(() => _pomodoroNotif = v);
                              await NotificationService.instance
                                  .setPomodoroEnabled(v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sección Acerca de

                    _SectionHeader(title: 'Acerca de'),
                    const SizedBox(height: 8),
                    GlassCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.textSecondary,
                            title: 'Versión',
                            subtitle: '1.0.0',
                          ),
                          _Divider(),
                          _SettingsTile(
                            icon: Icons.favorite_rounded,
                            iconColor: AppColors.error,
                            title: 'Life Companion',
                            subtitle: 'Tu asistente de vida personal',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.glassBorder,
      indent: 56,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                      ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

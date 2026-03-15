import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_usage/app_usage.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/safe_pop_scope.dart';
import '../../../agenda/presentation/state/task_bloc.dart';
import '../../../agenda/presentation/state/task_state.dart';
import '../../../habits/presentation/state/habit_bloc.dart';
import '../../../habits/presentation/state/habit_state.dart';
import '../../../gamification/presentation/state/gamification_bloc.dart';
import '../../../gamification/presentation/state/gamification_state.dart';
import '../../domain/services/digital_wellbeing_service.dart';
import 'package:permission_handler/permission_handler.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  List<AppUsageInfo> _appUsages = [];
  Duration _totalScreenTime = Duration.zero;
  bool _isLoadingUsage = true;
  String? _usageError;

  @override
  void initState() {
    super.initState();
    _loadDigitalWellbeing();
  }

  Future<void> _loadDigitalWellbeing() async {
    setState(() {
      _isLoadingUsage = true;
      _usageError = null;
    });

    final service = DigitalWellbeingService.instance;
    final hasPermission = await service.checkAndRequestPermission();
    if (!hasPermission) {
      setState(() {
        _isLoadingUsage = false;
        _usageError = 'Se requieren permisos de Uso de Aplicaciones.';
      });
      return;
    }

    try {
      final usages = await service.getDailyUsage();
      final total = await service.getTotalScreenTime();
      if (mounted) {
        setState(() {
          // Tomar el top 5
          _appUsages = usages.take(5).toList();
          _totalScreenTime = total;
          _isLoadingUsage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUsage = false;
          _usageError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      fallbackRoute: '/',
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Hub de Estadísticas',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDigitalWellbeing,
        color: AppColors.primary,
        backgroundColor: Theme.of(context).cardTheme.color,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildProductivityCard(),
            const SizedBox(height: 20),
            _buildHabitsCard(),
            const SizedBox(height: 20),
            _buildGamificationCard(),
            const SizedBox(height: 20),
            _buildDigitalWellbeingCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildProductivityCard() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        int total = 0;
        int completed = 0;
        if (state is TaskLoaded) {
          total = state.tasks.length;
          completed = state.tasks.where((t) => t.isCompleted).length;
        }
        final double progress = total == 0 ? 0 : completed / total;

        return GlassCard(
          margin: EdgeInsets.zero,
          borderColor: AppColors.catTasks.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: AppColors.catTasks),
                  SizedBox(width: 8),
                  Text('Productividad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tareas Completadas', style: TextStyle(color: AppColors.textSecondary)),
                  Text('$completed / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.catTasks),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitsCard() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        int bestStreak = 0;
        int activeHabits = 0;
        if (state is HabitLoaded) {
          activeHabits = state.habits.length;
          for (var h in state.habits) {
            if (h.currentStreak > bestStreak) bestStreak = h.currentStreak;
          }
        }

        return GlassCard(
          margin: EdgeInsets.zero,
          borderColor: AppColors.catHabits.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.loop_rounded, color: AppColors.catHabits),
                  SizedBox(width: 8),
                  Text('Hábitos Activos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(label: 'Total Activos', value: '$activeHabits'),
                  _StatItem(label: 'Mejor Racha', value: '$bestStreak días', color: AppColors.warning),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGamificationCard() {
    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, state) {
        String level = 'Principiante';
        int xp = 0;
        if (state is GamificationLoaded) {
          level = state.stats.level;
          xp = state.stats.totalXp;
        }

        return GlassCard(
          margin: EdgeInsets.zero,
          borderColor: AppColors.accent.withValues(alpha: 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.accent, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nivel Actual', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(level, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('XP Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('$xp XP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDigitalWellbeingCard() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.phonelink_ring_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Bienestar Digital', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingUsage)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ))
          else if (_usageError != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 40),
                  const SizedBox(height: 8),
                  Text(_usageError!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textHint)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                    child: const Text('Abrir Ajustes'),
                  )
                ],
              ),
            )
          else ...[
            _buildScreenTimeHeader(),
            const SizedBox(height: 30),
            if (_appUsages.isNotEmpty)
              AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _appUsages.first.usage.inMinutes.toDouble(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.transparent,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
                      ),
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          return;
                        }
                        if (event is FlTapUpEvent) {
                          final index =
                              barTouchResponse.spot!.touchedBarGroupIndex;
                          if (index >= 0 && index < _appUsages.length) {
                            _showAppDetails(context, _appUsages[index]);
                          }
                        }
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= _appUsages.length) return const SizedBox.shrink();
                            // En versiones recientes de app_usage appName nunca es nullable
                            String name = _appUsages[idx].appName;
                            if (name == 'Unknown' || name.trim().isEmpty) {
                              name = _appUsages[idx].packageName.split('.').last;
                            }
                            if (name.length > 8) name = name.substring(0, 8);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(name, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: _appUsages.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.usage.inMinutes.toDouble(),
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              const Center(child: Text('No hay datos suficientes de uso hoy.', style: TextStyle(color: AppColors.textHint))),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenTimeHeader() {
    final hours = _totalScreenTime.inHours;
    final minutes = _totalScreenTime.inMinutes.remainder(60);
    return Center(
      child: Column(
        children: [
          const Text('TIEMPO EN PANTALLA HOY', style: TextStyle(color: AppColors.textHint, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$hours', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const Text('h ', style: TextStyle(fontSize: 20, color: AppColors.textSecondary)),
              Text('$minutes', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const Text('m', style: TextStyle(fontSize: 20, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
  void _showAppDetails(BuildContext context, AppUsageInfo app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String name = app.appName;
        if (name == 'Unknown' || name.trim().isEmpty) {
          name = app.packageName.split('.').last;
        }
        final hours = app.usage.inHours;
        final minutes = app.usage.inMinutes.remainder(60);

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.android_rounded,
                      color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Paquete: ${app.packageName}',
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 12),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tiempo de uso hoy',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$hours',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const Text('h ',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary)),
                  Text('$minutes',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const Text('m',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}